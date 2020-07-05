# Fast Implementation of Base58 encoding

Base algorithm is copied from https://github.com/trezor/trezor-crypto/blob/master/base58.c

And updating optimization from https://github.com/mr-tron/base58

## Usage

A simple usage example:

```dart
import 'dart:convert'; // for utf8
import 'package:fast_base58/fast_base58.dart';

main() {
  var encodedStr = Base58Encode(utf8.encode('bitcoin'.codeUnits)); // Uint8List(raw bytes) to base58 string
  print(encodedStr); // 4jJc4sAwPs

  var decodedRaw = Base58Decode('4jJc4sAwPs'); // base58 string to Uint8List(raw bytes)
  print(utf8.decode(decodedRaw)); // bitcoin
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://github.com/maoxs2/dart_fast_base58
