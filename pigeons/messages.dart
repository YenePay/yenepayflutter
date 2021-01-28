import 'package:pigeon/pigeon.dart';

class YenepayPaymentRequest {
  String merchantCode;
  String merchantOrderId;
  String ipnUrl;
  String returnUrl;
  double tax1;
  double tax2;
  double deliveryFee;
  double handlingFee;
  double discount;
  bool isUseSandboxEnabled = false;
  List<YenepayOrderedItem> items = [];
}

class YenepayOrderedItem {
  String itemId;
  String itemName;
  int quantity = 1;
  double unitPrice;
}

@HostApi()
abstract class YenePayApi {
  void requestPayment(YenepayPaymentRequest request);
}
