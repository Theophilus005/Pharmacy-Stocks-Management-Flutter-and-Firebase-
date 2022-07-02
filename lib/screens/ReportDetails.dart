import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'TellerStock.dart';
import '../models/TransactionModel.dart';
import '../models/stockModel.dart';

class ReportDetails extends StatefulWidget {
  final String date;
  final String name;
  final String userType;

  const ReportDetails({Key key, this.date, this.name, this.userType})
      : super(key: key);

  @override
  _ReportDetailsState createState() => _ReportDetailsState();
}

List<TransactionModel> transactions;
bool isLoading = false;
double totalSales = 0;

List openingStocks;
List<StockModel> closingStocks;

int openingStockCount = 0;
int closingStockCount = 0;

class _ReportDetailsState extends State<ReportDetails> {
  Future getTransactions() async {
    setState(() {
      isLoading = true;
    });

    try {
      //initial
      await Firestore.instance
          .collection("Daily Sales")
          .document(widget.date)
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
          .document(widget.date)
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
        //getStockTotal();
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future getClosingStock() async {
    setState(() {
      isLoading = true;
    });
    try {
      //Initial
      await Firestore.instance
          .collection("Daily Sales")
          .document(widget.date)
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
          .document(widget.date)
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
        .document(widget.date)
        .collection("Opening Stock")
        .getDocuments();

    setState(() {
      openingStocks = getOpenStocks.documents;
      calculateOpeningStock(openingStocks.length, openingStocks);
      isLoading = false;
    });
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

  @override
  void initState() {
    getTransactions();
    getOpeningStock();
    getClosingStock();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Report Details"),
        backgroundColor: Colors.deepPurple[400],
        elevation: 0,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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

                //Sales Details
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          color: Colors.grey[200],
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          height: 90,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "Sales Report",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  Icon(Icons.book),
                                ],
                              ),
                              Text(
                                date,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 15),
                        SaleItem(
                          type: "header",
                        ),
                        ListView.builder(
                            itemCount: transactions.length,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return SaleItem(
                                medicine: transactions[index].name,
                                quantity: transactions[index].quantity,
                                unitPrice: transactions[index].price /
                                    transactions[index].quantity,
                                totalPrice: transactions[index].price,
                              );
                            }),
                        Container(
                          padding: EdgeInsets.only(left: 20),
                          width: double.infinity,
                          height: 50,
                          color: Colors.grey[200],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Total Sales: GH¢" +
                                    totalSales.toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Stock Report",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[500],
                          ),
                        ),
                        SizedBox(height: 20),
                        Panel(
                          name: "Opening Stock",
                          icon: Icon(Icons.arrow_upward,
                              size: 40, color: Colors.white),
                          type: "Report",
                          figure:
                              "Total Stock: " + openingStockCount.toString(),
                          color: Colors.green[400],
                          route: () => Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => TellerStock(
                                type: "Opening",
                                date: widget.date,
                                name: widget.name,
                                userType: widget.userType,
                              ),
                            ),
                          ),
                        ),
                        Panel(
                          name: "Closing Stock",
                          icon: Icon(Icons.arrow_downward,
                              size: 40, color: Colors.white),
                          type: "Report",
                          figure: "Remaining Stock: " +
                              closingStockCount.toString(),
                          color: Colors.red[400],
                          route: () => Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => TellerStock(
                                type: "Closing",
                                date: widget.date,
                                name: widget.name,
                                userType: widget.userType,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            )),
    );
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
        margin: EdgeInsets.only(bottom: 17),
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
                icon,
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

class SaleItem extends StatelessWidget {
  final String medicine;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String type;

  const SaleItem({
    Key key,
    this.medicine,
    this.unitPrice,
    this.totalPrice,
    this.quantity,
    this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double cellSize = 0.3;

    return Container(
      color: type == "header" ? Colors.grey : Colors.grey[200],
      height: 40,
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * cellSize,
            child: Center(
              child: Text(
                type == "header" ? "Name" : medicine,
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * cellSize,
            padding: EdgeInsets.only(left: 20),
            child: Center(
              child: Text(
                type == "header"
                    ? "Cost"
                    : quantity.toString() +
                        " x ¢" +
                        unitPrice.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * cellSize,
            padding: EdgeInsets.only(left: 20),
            child: Center(
              child: Text(
                type == "header"
                    ? "Total"
                    : "¢" + totalPrice.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
