import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/TransactionModel.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({Key key}) : super(key: key);

  @override
  _TransactionHistoryState createState() => _TransactionHistoryState();
}

List<DocumentSnapshot> dates;
String date = DateTime.now().toString().substring(0, 10);
bool isLoading = false;
List<TransactionModel> transactions;

class _TransactionHistoryState extends State<TransactionHistory> {
  Future getTransactions() async {
    setState(() {
      isLoading = true;
    });

    try {
      Firestore.instance
          .collection("Transaction History")
          .orderBy("Date", descending: true)
          .snapshots()
          .listen((snapshot) {
        setState(() {
          transactions = snapshot.documents
              .map(
                  (documents) => TransactionModel.fromFirestore(documents.data))
              .toList();
        });
        //getStockTotal();
      });
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      isLoading = false;
    });
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
        title: Text("Transaction History"),
        backgroundColor: Colors.deepPurple[400],
        elevation: 0,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : transactions.isEmpty
              ? Center(
                  child: Text("No Transaction History"),
                )
              : SingleChildScrollView(
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
                              "Teller: Jon Doe",
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              "ID: 53453634",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),

                      //Reports
                      Container(
                        child: Column(
                          children: <Widget>[
                            Transaction(
                              type: "header",
                            ),
                            SizedBox(
                              height: 500,
                              child: ListView.builder(
                                  itemCount: transactions.length,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (context, index) {
                                    return Transaction(
                                      medicine: transactions[index].name,
                                      quantity: transactions[index].quantity,
                                      unitPrice: transactions[index].price /
                                          transactions[index].quantity,
                                      totalPrice: transactions[index].price,
                                      teller: transactions[index].teller,
                                      date: transactions[index].date,
                                    );
                                  }),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
    );
  }
}

class Transaction extends StatelessWidget {
  final String medicine;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String type;
  final String date;
  final String user;
  final String teller;

  const Transaction(
      {Key key,
      this.medicine,
      this.unitPrice,
      this.totalPrice,
      this.quantity,
      this.type,
      this.user,
      this.teller,
      this.date})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double cellSize = 0.2;

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
          Container(
            width: MediaQuery.of(context).size.width * cellSize,
            padding: EdgeInsets.only(left: 20),
            child: Center(
              child: Text(
                type == "header" ? "Date" : date,
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
                type == "header" ? "Teller" : teller,
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
