import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pms/models/StockModel.dart';

class MakeTransaction extends StatefulWidget {
  final String name;
  final String userType;

  const MakeTransaction({Key key, this.name, this.userType}) : super(key: key);

  @override
  _MakeTransactionState createState() => _MakeTransactionState();
}

int quantity = 1;
String price;
double unitPrice;
double totalPrice;
int maxQuantity = 1;

String medicine;
List firstQueryResults = [];
List secondQueryResults = [];
List items;
List<StockModel> stocks;
int stockLength;
bool isSearching = false;
bool useSearch = false;
bool isLoading = true;
String date = DateTime.now().toString().substring(0, 10);

//Controller
final medicineController = new TextEditingController();

Color selected = Colors.deepPurple[200];
Color notSelected = Colors.grey[200];
List<Color> colors = [];

class _MakeTransactionState extends State<MakeTransaction> {
  void resetColors(int length) {
    colors = [];
    for (int i = 0; i < length; i++) {
      colors.add(notSelected);
    }
  }

  Future getClosingStock() async {
    medicineController.clear();
    try {
      //Intial stock
      await Firestore.instance
          .collection("Daily Sales")
          .document(date)
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

      //Stream
      Firestore.instance
          .collection("Daily Sales")
          .document(date)
          .collection("Closing Stock")
          .snapshots()
          .listen((snapshot) {
        setState(() {
          stocks = snapshot.documents
              .map((documents) => StockModel.fromFirestore(documents.data))
              .toList();
          stockLength = stocks.length;
          resetColors(stockLength);
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
        getClosingStock();
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
          .collection("Daily Sales")
          .document(date)
          .collection("Closing Stock")
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

  Future makeTransaction() async {
    bool isValid = false;
    int number;
    double unitCost;
    double totalCost;

    if (medicineController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      //Check if medicine is in stock
      for (int i = 0; i < stocks.length; i++) {
        if (stocks[i].name == medicineController.text) {
          isValid = true;
          number = int.parse(stocks[i].quantity);
          unitCost = double.parse(stocks[i].price);
        }
      }

      if (number == 0) {
        return "Out of stock";
      }

      if (isValid && number > 0) {
        number = number - quantity;
        totalCost = unitCost * quantity;
        print(totalCost);

        //Adds Transaction to Database
        await Firestore.instance
            .collection("Daily Sales")
            .document(date)
            .collection("Transactions")
            .document(DateTime.now().toString())
            .setData(
          {
            'Name': medicineController.text,
            'Price': totalCost,
            'Quantity': quantity,
            'Remaining': number,
            'Date': DateTime.now().toString().substring(0, 10),
            'Time': DateTime.now().toString().substring(10, 16),
            'Teller': widget.name,
          },
        );

        //Transaction History
        await Firestore.instance
            .collection("Transaction History")
            .document(DateTime.now().toString())
            .setData(
          {
            'Name': medicineController.text,
            'Price': totalCost,
            'Quantity': quantity,
            'Remaining': number,
            'Date': DateTime.now().toString().substring(0, 10),
            'Time': DateTime.now().toString().substring(10, 16),
            'Teller': widget.name,
          },
        );
        print("added");

        //Updates the quantity of the stocks;
        await Firestore.instance
            .collection("Stocks")
            .document(medicineController.text)
            .updateData({
          'Quantity': number.toString(),
        });

        //Updates the quantity of the closing stocks;
        await Firestore.instance
            .collection("Daily Sales")
            .document(date)
            .collection("Closing Stock")
            .document(medicineController.text)
            .updateData({
          'Quantity': number.toString(),
        });

        print("updated");

        //Fetch the closing stock again
        getClosingStock();

        setState(() {
          isLoading = false;
        });

        return "Transaction successful";
      } else {
        setState(() {
          isLoading = false;
        });
        return "Medicine is not valid";
      }
    } else {
      return "No medicine chosen";
    }
  }

  @override
  void initState() {
    getClosingStock();

    setState(() {
      if (firstQueryResults.length != 0) {
        stockLength = firstQueryResults.length;
      } else if (secondQueryResults.length != 0) {
        stockLength = secondQueryResults.length;
      }
    });

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Make Transaction"),
        backgroundColor: Colors.deepPurple[400],
        elevation: 0,
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          onPressed: () async {
            String status = await makeTransaction();
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text(status),
                duration: Duration(seconds: 5),
                backgroundColor: Colors.grey[700],
              ),
            );
          },
          backgroundColor: Colors.deepPurple[400],
          child: Icon(Icons.check),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : stocks.isEmpty
              ? Center(
                  child: Text("No stock available"),
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
                      SizedBox(height: 30),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Choose Medicine",
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              controller: medicineController,
                              onChanged: (val) {
                                setState(() {
                                  initiateSearch2(val);
                                });
                              },
                              decoration: InputDecoration(
                                //prefixIcon: ,
                                hintText: "Search stock...",
                                labelStyle: TextStyle(color: Colors.black38),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.deepPurple[300]),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.deepPurple[400]),
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            isSearching
                                ? Container(
                                    width: double.infinity,
                                    height: 250,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "Stock Available",
                                          style: TextStyle(
                                            fontSize: 17,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        SearchItem(
                                          name: "Name",
                                          price: "Price",
                                          quantity: "Quantity",
                                          color: Colors.grey,
                                        ),
                                        ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount: stockLength,
                                            itemBuilder: (context, index) {
                                              String stockName = useSearch
                                                  ? items[index]['Name']
                                                  : stocks[index].name;

                                              String stockPrice = useSearch
                                                  ? items[index]['Price']
                                                  : stocks[index].price;

                                              String stockQuantity = useSearch
                                                  ? items[index]['Quantity']
                                                  : stocks[index].quantity;

                                              return SearchItem(
                                                name: stockName,
                                                quantity: stockQuantity,
                                                price: "¢" +
                                                    double.parse(stockPrice)
                                                        .toStringAsFixed(2),
                                                color: colors[index],
                                                select: () {
                                                  resetColors(stockLength);
                                                  setState(() {
                                                    medicine = stockName;
                                                    maxQuantity = int.parse(
                                                        stockQuantity);
                                                    medicineController.text =
                                                        stockName;
                                                    price = "¢" + stockPrice;
                                                    unitPrice = double.parse(
                                                        stockPrice);
                                                    colors[index] = selected;
                                                  });
                                                },
                                              );
                                            }),
                                        SizedBox(height: 20),
                                        Text(
                                          "Quantity",
                                          style: TextStyle(
                                            fontSize: 17,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        Container(
                                          child: Row(
                                            children: <Widget>[
                                              GestureDetector(
                                                onTap: () {
                                                  if (quantity > 1) {
                                                    setState(() {
                                                      quantity--;
                                                      totalPrice =
                                                          unitPrice * quantity;
                                                    });
                                                  }
                                                },
                                                child: CircleAvatar(
                                                  child: Icon(
                                                      Icons.arrow_back_ios),
                                                  foregroundColor:
                                                      Colors.deepPurple[400],
                                                ),
                                              ),
                                              SizedBox(width: 30),
                                              Text(
                                                quantity.toString(),
                                                style: TextStyle(fontSize: 17),
                                              ),
                                              SizedBox(width: 30),
                                              GestureDetector(
                                                onTap: () {
                                                  if (quantity < maxQuantity) {
                                                    setState(() {
                                                      quantity++;
                                                      totalPrice =
                                                          unitPrice * quantity;
                                                    });
                                                  }
                                                },
                                                child: CircleAvatar(
                                                  child: Icon(
                                                      Icons.arrow_forward_ios),
                                                  foregroundColor:
                                                      Colors.deepPurple[400],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
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

class SearchItem extends StatelessWidget {
  final String name;
  final String price;
  final String quantity;
  final Color color;
  final Function select;

  const SearchItem(
      {Key key, this.name, this.price, this.quantity, this.color, this.select})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: select,
      child: Container(
        width: double.infinity,
        height: 40,
        color: color,
        margin: EdgeInsets.symmetric(vertical: 7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.4,
              child: Center(
                child: Text(name),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.15,
              child: Center(
                child: Text(price),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.2,
              child: Center(
                child: Text(quantity),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
