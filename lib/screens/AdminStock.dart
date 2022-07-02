import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'AddStock.dart';
import '../models/StockModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminStock extends StatefulWidget {
  final String name;
  final String userType;

  const AdminStock({Key key, this.name, this.userType}) : super(key: key);

  @override
  _AdminStockState createState() => _AdminStockState();
}

bool isLoading = false;
bool isSearching = false;
bool useSearch = false;
int stockLength;
List<StockModel> stocks;
List firstQueryResults = [];
List secondQueryResults = [];
List items;

class _AdminStockState extends State<AdminStock> {
  Future getStock() async {
    setState(() {
      isLoading = true;
    });
    try {
      //Initial Stock
      await Firestore.instance
          .collection("Stocks")
          .orderBy("Date added", descending: true)
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
      Firestore.instance
          .collection("Stocks")
          .orderBy("Date added", descending: true)
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
    //initiateSearch2("");
    getStock();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Stock"),
        backgroundColor: Colors.deepPurple[400],
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => AddStock(
              name: widget.name,
              userType: widget.userType,
            ),
          ),
        ),
        backgroundColor: Colors.deepPurple[400],
        child: Icon(Icons.add),
      ),
      body: Builder(
        builder: (context) => isLoading
            ? Center(child: CircularProgressIndicator())
            : stocks.isEmpty
                ? Center(
                    child: Text("No stocks added"),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        //Bottom App Bar
                        Container(
                          width: double.infinity,
                          height: 120,
                          padding: EdgeInsets.symmetric(horizontal: 18),
                          color: Colors.deepPurple[400],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                      setState(() {
                                        initiateSearch2(val);
                                      });
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
                                      labelStyle:
                                          TextStyle(color: Colors.black38),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 9),
                              Text(
                                "Double tap to delete from stock",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
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
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                      child: Center(child: Text("Name")),
                                    ),
                                    Container(
                                      child: Center(
                                        child: Text("Quantity"),
                                      ),
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                    ),
                                    Container(
                                      child: Center(
                                        child: Text("Price"),
                                      ),
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                    ),
                                    Container(
                                      child: Center(
                                        child: Text("Date"),
                                      ),
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                    ),
                                  ],
                                ),
                              ),
                              ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: stockLength,
                                  itemBuilder: (context, index) {
                                    String name = useSearch
                                        ? items[index]['Name']
                                        : stocks[index].name;
                                    return StockItem(
                                        name: name,
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
                                        remove: () async {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          await Firestore.instance
                                              .collection("Stocks")
                                              .document(name)
                                              .delete();

                                          initiateSearch2("");

                                          setState(() {
                                            isLoading = false;
                                          });

                                          Scaffold.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  name + " has been deleted"),
                                              duration: Duration(seconds: 5),
                                              backgroundColor: Colors.grey[700],
                                            ),
                                          );

                                          print("removed");
                                        });
                                  }),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
      ),
    );
  }
}

class StockItem extends StatelessWidget {
  final String name;
  final String quantity;
  final String price;
  final String date;
  final Function remove;

  const StockItem(
      {Key key, this.name, this.quantity, this.price, this.date, this.remove})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: remove,
      child: Container(
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
      ),
    );
  }
}
