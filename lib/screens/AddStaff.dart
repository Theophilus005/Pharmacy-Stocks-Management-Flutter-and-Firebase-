import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class AddStaff extends StatefulWidget {
  final String userType;
  final String name;

  const AddStaff({Key key, this.userType, this.name}) : super(key: key);

  @override
  _AddStaffState createState() => _AddStaffState();
}

List<DropdownMenuItem> dropdownItems = [
  DropdownMenuItem(
    child: Text("Teller"),
    value: "Teller",
  ),
  DropdownMenuItem(
    child: Text("Administrator"),
    value: "Admin",
  ),
];

//Text Editing Controllers
final name = new TextEditingController();
final email = new TextEditingController();

String userType;
bool isLoading = false;

class _AddStaffState extends State<AddStaff> {
  Future addUser() async {
    String collection;
    String password = Random().nextInt(999999).toString();

    if (userType == null || name.text.isEmpty || email.text.isEmpty) {
      //Alert
      return "Fill all fields";
    } else {
      if (userType == "Teller") {
        collection = "Tellers";
      } else {
        collection = "Administrators";
      }
      setState(() {
        isLoading = true;
      });
      await Firestore.instance
          .collection(collection)
          .document(name.text)
          .setData({
        'Name': name.text,
        'Email': email.text,
        'User Type': userType,
        'Password': password,
        'level': "normal",
        'date': DateTime.now().toString().substring(0, 10),
      });
      setState(() {
        isLoading = false;
      });

      await sendEmail(email.text, name.text, password, userType);

      userType = null;
      print("user added");
      print(password);
      return "User Added Successfully";
    }
  }

  //Sends Emails
  Future sendEmail(
      String email, String name, String password2, String userType) async {
    String username = 'pmschemical@gmail.com';
    String password = 'password 1234';

    // ignore: deprecated_member_use
    final smtpServer = gmail(username, password);

    // Create our message.
    final message = Message()
      ..from = Address(username, "Mariam Adam License Chemical Drugs")
      ..recipients.add(email)
      ..subject = userType + ' Notification'
      ..html = "<h3> Login Credentials </h3> \n " +
          "<p> Username: " +
          name +
          "</p>\n" +
          "<p> Account Type: " +
          userType +
          " Account" +
          "</p>\n" +
          "<p> Password: " +
          password2 +
          "</p>\n";

    try {
      setState(() {
        isLoading = true;
      });
      final sendReport = await send(message, smtpServer);
      setState(() {
        isLoading = false;
      });
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Message not sent.');
      print(e.toString());
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add User"),
        backgroundColor: Colors.deepPurple[400],
        elevation: 0,
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          onPressed: () async {
            String status = await addUser();

            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text(status),
                duration: Duration(seconds: 5),
                backgroundColor: Colors.grey[700],
              ),
            );
          }, //addUser,
          backgroundColor: Colors.deepPurple[400],
          child: Icon(Icons.check),
        ),
      ),
      body: isLoading
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
                      children: <Widget>[
                        TextFormField(
                          controller: name,
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
                            prefixIcon: Icon(Icons.person),
                            labelText: "Name",
                            labelStyle: TextStyle(color: Colors.black38),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: email,
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
                            prefixIcon: Icon(Icons.email),
                            labelText: "Email",
                            labelStyle: TextStyle(color: Colors.black38),
                          ),
                        ),
                        SizedBox(height: 20),
                        DropdownButtonFormField(
                          hint: Text("Select User Type",
                              style: TextStyle(color: Colors.black54)),
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.deepPurple[300])),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.deepPurple[300])),
                          ),
                          items: dropdownItems,
                          onChanged: (val) {
                            setState(() {
                              userType = val;
                            });
                          },
                        ),
                        SizedBox(height: 20),
                        Container(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.info,
                                color: Colors.grey[500],
                                size: 20,
                              ),
                              SizedBox(width: 5),
                              Text(
                                "Password will be sent to the email provided",
                                style: TextStyle(
                                  color: Colors.grey[500],
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
            ),
    );
  }
}
