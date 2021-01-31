import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import '../models.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  TextEditingController _textFieldController = TextEditingController();
  String valueText;
  Future<void> _displayTextInputDialog(
      BuildContext context, SettingModel _settings) async {
    _textFieldController.text = _settings.merchantCode;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter YenePay Account Code'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "eg. 0008"),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                child: Text('OK'),
                onPressed: () async {
                  await _settings.setMerchantCode(valueText);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var _settings = context.watch<SettingModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: 'Sandbox mode',
            tiles: [
              SettingsTile.switchTile(
                title: 'Use Sandbox Mode',
                subtitle: 'If enabled the app will checkout to YenePay Sandbox',
                leading: Icon(Icons.cloud_circle_outlined),
                switchValue: _settings.useSandbox,
                onToggle: (bool value) async {
                  await _settings.setUseSandbox(value);
                },
              ),
            ],
          ),
          SettingsSection(
            title: 'Account',
            tiles: [
              SettingsTile(
                title: 'Merchant Code',
                subtitle: _settings.merchantCode != null
                    ? 'Selected code - ${_settings.merchantCode}'
                    : 'Please enter your YenePay merchant code',
                leading: Icon(Icons.account_box),
                onPressed: (context) {
                  _displayTextInputDialog(context, _settings);
                },
              ),
            ],
          ),
          SettingsSection(
            title: 'Payment',
            tiles: [
              SettingsTile(
                title: 'Currency',
                subtitle: _settings.currency,
                leading: Icon(Icons.money),
                onPressed: (BuildContext context) =>
                    Navigator.pushNamed(context, '/selectCurrency'),
              ),
            ],
          ),
          SettingsSection(
            title: "Delivery Fee",
            tiles: [
              SettingsTile.switchTile(
                title: 'Use Delivery Fee',
                subtitle: 'If enabled the app will charge delivery fee',
                leading: Icon(Icons.local_shipping),
                switchValue: _settings.useDeliveryFee,
                onToggle: (bool value) async {
                  await _settings.setUseDeliveryFee(value);
                },
              ),
            ],
          ),
          CustomSection(
            child: !_settings.useDeliveryFee
                ? Center(
                    child: Text(''),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      new Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                            'Delivery Fee Amount - ${_settings.currency} ${_settings.deliveryFeeAmt}'),
                      ),
                      Slider(
                        min: 0,
                        max: 100,
                        divisions: 100,
                        value: _settings.deliveryFeeAmt,
                        onChanged: (value) async {
                          _settings.setDeliveryFeeAmt(value);
                        },
                      ),
                    ],
                  ),
          ),
          SettingsSection(
            title: "Discount",
            tiles: [
              SettingsTile.switchTile(
                title: 'Use Discount',
                subtitle: 'If enabled the app dicount from total',
                leading: Icon(Icons.tag),
                switchValue: _settings.useDiscount,
                onToggle: (bool value) async {
                  await _settings.setUseDiscount(value);
                },
              ),
            ],
          ),
          CustomSection(
            child: !_settings.useDiscount
                ? Center(
                    child: Text(''),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      new Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                            'Discount Amount - ${_settings.currency} ${_settings.discountAmt}'),
                      ),
                      Slider(
                        min: 0,
                        max: 100,
                        divisions: 100,
                        value: _settings.discountAmt,
                        onChanged: (value) async {
                          _settings.setDiscountAmt(value);
                        },
                      ),
                    ],
                  ),
          ),
          SettingsSection(
            title: "Handling Fee",
            tiles: [
              SettingsTile.switchTile(
                title: 'Use Handling Fee',
                subtitle: 'If enabled the app will charge handling fee',
                leading: Icon(Icons.shop_outlined),
                switchValue: _settings.useHandlingFee,
                onToggle: (bool value) async {
                  await _settings.setUseHandlingFee(value);
                },
              ),
            ],
          ),
          CustomSection(
            child: !_settings.useHandlingFee
                ? Center(
                    child: Text(''),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      new Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                            'Handling Fee Amount - ${_settings.currency} ${_settings.handlingFeeAmt}'),
                      ),
                      Slider(
                        min: 0,
                        max: 100,
                        divisions: 100,
                        value: _settings.handlingFeeAmt,
                        onChanged: (value) async {
                          _settings.setHandlingFeeAmt(value);
                        },
                      ),
                    ],
                  ),
          ),
          SettingsSection(
            title: "Tax 1",
            tiles: [
              SettingsTile.switchTile(
                title: 'Use Tax 1',
                subtitle: 'If enabled the app will charge tax 1',
                leading: Icon(Icons.list),
                switchValue: _settings.useTax1,
                onToggle: (bool value) async {
                  await _settings.setUseTax1(value);
                },
              ),
            ],
          ),
          CustomSection(
            child: !_settings.useTax1
                ? Center(
                    child: Text(''),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      new Container(
                        padding: const EdgeInsets.all(16.0),
                        child:
                            Text('Tax 1 Percent - ${_settings.tax1Percent} %'),
                      ),
                      Slider(
                        min: 0,
                        max: 100,
                        divisions: 20,
                        value: _settings.tax1Percent,
                        onChanged: (value) async {
                          _settings.setTax1Percent(value);
                        },
                      ),
                    ],
                  ),
          ),
          SettingsSection(
            title: "Tax 2",
            tiles: [
              SettingsTile.switchTile(
                title: 'Use Tax 2',
                subtitle: 'If enabled the app will charge tax 2',
                leading: Icon(Icons.list),
                switchValue: _settings.useTax2,
                onToggle: (bool value) async {
                  await _settings.setUseTax2(value);
                },
              ),
            ],
          ),
          CustomSection(
            child: !_settings.useTax2
                ? Center(
                    child: Text(''),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      new Container(
                        padding: const EdgeInsets.all(16.0),
                        child:
                            Text('Tax 2 Percent - ${_settings.tax2Percent} %'),
                      ),
                      Slider(
                        min: 0,
                        max: 100,
                        divisions: 20,
                        value: _settings.tax2Percent,
                        onChanged: (value) async {
                          _settings.setTax2Percent(value);
                        },
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
