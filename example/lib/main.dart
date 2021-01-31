import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yenepayflutter/yenepayflutter.dart';
import 'package:yenepayflutter/messages.dart';
import 'package:yenepayflutter_example/screens/cart.dart';
import 'package:yenepayflutter_example/screens/select_currency.dart';
import 'package:yenepayflutter_example/screens/setting.dart';
import 'package:yenepayflutter_example/screens/shop.dart';
import 'package:yenepayflutter_example/screens/payment.dart';
import 'models.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      FutureProvider(
        create: (context) async {
          var pref = await SharedPreferences.getInstance();
          return pref;
        },
      ),
      ChangeNotifierProvider(create: (context) => PaymentModel()),
      ChangeNotifierProxyProvider<SharedPreferences, SettingModel>(
        create: (context) {
          var pref = Provider.of<SharedPreferences>(context, listen: false);
          return SettingModel(pref);
        },
        update: (context, prefs, settings) {
          settings.pref = prefs;
          return settings;
        },
      ),
      ChangeNotifierProxyProvider<SettingModel, ShoppingCart>(
        create: (context) => ShoppingCart(),
        update: (context, settings, cart) {
          cart.settings = settings;
          return cart;
        },
      )
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navKey = GlobalKey<NavigatorState>();
  @override
  void initState() {
    super.initState();
    // _initPlugin();
    // initPlatformState();
  }

  void _initPlugin(BuildContext context) {
    Yenepayflutter.setEventHandlers((response) {
      var payment = Provider.of<PaymentModel>(context, listen: false);
      payment.response = response;
      _navKey.currentState.pushNamed('/payment');
    }, (error) {
      var payment = Provider.of<PaymentModel>(context, listen: false);
      payment.setException(error as PlatformException);
      _navKey.currentState.pushNamed('/payment');
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
    } on PlatformException {}

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    _initPlugin(context);
    return MaterialApp(
      title: "YenePay Flutter",
      navigatorKey: _navKey,
      initialRoute: '/',
      routes: {
        '/': (context) => Shop(),
        '/cart': (context) => Cart(),
        '/settings': (context) => Settings(),
        '/selectCurrency': (context) => SelectCurrency(),
        '/payment': (context) => Payment()
      },
    );
  }
}

// child: MaterialApp(
//         title: 'Provider Demo',
//         theme: appTheme,
//         initialRoute: '/',
//         routes: {
//           '/': (context) => MyLogin(),
//           '/catalog': (context) => MyCatalog(),
//           '/cart': (context) => MyCart(),
//         },
//       )
