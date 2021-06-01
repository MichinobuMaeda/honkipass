import 'package:flutter/material.dart';
import 'password_generator.dart';
import 'ui.dart';

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
  Widget build(BuildContext context) => MaterialApp(
        title: '本気でパスワード v4',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          fontFamily: 'NotoSansJP',
        ),
        home: MyHomePage(title: '本気でパスワード v4'),
      );
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _pg = new PasswordGenerator();
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScaffoldMessengerState messageState = ScaffoldMessenger.of(context);
    _pg.onFailureToGenerate(() {
      messageState.removeCurrentSnackBar();
      messageState.showSnackBar(buildSnackBarError('パスワードを生成できませんでした。'));
    });
    _pg.onCopiedToClipboard(() {
      messageState.removeCurrentSnackBar();
      messageState.showSnackBar(buildSnackBarInfo('パスワードをクリップボードにコピーしました。'));
    });

    Widget textFieldPassword = TextField(
      controller: TextEditingController()..text = _pg.password,
      focusNode: _focusNode,
      readOnly: true,
      style: monospaceStyle(),
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'パスワード',
      ),
    );

    Widget buttonCopyPassword =
        buildButton(Icon(Icons.copy), 'コピー', () => _pg.copyToClipboard());

    Widget buttonGeneratePassword = buildButton(Icon(Icons.refresh), '生成', () {
      setState(() {
        _pg.generate();
        _focusNode.requestFocus();
      });
    });

    Widget boxCharList = ColoredBox(
      color: Colors.black26,
      child: Padding(
        padding: EdgeInsets.all(4.0),
        child: Wrap(
          alignment: WrapAlignment.start,
          spacing: 4.0,
          runSpacing: 4.0,
          children: _pg.charList
              .map(
                (item) => ColoredBox(
                  color: item.used
                      ? item.active
                          ? Colors.yellow
                          : Colors.pink
                      : item.active
                          ? Colors.white
                          : Colors.transparent,
                  child: Text(
                    item.c,
                    style: monospaceStyle(),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );

    Widget labelLength = Text(
      (' ' + _pg.length.round().toString())
          .substring(_pg.length.round() < 10 ? 0 : 1),
      style: monospaceStyle(),
    );

    Widget sliderLength = Slider(
        value: _pg.length,
        min: 4,
        max: 32,
        divisions: (32 - 4),
        label: _pg.length.round().toString(),
        onChanged: (double value) => setState(() => _pg.length = value));

    Map<CharRange, String> charRangeLabels = {
      CharRange.std64: '標準64文字',
      CharRange.ext88: '拡張88文字',
      CharRange.custom: '詳細設定',
    };

    List<Widget> selectCharRange = charRangeLabels.keys
        .map((key) => ListTile(
              title: Text(charRangeLabels[key]!),
              leading: Radio<CharRange>(
                value: key,
                groupValue: _pg.charRange,
                onChanged: (CharRange? value) =>
                    setState(() => _pg.charRange = value!),
              ),
            ))
        .toList();

    Widget toggleRequireUpperCase = buildCheckBox(
      '大文字',
      _pg.requireUpperCase,
      _pg.charRange == CharRange.custom
          ? (bool? value) => setState(() => _pg.requireUpperCase = value!)
          : null,
    );

    Widget toggleRequireLowerCase = buildCheckBox(
      '小文字',
      _pg.requireLowerCase,
      _pg.charRange == CharRange.custom
          ? (bool? value) => setState(() => _pg.requireLowerCase = value!)
          : null,
    );

    Widget toggleRequireDigit = buildCheckBox(
      '数字',
      _pg.requireDigit,
      _pg.charRange == CharRange.custom
          ? (bool? value) => setState(() => _pg.requireDigit = value!)
          : null,
    );

    Widget toggleRequireSymbol = buildCheckBox(
      '記号',
      _pg.requireSymbol,
      _pg.charRange == CharRange.custom
          ? (bool? value) => setState(() => _pg.requireSymbol = value!)
          : null,
    );

    Widget toggleForbidExcludes = buildCheckBox(
      '指定した文字を除外する',
      _pg.forbidExcludes,
      _pg.charRange == CharRange.custom
          ? (bool? value) => setState(() => _pg.forbidExcludes = value!)
          : null,
    );

    Widget textFieldExcludes = TextField(
        controller: TextEditingController()..text = _pg.excludes,
        style: monospaceStyle(),
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: '除外する文字',
        ),
        enabled: _pg.charRange == CharRange.custom,
        onChanged: (String value) {
          _pg.excludes = value;
        },
        onSubmitted: (String value) => setState(() {}));

    Widget toggleRequireAllTypes = buildCheckBox(
      'すべての文字種を使用する',
      _pg.requireAllTypes,
      (bool? value) => setState(() => _pg.requireAllTypes = value!),
    );
    Widget toggleForbidRepeat = buildCheckBox(
      '同じ文字を繰り返して使用しない',
      _pg.forbidRepeat,
      (bool? value) => setState(() => _pg.forbidRepeat = value!),
    );

    Widget buttonReset = buildButton(
      Icon(Icons.close),
      '設定をリセットする',
      () {
        setState(() {
          _pg.reset();
        });
      },
      color: ButtonColors.danger,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
                    Row(children: [
                      Flexible(child: textFieldPassword),
                      gutter,
                      buttonCopyPassword,
                      gutter,
                      buttonGeneratePassword,
                    ]),
                    gutter,
                    boxCharList,
                    gutter,
                    Row(
                      children: [
                            labelLength,
                            Flexible(child: sliderLength),
                          ] +
                          selectCharRange
                              .map((w) => Flexible(child: w))
                              .toList(),
                    ),
                    Row(
                      children: [
                        Flexible(child: toggleRequireUpperCase),
                        Flexible(child: toggleRequireLowerCase),
                        Flexible(child: toggleRequireDigit),
                        Flexible(child: toggleRequireSymbol),
                      ],
                    ),
                    Row(children: [
                      Flexible(child: toggleForbidExcludes),
                      Flexible(child: textFieldExcludes),
                    ]),
                    Row(children: [
                      Flexible(child: toggleRequireAllTypes),
                      Flexible(child: toggleForbidRepeat),
                    ]),
                    gutter,
                    buttonReset,
                  ],
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
                      Row(children: [
                        Flexible(child: textFieldPassword),
                        gutter,
                      ]),
                      gutter,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          buttonCopyPassword,
                          gutter,
                          buttonGeneratePassword,
                        ],
                      ),
                      gutter,
                      boxCharList,
                      gutter,
                      Row(children: [
                        labelLength,
                        Flexible(child: sliderLength),
                      ]),
                      Row(
                        children: selectCharRange
                            .map((w) => Flexible(child: w))
                            .toList(),
                      ),
                      Row(
                        children: [
                          Flexible(child: toggleRequireUpperCase),
                          Flexible(child: toggleRequireLowerCase),
                          Flexible(child: toggleRequireDigit),
                          Flexible(child: toggleRequireSymbol),
                        ],
                      ),
                      Row(children: [
                        Flexible(child: toggleForbidExcludes),
                        Flexible(child: textFieldExcludes),
                      ]),
                    ] +
                    [
                      toggleRequireAllTypes,
                      toggleForbidRepeat,
                      gutter,
                      buttonReset,
                    ],
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
                      Row(children: [
                        Flexible(child: textFieldPassword),
                        gutter,
                      ]),
                      gutter,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          buttonCopyPassword,
                          gutter,
                          buttonGeneratePassword,
                        ],
                      ),
                      gutter,
                      boxCharList,
                      gutter,
                      Row(children: [
                        labelLength,
                        Flexible(child: sliderLength),
                      ]),
                    ] +
                    selectCharRange +
                    <Widget>[
                      Row(children: [
                        Flexible(child: toggleRequireUpperCase),
                        Flexible(child: toggleRequireLowerCase),
                      ]),
                      Row(children: [
                        Flexible(child: toggleRequireDigit),
                        Flexible(child: toggleRequireSymbol),
                      ]),
                      toggleForbidExcludes,
                      textFieldExcludes,
                      toggleRequireAllTypes,
                      toggleForbidRepeat,
                      gutter,
                      buttonReset,
                    ],
              ),
            ),
          );
        }
      }),
    );
  }
}
