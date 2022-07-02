import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'MakeTransaction.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/TransactionModel.dart';

class Transactions extends StatefulWidget {
  final String name;
  final String userType;

  const Transactions({Key key, this.name, this.userType}) : super(key: key);

  @override
  _TransactionsState createState() => _TransactionsState();
}

String date = DateTime.now().toString().substring(0, 10);

List<TransactionModel> transactions;
bool isLoading = false;

class _TransactionsState extends State<Transactions> {
  Future getTransactions() async {
    setState(() {
      isLoading = true;
    });

    try {
      //Get initial transactions
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
          isLoading = false;
        });
        //getStockTotal();
      });
    } catch (e) {
      print(e.toString());
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
          title: Text("Transactions"),
          elevation: 0,
          backgroundColor: Colors.deepPurple[400],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => MakeTransaction(
                name: widget.name,
                userType: widget.userType,
              ),
            ),
          ),
          child: Icon(Icons.add),
          backgroundColor: Colors.deepPurple[400],
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : transactions.isEmpty
                ? Center(
                    child: Text("No Transactions Today"),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
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
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            "Transactions Today",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          child: Column(
                            children: <Widget>[
                              TransactionItem(
                                name: "Name",
                                price: "Total Cost",
                                remaining: "Remaining",
                                time: "Time",
                                color: Colors.grey,
                              ),
                              ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  itemCount: transactions.length,
                                  itemBuilder: (context, index) {
                                    return TransactionItem(
                                      name: transactions[index].name,
                                      price: "¢" +
                                          transactions[index]
                                              .price
                                              .toStringAsFixed(2),
                                      remaining: transactions[index]
                                          .remaining
                                          .toString(),
                                      time: transactions[index].time,
                                      color: Colors.grey[200],
                                    );
                                  })
                              /*TransactionItem(
                            name: "Paracetamol",
                            price: "¢24.00",
                            remaining: "5",
                            time: "12:30 PM",
                            color: Colors.grey[200],
                          ),*/
                            ],
                          ),
                        ),
                      ],
                    ),
                  ));
  }
}

class TransactionItem extends StatelessWidget {
  final String name;
  final String price;
  final String remaining;
  final String time;
  final Color color;

  const TransactionItem(
      {Key key, this.name, this.price, this.remaining, this.time, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      height: 40,
      margin: EdgeInsets.symmetric(horizontal: 3, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.2,
            child: Center(
              child: Text(name),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.2,
            child: Center(
              child: Text(price),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.2,
            child: Center(
              child: Text(remaining),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.2,
            child: Center(
              child: Text(time),
            ),
          ),
        ],
      ),
    );
  }
}
