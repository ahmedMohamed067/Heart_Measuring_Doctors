import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../pages.dart';

class Requests extends StatelessWidget {
  Requests(this.userDocument);

  final DocumentSnapshot userDocument;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: userDocument.reference
          .collection("requests")
          .orderBy("date", descending: true)
          .snapshots(),
      builder: (context, querySnapshot) {
        if (!querySnapshot.hasData)
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          );

        List<DocumentSnapshot> requests = querySnapshot.data?.documents;

        if (requests.isEmpty)
          return Center(
            child: Text(
              "No Requests yet",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          );

        return ListView(
          padding: EdgeInsets.only(bottom: 35, top: 10),
          children: List.generate(
            requests.length,
            (index) {
              DocumentSnapshot request = requests[index];

              String time =
                  formatDate(request["time"].toDate(), [hh, ":", mm, " ", am]);

              return Padding(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 20),
                child: GestureDetector(
                  onLongPress: () async {
                    await showDialog(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: Text("Delete"),
                        content: Text(
                            "Are your sure you want to delete ${request["patientName"]}'s request ?"),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: Text("cancel"),
                            onPressed: () {
                              pop(context);
                            },
                          ),
                          CupertinoDialogAction(
                            child: Text(
                              "Delete",
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () async {
                              await request.reference.delete();
                              pop(context);
                            },
                          )
                        ],
                      ),
                    );
                  },
                  child: Material(
                    elevation: 10,
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    child: ListTile(
                      contentPadding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                      title: Text(request["patientName"]),
                      subtitle: Text(
                          "${request["clinicName"]} - ${request["day"]} - $time"),
                      trailing: IconButton(
                        onPressed: () {
                          launch("tel:${request["phone"]}");
                        },
                        icon: Icon(
                          Icons.call,
                          color: Colors.lightBlue[900],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
