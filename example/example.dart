import 'dart:convert';

import 'package:fast_base58/fast_base58.dart';

void main() {
  // Uint8List(raw bytes) to base58 string
  var encodedStr = Base58Encode(utf8.encode('bitcoin'));
  // 4jJc4sAwPs
  print(encodedStr);

  // base58 string to Uint8List(raw bytes)
  var decodedRaw = Base58Decode('4jJc4sAwPs');
  // bitcoin
  print(utf8.decode(decodedRaw));
}
