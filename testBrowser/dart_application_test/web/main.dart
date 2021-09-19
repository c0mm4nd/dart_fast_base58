import 'dart:convert';
import 'dart:html';
import 'package:fast_base58/fast_base58.dart';

void main() {
  var input = querySelector('#input');
  input!.onKeyUp.listen((e) {
    var raw = Base58Decode((input as InputElement).value!);

    querySelector('#hex')?.text = List.generate(
            raw.length, (index) => raw[index].toRadixString(16).padLeft(2, '0'))
        .join();
    querySelector('#output')?.text = utf8.decode(raw);
  });
}
