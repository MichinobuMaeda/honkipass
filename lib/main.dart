import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'ui.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class CharStatus {
  late String c;
  late bool active = false;
  bool used = false;

  CharStatus(String c, bool active) {
    this.c = c;
    this.active = active;
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '本気でパスワード v4',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'NotoSansJP',
      ),
      home: MyHomePage(title: '本気でパスワード v4'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

const String std64Chars = 'std64Chars';
const String ext88Chars = 'ext88Chars';
const String customChars = 'customChars';

class _MyHomePageState extends State<MyHomePage> {
  late FocusNode _focusNode;
  late double _length;
  late bool _useUpperCase;
  late bool _useLowerCase;
  late bool _useDigit;
  late bool _useSymbol;
  late bool _avoidExcludes;
  late bool _useAllTypes;
  late bool _avoidRepeat;
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _excludesController = new TextEditingController();
  final RadioController _charactersToUseController = new RadioController({
    std64Chars: '標準64文字',
    ext88Chars: '拡張88文字',
    customChars: '詳細設定',
  }, std64Chars);
  late List<CharStatus> _charList;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _reset();
  }

  void _reset() {
    _length = 8;
    _charactersToUseController.value = std64Chars;
    _useUpperCase = true;
    _useLowerCase = true;
    _useDigit = true;
    _useSymbol = true;
    _avoidExcludes = true;
    _useAllTypes = true;
    _avoidRepeat = true;
    _excludesController.text = "Il10O8B3Egqvu!|[]{}";
    _generate();
  }

  void _copyPassword() {
    Clipboard.setData(ClipboardData(text: _passwordController.text));
    showSnackBarInfo(context, 'パスワードをクリップボードにコピーしました。');
  }

  String? _generatePassword() {
    final String allReadableChars =
        '!"#\$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~';
    final String standard64Chars =
        '!#%+23456789:=?@ABCDEFGHJKLMNPRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
    final String larger88Chars =
        '!"#\$%&\'()*+,-./23456789:;<=>?@ABCDEFGHJKLMNOPRSTUVWXYZ[\\]^_abcdefghijkmnopqrstuvwxyz{|}~';
    final int maxRepeat = 10000;

    final RegExp reUpperCase = RegExp(r'[A-Z]');
    final RegExp reLowerCase = RegExp(r'[a-z]');
    final RegExp reDigit = RegExp(r'[0-9]');
    final RegExp reSymbol = RegExp(r'[^0-9A-Za-z]');

    _charList = allReadableChars.split('').map((c) {
      return new CharStatus(
          c,
          (_charactersToUseController.value == std64Chars &&
                  -1 < standard64Chars.indexOf(c)) ||
              (_charactersToUseController.value == ext88Chars &&
                  -1 < larger88Chars.indexOf(c)) ||
              (_charactersToUseController.value == customChars &&
                  ((_useUpperCase && reUpperCase.hasMatch(c)) ||
                      (_useLowerCase && reLowerCase.hasMatch(c)) ||
                      (_useDigit && reDigit.hasMatch(c)) ||
                      (_useSymbol && reSymbol.hasMatch(c))) &&
                  !(_avoidExcludes &&
                      -1 < _excludesController.text.indexOf(c))));
    }).toList();

    final List<String> chars = _charList.where((item) {
      return item.active;
    }).map((item) {
      return item.c;
    }).toList();

    final Random random = new Random();

    for (var i = 0; i < maxRepeat; ++i) {
      if (0 == chars.length) {
        break;
      }

      final password = (new List.generate(
        _length.round().toInt(),
        (_) => chars[random.nextInt(chars.length)],
      )).join('');

      if (_useAllTypes) {
        if (_charactersToUseController.value == customChars) {
          if ((_useUpperCase && !reUpperCase.hasMatch(password)) ||
              (_useLowerCase && !reLowerCase.hasMatch(password)) ||
              (_useDigit && !reDigit.hasMatch(password)) ||
              (_useSymbol && !reSymbol.hasMatch(password))) {
            continue;
          }
        } else {
          if ((!reUpperCase.hasMatch(password)) ||
              (!reLowerCase.hasMatch(password)) ||
              (!reDigit.hasMatch(password)) ||
              (!reSymbol.hasMatch(password))) {
            continue;
          }
        }
      }

      if (_avoidRepeat) {
        if (password.split('').any((c) {
          return c.allMatches(password).length > 1;
        })) {
          continue;
        }
      }

      for (var i = 0; i < _charList.length; ++i) {
        _charList[i].used = _charList[i].c.allMatches(password).length > 0;
      }
      return password;
    }
    return null;
  }

  void _generate() {
    final password = _generatePassword();
    if (password != null) {
      _passwordController.text = password;
    } else {
      showSnackBarError(context, 'パスワードを生成できませんでした。');
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Widget buildRadioChars(String optionValue) {
    return buildRadio(_charactersToUseController, optionValue, (String? value) {
      setState(() {
        _charactersToUseController.value = value!;
        _generate();
      });
    });
  }

  List<Widget> _flexibleList(List<Widget> children) {
    return children.map((child) {
      return new Flexible(child: child);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    _focusNode.requestFocus();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          // IconButton(
          //   icon: const Icon(Icons.download),
          //   tooltip: 'ダウンロード',
          //   onPressed: () {},
          // ),
        ],
      ),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        final double edge = (constraints.maxWidth > 840)
            ? 24.0
            : (constraints.maxWidth > 600)
                ? 16.0
                : 12.0;
        final Widget gutter = (constraints.maxWidth > 840)
            ? SizedBox(width: 16, height: 16)
            : (constraints.maxWidth > 600)
                ? SizedBox(width: 12, height: 12)
                : SizedBox(width: 8, height: 8);

        final List<Widget> sectionPassword = [
          new Flexible(
              child: TextField(
            controller: _passwordController,
            focusNode: _focusNode,
            readOnly: true,
            style: monospaceStyle(),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'パスワード',
            ),
          )),
          gutter,
        ];

        final List<Widget> sectionResultButtons = [
          buildButton(Icon(Icons.copy), 'コピー', () {
            _copyPassword();
          }),
          gutter,
          buildButton(Icon(Icons.refresh), '生成', () {
            setState(() {
              _generate();
            });
          }),
        ];

        final List<Widget> sectionCharList = <Widget>[
          new Flexible(
            child: ColoredBox(
              color: Colors.black26,
              child: Padding(
                padding: EdgeInsets.all(4.0),
                child: RichText(
                  text: TextSpan(
                    children: _charList.map((item) {
                      return TextSpan(children: [
                        TextSpan(
                          text: item.c,
                          style: monospaceStyle(
                              backgroundColor: item.used
                                  ? Colors.yellow
                                  : item.active
                                      ? Colors.white
                                      : Colors.transparent),
                        ),
                        TextSpan(text: ' '),
                      ]);
                    }).toList(),
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          )
        ];

        final List<Widget> sectionLength = <Widget>[
          Text(
            (' ' + _length.round().toString())
                .substring(_length.round() < 10 ? 0 : 1),
            style: monospaceStyle(),
          ),
          new Flexible(
              child: Slider(
            value: _length,
            min: 4,
            max: 32,
            divisions: (32 - 4),
            label: _length.round().toString(),
            onChanged: (double value) {
              setState(() {
                _length = value;
                _generate();
              });
            },
          )),
        ];

        final List<Widget> sectionCharRange = <Widget>[
          buildRadioChars(std64Chars),
          buildRadioChars(ext88Chars),
          buildRadioChars(customChars),
        ];

        final List<Widget> sectionCharTypes1 = <Widget>[
          buildCheckBox(
            '大文字',
            _useUpperCase,
            (_charactersToUseController.value == customChars)
                ? (bool? value) {
                    setState(() {
                      _useUpperCase = value!;
                      _generate();
                    });
                  }
                : null,
          ),
          buildCheckBox(
            '小文字',
            _useLowerCase,
            (_charactersToUseController.value == customChars)
                ? (bool? value) {
                    setState(() {
                      _useLowerCase = value!;
                      _generate();
                    });
                  }
                : null,
          ),
        ];

        final List<Widget> sectionCharTypes2 = <Widget>[
          buildCheckBox(
            '数字',
            _useDigit,
            (_charactersToUseController.value == customChars)
                ? (bool? value) {
                    setState(() {
                      _useDigit = value!;
                      _generate();
                    });
                  }
                : null,
          ),
          buildCheckBox(
            '記号',
            _useSymbol,
            (_charactersToUseController.value == customChars)
                ? (bool? value) {
                    setState(() {
                      _useSymbol = value!;
                      _generate();
                    });
                  }
                : null,
          ),
        ];

        final List<Widget> sectionExcludes = <Widget>[
          buildCheckBox(
            '指定した文字を除外する',
            _avoidExcludes,
            (_charactersToUseController.value == customChars)
                ? (bool? value) {
                    setState(() {
                      _avoidExcludes = value!;
                      _generate();
                    });
                  }
                : null,
          ),
          TextField(
            controller: _excludesController,
            style: monospaceStyle(),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: '除外する文字',
            ),
            enabled: (_charactersToUseController.value == customChars),
          ),
        ];

        final List<Widget> sectionParanoid = <Widget>[
          buildCheckBox(
            'すべての文字種を使用する',
            _useAllTypes,
            (bool? value) {
              setState(() {
                _useAllTypes = value!;
                _generate();
              });
            },
          ),
          buildCheckBox(
            '同じ文字を繰り返して使用しない',
            _avoidRepeat,
            (bool? value) {
              setState(() {
                _avoidRepeat = value!;
                _generate();
              });
            },
          ),
        ];

        final List<Widget> sectionReset = <Widget>[
          gutter,
          buildButton(Icon(Icons.close), '設定をリセットする', () {
            setState(() {
              _reset();
            });
          }, ButtonColors.danger),
        ];

        if (constraints.maxWidth > 840) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(edge),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                  maxWidth: 960,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                        Row(children: sectionPassword + sectionResultButtons),
                        gutter,
                        Row(children: sectionCharList),
                        gutter,
                        Row(
                            children: sectionLength +
                                _flexibleList(sectionCharRange)),
                        Row(
                          children: _flexibleList(
                              sectionCharTypes1 + sectionCharTypes2),
                        ),
                        Row(children: _flexibleList(sectionExcludes)),
                        Row(children: _flexibleList(sectionParanoid)),
                      ] +
                      sectionReset,
                ),
              ),
            ),
          );
        } else if (constraints.maxWidth > 600) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(edge),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                maxWidth: 960,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                      Row(children: sectionPassword),
                      gutter,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: sectionResultButtons,
                      ),
                      gutter,
                      Row(children: sectionCharList),
                      gutter,
                      Row(children: sectionLength),
                      Row(children: _flexibleList(sectionCharRange)),
                      Row(
                        children: _flexibleList(
                            sectionCharTypes1 + sectionCharTypes2),
                      ),
                      Row(children: _flexibleList(sectionExcludes)),
                    ] +
                    sectionParanoid +
                    sectionReset,
              ),
            ),
          );
        } else {
          return SingleChildScrollView(
            padding: EdgeInsets.all(edge),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                maxWidth: 960,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                      Row(children: sectionPassword),
                      gutter,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: sectionResultButtons,
                      ),
                      gutter,
                      Row(children: sectionCharList),
                      gutter,
                      Row(children: sectionLength),
                    ] +
                    sectionCharRange +
                    <Widget>[
                      Row(children: _flexibleList(sectionCharTypes1)),
                      Row(children: _flexibleList(sectionCharTypes2)),
                    ] +
                    sectionExcludes +
                    sectionParanoid +
                    sectionReset,
              ),
            ),
          );
        }
      }),
    );
  }
}
