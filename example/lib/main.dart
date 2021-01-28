import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:yenepayflutter/yenepayflutter.dart';
import 'package:yenepayflutter/messages.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'New';

  @override
  void initState() {
    super.initState();
    _initPlugin();
    // initPlatformState();
  }

  void _initPlugin() {
    Yenepayflutter.setEventHandlers((response) {
      setState(() {
        _platformVersion = response.toString();
      });
    }, (error) {
      setState(() {
        _platformVersion = (error as PlatformException).message;
      });
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> requestPayment() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      dynamic item = {
        "itemId": "0001",
        "itemName": "ReactNative Test Item",
        "unitPrice": 1.0,
        "quantity": 2
      };
      YenepayPaymentRequest order = new YenepayPaymentRequest()
        ..merchantCode = "0008"
        ..merchantOrderId = "79879987987"
        ..ipnUrl = ""
        ..returnUrl = "com.yenepay.flutterexample:/payment2return"
        ..items = [item];

      await Yenepayflutter.requestPayment(order);
      platformVersion = 'Payment Submitted';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Text('Result: $_platformVersion\n'),
      ),
      floatingActionButton: FloatingActionButton(
          tooltip: 'Add', // used by assistive technologies
          child: Icon(Icons.add),
          onPressed: () {
            requestPayment();
          }),
    ));
  }
}
