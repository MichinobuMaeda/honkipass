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
      messageState.showSnackBar(
          buildSnackBar('パスワードを生成できませんでした。', meaning: Meanings.danger));
    });
    _pg.onCopiedToClipboard(() {
      messageState.removeCurrentSnackBar();
      messageState.showSnackBar(buildSnackBar('パスワードをクリップボードにコピーしました。'));
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        final sp = 24.0;
        final double edge = (constraints.maxWidth > 840)
            ? sp
            : (constraints.maxWidth > 600)
                ? sp * 0.75
                : sp * 0.5;

        return SingleChildScrollView(
          padding: EdgeInsets.all(edge),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                maxWidth: 960,
              ),
              child: Wrap(
                runSpacing: sp,
                children: [
                  _result(sp),
                  _charList(),
                  _basicSettings(sp),
                  _charRangeDetails(sp),
                  _paranoids(sp),
                  _reset(),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _result(double sp) => Align(
        alignment: Alignment.topLeft,
        child: Wrap(
          spacing: sp,
          runSpacing: sp,
          alignment: WrapAlignment.end,
          children: [
            Container(
                width: 480.0,
                child: TextField(
                    controller: TextEditingController()..text = _pg.password,
                    focusNode: _focusNode,
                    readOnly: true,
                    style: monospaceStyle(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'パスワード',
                    ))),
            buildButton(Icon(Icons.copy), 'コピー', () => _pg.copyToClipboard()),
            buildButton(
                Icon(Icons.refresh),
                '生成',
                () => setState(() {
                      _pg.generate();
                      _focusNode.requestFocus();
                    }))
          ],
        ),
      );

  Widget _charList() => ColoredBox(
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
                  .toList())));

  Widget _basicSettings(sp) => Align(
      alignment: Alignment.topLeft,
      child: Wrap(spacing: sp, runSpacing: sp, children: [
        ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 360.0),
            child: Row(children: [
              Text(
                  (' ' + _pg.length.round().toString())
                      .substring(_pg.length.round() < 10 ? 0 : 1),
                  style: monospaceStyle()),
              Flexible(
                  child: Slider(
                value: _pg.length,
                min: 4,
                max: 32,
                divisions: (32 - 4),
                label: _pg.length.round().toString(),
                onChanged: (double value) => setState(() => _pg.length = value),
              ))
            ])),
        ConstrainedBox(
            constraints: BoxConstraints(minWidth: 360.0),
            child: Wrap(spacing: sp, runSpacing: sp, children: [
              buildToggle('標準64文字', _pg.charRange == CharRange.std64,
                  (bool? value) {
                if (value == true) {
                  setState(() => _pg.charRange = CharRange.std64);
                }
              }),
              buildToggle('拡張88文字', _pg.charRange == CharRange.ext88,
                  (bool? value) {
                if (value == true) {
                  setState(() => _pg.charRange = CharRange.ext88);
                }
              }),
              buildToggle('詳細設定', _pg.charRange == CharRange.custom,
                  (bool? value) {
                if (value == true) {
                  setState(() => _pg.charRange = CharRange.custom);
                }
              })
            ]))
      ]));

  Widget _charRangeDetails(sp) => Align(
        alignment: Alignment.topLeft,
        child: Wrap(spacing: sp, runSpacing: sp, children: [
          buildToggle(
              '大文字',
              _pg.requireUpperCase,
              _pg.charRange == CharRange.custom
                  ? (bool? value) =>
                      setState(() => _pg.requireUpperCase = value!)
                  : null),
          buildToggle(
              '小文字',
              _pg.requireLowerCase,
              _pg.charRange == CharRange.custom
                  ? (bool? value) =>
                      setState(() => _pg.requireLowerCase = value!)
                  : null),
          buildToggle(
              '数字',
              _pg.requireDigit,
              _pg.charRange == CharRange.custom
                  ? (bool? value) => setState(() => _pg.requireDigit = value!)
                  : null),
          buildToggle(
              '記号',
              _pg.requireSymbol,
              _pg.charRange == CharRange.custom
                  ? (bool? value) => setState(() => _pg.requireSymbol = value!)
                  : null),
          Container(
              width: 360.0,
              child: TextField(
                  controller: TextEditingController()..text = _pg.excludes,
                  style: monospaceStyle(
                      color: _pg.charRange == CharRange.custom &&
                              _pg.forbidExcludes
                          ? Colors.black
                          : Colors.black38),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '除外する文字',
                    suffixIcon: IconButton(
                        onPressed: _pg.charRange == CharRange.custom
                            ? () => setState(
                                () => _pg.forbidExcludes = !_pg.forbidExcludes)
                            : null,
                        icon: Icon(
                            _pg.forbidExcludes
                                ? Icons.check_circle
                                : Icons.unpublished,
                            color: _pg.charRange == CharRange.custom &&
                                    _pg.forbidExcludes
                                ? Colors.teal
                                : Colors.black38)),
                  ),
                  enabled: _pg.charRange == CharRange.custom,
                  onChanged: (String value) => _pg.excludes = value,
                  onSubmitted: (String value) => setState(() {}))),
        ]),
      );

  Widget _paranoids(sp) => Align(
        alignment: Alignment.topLeft,
        child: Wrap(spacing: sp, runSpacing: sp, children: [
          buildToggle('すべての文字種を使用する', _pg.requireAllTypes,
              (bool? value) => setState(() => _pg.requireAllTypes = value!)),
          buildToggle('同じ文字を繰り返して使用しない', _pg.forbidRepeat,
              (bool? value) => setState(() => _pg.forbidRepeat = value!)),
        ]),
      );

  Widget _reset() => buildButton(
      Icon(Icons.close), '設定をリセットする', () => setState(() => _pg.reset()),
      meaning: Meanings.danger);
}
