// Copyright (c) 2015-2016, the Dogma Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

//---------------------------------------------------------------------
// Imports
//---------------------------------------------------------------------

import 'annotated_metadata.dart';
import 'default_metadata.dart';
import 'enclosing_metadata.dart';
import 'parameter_kind.dart';
import 'type_metadata.dart';
import 'typed_metadata.dart';

//---------------------------------------------------------------------
// Library contents
//---------------------------------------------------------------------

/// Contains metadata for a parameter on a function or method.
class ParameterMetadata extends AnnotatedMetadata
                           with EnclosedMetadata
                     implements DefaultMetadata,
                                TypedMetadata {
  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  @override
  final TypeMetadata type;
  /// The kind of parameter.
  final ParameterKind parameterKind;
  /// Whether the parameter is an initializer.
  ///
  /// This should only be in constructors and signifies when `this.value` is
  /// used.
  final bool isInitializer;
  @override
  final dynamic defaultValue;

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// Creates an instance of [ParameterMetadata] with the given [name] and
  /// accepting the given [type].
  ///
  /// By default the [parameterKind] is set to required. If the parameter is
  /// optional then [defaultValue] should be set unless null is desired for the
  /// default value.
  ParameterMetadata(String name,
                   {TypeMetadata type,
                    this.parameterKind: ParameterKind.required,
                    this.isInitializer: false,
                    this.defaultValue,
                    List annotations})
      : type = type ?? dynamicType
      , super(name, annotations, '');

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// Whether the parameter is required by calling code.
  bool get isRequired => parameterKind == ParameterKind.required;
  /// Whether the parameter is optional for calling code.
  bool get isOptional => !isRequired;
}
