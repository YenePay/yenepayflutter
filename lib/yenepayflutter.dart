import 'dart:async';

import 'messages.dart';

typedef void PaymentResponseHandler(YenepayPaymentResponse response);
typedef void PaymentErrorHandler(dynamic error);

class Yenepayflutter {
  static void setEventHandlers(
      PaymentResponseHandler success, PaymentErrorHandler error) {
    _api.channel.receiveBroadcastStream().listen((event) {
      success(YenepayPaymentResponse.decode(event));
    }, onError: (err) {
      error(err);
    });
  }

  static YenePayApi _apiInstance;

  static YenePayApi get _api {
    if (_apiInstance == null) {
      _apiInstance = YenePayApi();
    }
    return _apiInstance;
  }

  static Future<void> requestPayment(YenepayPaymentRequest request) async {
    await _api.requestPayment(request);
    return;
  }
}
