import 'package:flutter/material.dart';

bool _light = true;

class SettingsView extends StatefulWidget {
  final Function(bool) onChanged;

  const SettingsView({Key key, this.onChanged}) : super(key: key);
  
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
            'Light Theme',
            style: TextStyle(
              fontSize: 16.0,
            ),
        ),
        Switch(
          value: _light,
          onChanged: (state) {
            setState(() {
              _light = state;
            });
            widget.onChanged(state);
          },
        )
      ],
    );
  }
}
