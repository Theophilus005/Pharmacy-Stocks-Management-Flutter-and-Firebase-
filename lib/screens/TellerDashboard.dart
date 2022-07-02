import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'TotalSales.dart';
import 'TellerStock.dart';
import 'Transactions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/TransactionModel.dart';
import '../models/StockModel.dart';
import 'ChangePassword.dart';

class TellerDashboard extends StatefulWidget {
  final String name;
  final String userType;

  const TellerDashboard({Key key, this.name, this.userType}) : super(key: key);

  @override
  _TellerDashboardState createState() => _TellerDashboardState();
}

String date = DateTime.now().toString().substring(0, 10);
bool isLoading = false;

List<TransactionModel> transactions;
List<StockModel> closingStocks;
List openingStocks;

double totalSales = 0;
int openingStockCount = 0;
int closingStockCount = 0;

class _TellerDashboardState extends State<TellerDashboard> {
  Future getTransactions() async {
    setState(() {
      isLoading = true;
    });

    try {
      //Initial Stock
      await Firestore.instance
          .collection("Daily Sales")
          .document(date)
          .collection("Transactions")
          .getDocuments()
          .then((snapshot) => {
                setState(() {
                  transactions = snapshot.documents
                      .map((documents) =>
                          TransactionModel.fromFirestore(documents.data))
                      .toList();
                  calculateTotalSales();
                })
              });

      //Stream
      Firestore.instance
          .collection("Daily Sales")
          .document(date)
          .collection("Transactions")
          .snapshots()
          .listen((snapshot) {
        setState(() {
          transactions = snapshot.documents
              .map(
                  (documents) => TransactionModel.fromFirestore(documents.data))
              .toList();
          calculateTotalSales();
          isLoading = false;
        });
      });
    } catch (e) {
      print(e.toString());
    }
  }

  calculateTotalSales() {
    totalSales = 0;
    for (int i = 0; i < transactions.length; i++) {
      totalSales = totalSales + transactions[i].price;
    }
  }

  calculateOpeningStock(int length, List stocks) {
    openingStockCount = 0;
    for (int i = 0; i < length; i++) {
      openingStockCount =
          openingStockCount + int.parse(stocks[i].data["Quantity"]);
    }
  }

  calculateClosingStock(int length, List stocks) {
    closingStockCount = 0;
    for (int i = 0; i < length; i++) {
      closingStockCount = closingStockCount + int.parse(stocks[i].quantity);
    }
  }

  Future setStocks() async {
    setState(() {
      isLoading = true;
    });

    //Check if stocks is set;
    var status = await Firestore.instance
        .collection("Daily Sales")
        .document(date)
        .collection("Stock States")
        .document("Data")
        .get();

    //Check and set stocks
    if (status.data == null ||
        status.data["Opening Stock"] != "complete" ||
        status.data["Closing Stock"] != "complete") {
      //Fetching from the main stocks
      var openStocks =
          await Firestore.instance.collection("Stocks").getDocuments();

      //Set opening stock
      for (int i = 0; i < openStocks.documents.length; i++) {
        await Firestore.instance
            .collection("Daily Sales")
            .document(date)
            .collection("Opening Stock")
            .document(openStocks.documents[i].documentID)
            .setData(openStocks.documents[i].data);
      }

      //Set closing stock
      for (int i = 0; i < openStocks.documents.length; i++) {
        await Firestore.instance
            .collection("Daily Sales")
            .document(date)
            .collection("Closing Stock")
            .document(openStocks.documents[i].documentID)
            .setData(openStocks.documents[i].data);
      }

      //Set stock completion
      await Firestore.instance
          .collection("Daily Sales")
          .document(date)
          .collection("Stock States")
          .document("Data")
          .setData({
        'Opening Stock': 'complete',
        'Closing Stock': 'complete',
      });

      //Update Daily Report
      await Firestore.instance
          .collection("Daily Report")
          .document(date)
          .setData({
        "Date": date,
      });

      print("Stocks set");

      setState(() {
        isLoading = false;
        calculateOpeningStock(
            openStocks.documents.length, openStocks.documents);

        closingStockCount = openingStockCount;
      });
    } else {
      print("Stocks already set");

      await getOpeningStock();
      await getClosingStock();

      setState(() {
        isLoading = false;
      });
    }
  }

