import 'dart:typed_data';

import 'package:fast_base58/fast_base58.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    setUp(() {});

    test('First Test', () {
      var vec = {
        'bitcoin': '4jJc4sAwPs',
        'helloworld': '6sBRWyteSSzHrs',
      };
      vec.forEach((String k, v) {
        expect(Base58Encode(Uint8List.fromList(k.codeUnits)), v);
        expect(String.fromCharCodes(Base58Decode(v)), k);
      });
    });
  });
}
