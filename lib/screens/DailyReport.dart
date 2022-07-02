import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'ReportDetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DailyReport extends StatefulWidget {
  final String name;
  final String userType;

  const DailyReport({Key key, this.name, this.userType}) : super(key: key);

  @override
  _DailyReportState createState() => _DailyReportState();
}

List<DocumentSnapshot> dates;
String date = DateTime.now().toString().substring(0, 10);
bool isLoading = false;

class _DailyReportState extends State<DailyReport> {
  Future getDateReports() async {
    setState(() {
      isLoading = true;
    });
    var reports = await Firestore.instance
        .collection("Daily Report")
        .orderBy("Date", descending: true)
        .getDocuments();

    setState(() {
      dates = reports.documents;
      isLoading = false;
    });

    print("Done");
  }

  @override
  void initState() {
    getDateReports();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daily Report"),
        backgroundColor: Colors.deepPurple[400],
        elevation: 0,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : dates.isEmpty
              ? Center(
                  child: Text("No Reports Yet"),
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
                      SizedBox(height: 10),

                      ListView.builder(
                          itemCount: dates.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemBuilder: (context, index) {
                            return ReportTile(
                              date: dates[index]["Date"],
                              color: dates[index]["Date"] == date
                                  ? Colors.deepPurple[200]
                                  : Colors.grey[300],
                              route: () => Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => ReportDetails(
                                    date: dates[index]["Date"],
                                    name: widget.name,
                                    userType: widget.userType,
                                  ),
                                ),
                              ),
                            );
                          }),

                      /*ReportTile(
              date: "12/17/2021",
              teller: "John Doe",
              time: "12:30 PM",
              color: Colors.grey[300],
              route: () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => ReportDetails(),
                ),
              ),
            ),
            ReportTile(
              date: "12/17/2021",
              teller: "John Doe",
              time: "12:30 PM",
              color: Colors.grey[300],
              route: () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => ReportDetails(),
                ),
              ),
            )*/
                    ],
                  ),
                ),
    );
  }
}

class ReportTile extends StatelessWidget {
  final String date;
  final Color color;
  final Function route;

  const ReportTile({Key key, this.date, this.route, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: route,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        height: 80,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 21,
                    ),
                  ),
                  Icon(Icons.book),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
