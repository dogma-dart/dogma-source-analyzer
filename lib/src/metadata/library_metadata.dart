// Copyright (c) 2015-2016, the Dogma Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

//---------------------------------------------------------------------
// Imports
//---------------------------------------------------------------------

import 'annotated_metadata.dart';
import 'enclosing_metadata.dart';
import 'class_metadata.dart';
import 'field_metadata.dart';
import 'function_metadata.dart';
import 'typedef_metadata.dart';
import 'uri_referenced_metadata.dart';

//---------------------------------------------------------------------
// Library contents
//---------------------------------------------------------------------

/// Contains metadata for a dart library.
class LibraryMetadata extends AnnotatedMetadata with EnclosingMetadata {
  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The location of the library.
  final Uri uri;
  /// The import references for the library.
  final List<UriReferencedMetadata> imports;
  /// The export references for the library.
  final List<UriReferencedMetadata> exports;
  /// The classes contained within the library.
  final List<ClassMetadata> classes;
  /// The functions contained within the library.
  final List<FunctionMetadata> functions;
  /// The fields contained within the library.
  final List<FieldMetadata> fields;
  /// The function type definitions contained within the library.
  final List<TypedefMetadata> typedefs;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /// Creates an instance of [LibraryMetadata] with the given [uri].
  ///
  /// The library can be given a [name]. This would correspond to a `library`
  /// directive within the library. The library directive has been optional
  /// so it is not required.
  ///
  ///     library foo;
  ///
  /// For referenced dart files the [imports] and [exports] can be specified.
  ///
  /// A list of [classes], [functions], and [fields] can be specified.
  ///
  /// Metadata such as [comments] and [annotations] can also be added to the
  /// library. If specified then a library directive will need to be present.
  LibraryMetadata(Uri uri,
                 {String name: '',
                  List<UriReferencedMetadata> imports,
                  List<UriReferencedMetadata> exports,
                  List<ClassMetadata> classes,
                  List<FunctionMetadata> functions,
                  List<FieldMetadata> fields,
                  List<TypedefMetadata> typedefs,
                  List annotations,
                  String comments})
      : uri = uri
      , imports = imports ?? <UriReferencedMetadata>[]
      , exports = exports ?? <UriReferencedMetadata>[]
      , classes = classes ?? <ClassMetadata>[]
      , functions = functions ?? <FunctionMetadata>[]
      , fields = fields ?? <FieldMetadata>[]
      , typedefs = typedefs ?? <TypedefMetadata>[]
      , super(name, annotations, comments)
  {
    // Use `this` to properly scope the value
    encloseList(this.imports);
    encloseList(this.exports);
    encloseList(this.classes);
    encloseList(this.functions);
    encloseList(this.fields);
    encloseList(this.typedefs);
  }

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// The libraries imported into this library.
  Iterable<LibraryMetadata> get imported =>
      imports.map<LibraryMetadata>((value) => value.library);

  /// The libraries exported by this library.
  Iterable<LibraryMetadata> get exported =>
      exports.map<LibraryMetadata>((value) => value.library);
}
