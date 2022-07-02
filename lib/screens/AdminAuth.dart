import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'AdminDashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAuth extends StatefulWidget {
  const AdminAuth({Key key}) : super(key: key);

  @override
  _AdminAuthState createState() => _AdminAuthState();
}

final nameController = new TextEditingController();
final passwordController = new TextEditingController();
bool isLoading = false;

class _AdminAuthState extends State<AdminAuth> {
  //Login Function
  Future login() async {
    if (nameController.text.isEmpty || passwordController.text.isEmpty) {
      return "Fill all fields";
    } else {
      setState(() {
        isLoading = true;
      });
      var doc = await Firestore.instance
          .collection("Administrators")
          .document(nameController.text)
          .get();
      if (doc.exists) {
        //Check password
        if (doc.data["Password"] == passwordController.text) {
          setState(() {
            isLoading = false;
          });
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (context) => AdminDashboard(
                name: doc.data["Name"],
                level: doc.data["level"],
                userType: doc.data["User Type"],
              ),
            ),
          );
        } else {
          setState(() {
            isLoading = false;
          });
          return "Wrong Password";
        }
      } else {
        setState(() {
          isLoading = false;
        });
        return "Wrong Name";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mariam Adam License Chemical Drugs"),
        backgroundColor: Colors.deepPurple[400],
      ),
      body: Builder(
        builder: (context) => isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "ADMINISTRATOR LOGIN",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: "Open Sans",
                          fontWeight: FontWeight.w600,
                          color: Colors.deepPurple[400],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: 300,
                        height: 300,
                        child: SvgPicture.asset("assets/images/doctors.svg",
                            fit: BoxFit.cover),
                      ),
                      Form(
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 30),
                            TextField(
                              type: "Name",
                              controller: nameController,
                            ),
                            SizedBox(height: 20),
                            TextField(
                              type: "Password",
                              controller: passwordController,
                            ),
                            SizedBox(height: 20),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => AdminDashboard(),
                                ),
                              ),
                              child: GestureDetector(
                                onTap: () async {
                                  String status = await login();
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          FontAwesomeIcons.doorOpen,
                                          color: Colors.white,
                                          size: 25,
                                        ),
                                        SizedBox(width: 15),
                                        Text("LOGIN",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                            )),
                                      ],
                                    )),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class TextField extends StatelessWidget {
  final String type;
  final TextEditingController controller;

  const TextField({Key key, this.type, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      child: TextFormField(
        controller: controller,
        obscureText: type == "Password" ? true : false,
        decoration: InputDecoration(
          prefixIcon: type == "Name"
              ? Icon(
                  FontAwesomeIcons.userAlt,
                  size: 20,
                )
              : Icon(
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
