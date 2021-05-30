import 'package:flutter/material.dart';

TextStyle monospaceStyle({
  Color backgroundColor = Colors.transparent,
  Color color = Colors.black,
  double fontSize = 18,
}) {
  return TextStyle(
    fontFamily: 'RobotoMono',
    backgroundColor: backgroundColor,
    color: color,
    fontSize: fontSize,
  );
}

enum ButtonColors { primary, secondary, info, warning, danger }

final Map<ButtonColors, Color> _buttonColors = {
  ButtonColors.primary: Colors.teal,
  ButtonColors.secondary: Colors.blueGrey,
  ButtonColors.info: Colors.blueAccent,
  ButtonColors.warning: Colors.orange,
  ButtonColors.danger: Colors.deepOrangeAccent,
};

Widget buildButton(Icon icon, String label, void onPressed(),
    [ButtonColors color = ButtonColors.primary]) {
  return ElevatedButton.icon(
    onPressed: onPressed,
    icon: icon,
    label: Text(label),
    style: ElevatedButton.styleFrom(
      minimumSize: Size(120, 56),
      primary: _buttonColors[color],
    ),
  );
}

Widget buildCheckBox(
    String label, bool initialValue, void onChanged(bool? value)?) {
  return ListTile(
    title: Text(label),
    leading: Checkbox(
      value: initialValue,
      onChanged: onChanged,
    ),
  );
}

class RadioController {
  late Map<String, String> labels;
  late String value;

  RadioController(Map<String, String> labels, String initialValue) {
    this.labels = labels;
    this.value = initialValue;
  }
}

Widget buildRadio(
    RadioController controller, String value, void onChanged(String? value)) {
  return ListTile(
    title: Text(controller.labels[value]!),
    leading: Radio<String>(
      value: value,
      groupValue: controller.value,
      onChanged: onChanged,
    ),
  );
}

void showSnackBar(
  BuildContext context,
  String text, {
  IconData? icon,
  Color iconColor = Colors.white,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(children: [
        Icon(
          icon,
          color: iconColor,
        ),
        SizedBox(width: 4),
        Text(
          text,
        ),
      ]),
      action: SnackBarAction(
        label: '閉じる',
        onPressed: () {},
      ),
    ),
  );
}

void showSnackBarInfo(BuildContext context, String text) {
  showSnackBar(context, text, icon: Icons.info, iconColor: Colors.lightBlue);
}

void showSnackBarWarn(BuildContext context, String text) {
  showSnackBar(context, text, icon: Icons.warning, iconColor: Colors.orange);
}

void showSnackBarError(BuildContext context, String text) {
  showSnackBar(context, text, icon: Icons.error, iconColor: Colors.pink);
}
