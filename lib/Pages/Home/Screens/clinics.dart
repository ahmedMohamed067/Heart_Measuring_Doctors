import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';

import '../../pages.dart';

class Clinics extends StatelessWidget {
  Clinics(this.userDocument);

  final DocumentSnapshot userDocument;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: userDocument.reference
          .collection("clinics")
          .orderBy("date", descending: true)
          .snapshots(),
      builder: (context, querySnapshot) {
        if (!querySnapshot.hasData)
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          );

        List<DocumentSnapshot> clinics = querySnapshot.data?.documents;

        if (clinics.isEmpty)
          return Center(
            child: Text(
              "Add clinic.",
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
            clinics.length,
            (index) {
              DocumentSnapshot clinic = clinics[index];

              String from =
                  formatDate(clinic["from"].toDate(), [hh, ":", nn, " ", am]);
              String to =
                  formatDate(clinic["to"].toDate(), [hh, ":", nn, " ", am]);

              return Padding(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 20),
                child: GestureDetector(
                  onLongPress: () async {
                    await showDialog(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: Text("Delete"),
                        content: Text(
                            "Are your sure you want to delete ${clinic["clinicName"]} ?"),
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
                              await clinic.reference.delete();
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
                    title: Text(clinic["clinicName"]),
                    subtitle: Text("From $from to $to"),
                    trailing: Text(clinic["phone"]),
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
