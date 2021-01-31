import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:yenepayflutter/messages.dart';

class Product {
  String id;
  String name;
  String image;
  double price;
  Product(this.id, this.name, this.image, this.price);

  YenepayPaymentRequest generatePayment(SettingModel settings) {
    List<Object> _items = [];
    _items.add(
        {"itemId": id, "itemName": name, "unitPrice": price, "quantity": 1});
    var request = YenepayPaymentRequest()
      ..merchantOrderId = Uuid().v4()
      ..ipnUrl = Constants.IPN_URL
      ..returnUrl = Constants.RETURN_URL
      ..items = _items;
    settings.populatePaymentDetails(request, price);
    return request;
  }

  static List<Product> generateProducts() {
    return List.of([
      new Product('PID_1', 'Gift card (2 ETB)', 'product_2giftcart.jpeg', 2),
      new Product('PID_2', 'Adidas Shoe', 'product_adidas.jpg', 150),
      new Product('PID_3', 'Asus Pc', 'product_asuspc_N551JK.jpeg', 1200),
      new Product('PID_4', 'Leica T Camera', 'product_LeicaT.jpeg', 200),
      new Product('PID_5', 'Gift card (5 ETB)', 'product_5giftcart.jpeg', 5),
      new Product('PID_6', 'Levi Jeans', 'product_LeviJeans.jpg', 50),
      new Product(
          'PID_7', 'Lumia 1020 smartphone', 'product_Lumia1020.jpeg', 190),
      new Product('PID_8', 'Macbook Pro', 'product_macbook.jpeg', 1900),
      new Product(
          'PID_9', 'Nike Floral Shoe', 'product_NikeFloralShoe.jpg', 170),
      new Product('PID_10', 'Nike Shirt', 'product_NikeShirt.jpg', 90),
      new Product('PID_11', 'Nike Zoom Shoe', 'product_NikeZoom.jpg', 120),
      new Product(
          'PID_12', 'Nikon Camera', 'product_NikonCamera_red.jpeg', 110),
      new Product('PID_13', 'Pill Beats Speaker', 'product_PillBeats.jpeg', 95),
      new Product('PID_14', 'Smart Speaker', 'product_Speakers.jpeg', 54),
      new Product(
          'PID_15', 'Gift card (10 ETB)', 'product_10giftcart.jpeg', 10),
      new Product('PID_16', 'Sunglasses', 'product_Sunglasses.jpg', 25),
      new Product('PID_17', 'Women T-Shirt', 'product_WomenTShirt.jpg', 45)
    ]);
  }

  PaymentLineItem getGrandTotalLineItem(SettingModel settings) {
    return settings.getGrandTotalLineItem(price);
  }
}

class CartItem extends Product {
  int quantity;
  CartItem(Product product, int qty)
      : super(product.id, product.name, product.image, product.price) {
    quantity = qty > 0 ? qty : 1;
  }
  double get itemTotal => price * quantity;
}

class ShoppingCart extends ChangeNotifier {
  static ShoppingCart _cart;
  static ShoppingCart get instance {
    if (_cart == null) {
      _cart = ShoppingCart();
    }
    return _cart;
  }

  List<CartItem> items;
  SettingModel _settings;
  ShoppingCart() {
    this.items = [];
  }

  /// The current catalog. Used to construct items from numeric ids.
  SettingModel get settings => _settings;

  set settings(SettingModel newCatalog) {
    _settings = newCatalog;
    // Notify listeners, in case the new catalog provides information
    // different from the previous one. For example, availability of an item
    // might have changed.
    notifyListeners();
  }

  void addItem(CartItem item) {
    if (items.isNotEmpty) {
      var existing = items.firstWhere((element) => element.id == item.id,
          orElse: () => null);
      if (existing != null) {
        existing.quantity += item.quantity;
      } else {
        items.add(item);
      }
    } else {
      items.add(item);
    }
    notifyListeners();
  }

  void clearItems() {
    items.clear();
    notifyListeners();
  }

  int get getItemsCount => items.isNotEmpty
      ? items.map((e) => e.quantity).reduce((a, b) => a + b)
      : 0;
  double get getItemsTotal => items.isNotEmpty
      ? items.map((e) => e.itemTotal).reduce((a, b) => a + b)
      : 0;

