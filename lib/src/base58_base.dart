class Base58Exception {
  String cause;
  Base58Exception(this.cause);
}

// Alphabet is a a b58 alphabet.
class Alphabet {
  List<int> decode; // = List(128);
  List<int> encode; // 58

  Alphabet(String s) {
    if (s.length != 58) {
      throw Base58Exception('base58 alphabets must be 58 bytes long');
    }

    encode = s.codeUnits;

    decode = List<int>.filled(128, -1);

    var distinct = 0;
    encode.asMap().forEach((i, b) {
      if (decode[b] == -1) {
        distinct++;
      }
      decode[b] = i.toSigned(8);
    });

    if (distinct != 58) {
      throw Base58Exception(
          'provided alphabet does not consist of 58 distinct characters');
    }
  }
}

// BTCAlphabet is the bitcoin base58 alphabet.
var BTCAlphabet =
    Alphabet('123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz');

// FlickrAlphabet is the flickr base58 alphabet.
var FlickrAlphabet =
    Alphabet('123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ');

// Encode encodes the passed bytes into a base58 encoded string.
String Base58Encode(List<int> bin) {
  return FastBase58EncodingAlphabet(bin, BTCAlphabet);
}

// EncodeAlphabet encodes the passed bytes into a base58 encoded string with the
// passed alphabet.
String EncodeAlphabet(List<int> bin, Alphabet alphabet) {
  return FastBase58EncodingAlphabet(bin, alphabet);
}

// Decode decodes the base58 encoded bytes.
List<int> Base58Decode(String str) {
  return FastBase58DecodingAlphabet(str, BTCAlphabet);
}

// DecodeAlphabet decodes the base58 encoded bytes using the given b58 alphabet.
List<int> DecodeAlphabet(String str, Alphabet alphabet) {
  return FastBase58DecodingAlphabet(str, alphabet);
}

// FastBase58EncodingAlphabet encodes the passed bytes into a base58 encoded
// string with the passed alphabet.
String FastBase58EncodingAlphabet(List<int> bin, Alphabet alphabet) {
  var size = bin.length;

  var zcount = 0;
  for (; zcount < size && bin[zcount] == 0;) {
    zcount++;
  }

  // It is crucial to make this as short as possible, especially for
  // the usual case of bitcoin addrs
  size = (zcount +
      // This is an integer simplification of
      // ceil(log(256)/log(58))
      (size - zcount) * 555 ~/ 406 +
      1);

  var out = List<int>.filled(size, 0);

  var i = 0, high = 0;

  high = size - 1;
  bin.forEach((b) {
    i = size - 1;
    for (var carry = b; i > high || carry != 0; i--) {
      carry = (carry + 256 * (out[i])).toUnsigned(32);
      out[i] = (carry % 58).toUnsigned(8);
      carry = carry ~/ 58;
    }
    high = i;
  });

  // Determine the additional "zero-gap" in the buffer (aside from zcount)
  for (i = zcount; i < size && out[i] == 0; i++) {}

  // Now encode the values with actual alphabet in-place
  var val = out.sublist(i - zcount);
  size = val.length;
  for (i = 0; i < size; i++) {
    out[i] = alphabet.encode[val[i]];
  }

  return String.fromCharCodes(out.sublist(0, size));
}

// FastBase58DecodingAlphabet decodes the base58 encoded bytes using the given
// b58 alphabet.
List<int> FastBase58DecodingAlphabet(String str, Alphabet alphabet) {
  if (str.isEmpty) {
    throw Base58Exception('zero length string');
  }

  var zero = alphabet.encode[0];
  var b58sz = str.length;

  var zcount = 0;
  for (var i = 0; i < b58sz && str.runes.toList()[i] == zero; i++) {
    zcount++;
  }

  var t = 0; // u64
  var c = 0; // u64

  // the 32bit algo stretches the result up to 2 times
  var binu = List<int>.filled(2 * ((b58sz * 406 ~/ 555) + 1), 0); // list<byte>
  var outi = List<int>.filled((b58sz + 3) ~/ 4, 0); // list<uint32>

  str.runes.forEach((int r) {
    if (r > 127) {
      throw Base58Exception('high-bit set on invalid digit');
    }
    if (alphabet.decode[r] == -1) {
      throw Base58Exception('invalid base58 digit' + String.fromCharCode(r));
    }

    c = alphabet.decode[r];

    for (var j = outi.length - 1; j >= 0; j--) {
      t = (outi[j] * 58 + c).toUnsigned(64);
      c = (t >> 32).toUnsigned(64);
      outi[j] = (t & 0xffffffff).toUnsigned(32);
    }
  });

  var mask = ((b58sz % 4) * 8).toUnsigned(32);
  if (mask == 0) {
    mask = 32;
  }
  mask = (mask - 8).toUnsigned(32);

  var outLen = 0;
  for (var j = 0; j < outi.length; j++) {
    for (; mask < 32;) {
      // loop relies on uint overflow
      binu[outLen] = (outi[j] >> mask).toUnsigned(8);
      mask = (mask - 8).toUnsigned(32);
      outLen++;
    }
    mask = 24;
  }

  // find the most significant byte post-decode, if any
  for (var msb = zcount; msb < binu.length; msb++) {
    if (binu[msb] > 0) {
      return binu.sublist(msb - zcount, outLen);
    }
  }

  // it's all zeroes
  return binu.sublist(0, outLen);
}
