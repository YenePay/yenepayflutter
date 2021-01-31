import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models.dart';

class Payment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _payment = context.watch<PaymentModel>();
    TextStyle textStyle = Theme.of(context).textTheme.headline4;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Payment'),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(20.0),
              child: Text('Payment Status', style: textStyle),
            ),
            Container(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: paymentStatusWidget(context, _payment),
                )),
            Container(
              padding: const EdgeInsets.all(8.0),
              child:
                  Text(_payment.hasResult ? _payment.response.toString() : ''),
            )
          ]),
        ));
  }

  Widget paymentStatusWidget(BuildContext context, PaymentModel paymentModel) {
    TextStyle textStyle = Theme.of(context).textTheme.headline6;
    return (paymentModel.hasError || paymentModel.isCanceled)
        ? Column(children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.error, color: Colors.red, size: 56.0),
            ),
            Center(
              child: Text(
                  paymentModel.hasError
                      ? paymentModel.paymentError
                      : paymentModel.hasResult
                          ? paymentModel.response.statusText
                          : 'Uknown error occured',
                  style: textStyle),
            )
          ])
        : paymentModel.isCompleted
            ? Column(children: [
                Icon(Icons.thumb_up, color: Colors.green, size: 56.0),
                Text('Payment Completed', style: textStyle)
              ])
            : paymentModel.isPending
                ? Column(children: [
                    Icon(Icons.alarm, color: Colors.blue, size: 56.0),
                    Text('Waiting Payment', style: textStyle)
                  ])
                : Text(null);
  }
}
