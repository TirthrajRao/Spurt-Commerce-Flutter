import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:spurtcommerce/config.dart' as config;
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spurtcommerce/screens/cart.dart';
import 'package:spurtcommerce/screens/home.dart';
import 'package:spurtcommerce/screens/wishlist.dart';
import 'package:toast/toast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ProductViewScreen extends StatefulWidget {
  final id;
  final name;
  ProductViewScreen({Key key, @required this.id, this.name}) : super(key: key);
  @override
  ProductViewScreenState createState() => ProductViewScreenState();
}

class ProductViewScreenState extends State<ProductViewScreen> {
  List product;
  List productImage;
  bool isaddtocart = true;
  bool iswishlisted = true;
  bool loader = false;
  dynamic qty = 1;
  var obj;
  var objPrice;
  List<dynamic> listobj = [];
  List<dynamic> listprice = [];
    List<String> count_cart;
  List<String> count_wishlist;

  @override
  void initState() {
    super.initState();
    this.getProduct(); // Function for get product details
    this.checkinCartid();
    this.getCount();
  }
 getCount() async {
    final prefs = await SharedPreferences.getInstance();
    count_wishlist = prefs.getStringList('id_wishlist') ?? List<String>();
    count_cart = prefs.getStringList('obj_list') ?? List<String>();
    print(
        ">>>>>>>>${count_wishlist.length}>>home>>>>>length of obj list====${count_cart.length}");
  }
/** This function for check  product added or not in wishlist and cart */
  checkinCartid() async {
    var id = this.widget.id;
    final prefs = await SharedPreferences.getInstance();
    List<String> show_id = prefs.getStringList('id_list') ?? List<String>();
    List<String> list = show_id;
    List<String> show_wishlist =
        prefs.getStringList('id_wishlist') ?? List<String>();

    //For cart
    var n = list.contains(id);
    if (n == true) {
      setState(() {
        isaddtocart = false;
      });
    } else {
      setState(() {
        iswishlisted = true;
      });
    }
// For wishlist
    var listid = show_wishlist.contains(id);
    if (listid == true) {
      setState(() {
        iswishlisted = false;
      });
    } else {
      setState(() {
        iswishlisted = true;
      });
    }
  }

/*
 *  Fetch Product get by id
 */
  Future<String> getProduct() async {
    var id = this.widget.id;
    var response = await http.get(
        Uri.encodeFull(config.baseUrl + 'product-store/productdetail/$id'),
        headers: {"Accept": "application/json"});
    setState(() {
      product = json.decode(response.body)['data'];
    });

    setState(() {
      productImage = product[0]['productImage'];
    });
    // final prefs = await SharedPreferences.getInstance();
    loader = true;
    return "Successfull";
  }

/*
 *  save qty value when click on Add to cart button  
 * store Array(id,qty,price,updatedqty) in SharedPreferences
*/
  _saveQtyValue(id, price, name, model) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> show_obj = prefs.getStringList('obj_list') ?? List<String>();
    listobj = show_obj;

    obj = {
      'productId': id,
      'quantity': qty,
      'price': price,
      'updatedPrice': price,
      'name': name,
      'model': model
    };

    listobj.add(json.encode(obj));
    prefs.setStringList('obj_list', listobj);

    List<String> show_id = prefs.getStringList('id_list') ?? List<String>();
    List<String> list = show_id;
    list.add(id);
    prefs.setStringList('id_list', list);
    Toast.show("Added to cart", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);

    setState(() {
      isaddtocart = false;
    });

  
  }