  Future getClosingStock() async {
    setState(() {
      isLoading = true;
    });
    try {
      //Initial Stock
      await Firestore.instance
          .collection("Daily Sales")
          .document(date)
          .collection("Closing Stock")
          .getDocuments()
          .then((snapshot) => {
                setState(() {
                  closingStocks = snapshot.documents
                      .map((documents) =>
                          StockModel.fromFirestore(documents.data))
                      .toList();
                  calculateClosingStock(closingStocks.length, closingStocks);
                })
              });

      //Stream
      Firestore.instance
          .collection("Daily Sales")
          .document(date)
          .collection("Closing Stock")
          .snapshots()
          .listen((snapshot) {
        setState(() {
          closingStocks = snapshot.documents
              .map((documents) => StockModel.fromFirestore(documents.data))
              .toList();
          calculateClosingStock(closingStocks.length, closingStocks);
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

    var getOpenStocks = await Firestore.instance
        .collection("Daily Sales")
        .document(date)
        .collection("Opening Stock")
        .getDocuments();

    setState(() {
      openingStocks = getOpenStocks.documents;
      calculateOpeningStock(openingStocks.length, openingStocks);
      isLoading = false;
    });
  }

  @override
  void initState() {
    setStocks();
    getTransactions();

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Teller Dashboard"),
          backgroundColor: Colors.deepPurple[400],
          elevation: 0,
        ),
        drawer: Drawer(
          child: SafeArea(
            child: Menu(
              route: () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => ChangePassword(
                    name: widget.name,
                    userType: widget.userType,
                  ),
                ),
              ),
            ),
          ),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: <Widget>[
                    //Bottom App Bar
                    Container(
                      width: double.infinity,
                      height: 36,
                      padding: EdgeInsets.only(left: 18),
                      color: Colors.deepPurple[400],
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.userType.toUpperCase() + ": " + widget.name,
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),

                    //Main body
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                FontAwesomeIcons.calendar,
                                size: 25,
                              ),
                              SizedBox(width: 5),
                              Container(
                                margin: EdgeInsets.only(top: 5),
                                child: Text(
                                  "Today",
                                  style: TextStyle(fontSize: 22),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 5),
                            child: Text(
                              date,
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Panel(
                      name: "Total Sales",
                      icon: Icon(FontAwesomeIcons.moneyBill,
                          size: 30, color: Colors.white),
                      type: "Report",
                      figure: "GH¢" + totalSales.toStringAsFixed(2),
                      color: Colors.green[400],
                      route: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => TotalSales(
                            name: widget.name,
                            userType: widget.userType,
                          ),
                        ),
                      ),
                    ),
                    Panel(
                      name: "Transactions",
                      icon: Icon(FontAwesomeIcons.bookMedical,
                          size: 30, color: Colors.white),
                      type: "Sell",
                      figure: "Count: " + transactions.length.toString(),
                      color: Colors.orange[500],
                      route: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => Transactions(
                            name: widget.name,
                            userType: widget.userType,
                          ),
                        ),
                      ),
                    ),
                    Panel(
                      name: "Opening Stock",
                      icon: Icon(Icons.arrow_upward,
                          size: 40, color: Colors.white),
                      type: "Items",
                      figure: "Total Stock: " + openingStockCount.toString(),
                      color: Colors.red[400],
                      route: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => TellerStock(
                            type: "Opening",
                            name: widget.name,
                            userType: widget.userType,
                            date: date,
                          ),
                        ),
                      ),
                    ),

                    Panel(
                      name: "Closing Stock",
                      icon: Icon(Icons.arrow_downward,
                          size: 40, color: Colors.white),
                      type: "Items",
                      figure:
                          "Remaining Stock : " + closingStockCount.toString(),
                      color: Colors.blue[400],
                      route: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => TellerStock(
                            type: "Closing",
                            name: widget.name,
                            userType: widget.userType,
                            date: date,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 5),

                    //Copyright
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.copyright,
                            size: 20,
                            color: Colors.grey[500],
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Mariam Adam License Chemical Drugs, " +
                                DateTime.now().year.toString(),
                            style: TextStyle(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ));
  }
}

class Panel extends StatelessWidget {
  final String name;
  final Icon icon;
  final String type;
  final String figure;
  final Color color;
  final Function route;

  const Panel(
      {Key key,
      this.name,
      this.icon,
      this.type,
      this.figure,
      this.color,
      this.route})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return //Buttons
        GestureDetector(
      onTap: route,
      child: Container(
        width: double.infinity,
        height: 120,
        margin: EdgeInsets.only(left: 10, right: 10, bottom: 17),
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                  ),
                ),
                Padding(
                  padding: name == "Total Sales"
                      ? EdgeInsets.only(right: 8.0)
                      : EdgeInsets.only(right: 0),
                  child: icon,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  type,
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
                Text(
                  figure,
                  style: TextStyle(color: Colors.white, fontSize: 23),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Menu extends StatelessWidget {
  final Function route;

  const Menu({Key key, this.route}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.deepPurple[400],
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 50),
          Text(
            "Account",
            style: TextStyle(color: Colors.white, fontSize: 17),
          ),
          SizedBox(height: 15),
          GestureDetector(
            onTap: route,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              width: double.infinity,
              height: 45,
              padding: EdgeInsets.only(left: 10),
              child: Row(
                children: <Widget>[
                  Icon(Icons.lock, size: 30, color: Colors.purple),
                  SizedBox(width: 5),
                  Text(
                    "Change password",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
