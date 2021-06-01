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

enum ButtonColors { primary, secondary, info, warning, danger }

final Map<ButtonColors, Color> _buttonColors = {
  ButtonColors.primary: Colors.teal,
  ButtonColors.secondary: Colors.blueGrey,
  ButtonColors.info: Colors.blueAccent,
  ButtonColors.warning: Colors.orange,
  ButtonColors.danger: Colors.deepOrangeAccent,
};

Widget buildButton(Icon icon, String label, void onPressed(),
        {ButtonColors color = ButtonColors.primary}) =>
    ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: Text(label),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(120, 56),
        primary: _buttonColors[color],
      ),
    );

Widget buildCheckBox(
        String label, bool initialValue, void onChanged(bool? value)?) =>
    ListTile(
      title: Text(label),
      leading: Checkbox(
        value: initialValue,
        onChanged: onChanged,
      ),
    );

SnackBar buildSnackBar(
  String text, {
  IconData? icon,
  Color iconColor = Colors.white,
  int duration = 2000,
}) =>
    SnackBar(
      content: Row(children: [
        Icon(
          icon,
          color: iconColor,
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

SnackBar buildSnackBarInfo(String text) =>
    buildSnackBar(text, icon: Icons.info, iconColor: Colors.lightBlue);

SnackBar buildSnackBarWarn(String text) =>
    buildSnackBar(text, icon: Icons.warning, iconColor: Colors.orange);

SnackBar buildSnackBarError(String text) =>
    buildSnackBar(text, icon: Icons.error, iconColor: Colors.pink);
