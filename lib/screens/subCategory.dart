import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:spurtcommerce/config.dart' as config;
import 'package:carousel_pro/carousel_pro.dart';
import 'package:spurtcommerce/screens/categoryProductlist.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:spurtcommerce/screens/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SubCategoryScreen extends StatefulWidget {
  final id;
  final name;
  SubCategoryScreen({Key key, @required this.id, this.name}) : super(key: key);

  @override
  SubCategoryScreenState createState() => SubCategoryScreenState();
}

class SubCategoryScreenState extends State<SubCategoryScreen> {
  List bannreData;
  bool loader = false;
  List subcategoryList;
 List<String> count_cart;
  List<String> count_wishlist;
  List image;

  @override
  void initState() {
    super.initState();
    this.getJSONData();
    this.getSubCategory();
    this.getimg();
    this.getCount();
  }
  getCount() async {
    final prefs = await SharedPreferences.getInstance();
    count_wishlist = prefs.getStringList('id_wishlist') ?? List<String>();
    count_cart = prefs.getStringList('obj_list') ?? List<String>();
    print(
        ">>>>>>>>${count_wishlist.length}>>home>>>>>length of obj list====${count_cart.length}");
  }
/*
 Set static image for sub category list 
 */
  getimg() {
    if (this.widget.name == "ELECTRONICS") {
      image = [
        'assets/electronics/mobile.png',
        'assets/electronics/laptop.jpg',
        'assets/electronics/headphone.jpg',
        'assets/electronics/tv.jpg'
      ];
    } else if (this.widget.name == "MEN's FASHION") {
      image = [
        'assets/men/menwatch.jpg',
        'assets/men/menclothes.jpg',
        'assets/men/shoesmen.jpg',
        'assets/men/shortswear.jpg',
      ];
    } else if (this.widget.name == "BABY & KIDS") {
      image = [
        'assets/baby/toys.jpg',
        'assets/baby/boycloths.jpg',
        'assets/baby/girlcloths.jpg',
        'assets/baby/kidbag.jpeg',
      ];
    } else if (this.widget.name == "SPORTS") {
      image = [
        'assets/sports/cricket.jpg',
        'assets/sports/cycling.jpeg',
        'assets/sports/badminton.jpg',
        'assets/sports/football.jpg',
      ];
    } else if (this.widget.name == "HOME DECOR & FURNITURE") {
      image = [
        'assets/home/kitchen.jpg',
        'assets/home/furnichar.jpeg',
        'assets/home/decore.jpg',
        'assets/home/lighting.jpg',
      ];
    } else if (this.widget.name == "WOMEN FASHION") {
      image = [
        'assets/women/watch.webp',
        'assets/women/clothes.jpg',
        'assets/women/shoes.jpg',
        'assets/women/shortwear.jpg',
      ];
    }
  }

/*
   For Banner image 
 */
  Future<String> getJSONData() async {
    var response = await http.get(
        Uri.encodeFull(config.baseUrl + 'list/banner-list'),
        headers: {"Accept": "application/json"});
    setState(() {
      bannreData = json.decode(response.body)['data'];
    });
    loader = true;
    return "Successfull";
  }

  /*
 
  For sub category list
 */
  Future<String> getSubCategory() async {
    var id = this.widget.id;
    var subcategory;
    var response = await http.get(
        Uri.encodeFull(config.baseUrl + 'list/category-list'),
        headers: {"Accept": "application/json"});
    var category = json.decode(response.body)['data'];

    for (var i = 0; i <= await category.length; i++) {
      if (id == category[i]['children'][0]['parentInt']) {
        subcategory = await category[i]['children'];
      }
      setState(() {
        subcategoryList = subcategory;
      });
    }

    loader = true;
    return "Successfull";
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      drawer: DrawerScreen(),
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
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 3.5,
                            width: MediaQuery.of(context).size.width,
                            child: Carousel(
                              images: [
                                NetworkImage(config.mediaUrlBanner +
                                    '${bannreData[0]['image']}'),
                                NetworkImage(config.mediaUrlBanner +
                                    '${bannreData[1]['image']}'),
                                NetworkImage(config.mediaUrlBanner +
                                    '${bannreData[2]['image']}'),
                                NetworkImage(config.mediaUrlBanner +
                                    '${bannreData[3]['image']}'),
                                NetworkImage(config.mediaUrlBanner +
                                    '${bannreData[4]['image']}'),
                              ],
                              dotSpacing: 15.0,
                              dotBgColor: Colors.black.withOpacity(0.0),
                              borderRadius: false,
                              boxFit: BoxFit.fill,
                            )),
                      ])),
                      SliverList(
                        delegate: SliverChildListDelegate([
                          Column(
                            children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: new Container(
                                    margin: const EdgeInsets.only(
                                        left: 20.0,
                                        right: 20.0,
                                        top: 20.0,
                                        bottom: 20),
                                    child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'New Arrivals',
                                          style: TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )),
                                  )),
                            ],
                          ),
                        ]),
                      ),
                      SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 0.0,
                            crossAxisSpacing: 0.0,
                          ),
                          delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                            if (index <= 3) {
                              return new Container(
                                  child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CategoryProductlistScreen(
                                          id: '${subcategoryList[index]["categoryId"]}',
                                          name:
                                              '${subcategoryList[index]['name']}',
                                        ),
                                      ));
                                },
                                child: SizedBox(
                                  child: new Card(
                                    elevation: 5.0,
                                    child: new Container(
                                      alignment: Alignment.center,
                                      child: Column(
                                        children: [
                                          new Container(
                                            child: Image.asset(image[index],
                                                width: 150,
                                                height: 150,
                                                fit: BoxFit.fitWidth),
                                          ),
                                          new Divider(),
                                          Text(
                                            '${subcategoryList[index]['name']}',
                                            style: TextStyle(
                                              fontSize: 15.0,
                                              color: Colors.black,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ));
                            }
                          }, childCount: subcategoryList.length)),
                    ],
                  )
                : Align(
                    alignment: Alignment.center,
                    child: SpinKitCircle(color: Colors.deepPurple),
                  )));
  }
}