  YenepayPaymentRequest generatePayment() {
    var request = YenepayPaymentRequest()
      ..merchantOrderId = Uuid().v4()
      ..ipnUrl = Constants.IPN_URL
      ..returnUrl = Constants.RETURN_URL
      ..items = items
          .map((e) => {
                "itemId": e.id,
                "itemName": e.name,
                "unitPrice": e.price,
                "quantity": e.quantity
              })
          .toList();
    _settings.populatePaymentDetails(request, getItemsTotal);
    return request;
  }

  List<PaymentLineItem> getLineItems() {
    return _settings.generateLineItems(getItemsTotal);
  }

  PaymentLineItem getGrandTotalLineItem() {
    return _settings.getGrandTotalLineItem(getItemsTotal);
  }
}

typedef ProductCallback(Product product);

class ProductCard extends StatelessWidget {
  const ProductCard(
      {Key key,
      @required this.item,
      this.onBuyTap,
      this.onCartTap,
      this.selected: false})
      : super(key: key);

  final ProductCallback onCartTap;
  final ProductCallback onBuyTap;
  final Product item;

  final bool selected;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.headline4;

    if (selected)
      textStyle = textStyle.copyWith(color: Colors.lightGreenAccent[400]);

    return Card(
        color: Colors.white,
        child: Column(
          children: [
            new Container(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset('assets/${item.image}')),
            new Container(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: Theme.of(context).textTheme.headline6),
                  Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'),
                  ButtonBar(
                    children: [
                      RaisedButton(
                          child: Text('Add to cart'),
                          color: Colors.indigoAccent,
                          textColor: Colors.white,
                          onPressed: () {
                            onCartTap(item);
                          }),
                      RaisedButton(
                          child: Text('Buy now'),
                          color: Colors.indigoAccent,
                          textColor: Colors.white,
                          onPressed: () {
                            onBuyTap(item);
                          })
                    ],
                  )
                ],
              ),
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ));
  }
}

class SettingModel extends ChangeNotifier {
  SharedPreferences prefs;

  SettingModel(this.prefs);

  set pref(SharedPreferences value) {
    prefs = value;
  }

  bool get useSandbox {
    return getBool('useSandbox');
  }

  Future<void> setUseSandbox(bool value) async {
    return await setBool('useSandbox', value);
  }

  String get merchantCode {
    return prefs.getString('merchantCode');
  }

  Future<void> setMerchantCode(String value) {
    return setString('merchantCode', value);
  }

  String get currency {
    return prefs.getString('currency');
  }

  Future<void> setCurrency(String value) {
    return setString('currency', value);
  }

  bool get useDeliveryFee {
    return getBool('useDeliveryFee');
  }

  Future<void> setUseDeliveryFee(bool value) async {
    return await setBool('useDeliveryFee', value);
  }

  double get deliveryFeeAmt {
    return getDouble('deliveryFeeAmt');
  }

  Future<void> setDeliveryFeeAmt(double value) {
    return setDouble('deliveryFeeAmt', value);
  }

  bool get useDiscount {
    return getBool('useDiscount');
  }

  Future<void> setUseDiscount(bool value) {
    return setBool('useDiscount', value);
  }

  double get discountAmt {
    return getDouble('discountAmt');
  }

  Future<void> setDiscountAmt(double value) {
    return setDouble('discountAmt', value);
  }

  bool get useHandlingFee {
    return getBool('useHandlingFee');
  }

  Future<void> setUseHandlingFee(bool value) {
    return setBool('useHandlingFee', value);
  }

  double get handlingFeeAmt {
    return getDouble('handlingFeeAmt');
  }

  Future<void> setHandlingFeeAmt(double value) {
    return setDouble('handlingFeeAmt', value);
  }

  bool get useTax1 {
    return getBool('useTax1');
  }

  Future<void> setUseTax1(bool value) {
    return setBool('useTax1', value);
  }

  double get tax1Percent {
    return getDouble('tax1Percent');
  }

  Future<void> setTax1Percent(double value) {
    return setDouble('tax1Percent', value);
  }

  bool get useTax2 {
    return getBool('useTax2');
  }

  Future<void> setUseTax2(bool value) {
    return setBool('useTax2', value);
  }

  double get tax2Percent {
    return getDouble('tax2Percent');
  }

  Future<void> setTax2Percent(double value) {
    return setDouble('tax2Percent', value);
  }

  Future<void> setDouble(String key, double value) async {
    await prefs.setDouble(key, value);
    notifyListeners();
  }

  Future<void> setBool(String key, bool value) async {
    await prefs.setBool(key, value);
    notifyListeners();
  }

