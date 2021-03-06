// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/analyzer.dart';
import 'package:code_builder/code_builder.dart';
import 'package:test/test.dart';

void main() {
  group('Identity scope', () {
    Scope scope;

    setUp(() => scope = const Scope.identity());

    test('should do nothing', () {
      var identifiers = <Identifier>[
        scope.getIdentifier('Foo', 'package:foo/foo.dart'),
        scope.getIdentifier('Bar', 'package:foo/foo.dart'),
        scope.getIdentifier('Baz', 'package:baz/baz.dart'),
      ].map/*<String>*/((i) => i.toSource());

      expect(
        identifiers,
        [
          'Foo',
          'Bar',
          'Baz',
        ],
      );

      expect(scope.getImports(), isEmpty);
    });
  });

  group('Deduplicating scope', () {
    Scope scope;

    setUp(() => scope = new Scope.dedupe());

    test('should just output non-prefixed and de-duplicate imports', () {
      var identifiers = <Identifier>[
        scope.getIdentifier('Foo', 'package:foo/foo.dart'),
        scope.getIdentifier('Bar', 'package:foo/foo.dart'),
        scope.getIdentifier('Baz', 'package:baz/baz.dart'),
      ].map/*<String>*/((i) => i.toSource());

      expect(
        identifiers,
        [
          'Foo',
          'Bar',
          'Baz',
        ],
      );

      expect(
        scope.getImports().map/*<String>*/((i) => i.toAst().toSource()),
        [
          r"import 'package:foo/foo.dart';",
          r"import 'package:baz/baz.dart';",
        ],
      );
    });
  });

  group('Incrementing scope', () {
    Scope scope;

    setUp(() => scope = new Scope());

    test('should out prefixed with a counter', () {
      var identifiers = <Identifier>[
        scope.getIdentifier('Foo', 'package:foo/foo.dart'),
        scope.getIdentifier('Bar', 'package:foo/foo.dart'),
        scope.getIdentifier('Baz', 'package:baz/baz.dart'),
      ].map/*<String>*/((i) => i.toSource());

      expect(
        identifiers,
        [
          '_i1.Foo',
          '_i1.Bar',
          '_i2.Baz',
        ],
      );

      expect(
        scope.getImports().map/*<String>*/((i) => i.toAst().toSource()),
        [
          r"import 'package:foo/foo.dart' as _i1;",
          r"import 'package:baz/baz.dart' as _i2;",
        ],
      );
    });
  });
}
