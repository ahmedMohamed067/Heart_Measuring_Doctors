import 'package:doctors/Pages/Home/Screens/clinics.dart';
import 'package:doctors/Pages/Home/Screens/requests.dart';

import '../pages.dart';

class Home extends StatefulWidget {
  Home(this.userDocument);
  final DocumentSnapshot userDocument;
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  bool isLoading = false;
  TabController controller;
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  int selectedIndex = 0;
  List<String> titles = ["Requests", "Clinics"];

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);

    controller.addListener(() {
      setState(() => selectedIndex = controller.index);
    });

    _firebaseMessaging
        .subscribeToTopic(widget.userDocument.documentID)
        .then((_) {
      print("subscriped");
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      // onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onRsesume: $message");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var body = TabBarView(
      controller: controller,
      children: <Widget>[
        Requests(widget.userDocument),
        Clinics(widget.userDocument),
      ],
    );

    var topBar = ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      title: Text(
        "Hi ${widget.userDocument["fullName"]}",
        style: TextStyle(
          color: Colors.white,
          fontSize: 35,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        titles[selectedIndex],
        style: TextStyle(
          color: Colors.white54,
          fontSize: 17,
        ),
      ),
      trailing: GestureDetector(
        onTap: (isLoading)
            ? null
            : () async {
                setState(() => isLoading = !isLoading);

                await _firebaseMessaging
                    .unsubscribeFromTopic(widget.userDocument.documentID);
                await FirebaseAuth.instance.signOut();
                push(context, Login(), initial: true);

                setState(() => isLoading = !isLoading);
              },
        child: (isLoading)
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
              )
            : Image.asset(
                "assets/logo.png",
                // height: size.width / 3,
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: (selectedIndex == 0)
            ? null
            : FloatingActionButton(
                onPressed: () {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => AddDialog(widget.userDocument),
                  );
                },
                backgroundColor: Colors.lightBlue[900],
                child: Icon(Icons.add),
              ),
        backgroundColor: Colors.transparent,
        bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            controller.animateTo(index);
          },
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.notifications,
                size: (selectedIndex == 0) ? 30 : 28,
                color: (selectedIndex == 0)
                    ? Colors.lightBlue[900]
                    : Colors.lightBlue[900].withOpacity(0.7),
              ),
              title: SizedBox(),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.edit,
                size: (selectedIndex == 1) ? 30 : 28,
                color: (selectedIndex == 1)
                    ? Colors.lightBlue[900]
                    : Colors.lightBlue[900].withOpacity(0.7),
              ),
              title: SizedBox(),
            )
          ],
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              topBar,
              Expanded(
                child: body,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
