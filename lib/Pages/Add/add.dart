import '../pages.dart';

class AddDialog extends StatefulWidget {
  AddDialog(this.userDocument);
  final DocumentSnapshot userDocument;
  @override
  _AddDialogState createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  bool isLoading = false;
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  Map<String, dynamic> clinic = new Map<String, dynamic>();
  List<FocusNode> nodes = List.generate(2, (index) => FocusNode());
  List<String> days = [
    "Saturday",
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
  ];

  @override
  void initState() {
    super.initState();
    clinic["days"] = List.generate(days.length, (index) => days[index]);
  }

  Future get add async {
    setState(() => isLoading = !isLoading);

    if (formKey.currentState.validate() &&
        clinic["from"] != null &&
        clinic["to"] != null &&
        clinic["days"].isNotEmpty) {
      clinic["date"] = DateTime.now();

      TimeOfDay _from = clinic["from"];
      TimeOfDay _to = clinic["to"];

      DateTime now = DateTime.now();

      clinic["from"] =
          DateTime(now.year, now.month, now.day, _from.hour, _from.minute);

      clinic["to"] =
          DateTime(now.year, now.month, now.day, _to.hour, _to.minute);

      await widget.userDocument.reference.collection("clinics").add(clinic);

      pop(context);
    }

    setState(() => isLoading = !isLoading);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    var name = Padding(
      padding: EdgeInsets.only(bottom: 20, left: 10, right: 10),
      child: TextFormField(
        focusNode: nodes[0],
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (text) =>
            FocusScope.of(context).requestFocus(nodes[1]),
        validator: (text) {
          if (text.isEmpty) {
            return "Do not leave empty.";
          } else {
            setState(() => clinic["clinicName"] = text);
          }
        },
        decoration: InputDecoration(
          labelText: "Name",
          // labelStyle: TextStyle(color: Colors.white),
        ),
      ),
    );

    var phone = Padding(
      padding: EdgeInsets.only(bottom: 20, left: 10, right: 10),
      child: TextFormField(
        focusNode: nodes[1],
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.done,
        validator: (text) {
          if (text.isEmpty) {
            return "Do not leave empty.";
          } else {
            setState(() => clinic["phone"] = text);
          }
        },
        decoration: InputDecoration(
          labelText: "Phone",
          // labelStyle: TextStyle(color: Colors.white),
        ),
      ),
    );

    var daysWidget = Column(
      children: List.generate(
        days.length,
        (index) => CheckboxListTile(
          value: clinic["days"].contains(days[index]),
          title: Text(days[index]),
          onChanged: (checked) {
            setState(() {
              if (checked) {
                clinic["days"].add(days[index]);
                print("added");
              } else {
                clinic["days"].remove(days[index]);
                print("deleted");
              }
            });
          },
        ),
      ),
    );

    var from = Expanded(
      child: FlatButton(
        onPressed: () async {
          clinic["from"] = await showTimePicker(
              context: context, initialTime: TimeOfDay.now());
          setState(() {});
        },
        child: Text(
          (clinic["from"] != null) ? "${clinic["from"].hour} " : "From",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    var to = Expanded(
      child: FlatButton(
        onPressed: () async {
          clinic["to"] = await showTimePicker(
              context: context, initialTime: TimeOfDay.now());
          setState(() {});
        },
        child: Text(
          (clinic["to"] != null) ? "${clinic["to"].hour} " : "To",
          style: TextStyle(
            color: Colors.black54,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    var doneButton = GestureDetector(
      onTap: () async {
        await add.catchError((error) {
          print(error);
          setState(() => isLoading = !isLoading);
        });
      },
      child: Material(
        borderRadius: BorderRadius.circular(10),
        color: Colors.lightBlue,
        elevation: 10,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: (isLoading)
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.lightBlue[900]),
                  ),
                )
              : Text(
                  "Done",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );

    var topBar = Row(
      children: <Widget>[
        IconButton(
          onPressed: () => pop(context),
          icon: Icon(
            Icons.close,
            size: 27,
          ),
        ),
      ],
    );

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
        child: Material(
          elevation: 10,
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: EdgeInsets.fromLTRB(15, 15, 15, 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                topBar,
                SizedBox(height: 15),
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: <Widget>[
                          name,
                          phone,
                          daysWidget,
                          Row(children: <Widget>[from, to])
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 25),
                doneButton,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
