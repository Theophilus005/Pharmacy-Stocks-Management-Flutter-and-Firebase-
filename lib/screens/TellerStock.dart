import 'package:flutter/material.dart';
import '../models/StockModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TellerStock extends StatefulWidget {
  final String type;
  final String date;
  final String name;
  final String userType;

  const TellerStock({Key key, this.type, this.date, this.name, this.userType})
      : super(key: key);

  @override
  _TellerStockState createState() => _TellerStockState();
}

List<StockModel> stocks;
bool isLoading = false;
bool isSearching = false;
bool useSearch = false;
int stockLength;
String date = DateTime.now().toString().substring(0, 10);
List firstQueryResults = [];
List secondQueryResults = [];
List items;

class _TellerStockState extends State<TellerStock> {
  Future getCurrentStock() async {
    setState(() {
      isLoading = true;
    });
    try {
      //Inital stock
      await Firestore.instance
          .collection("Stocks")
          .getDocuments()
          .then((snapshot) => {
                setState(() {
                  stocks = snapshot.documents
                      .map((documents) =>
                          StockModel.fromFirestore(documents.data))
                      .toList();
                  stockLength = stocks.length;
                })
              });

      //Stream
      Firestore.instance.collection("Stocks").snapshots().listen((snapshot) {
        setState(() {
          stocks = snapshot.documents
              .map((documents) => StockModel.fromFirestore(documents.data))
              .toList();
          stockLength = stocks.length;
          isLoading = false;
        });
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future getOpeningStock() async {
    setState(() {
      isLoading = true;
    });
    try {
      //Get initial Stock
      await Firestore.instance
          .collection("Daily Sales")
          .document(widget.date)
          .collection("Opening Stock")
          .getDocuments()
          .then((snapshot) => {
                setState(() {
                  stocks = snapshot.documents
                      .map((documents) =>
                          StockModel.fromFirestore(documents.data))
                      .toList();
                  stockLength = stocks.length;
                })
              });

      Firestore.instance
          .collection("Daily Sales")
          .document(widget.date)
          .collection("Opening Stock")
          .snapshots()
          .listen((snapshot) {
        setState(() {
          stocks = snapshot.documents
              .map((documents) => StockModel.fromFirestore(documents.data))
              .toList();
          stockLength = stocks.length;
          isLoading = false;
        });
      });
    } catch (e) {
      print(e.toString());
    }
  }

  //Stream
  Future getClosingStock() async {
    setState(() {
      isLoading = true;
    });
    try {
      //Get initial Stock
      await Firestore.instance
          .collection("Daily Sales")
          .document(widget.date)
          .collection("Closing Stock")
          .getDocuments()
          .then((snapshot) => {
                setState(() {
                  stocks = snapshot.documents
                      .map((documents) =>
                          StockModel.fromFirestore(documents.data))
                      .toList();
                  stockLength = stocks.length;
                })
              });

      Firestore.instance
          .collection("Daily Sales")
          .document(widget.date)
          .collection("Closing Stock")
          .snapshots()
          .listen((snapshot) {
        setState(() {
          stocks = snapshot.documents
              .map((documents) => StockModel.fromFirestore(documents.data))
              .toList();
          stockLength = stocks.length;
          isLoading = false;
        });
      });
    } catch (e) {
      print(e.toString());
    }
  }

  //Searches Opening/Closing Stock
  initiateSearch1(String value, String type) async {
    if (value.length == 0) {
      setState(() {
        stockLength = stocks.length;
        firstQueryResults = [];
        secondQueryResults = [];
        useSearch = false;
        isSearching = false;
      });
    }

    var capitalizedValue =
        value.substring(0, 1).toUpperCase() + value.substring(1);

    if (firstQueryResults.length == 0 && value.length == 1) {
      await Firestore.instance
          .collection("Daily Sales")
          .document(widget.date)
          .collection(type + " Stock")
          .where("Search Key", isEqualTo: value.substring(0, 1).toUpperCase())
          .getDocuments()
          .then((QuerySnapshot docs) {
        for (int i = 0; i < docs.documents.length; ++i) {
          setState(() {
            firstQueryResults.add(docs.documents[i].data);
          });
          print(capitalizedValue);
        }
        setState(() {
          useSearch = true;
          isSearching = false;
          stockLength = firstQueryResults.length;
          items = firstQueryResults;
        });
      });
    } else {
      secondQueryResults = [];
      firstQueryResults.forEach((element) {
        if (element['Name'].startsWith(capitalizedValue)) {
          setState(() {
            secondQueryResults.add(element);
            print(capitalizedValue);
          });
        }
      });
      setState(() {
        useSearch = true;
        stockLength = secondQueryResults.length;
        items = secondQueryResults;
        isSearching = false;
      });
    }
  }

  //Searches current stock
  initiateSearch2(String value) async {
    if (value.length == 0) {
      setState(() {
        stockLength = stocks.length;
        firstQueryResults = [];
        secondQueryResults = [];
        useSearch = false;
        isSearching = false;
      });
    }

    var capitalizedValue =
        value.substring(0, 1).toUpperCase() + value.substring(1);

    if (firstQueryResults.length == 0 && value.length == 1) {
      setState(() {
        isSearching = true;
      });
      await Firestore.instance
          .collection("Stocks")
          .where("Search Key", isEqualTo: value.substring(0, 1).toUpperCase())
          .getDocuments()
          .then((QuerySnapshot docs) {
        for (int i = 0; i < docs.documents.length; ++i) {
          setState(() {
            firstQueryResults.add(docs.documents[i].data);
          });
          print(capitalizedValue);
        }
        setState(() {
          useSearch = true;
          isSearching = false;
          stockLength = firstQueryResults.length;
          items = firstQueryResults;
        });
      });
      print(firstQueryResults);
    } else {
      secondQueryResults = [];
      firstQueryResults.forEach((element) {
        if (element['Name'].startsWith(capitalizedValue)) {
          setState(() {
            secondQueryResults.add(element);
            print(secondQueryResults);
          });
        }
      });
      setState(() {
        useSearch = true;
        stockLength = secondQueryResults.length;
        items = secondQueryResults;
        isSearching = false;
      });
    }
  }

  @override
  void initState() {
    if (widget.type == "Current") {
      getCurrentStock();
    } else if (widget.type == "Opening") {
      getOpeningStock();
    } else {
      getClosingStock();
    }

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.type + " Stock"),
          backgroundColor: Colors.deepPurple[400],
          elevation: 0,
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : stocks.isEmpty ? Center(
              child: Text("No stock available"),
            ) : SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    //Bottom App Bar
                    Container(
                      width: double.infinity,
                      height: 100,
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      color: Colors.deepPurple[400],
                      child: Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                widget.userType.toUpperCase() +
                                    ": " +
                                    widget.name,
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Container(
                            child: Center(
                              child: TextFormField(
                                onChanged: (val) {
                                  if (widget.type != "Current") {
                                    initiateSearch1(val, widget.type);
                                  } else {
                                    initiateSearch2(val);
                                  }
                                },
                                cursorColor: Colors.white,
                                autofocus: false,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                  focusColor: Colors.white,
                                  fillColor: Colors.white,
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.white,
                                  ),
                                  hintText: "Search stock...",
                                  hintStyle: TextStyle(color: Colors.white),
                                  labelStyle: TextStyle(color: Colors.black38),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    isSearching
                        ? Container(
                            width: double.infinity,
                            height: 250,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Container(
                            width: double.infinity,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  color: Colors.grey,
                                  height: 40,
                                  width: double.infinity,
                                  margin: EdgeInsets.symmetric(horizontal: 3),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.2,
                                        child: Center(child: Text("Name")),
                                      ),
                                      Container(
                                        child: Center(
                                          child: Text("Quantity"),
                                        ),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.2,
                                      ),
                                      Container(
                                        child: Center(
                                          child: Text("Price"),
                                        ),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.2,
                                      ),
                                      Container(
                                        child: Center(
                                          child: Text("Date"),
                                        ),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.2,
                                      ),
                                    ],
                                  ),
                                ),
                                ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: stockLength,
                                    itemBuilder: (context, index) {
                                      return StockItem(
                                        name: useSearch
                                            ? items[index]['Name']
                                            : stocks[index].name,
                                        quantity: useSearch
                                            ? items[index]['Quantity']
                                            : stocks[index].quantity,
                                        price: double.parse(useSearch
                                                ? items[index]['Price']
                                                : stocks[index].price)
                                            .toStringAsFixed(2),
                                        date: useSearch
                                            ? items[index]['Date added']
                                            : stocks[index].date,
                                      );
                                    }),
                              ],
                            ),
                          )
                  ],
                ),
              ));
  }
}

class StockItem extends StatelessWidget {
  final String name;
  final String quantity;
  final String price;
  final String date;

  const StockItem({Key key, this.name, this.quantity, this.price, this.date})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 8),
      color: Colors.grey[200],
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.2,
                child: Center(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              Container(
                child: Center(
                  child: Text(
                    quantity,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
                width: MediaQuery.of(context).size.width * 0.2,
              ),
              Container(
                child: Center(
                  child: Text(
                    "¢" + price,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
                width: MediaQuery.of(context).size.width * 0.2,
              ),
              Container(
                child: Center(
                  child: Text(
                    date,
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                width: MediaQuery.of(context).size.width * 0.2,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
