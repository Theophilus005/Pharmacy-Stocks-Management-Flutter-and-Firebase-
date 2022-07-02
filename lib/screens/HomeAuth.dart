import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'AdminAuth.dart';
import 'TellerAuth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mailer/mailer.dart';

class HomeAuth extends StatelessWidget {
  const HomeAuth({Key key}) : super(key: key);

  Future addUser() async {
    await Firestore.instance
        .collection("Administrators")
        .document("Theophilus Addo")
        .setData({
      'id': 2,
      'Name': 'Theophilus Addo',
      'Password': 'abc',
      'level': 'super',
      'User Type': 'administrator',
      'date': DateTime.now().toString().substring(0, 10),
    });
    print("added");
  }

  Future getUser() async {
    var document =
        await Firestore.instance.collection("Administrators").getDocuments();
    print(document.documents[1].data);

    //print(user.documents.where((Name) => "Theophilus Addo"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                "MARIAM ADAM LICENSE CHEMICAL DRUGS",
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: "Open Sans",
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple[400],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 40),
            Container(
              width: 300,
              height: 300,
              child:
                  Image.asset("assets/images/pharmacy.png", fit: BoxFit.cover),
            ),
            SizedBox(height: 20),
            LogInButton(
              type: "TELLER",
              route: () => Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => TellerAuth()),
              ),
            ),
            SizedBox(height: 25),
            LogInButton(
              type: "ADMINISTRATOR",
              route: () => Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => AdminAuth()),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

class LogInButton extends StatelessWidget {
  final String type;
  final Function route;
  const LogInButton({Key key, this.type, this.route}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: route,
      child: Container(
        child: Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.deepPurple[400]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    type == "ADMINISTRATOR"
                        ? FontAwesomeIcons.userShield
                        : FontAwesomeIcons.userAlt,
                    size: 30,
                    color: Colors.deepPurple[400],
                  ),
                  SizedBox(width: 5),
                  Padding(
                    padding: type == "ADMINISTRATOR"
                        ? EdgeInsets.only(left: 10)
                        : EdgeInsets.only(left: 0),
                    child: Text(
                      type,
                      style: TextStyle(
                        fontSize: 18,
                      ),
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
