import 'package:flutter/material.dart';

TextStyle monospaceStyle({
  Color backgroundColor = Colors.transparent,
  Color color = Colors.black,
  double fontSize = 18,
}) =>
    TextStyle(
      fontFamily: 'RobotoMono',
      backgroundColor: backgroundColor,
      color: color,
      fontSize: fontSize,
    );

enum Meanings { primary, secondary, info, success, warning, danger }

const Map<Meanings, Color> _buttonColors = {
  Meanings.primary: Colors.teal,
  Meanings.secondary: Colors.blueGrey,
  Meanings.info: Colors.blueAccent,
  Meanings.success: Colors.green,
  Meanings.warning: Colors.orange,
  Meanings.danger: Colors.deepOrangeAccent,
};

const Map<Meanings, Color> _iconColors = _buttonColors;

const Map<Meanings, IconData> _icons = {
  Meanings.primary: Icons.info,
  Meanings.secondary: Icons.info,
  Meanings.info: Icons.info,
  Meanings.success: Icons.info,
  Meanings.warning: Icons.warning,
  Meanings.danger: Icons.error,
};

Widget buildButton(Icon icon, String label, void onPressed(),
        {Meanings meaning = Meanings.primary}) =>
    ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: Text(label),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(120, 56),
        primary: _buttonColors[meaning],
      ),
    );

Widget buildToggle(String label, bool value, void onChanged(bool? value)?) =>
    ChoiceChip(
      selected: value,
      onSelected: onChanged,
      label: Text(label),
      labelStyle: TextStyle(color: value ? Colors.white : Colors.black),
      selectedColor: onChanged != null ? Colors.teal : Colors.black26,
    );

SnackBar buildSnackBar(
  String text, {
  Meanings meaning = Meanings.info,
  int duration = 2000,
}) =>
    SnackBar(
      content: Row(children: [
        Icon(
          _icons[meaning],
          color: _iconColors[meaning],
        ),
        SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            maxLines: 10,
          ),
        ),
      ]),
      duration: Duration(milliseconds: duration),
      action: SnackBarAction(
        label: '×',
        onPressed: () {},
      ),
    );
