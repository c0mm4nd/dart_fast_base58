/// Libary fast_base58 provides fast implementation of base58 encoding.
///
/// Base58 is a group of binary-to-text encoding schemes used to represent large integers as alphanumeric text, introduced by Satoshi Nakamoto for use with Bitcoin. It has since been applied to other cryptocurrencies and applications. It is similar to Base64 but has been modified to avoid both non-alphanumeric characters and letters which might look ambiguous when printed. It is therefore designed for human users who manually enter the data, copying from some visual source, but also allows easy copy and paste because a double-click will usually select the whole string.
///
/// Compared with Base64, the following similar-looking letters are omitted: 0 (zero), O (capital o), I (capital i) and l (lower case L) as well as the non-alphanumeric characters + (plus) and / (slash). In contrast with Base64, the digits of the encoding do not line up well with byte boundaries of the original data. For this reason, the method is well-suited to encode large integers, but not designed to encode longer portions of binary data. The actual order of letters in the alphabet depends on the application, which is the reason why the term “Base58” alone is not enough to fully describe the format. A variant, Base56, excludes 1 (one) and o (lowercase o) compared with Base 58.
///
/// Libary fast_base58 supports both flickr alphabet (123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ) and Bitcoin addresses/IPFS hashes 's alphabet (123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz)
///
/// Base algorithm is copied from https://github.com/trezor/trezor-crypto/blob/master/base58.c
library fast_base58;

export 'src/base58_base.dart';
