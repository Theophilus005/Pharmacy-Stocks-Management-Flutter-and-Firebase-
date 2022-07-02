import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddStock extends StatefulWidget {
  final String name;
  final String userType;

  const AddStock({Key key, this.name, this.userType}) : super(key: key);

  @override
  _AddStockState createState() => _AddStockState();
}

bool isLoading = false;

//Text Editing Controllers
final name = new TextEditingController();
final price = new TextEditingController();
final quantity = new TextEditingController();

class _AddStockState extends State<AddStock> {
  @override
  Widget build(BuildContext context) {
    //Add Stock
    Future addStock() async {
      if (name.text.isEmpty || price.text.isEmpty || quantity.text.isEmpty) {
        //Alert
        return "Fill all fields";
      } else {
        setState(() {
          isLoading = true;
        });
        await Firestore.instance
            .collection("Stocks")
            .document(name.text)
            .setData({
          'Name': name.text,
          'Price': price.text,
          'Quantity': quantity.text,
          'Date added': DateTime.now().toString().substring(0, 16),
          'Search Key': name.text.substring(0, 1).toUpperCase(),
        });
        setState(() {
          isLoading = false;
        });
        return "Stock added";
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Stock"),
        backgroundColor: Colors.deepPurple[400],
        elevation: 0,
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          onPressed: () async {
            String status = await addStock();
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
          ? Center(child: CircularProgressIndicator())
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
                  SizedBox(height: 20),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Stock Form",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[500],
                          ),
                        ),
                        SizedBox(height: 20),
                        InputField(
                          name: "Name",
                          controller: name,
                        ),
                        SizedBox(height: 20),
                        InputField(
                          name: "Price",
                          controller: price,
                        ),
                        SizedBox(height: 20),
                        InputField(
                          name: "Quantity",
                          controller: quantity,
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class InputField extends StatelessWidget {
  final String name;
  final TextEditingController controller;

  const InputField({Key key, this.name, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.deepPurple[300],
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.deepPurple[400],
          ),
        ),
        labelText: name,
        labelStyle: TextStyle(color: Colors.black38),
      ),
    );
  }
}
