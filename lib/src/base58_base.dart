import 'dart:typed_data';

class Base58Exception {
  String cause;
  Base58Exception(this.cause);
}

// Alphabet is a a b58 alphabet.
class Alphabet {
  List<int> decode = List(128);
  List<int> encode;

  Alphabet(String s) {
    if (s.length != 58) {
      throw Base58Exception('base58 alphabets must be 58 bytes long');
    }

    encode = s.codeUnits;
    for (var i = 0; i < decode.length; i++) {
      decode[i] = -1;
    }

    encode.asMap().forEach((i, b) => {decode[b] = i});
  }
}

// BTCAlphabet is the bitcoin base58 alphabet.
var BTCAlphabet =
    Alphabet('123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz');

// FlickrAlphabet is the flickr base58 alphabet.
var FlickrAlphabet =
    Alphabet('123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ');

// Encode encodes the passed bytes into a base58 encoded string.
String Base58Encode(Uint8List bin) {
  return FastBase58EncodingAlphabet(bin, BTCAlphabet);
}

// EncodeAlphabet encodes the passed bytes into a base58 encoded string with the
// passed alphabet.
String EncodeAlphabet(Uint8List bin, Alphabet alphabet) {
  return FastBase58EncodingAlphabet(bin, alphabet);
}

// Decode decodes the base58 encoded bytes.
Uint8List Base58Decode(String str) {
  return FastBase58DecodingAlphabet(str, BTCAlphabet);
}

// DecodeAlphabet decodes the base58 encoded bytes using the given b58 alphabet.
Uint8List DecodeAlphabet(String str, Alphabet alphabet) {
  return FastBase58DecodingAlphabet(str, alphabet);
}

// FastBase58EncodingAlphabet encodes the passed bytes into a base58 encoded
// string with the passed alphabet.
String FastBase58EncodingAlphabet(Uint8List bin, Alphabet alphabet) {
  var zero = alphabet.encode[0];

  var binsz = bin.lengthInBytes;
  int i, j, high;
  int carry;
  var zcount = 0;

  for (; zcount < binsz && bin[zcount] == 0;) {
    zcount++;
  }

  var sz = (binsz - zcount) * 138 ~/ 100 + 1;

  var buf = Uint8List(sz * 2 + zcount);

  var tmp = buf.sublist(sz + zcount);

  high = sz - 1;
  for (i = zcount; i < binsz; i++) {
    j = sz - 1;
    for (carry = bin[i]; j > high || carry != 0; j--) {
      carry = carry + 256 * tmp[j];
      tmp[j] = (carry % 58).toUnsigned(8);
      carry = carry ~/ 58;
    }

    high = j;
  }

  for (j = 0; j < sz && tmp[j] == 0; j++) {}

  var b58 = buf.sublist(0, sz - j + zcount);

  if (zcount != 0) {
    for (i = 0; i < zcount; i++) {
      b58[i] = zero;
    }
  }

  for (i = zcount; j < sz; i++) {
    b58[i] = alphabet.encode[tmp[j]];
    j++;
  }

  return String.fromCharCodes(b58);
}

// FastBase58DecodingAlphabet decodes the base58 encoded bytes using the given
// b58 alphabet.
Uint8List FastBase58DecodingAlphabet(String str, Alphabet alphabet) {
  if (str.isEmpty) {
    throw Base58Exception('zero length string');
  }

  int t, c, zmask;
  var zcount = 0;
  var b58u = Runes(str);

  var b58sz = b58u.length;

  var outisz = (b58sz + 3) >> 2;
  var binu = Uint8List((b58sz + 3) * 3);
  var bytesleft = b58sz & 3;
  var zero = alphabet.encode[0]; // rune

  if (bytesleft > 0) {
    zmask = 0xffffffff << bytesleft * 8;
  } else {
    bytesleft = 4;
  }

  var outi = Uint32List(outisz);

  for (var i = 0; i < b58sz && b58u.toList()[i] == zero; i++) {
    zcount++;
  }

  for (var r in b58u.toList()) {
    if (r > 127) {
      throw Base58Exception('high-bit set on invalid digit');
    }

    if (alphabet.decode[r] == -1) {
      throw Base58Exception('invalid base58 digit: ${r}');
    }

    c = alphabet.decode[r];

    for (var j = outisz - 1; j >= 0; j--) {
      t = outi[j] * 58 + c;
      c = (t >> 32) & 0x3f;
      outi[j] = t & 0xffffffff;
    }

    if (c > 0) {
      throw Base58Exception('output number too big (carry to the next int32)');
    }

    if (outi[0] & zmask != 0) {
      throw Base58Exception(
          'output number too big (last int32 filled too far)');
    }
  }

  var j = 0, cnt = 0;
  for (; j < outisz; j++) {
    var mask = ((bytesleft - 1) * 8).toUnsigned(8);
    for (; mask <= 0x18;) {
      binu[cnt] = (outi[j] >> mask).toUnsigned(8);
      mask = (mask - 8).toUnsigned(8);
      cnt = cnt + 1;
    }
    if (j == 0) {
      bytesleft = 4; // because it could be less than 4 the first time through
    }
  }

  var n = 0;
  for (var v in binu) {
    if (v > 0) {
      var start = n - zcount;
      if (start < 0) {
        start = 0;
      }
      return Uint8List.fromList(binu.toList().sublist(start, cnt));
    }
    n++;
  }

  return Uint8List.fromList(binu.toList().sublist(0, cnt));
}
