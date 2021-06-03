import 'dart:math';
import 'package:flutter/services.dart';

enum CharRange { std64, ext88, custom }

class CharStatus {
  late String c;
  bool active = true;
  bool used = false;

  CharStatus(String c) {
    this.c = c;
  }
}

class PasswordGenerator {
  static final String _allReadableChars =
      '!"#\$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~';
  static final String _standard64Chars =
      '!#%+23456789:=?@ABCDEFGHJKLMNPRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
  static final String _larger88Chars =
      '!"#\$%&\'()*+,-./23456789:;<=>?@ABCDEFGHJKLMNOPRSTUVWXYZ[\\]^_abcdefghijkmnopqrstuvwxyz{|}~';
  static final String _defaultExcludesChars = 'Il10O8B3Egqvu!|[]{}';
  static final CharRange _defaultCharRange = CharRange.std64;
  static final int _maxRepeat = 10000;

  static RegExp _reUpperCase = RegExp(r'[A-Z]');
  static RegExp _reLowerCase = RegExp(r'[a-z]');
  static RegExp _reDigit = RegExp(r'[0-9]');
  static RegExp _reSymbol = RegExp(r'[^0-9A-Za-z]');

  late double _length;
  late CharRange _charRange;
  late bool _requireUpperCase;
  late bool _requireLowerCase;
  late bool _requireDigit;
  late bool _requireSymbol;
  late bool _forbidExcludes;
  late String _excludes;
  late bool _requireAllTypes;
  late bool _forbidRepeat;
  late String _password;
  late bool _statusGenerated;
  late List<CharStatus> _charList;
  Function _onGenerated = () {};
  Function _onFailureToGenerate = () {};
  Function _onCopiedToClipboard = () {};

  PasswordGenerator() {
    _charList =
        _allReadableChars.split('').map((c) => new CharStatus(c)).toList();
    reset();
  }

  void reset() {
    _length = 8;
    _charRange = _defaultCharRange;
    _requireUpperCase = true;
    _requireLowerCase = true;
    _requireDigit = true;
    _requireSymbol = true;
    _forbidExcludes = true;
    _excludes = _defaultExcludesChars;
    _requireAllTypes = true;
    _forbidRepeat = true;
    generate();
  }

  void generate() {
    _statusGenerated = false;

    for (CharStatus cs in _charList) {
      final c = cs.c;
      switch (_charRange) {
        case CharRange.std64:
          cs.active = _standard64Chars.contains(cs.c);
          break;
        case CharRange.ext88:
          cs.active = _larger88Chars.contains(cs.c);
          break;
        case CharRange.custom:
          cs.active = (((_requireUpperCase && _reUpperCase.hasMatch(c)) ||
                  (_requireLowerCase && _reLowerCase.hasMatch(c)) ||
                  (_requireDigit && _reDigit.hasMatch(c)) ||
                  (_requireSymbol && _reSymbol.hasMatch(c))) &&
              !(_forbidExcludes && _excludes.contains(c)));
          break;
      }
    }

    final List<String> chars =
        _charList.where((item) => item.active).map((item) => item.c).toList();

    if (0 == chars.length) {
      _onFailureToGenerate();
      return;
    }

    final Random random = new Random();

    for (var i = 0; i < _maxRepeat; ++i) {
      final result = (new List.generate(
        _length.round().toInt(),
        (_) => chars[random.nextInt(chars.length)],
      )).join('');

      if (_requireAllTypes) {
        if (_charRange == CharRange.custom) {
          if ((_requireUpperCase && !_reUpperCase.hasMatch(result)) ||
              (_requireLowerCase && !_reLowerCase.hasMatch(result)) ||
              (_requireDigit && !_reDigit.hasMatch(result)) ||
              (_requireSymbol && !_reSymbol.hasMatch(result))) {
            continue;
          }
        } else {
          if ((!_reUpperCase.hasMatch(result)) ||
              (!_reLowerCase.hasMatch(result)) ||
              (!_reDigit.hasMatch(result)) ||
              (!_reSymbol.hasMatch(result))) {
            continue;
          }
        }
      }

      if (_forbidRepeat) {
        if (result.split('').any((c) => c.allMatches(result).length > 1)) {
          continue;
        }
      }

      for (CharStatus cs in _charList) {
        cs.used = cs.c.allMatches(result).length > 0;
      }

      _password = result;
      _statusGenerated = true;
      _onGenerated();
      break;
    }

    if (!_statusGenerated) {
      _onFailureToGenerate();
    }
  }

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _password));
    _onCopiedToClipboard();
  }

  double get length {
    return _length;
  }

  set length(double value) {
    _length = value;
    generate();
  }

  CharRange get charRange {
    return _charRange;
  }

  set charRange(CharRange value) {
    _charRange = value;
    generate();
  }

  bool get requireUpperCase {
    return _requireUpperCase;
  }

  set requireUpperCase(bool value) {
    _requireUpperCase = value;
    generate();
  }

  bool get requireLowerCase {
    return _requireLowerCase;
  }

  set requireLowerCase(bool value) {
    _requireLowerCase = value;
    generate();
  }

  bool get requireDigit {
    return _requireDigit;
  }

  set requireDigit(bool value) {
    _requireDigit = value;
    generate();
  }

  bool get requireSymbol {
    return _requireSymbol;
  }

  set requireSymbol(bool value) {
    _requireSymbol = value;
    generate();
  }

  bool get forbidExcludes {
    return _forbidExcludes;
  }

  set forbidExcludes(bool value) {
    _forbidExcludes = value;
    generate();
  }

  String get excludes {
    return _excludes;
  }

  set excludes(String value) {
    _excludes = value;
    generate();
  }

  bool get requireAllTypes {
    return _requireAllTypes;
  }

  set requireAllTypes(bool value) {
    _requireAllTypes = value;
    generate();
  }

  bool get forbidRepeat {
    return _forbidRepeat;
  }

  set forbidRepeat(bool value) {
    _forbidRepeat = value;
    generate();
  }

  String get password {
    return _password;
  }

  bool get statusGenerated {
    return _statusGenerated;
  }

  List<CharStatus> get charList {
    return _charList;
  }

  void onGenerated(Function cb) {
    _onGenerated = cb;
  }

  void onFailureToGenerate(Function cb) {
    _onFailureToGenerate = cb;
  }

  void onCopiedToClipboard(Function cb) {
    _onCopiedToClipboard = cb;
  }
}
