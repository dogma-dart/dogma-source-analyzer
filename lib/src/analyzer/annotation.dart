// Copyright (c) 2015-2016, the Dogma Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

//---------------------------------------------------------------------
// Imports
//---------------------------------------------------------------------

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:analyzer/analyzer.dart';
import 'package:logging/logging.dart';

import 'constant_object.dart';
import 'mirrors.dart';

//---------------------------------------------------------------------
// Library contents
//---------------------------------------------------------------------

/// The logger for the library.
final Logger _logger =
    new Logger('dogma_source_metadata.src.analyzer.annotation');

/// A function that takes a annotation [element] from the analyzer and returns
/// an instantiation of the metadata.
///
/// If the [element] is not a supported type of annotation then the function
/// will return `null`.
typedef dynamic AnalyzeAnnotation(ElementAnnotation element);

/// Maps the name of the [parameter] to the computed value of the instance
/// based on the [constructorName].
///
/// The analyzer provides an API that will instantiate an object representing
/// the result of the object. It can do this since an annotation is constant.
/// However it will not be an actual instance of the object, just a generalized
/// object which contains the structure of the final object that would be
/// produced.
/// When instantiating the value of a constant object the analyzer returns the
/// structure of the final object.
///
///     class Annotation {
///       final int field;
///
///       Annotation(this.field);
///     }
///
/// In this case the `field` passed into the constructor directly corresponds
/// to the value of object the analyzer computes. This is true for any values
/// initialized using the `this.*` syntax.
///
/// However the API may not have this 1-1 relationship.
///
///      class Annotation {
///        final int field;
///        final int otherField;
///
///         Annotation(int value, this.otherField)
///            : field = value * 1000;
///      }
///
/// In this case to construct an instance of the annotation a mapping needs to
/// be provided. An example implementation in this case would be.
///
///     String mapAnnotationParameter(String constructor, String parameter) =>
///         parameter == 'value' ? 'field' : parameter;
///
/// A mapping function is required for any annotations where the names of the
/// parameters do not correspond to the names of the fields within the
/// constructed object.
typedef String ParameterNameMapper(String constructorName, String parameter);

/// Creates a list of annotations for the given [element] using the specified
/// [annotationCreators].
List createAnnotations(Element element,
                       List<AnalyzeAnnotation> annotationCreators) {
  final values = [];

  for (var metadata in element.metadata) {
    for (var creator in annotationCreators) {
      final value = creator(metadata);

      if (value != null) {
        values.add(value);
      }
    }
  }

  return values;
}

/// Creates a function that will instantiate an [annotation].
AnalyzeAnnotation analyzeAnnotation(String annotation,
                                   {String library: '',
                                    ParameterNameMapper parameterNameMapper: _passThroughParameters,
                                    CreateAnnotationInstance createAnnotation: createAnnotation,
                                    CreateDartValue createValue}) {
  final clazz = classMirror(annotation, library);

  return (element) {
    final representation = element.element;

    // Check to see if the representation is present
    if (representation == null) {
      // Get the AST to determine what annotation is failing
      final annotationAst = (element as ElementAnnotationImpl).annotationAst;
      _logger.severe('The annotation, $annotationAst, could not be instantiated. Make sure it is imported and accessible');
      return null;
    }

    // Check to see if the enclosing element is of the given type
    if (representation.enclosingElement.name != annotation) {
      return null;
    }

    var value;

    if (representation is ConstructorElement) {
      final constructorName = representation.name;
      _logger.fine('Annotation is being constructed through "$constructorName"');

      // Annotations are constant so get the result of the evaluation
      //
      // This ends up creating a generic object containing the resulting
      // fields of the instance.
      final evaluatedFields = element.constantValue;

      // Get the invocation
      final positionalArguments = [];
      final namedArguments = <Symbol, dynamic>{};

      // Iterate over the parameters to get the mirrors call
      for (var parameter in representation.parameters) {
        final parameterName = parameter.name;
        final mappedParameterName =
            parameterNameMapper(constructorName, parameterName);
        final parameterField = evaluatedFields.getField(mappedParameterName);
        final parameterValue = dartValue(parameterField, createValue);

        _logger.fine('Found $parameterName of value $parameterValue');
        _logger.finer('Parameter is mapped to $mappedParameterName');

        if (parameter.parameterKind == ParameterKind.NAMED) {
          _logger.finer('Parameter is named');
          namedArguments[new Symbol(parameterName)] = parameterValue;
        } else {
          _logger.finer('Parameter is positional');
          positionalArguments.add(parameterValue);
        }
      }

      value = createAnnotation(
          clazz,
          new Symbol(representation.name),
          positionalArguments,
          namedArguments
      );
    } else if (representation is PropertyAccessorElement) {
      _logger.finer('Annotation is a field');
    }

    return value;
  };
}

/// Passes through the [parameter] name.
///
/// Used when a [ParameterNameMapper] is not provided.
String _passThroughParameters(String _, String parameter) => parameter;
