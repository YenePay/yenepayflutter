import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:yenepayflutter/yenepayflutter.dart';
import '../models.dart';

class Shop extends StatelessWidget {
  final _products = Product.generateProducts();
  @override
  Widget build(BuildContext context) {
    var _cart = context.watch<ShoppingCart>();
    var _paymentModel = Provider.of<PaymentModel>(context, listen: false);
    var _count = _cart.getItemsCount;
    var _iconColor = _count > 0 ? Colors.red : Colors.white;
    return Scaffold(
      appBar: AppBar(
        title: const Text('YenePay Flutter Example'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: _iconColor),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Center(
        child: ListView.builder(
          itemCount: _products.length,
          itemBuilder: (BuildContext context, int index) {
            return ProductCard(
              item: _products[index],
              onCartTap: (product) {
                _cart.addItem(CartItem(product, 1));
              },
              onBuyTap: (product) async {
                var request = product.generatePayment(_cart.settings);
                try {
                  await Yenepayflutter.requestPayment(request);
                } on PlatformException catch (e) {
                  _paymentModel.setException(e);
                  Navigator.pushNamed(context, '/payment');
                }
              },
            );
          },
        ),
      ),
    );
  }
}
