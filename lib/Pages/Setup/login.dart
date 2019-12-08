import '../pages.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  List<FocusNode> nodes = List.generate(2, (index) => FocusNode());
  bool isLoading = false;

  String email, password;

  Future get initView async {
    setState(() => isLoading = !isLoading);

    await FirebaseAuth.instance.currentUser().then((user) async {
      if (user != null) {
        DocumentSnapshot userDocument = await Firestore.instance
            .collection("users")
            .document(user.uid)
            .get();

        push(context, Home(userDocument), initial: true);
      }
    });

    setState(() => isLoading = !isLoading);
  }

  @override
  void initState() {
    super.initState();
    initView.catchError((error) {
      print(error);
    });
  }

  Future get login async {
    setState(() => isLoading = !isLoading);

    if (formKey.currentState.validate()) {
      AuthResult auth = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

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

    var emailWidget = Padding(
      padding: EdgeInsets.only(bottom: 20, left: 10, right: 10),
      child: TextFormField(
        focusNode: nodes[0],
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.emailAddress,
        onFieldSubmitted: (text) =>
            FocusScope.of(context).requestFocus(nodes[1]),
        validator: (text) {
          if (text.isEmpty) {
            return "Do not leave empty";
          } else {
            setState(() => email = text);
          }
        },
        decoration: InputDecoration(
          labelText: "Email address",
          // labelStyle: TextStyle(color: Colors.white),
        ),
      ),
    );

    var passwordWidget = Padding(
      padding: EdgeInsets.only(bottom: 40, left: 10, right: 10),
      child: TextFormField(
        obscureText: true,
        focusNode: nodes[1],
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.text,
        validator: (text) {
          if (text.isEmpty) {
            return "Do not leave empty";
          } else {
            setState(() => password = text);
          }
        },
        decoration: InputDecoration(
          labelText: "Password",
          // labelStyle: TextStyle(color: Colors.white),
        ),
      ),
    );

    var loginButton = GestureDetector(
      onTap: () async {
        await login.catchError((error) {
          print(error);
          setState(() => isLoading = !isLoading);
        });
      },
      child: Material(
        borderRadius: BorderRadius.circular(10),
        color: Colors.lightBlue[900],
        elevation: 10,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text(
            "Login",
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
        height: size.width / 2.5,
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
                        "Login",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 35,
                        ),
                      ),
                    ),
                    emailWidget,
                    passwordWidget,
                    loginButton,
                  ],
                ),
        ),
      ),
    );

    var signUp = (isLoading)
        ? SizedBox()
        : FlatButton(
            onPressed: () {
              push(context, Register(), fullScreenDialog: true);
            },
            child: Text(
              "Don't have an accuont, Sign up.",
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
              SizedBox(height: 60),
              container,
              signUp,
            ],
          ),
        ),
      ),
    );
  }
}