  Future<void> setString(String key, String value) async {
    await prefs.setString(key, value);
    notifyListeners();
  }

  bool getBool(String key, [bool defaultValue = false]) {
    var result = prefs.getBool(key);
    return result != null ? result : defaultValue;
  }

  double getDouble(String key, [double defaultValue = 0]) {
    var result = prefs.getDouble(key);
    return result != null ? result : defaultValue;
  }

  double getSubTotal(double total) {
    var subTotal = total;
    if (useDiscount) {
      subTotal -= discountAmt;
    }
    if (useDeliveryFee) {
      subTotal += deliveryFeeAmt;
    }
    if (useHandlingFee) {
      subTotal += handlingFeeAmt;
    }
    return subTotal;
  }

  double getTax1(double total) {
    if (useTax1) {
      return total * (tax1Percent / 100);
    }
    return 0;
  }

  double getTax2(double total) {
    if (useTax2) {
      return total * (tax2Percent / 100);
    }
    return 0;
  }

  double getPaymentTotal(double total) {
    if (total <= 0) {
      return 0;
    }
    var subTotal = getSubTotal(total);
    return subTotal + getTax1(subTotal) + getTax2(subTotal);
  }

  PaymentLineItem getGrandTotalLineItem(double total) {
    return PaymentLineItem(
        'Total', currency != null ? currency : 'ETB', getPaymentTotal(total));
  }

  List<PaymentLineItem> generateLineItems(double total) {
    List<PaymentLineItem> result = [];
    if (total <= 0) {
      return result;
    }
    var curr = currency != null ? currency : 'ETB';
    result.add(PaymentLineItem('Items Total', curr, total));
    if (useDiscount) {
      result.add(PaymentLineItem('Discount', curr, -1 * discountAmt));
    }
    if (useDeliveryFee) {
      result.add(PaymentLineItem('Delivery Fee', curr, deliveryFeeAmt));
    }
    if (useHandlingFee) {
      result.add(PaymentLineItem('Handling Fee', curr, handlingFeeAmt));
    }
    var subTotal = getSubTotal(total);
    double tax1 = 0, tax2 = 0;
    if (useTax1) {
      tax1 = getTax1(subTotal);
      result.add(PaymentLineItem('Tax 1', curr, tax1));
    }
    if (useTax2) {
      tax1 = getTax2(subTotal);
      result.add(PaymentLineItem('Tax 2', curr, tax2));
    }
    return result;
  }

  void populatePaymentDetails(YenepayPaymentRequest request, double total) {
    request.merchantCode = merchantCode;
    request.isUseSandboxEnabled = useSandbox;
    request.ipnUrl = Constants.IPN_URL;
    request.returnUrl = Constants.RETURN_URL;
    if (useDiscount) {
      request.discount = discountAmt;
    }
    if (useDeliveryFee) {
      request.deliveryFee = deliveryFeeAmt;
    }
    if (useHandlingFee) {
      request.handlingFee = handlingFeeAmt;
    }
    var subTotal = getSubTotal(total);
    if (useTax1) {
      request.tax1 = getTax1(subTotal);
    }
    if (useTax2) {
      request.tax2 = getTax2(subTotal);
    }
  }
}

class PaymentLineItem {
  String name;
  String currency;
  double amount;
  PaymentLineItem(this.name, this.currency, this.amount);
}

class Constants {
  static const String IPN_URL = "";
  static const String RETURN_URL = "com.yenepay.flutterexample:/payment2return";
}

class PaymentModel extends ChangeNotifier {
  YenepayPaymentResponse _response;
  String _paymentError;
  YenepayPaymentResponse get response => _response;
  set response(YenepayPaymentResponse value) {
    _paymentError = null;
    _response = value;
    notifyListeners();
  }

  String get paymentError => _paymentError;
  set paymentError(String value) {
    _response = null;
    _paymentError = value;
    notifyListeners();
  }

  void setException(PlatformException exception) {
    if (exception != null) {
      paymentError = exception.message;
    }
  }

  bool get hasError => _paymentError != null;
  bool get hasResult => _response != null;
  bool get isCompleted => hasResult && _response.isPaymentCompleted;
  bool get isPending =>
      hasResult && (_response.isPending || _response.isVerifying);
  bool get isCanceled =>
      hasResult && (_response.isCanceled || _response.isVerifying);
  void reset() {
    _response = null;
    _paymentError = null;
    notifyListeners();
  }
}
