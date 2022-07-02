import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChangePassword extends StatefulWidget {
  final String name;
  final String userType;

  const ChangePassword({Key key, this.name, this.userType}) : super(key: key);

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

//Controllers
final oldPassword = new TextEditingController();
final newPassword = new TextEditingController();

bool isLoading = false;

class _ChangePasswordState extends State<ChangePassword> {
  Future changePassword() async {
    //Check if old password matches
    if (oldPassword.text.isEmpty || newPassword.text.isEmpty) {
      return "Fill all fields";
    } else {
      String typeName;
      if (widget.userType == "Teller") {
        typeName = "Tellers";
      } else if (widget.userType == "administrator") {
        typeName = "Administrators";
      }

      setState(() {
        isLoading = true;
      });

      var old = await Firestore.instance
          .collection(typeName)
          .document(widget.name)
          .get();

      if (old.data["Password"] == oldPassword.text) {
        print("same");

        //Update with new password
        await Firestore.instance
            .collection(typeName)
            .document(widget.name)
            .updateData({
          'Password': newPassword.text,
        });

        setState(() {
          isLoading = false;
          oldPassword.clear();
          newPassword.clear();
        });
        return "Password successfully changed";
      } else {
        setState(() {
          isLoading = false;
        });
        return "Old Password is incorrect";
      }
    }
  }

  @override
  void initState() {
    print(widget.userType);
    setState(() {
      isLoading = false;
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Change Password"),
        backgroundColor: Colors.deepPurple[400],
        elevation: 0,
      ),
      body: Builder(
        builder: (context) => isLoading
            ? Center(
                child: CircularProgressIndicator(),
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
                            widget.userType.toUpperCase() + ": " + widget.name,
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 40),

                    Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height,
                        child: Center(
                          child: Column(
                            children: <Widget>[
                              TextField(
                                type: "Old Password",
                                controller: oldPassword,
                              ),
                              SizedBox(height: 20),
                              TextField(
                                type: "New Password",
                                controller: newPassword,
                              ),
                              SizedBox(height: 20),
                              GestureDetector(
                                onTap: () async {
                                  String status = await changePassword();
                                  Scaffold.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(status),
                                      duration: Duration(seconds: 5),
                                      backgroundColor: Colors.grey[700],
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple[400],
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  width: 300,
                                  height: 60,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        FontAwesomeIcons.lock,
                                        color: Colors.white,
                                        size: 25,
                                      ),
                                      SizedBox(width: 15),
                                      Text("Change Password",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
      ),
    );
  }
}

class TextField extends StatelessWidget {
  final String type;
  final TextEditingController controller;

  const TextField({Key key, this.controller, this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      child: TextFormField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          prefixIcon: Icon(
            FontAwesomeIcons.key,
            size: 20,
          ),
          labelText: type,
          labelStyle: TextStyle(color: Colors.black38),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple[300]),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple[400]),
          ),
        ),
      ),
    );
  }
}
