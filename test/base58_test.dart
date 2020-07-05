import 'dart:convert';

import 'package:fast_base58/fast_base58.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    setUp(() {});

    test('First Test', () {
      var vec = {
        'bitcoin': '4jJc4sAwPs',
        'helloworld': '6sBRWyteSSzHrs',
        '比特幣': '3wJp7rKdW1tEv',
        '你好世界': '5KMpie3K6ztGQYmij',
        'salam dünýä': 'jREXyzsGzQ48Jrqb4Gb'
      };
      vec.forEach((String k, v) {
        expect(Base58Encode(utf8.encode(k)), v);
        expect(utf8.decode(Base58Decode(v)), k);
      });
    });
  });
  group('new test', () {
    test('First Test', () {
      Base58Decode('AYBxTPyyPvAXxKGBH2mZSyKDwCFVwM1zD4JYJZaVF4SK'); //dont panic
    });
  });
}
