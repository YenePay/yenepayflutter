import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:yenepayflutter/yenepayflutter.dart';
import '../models.dart';

class Cart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _cart = context.watch<ShoppingCart>();
    var _paymentModel = Provider.of<PaymentModel>(context, listen: false);
    var _items = _cart.getLineItems();
    var _total = _cart.getGrandTotalLineItem();
    TextStyle textStyle = Theme.of(context).textTheme.headline4;
    TextStyle amountStyle = Theme.of(context).textTheme.bodyText1;
    TextStyle totalStyle = Theme.of(context).textTheme.headline5;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          FlatButton(
            child: Text('Clear'),
            textColor: Colors.white,
            onPressed: () => _cart.clearItems(),
          )
        ],
      ),
      body: Column(children: [
        Container(
          padding: const EdgeInsets.all(20.0),
          child: Text('${_cart.getItemsCount} Items in your cart',
              style: textStyle),
        ),
        ListView.separated(
          shrinkWrap: true,
          itemCount: _items.length,
          itemBuilder: (BuildContext context, int index) {
            return Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_items[index].name, style: amountStyle),
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${_items[index].currency} ${_items[index].amount.toStringAsFixed(2)}',
                    style: amountStyle.apply(
                        color: _items[index].amount <= 0
                            ? Colors.redAccent
                            : Colors.black),
                  ),
                )
              ],
            );
          },
          separatorBuilder: (context, index) => Divider(
            color: Colors.black,
          ),
        ),
        Divider(
          color: Colors.black,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _total.name,
                style: totalStyle.apply(
                    color: _total.amount <= 0
                        ? Colors.redAccent
                        : Colors.blueAccent),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${_total.currency} ${_total.amount.toStringAsFixed(2)}',
                style: totalStyle.apply(
                    color: _total.amount <= 0
                        ? Colors.redAccent
                        : Colors.blueAccent),
              ),
            )
          ],
        ),
        Container(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: RaisedButton(
                child: Text('Pay now'),
                color: Colors.indigoAccent,
                textColor: Colors.white,
                onPressed: _total.amount <= 0
                    ? null
                    : () async {
                        var request = _cart.generatePayment();
                        try {
                          await Yenepayflutter.requestPayment(request);
                        } on PlatformException catch (e) {
                          _paymentModel.setException(e);
                          Navigator.pushNamed(context, '/payment');
                        }
                      },
              ),
            ))
      ]),
    );
  }
}
