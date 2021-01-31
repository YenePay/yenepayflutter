import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import '../models.dart';

class SelectCurrency extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _settings = Provider.of<SettingModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Currency'),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: 'Currencies',
            tiles: [
              SettingsTile(
                title: 'Ethiopian Birr',
                subtitle: 'ETB',
                leading: Icon(Icons.money),
                trailing: trailingWidget('ETB', _settings.currency),
                onPressed: (BuildContext context) async {
                  await _settings.setCurrency('ETB');
                  Navigator.pop(context);
                },
              ),
              SettingsTile(
                title: 'Us Dollar',
                subtitle: 'USD',
                leading: Icon(Icons.money),
                trailing: trailingWidget('USD', _settings.currency),
                onPressed: (BuildContext context) async {
                  await _settings.setCurrency('USD');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget trailingWidget(String value, String selectedValue) {
    return (value == selectedValue)
        ? Icon(Icons.check, color: Colors.blue)
        : Icon(null);
  }
}
