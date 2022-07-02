import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'TotalSales.dart';
import 'AdminStock.dart';
import 'DailyReport.dart';
import 'ManageStaff.dart';
import '../models/StockModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/TransactionModel.dart';
import '../models/usersModel.dart';
import 'ChangePassword.dart';

class AdminDashboard extends StatefulWidget {
  final String name;
  final String level;
  final String userType;

  const AdminDashboard({Key key, this.name, this.level, this.userType})
      : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

String date = DateTime.now().toString().substring(0, 10);
bool isLoading = false;
int stockTotal = 0;
double totalSales = 0;
int transactionsToday = 0;
List<StockModel> stocks;
List<TransactionModel> transactions;
List<UsersModel> administrators;
List<UsersModel> tellers;

class _AdminDashboardState extends State<AdminDashboard> {
  Future getStock() async {
    setState(() {
      isLoading = true;
    });

    try {
      //Initial
      await Firestore.instance
          .collection("Stocks")
          .getDocuments()
          .then((snapshot) => {
                setState(() {
                  stocks = snapshot.documents
                      .map((documents) =>
                          StockModel.fromFirestore(documents.data))
                      .toList();
                  getStockTotal();
                })
              });

      //Stream
      Firestore.instance.collection("Stocks").snapshots().listen((snapshot) {
        setState(() {
          stocks = snapshot.documents
              .map((documents) => StockModel.fromFirestore(documents.data))
              .toList();
          getStockTotal();
          isLoading = false;
        });
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future getAdministrators() async {
    setState(() {
      isLoading = true;
    });

    try {
      //Initial
      await Firestore.instance
          .collection("Administrators")
          .getDocuments()
          .then((snapshot) => {
                setState(() {
                  administrators = snapshot.documents
                      .map((documents) =>
                          UsersModel.fromFirestore(documents.data))
                      .toList();
                })
              });

      //Stream
      Firestore.instance
          .collection("Administrators")
          .snapshots()
          .listen((snapshot) {
        setState(() {
          administrators = snapshot.documents
              .map((documents) => UsersModel.fromFirestore(documents.data))
              .toList();
          isLoading = false;
        });
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future getTellers() async {
    setState(() {
      isLoading = true;
    });

    try {
      //Initial
      await Firestore.instance
          .collection("Tellers")
          .getDocuments()
          .then((snapshot) => {
                setState(() {
                  tellers = snapshot.documents
                      .map((documents) =>
                          UsersModel.fromFirestore(documents.data))
                      .toList();
                })
              });

      //Stream
      Firestore.instance.collection("Tellers").snapshots().listen((snapshot) {
        setState(() {
          tellers = snapshot.documents
              .map((documents) => UsersModel.fromFirestore(documents.data))
              .toList();
          isLoading = false;
        });
      });
    } catch (e) {
      print(e.toString());
    }
  }

  //Calculate Total Sales
  calculateTotalSales() {
    totalSales = 0;
    for (int i = 0; i < transactions.length; i++) {
      totalSales = totalSales + transactions[i].price;
    }
  }

  //Get Transactions
  Future getTransactionsToday() async {
    setState(() {
      isLoading = true;
    });

    try {
      //Initail
      await Firestore.instance
          .collection("Daily Sales")
          .document(date)
          .collection("Transactions")
          .orderBy("Time", descending: true)
          .getDocuments()
          .then((snapshot) => {
                setState(() {
                  transactions = snapshot.documents
                      .map((documents) =>
                          TransactionModel.fromFirestore(documents.data))
                      .toList();
                  transactionsToday = transactions.length;
                  calculateTotalSales();
                })
              });

      //Stream
      Firestore.instance
          .collection("Daily Sales")
          .document(date)
          .collection("Transactions")
          .orderBy("Time", descending: true)
          .snapshots()
          .listen((snapshot) {
        setState(() {
          transactions = snapshot.documents
              .map(
                  (documents) => TransactionModel.fromFirestore(documents.data))
              .toList();
          transactionsToday = transactions.length;
          calculateTotalSales();
          isLoading = false;
        });
        //getStockTotal();
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void getStockTotal() {
    stockTotal = 0;
    for (int i = 0; i < stocks.length; i++) {
      stockTotal = stockTotal + int.parse(stocks[i].quantity);
    }
    setState(() {});
  }

  @override
  void initState() {
    getStock();
    getTransactionsToday();
    getAdministrators();
    getTellers();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Admin Dashboard"),
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
                          SizedBox(
                            width: 20,
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
                    SizedBox(height: 20),
                    Panel(
                      name: "Sales Today",
                      icon: Icon(FontAwesomeIcons.moneyBill,
                          size: 30, color: Colors.white),
                      type: "Report",
                      figure: "GH¢" + totalSales.toStringAsFixed(2),
                      color: Colors.green[400],
                      route: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => TotalSales(
                            user: "Admin",
                            userType: widget.userType,
                            name: widget.name,
                          ),
                        ),
                      ),
                    ),
                    Panel(
                      name: "Daily Report",
                      icon: Icon(FontAwesomeIcons.chartLine,
                          size: 30, color: Colors.white),
                      type: "Report",
                      figure: "Transactions: " + transactionsToday.toString(),
                      color: Colors.orange[500],
                      route: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => DailyReport(
                            name: widget.name,
                            userType: widget.userType,
                          ),
                        ),
                      ),
                    ),
                    Panel(
                      name: "Stock",
                      icon: Icon(Icons.arrow_upward,
                          size: 40, color: Colors.white),
                      type: "Edit",
                      figure: "Total Stock: " + stockTotal.toString(),
                      color: Colors.red[400],
                      route: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => AdminStock(
                            name: widget.name,
                            userType: widget.userType,
                          ),
                        ),
                      ),
                    ),

                    Panel(
                      name: "Manage Users",
                      icon:
                          Icon(Icons.person_add, size: 40, color: Colors.white),
                      type: "Manage",
                      figure: "Total Users: " +
                          (administrators.length + tellers.length).toString(),
                      color: Colors.blue[400],
                      route: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => ManageStaff(
                            name: widget.name,
                            userType: widget.userType,
                          ),
                        ),
                      ),
                    ),

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
                  style: TextStyle(color: Colors.white, fontSize: 23),
                ),
                Padding(
                  padding: name == "Sales Today"
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