/*
* add to wishlist when click on favorite icon
 */
  addtowishlist(id) async {
    final prefs = await SharedPreferences.getInstance();
    var show_token = prefs.getString('jwt_token');

    if (show_token == null) {
      Navigator.of(context).pushNamed("/login");
    } else {
      List<String> show_wishid =
          prefs.getStringList('id_wishlist') ?? List<String>();

      List<String> wishlist = show_wishid;
      wishlist.add(id);
      prefs.setStringList('id_wishlist', wishlist);
      // wishlist api call
      var response = await http.post(
        config.baseUrl + 'customer/add-product-to-wishlist',
        headers: {"Authorization": json.decode(show_token)},
        body: {'productId': id},
      );

      loader = true;
      setState(() {
        iswishlisted = false;
      });
     
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(this.widget.name),
          actions: [
              Container(
              margin: EdgeInsets.fromLTRB(0, 0, 25, 0),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed("/cart");
                    },
                    child: Stack(
                      children: <Widget>[
                        IconButton(
                            icon: Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                        )),
                        new Positioned(
                          right: 9,
                          top: 5,
                          child: new Container(
                            padding: EdgeInsets.all(2),
                            decoration: new BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            child: Text(
                              '${count_cart.length}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed("/wishlist");
                    },
                    child: Stack(
                      children: <Widget>[
                        new IconButton(
                            icon: Icon(
                          Icons.favorite,
                          color: Colors.white,
                        )),
                        new Positioned(
                          right: 9,
                          top: 5,
                          child: new Container(
                            padding: EdgeInsets.all(2),
                            decoration: new BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            child: Text(
                              '${count_wishlist.length}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        body: Center(
            child: loader == true
                ? CustomScrollView(
                    slivers: <Widget>[
                      SliverList(
                          delegate: SliverChildListDelegate([
                        Column(children: [
                          CarouselSlider(
                            height: 200.0,
                            items: productImage.map((i) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 5.0),
                                      child: Image.network(
                                          config.mediaUrl +
                                              '${i['containerName']}' +
                                              '${i['image']}',
                                          width: 250,
                                          height: 200,
                                          fit: BoxFit.fill));
                                },
                              );
                            }).toList(),
                          ),
                        ]),
                      ])),
                      SliverList(
                          delegate: SliverChildListDelegate([
                        Row(children: <Widget>[
                          Expanded(
                            child: SizedBox(
                                height: 700.0,
                                child: new ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: product.length,
                                  itemBuilder: (BuildContext ctxt, int i) {
                                    return SizedBox(
                                      child: Card(
                                        color: Colors.grey[200],
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              right: 5.0, left: 5.0),
                                          child: new Container(
                                              margin: EdgeInsets.all(10),
                                              child: Column(
                                                children: <Widget>[
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      '${product[i]['name']}',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                          fontSize: 15.0),
                                                    ),
                                                  ),
                                                  new Divider(),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      'Category: ${product[i]['Category'][0]['categoryName']}',
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: TextStyle(
                                                          fontSize: 15.0),
                                                    ),
                                                  ),
                                                  new Divider(),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      'Availability : ${product[i]['price']}',
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: TextStyle(
                                                          fontSize: 15.0),
                                                    ),
                                                  ),
                                                  new Divider(),
                                                  Align(
                                                      child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Column(
                                                        children: <Widget>[
                                                          Text(
                                                            'Rs. : ${product[i]['price']}',
                                                            textAlign:
                                                                TextAlign.right,
                                                            style: TextStyle(
                                                                fontSize: 15.0,
                                                                color:
                                                                    Colors.red),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  )),
                                                  new Divider(),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: <Widget>[
                                                      iswishlisted == true
                                                          ? FlatButton(
                                                              onPressed: () => {
                                                                addtowishlist(
                                                                    '${product[i]['productId']}')
                                                              },
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                          10.0),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: <
                                                                    Widget>[
                                                                  Icon(Icons
                                                                      .favorite_border),
                                                                  Text(
                                                                    "    Wishlist",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  )
                                                                ],
                                                              ),
                                                            )
                                                          : FlatButton(
                                                              onPressed: () => {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              WishlistScreen(),
                                                                    )),
                                                              },
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                          10.0),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: <
                                                                    Widget>[
                                                                  Icon(Icons
                                                                      .favorite),
                                                                  Text(
                                                                    "    Wishlisted",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                      // Flexible(fit: FlexFit.tight, child: SizedBox()),
                                                      new VerticalDivider(
                                                          color: Colors.black),
                                                      Align(
                                                          child:
                                                              isaddtocart ==
                                                                      true
                                                                  ? FlatButton(
                                                                      onPressed:
                                                                          () =>
                                                                              {
                                                                        _saveQtyValue(
                                                                            '${product[i]['productId']}',
                                                                            '${product[i]['price']}',
                                                                            '${product[i]['name']}',
                                                                            '${product[i]['metaTagTitle']}')
                                                                      },
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              10.0),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: <
                                                                            Widget>[
                                                                          Icon(Icons
                                                                              .shopping_cart),
                                                                          Text(
                                                                              "   Add to Cart",
                                                                              style: TextStyle(fontWeight: FontWeight.bold))
                                                                        ],
                                                                      ),
                                                                    )
                                                                  : FlatButton(
                                                                      onPressed:
                                                                          () =>
                                                                              {
                                                                        Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (context) => CartScreen(),
                                                                            ))
                                                                      },
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              10.0),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: <
                                                                            Widget>[
                                                                          Icon(Icons
                                                                              .shopping_basket),
                                                                          Text(
                                                                              "   Go to Cart",
                                                                              style: TextStyle(fontWeight: FontWeight.bold))
                                                                        ],
                                                                      ),
                                                                    )),
                                                    ],
                                                  ),
                                                  new Divider(),
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Text(
                                                      'Description',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Html(
                                                        data:
                                                            '${product[i]['description']}',
                                                      )),
                                                ],
                                              )),
                                        ),
                                      ),
                                    );
                                  },
                                )),
                          ),
                        ]),
                      ])),
                    ],
                  )
                : Align(
                    alignment: Alignment.center,
                    child: SpinKitCircle(color: Colors.deepPurple),
                  )));
  }
}
