import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'AddStaff.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageStaff extends StatefulWidget {
  final String name;
  final String userType;

  const ManageStaff({Key key, this.name, this.userType}) : super(key: key);

  @override
  _ManageStaffState createState() => _ManageStaffState();
}

QuerySnapshot tellers;
QuerySnapshot administrators;
bool isLoading = false;

class _ManageStaffState extends State<ManageStaff> {
  Future getUsers() async {
    //Gets Users
    setState(() {
      isLoading = true;
    });
    tellers = await Firestore.instance.collection("Tellers").getDocuments();
    administrators =
        await Firestore.instance.collection("Administrators").getDocuments();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    getUsers();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Users"),
        backgroundColor: Colors.deepPurple[400],
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => AddStaff(
              name: widget.name,
              userType: widget.userType,
            ),
          ),
        ),
        backgroundColor: Colors.deepPurple[400],
        child: Icon(Icons.add),
      ),
      body: Builder(
        builder: (context) => isLoading
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Icon(
                                  FontAwesomeIcons.userAlt,
                                  size: 20,
                                  color: Colors.grey[500],
                                ),
                                SizedBox(width: 5),
                                Text(
                                  "Tellers",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            StaffRow(
                              type: "header",
                            ),
                            ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: tellers.documents.length,
                                itemBuilder: (context, index) {
                                  return StaffRow(
                                    name: tellers.documents[index].data["Name"],
                                    date: tellers.documents[index].data["date"],
                                    remove: () async {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      await Firestore.instance
                                          .collection("Tellers")
                                          .document(tellers
                                              .documents[index].data["Name"])
                                          .delete();
                                      getUsers();
                                      setState(() {
                                        isLoading = false;
                                      });
                                      Scaffold.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("User removed"),
                                          duration: Duration(seconds: 5),
                                          backgroundColor: Colors.grey[700],
                                        ),
                                      );
                                      print("user removed");
                                    },
                                    level:
                                        tellers.documents[index].data["level"],
                                  );
                                }),

                            SizedBox(height: 10),

                            //Administrators
                            Row(
                              children: <Widget>[
                                Icon(
                                  FontAwesomeIcons.userShield,
                                  size: 20,
                                  color: Colors.grey[500],
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "Administrators",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            StaffRow(
                              type: "header",
                            ),
                            ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: administrators.documents.length,
                                itemBuilder: (context, index) {
                                  return StaffRow(
                                    name: administrators
                                        .documents[index].data["Name"],
                                    date: administrators
                                        .documents[index].data["date"],
                                    remove: () async {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      await Firestore.instance
                                          .collection("Administrators")
                                          .document(administrators
                                              .documents[index].data["Name"])
                                          .delete();
                                      getUsers();
                                      setState(() {
                                        isLoading = false;
                                      });
                                      Scaffold.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("User removed"),
                                          duration: Duration(seconds: 5),
                                          backgroundColor: Colors.grey[700],
                                        ),
                                      );
                                      print("user removed");
                                    },
                                    level: administrators
                                        .documents[index].data["level"],
                                  );
                                }),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }
}

class StaffRow extends StatelessWidget {
  final String name;
  final String date;
  final Function remove;
  final String type;
  final String level;

  const StaffRow(
      {Key key, this.name, this.date, this.remove, this.type, this.level})
      : super(key: key);

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
                type == "header" ? "Name" : name,
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
                type == "header" ? "Date Added" : date,
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
              child: type == "header"
                  ? Text(
                      "Remove",
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  : GestureDetector(
                      onTap: level == "super" ? () {} : remove,
                      child: IconButton(
                        icon: Icon(FontAwesomeIcons.userAltSlash,
                            color: level == "super"
                                ? Colors.grey[400]
                                : Colors.red),
                        onPressed: level == "super" ? () {} : remove,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
