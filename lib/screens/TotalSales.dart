import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/TransactionModel.dart';

class TotalSales extends StatefulWidget {
  final String user;
  final String userType;
  final String name;

  const TotalSales({Key key, this.user, this.userType, this.name})
      : super(key: key);

  @override
  _TotalSalesState createState() => _TotalSalesState();
}

bool isLoading = false;
String date = DateTime.now().toString().substring(0, 10);
List<TransactionModel> transactions;
double totalSales = 0.0;

class _TotalSalesState extends State<TotalSales> {
  Future getTransactions() async {
    setState(() {
      isLoading = true;
    });

    try {
      //Initial transactions
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
          isLoading = false;
        });
        //getStockTotal();
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

  @override
  void initState() {
    getTransactions();

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Total Sales"),
        backgroundColor: Colors.deepPurple[400],
        elevation: 0,
      ),
      body: transactions == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : transactions.isEmpty
              ? Center(
                  child: Text("No Sales Today"),
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
                      ),
                      SizedBox(height: 20),

                      //Sales Details
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Sales Report",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                SizedBox(height: 15),
                                SaleItem(
                                  type: "header",
                                  user: widget.user,
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
                                        teller: transactions[index].teller,
                                        user: widget.user,
                                      );
                                    }),
                                Container(
                                  padding: EdgeInsets.only(left: 20),
                                  width: double.infinity,
                                  height: 50,
                                  color: Colors.grey[200],
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                              ],
                            ),
                          ),
                        ),
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
  final String user;
  final String teller;

  const SaleItem(
      {Key key,
      this.medicine,
      this.unitPrice,
      this.totalPrice,
      this.quantity,
      this.type,
      this.user,
      this.teller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double cellSize;
    if (user == "Admin") {
      cellSize = 0.2;
    } else {
      cellSize = 0.3;
    }

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
          user == "Admin"
              ? Container(
                  width: MediaQuery.of(context).size.width * cellSize,
                  padding: EdgeInsets.only(left: 20),
                  child: Center(
                    child: Text(
                      type == "header" ? "Teller" : teller,
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
