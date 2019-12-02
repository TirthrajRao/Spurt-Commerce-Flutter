import 'package:flutter/material.dart';
import 'package:spurtcommerce/screens/cartView.dart';
import 'package:spurtcommerce/screens/drawer.dart';
import 'package:spurtcommerce/screens/bottomTab.dart';

void main() {
  runApp(new CartScreen());
}

class CartScreen extends StatefulWidget {
  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      drawer: DrawerScreen(),
      // bottomNavigationBar: BottomTabScreen(),
      appBar: new AppBar(
        title: new Text('Cart'),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed("/wishlist");
            },
            child: Icon(
              Icons.favorite,
              color: Colors.white,
              size: 24.0,
            ),
          ),
        ],
      ),
      body: Center(child: CartView()),
    );
  }
}
