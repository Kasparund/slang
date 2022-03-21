import 'dart:convert';

import 'package:fast_i18n/src/tools/migrate_arb.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../util/resources_utils.dart';

void main() {
  late String arbInput;
  late String expectedOutput;

  setUp(() {
    arbInput = loadResource('migration/arb.arb');
    expectedOutput = loadResource('migration/arb.json');
  });

  test('compact csv', () {
    final result = migrateArb(arbInput, false);
    expect(JsonEncoder.withIndent('  ').convert(result), expectedOutput);
  });
}