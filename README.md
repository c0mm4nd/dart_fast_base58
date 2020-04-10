# Fast Implementation of Base58 encoding

Base algorithm is copied from https://github.com/trezor/trezor-crypto/blob/master/base58.c

## Usage

A simple usage example:

```dart
import 'package:fast_base58/fast_base58.dart';

main() {
  var encodedStr = Base58Encode(Uint8List.fromList('bitcoin'.codeUnits)); // Uint8List(raw bytes) to base58 string
  print(encodedStr); // 4jJc4sAwPs

  var decodedRaw = Base58Decode('4jJc4sAwPs'); // base58 string to Uint8List(raw bytes)
  print(String.fromCharCodes(decodedRaw)); // bitcoin
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://github.com/maoxs2/dart_fast_base58
