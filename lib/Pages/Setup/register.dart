import '../pages.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  List<FocusNode> nodes = List.generate(4, (index) => FocusNode());
  bool isLoading = false;

  Map<String, dynamic> user = new Map<String, dynamic>();
  String password, password2;

  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

  List<String> places = ["Cairo", "Giza"];

  Future get register async {
    setState(() => isLoading = !isLoading);

    if (formKey.currentState.validate()) {
      user["date"] = DateTime.now();

      AuthResult auth =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: user["email"],
        password: password,
      );

      await Firestore.instance
          .collection("users")
          .document(auth.user.uid)
          .setData(user);

      DocumentSnapshot userDocument = await Firestore.instance
          .collection("users")
          .document(auth.user.uid)
          .get();

      push(context, Home(userDocument), initial: true);
    }

    setState(() => isLoading = !isLoading);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    var userNameWidget = Padding(
      padding: EdgeInsets.only(bottom: 20, left: 10, right: 10),
      child: TextFormField(
        focusNode: nodes[0],
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.text,
        onFieldSubmitted: (text) =>
            FocusScope.of(context).requestFocus(nodes[1]),
        validator: (text) {
          if (text.isEmpty) {
            return "Do not leave empty";
          } else {
            setState(() => user["fullName"] = text);
          }
        },
        decoration: InputDecoration(
          labelText: "Username",
          // labelStyle: TextStyle(color: Colors.white),
        ),
      ),
    );

    var emailWidget = Padding(
      padding: EdgeInsets.only(bottom: 20, left: 10, right: 10),
      child: TextFormField(
        focusNode: nodes[1],
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.emailAddress,
        onFieldSubmitted: (text) =>
            FocusScope.of(context).requestFocus(nodes[2]),
        validator: (text) {
          if (text.isEmpty) {
            return "Do not leave empty";
          } else {
            setState(() => user["email"] = text);
          }
        },
        decoration: InputDecoration(
          labelText: "Email address",
          // labelStyle: TextStyle(color: Colors.white),
        ),
      ),
    );

    var password1Widget = Padding(
      padding: EdgeInsets.only(bottom: 40, left: 10, right: 10),
      child: TextFormField(
        obscureText: true,
        focusNode: nodes[2],
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.text,
        onFieldSubmitted: (text) =>
            FocusScope.of(context).requestFocus(nodes[3]),
        validator: (text) {
          if (text.isEmpty) {
            return "Do not leave empty";
          } else {
            setState(() => password2 = text);
          }
        },
        decoration: InputDecoration(
          labelText: "Password",
          // labelStyle: TextStyle(color: Colors.white),
        ),
      ),
    );

    var password2Widget = Padding(
      padding: EdgeInsets.only(bottom: 40, left: 10, right: 10),
      child: TextFormField(
        focusNode: nodes[3],
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.text,
        validator: (text) {
          if (text.isEmpty) {
            return "Do not leave empty";
          } else if (password2 != text) {
            return "Passwords doesn't match";
          } else {
            setState(() => password = text);
          }
        },
        obscureText: true,
        decoration: InputDecoration(
          labelText: "Password",
          // labelStyle: TextStyle(color: Colors.white),
        ),
      ),
    );

    var placeWidget = Padding(
      padding: EdgeInsets.only(bottom: 40, left: 10, right: 10),
      child: DropdownButton(
        isExpanded: true,
        value: user["city"],
        hint: Text("Select your city"),
        onChanged: (value) {
          setState(() => user["city"] = value);
        },
        items: places
            .map(
              (name) => DropdownMenuItem(
                value: name,
                child: Text(name),
              ),
            )
            .toList(),
      ),
    );

    var registerButton = GestureDetector(
      onTap: () async {
        await register.catchError((error) {
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
          child: Text(
            "Register",
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

    var logo = Hero(
      tag: "Logo",
      child: Image.asset(
        "assets/logo.png",
        height: size.width / 3,
      ),
    );

    var container = Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(10),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 25),
        child: Form(
          key: formKey,
          child: (isLoading)
              ? Container(
                  width: size.width / 2,
                  height: size.width / 2,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.lightBlue[900]),
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Text(
                        "Register",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 35,
                        ),
                      ),
                    ),
                    userNameWidget,
                    emailWidget,
                    password1Widget,
                    password2Widget,
                    placeWidget,
                    registerButton,
                  ],
                ),
        ),
      ),
    );

    var login = FlatButton(
      onPressed: () {
        pop(context);
      },
      child: Text(
        "Already registered ?, Sign in.",
        style: TextStyle(
          color: Colors.black54,
        ),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.lightBlue[900], Colors.lightBlue],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 25, horizontal: 25),
            children: <Widget>[
              logo,
              SizedBox(height: 30),
              container,
              login,
            ],
          ),
        ),
      ),
    );
  }
}
