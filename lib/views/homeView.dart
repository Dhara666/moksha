import 'dart:io';

import 'package:flutter/material.dart';
import 'package:moksha_beta/main.dart';
import 'package:moksha_beta/views/add_my_quotes.dart';
import 'package:moksha_beta/views/settingsView.dart';
import 'package:moksha_beta/views/slideshow.dart';
// import 'package:system_shortcuts/system_shortcuts.dart';

import '../services/auth_service.dart';
import 'my_quotes.dart';


String currentUserId = "";
String currentUserName = "";

class Home extends StatefulWidget {
  String? quote;
  Home({Key? key, this.quote}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  // initializing push notifs on start of the app

  int _currentIndex = 0;

  List<Widget>? _children;


  @override
  void initState() {
    print("-----> ${widget.quote}");
    _children = [FirestoreSlideshow(quote: widget.quote), MyQuotes(), SettingsPage()];
    // TODO: implement initState
    super.initState();
    currentUser();
    currentUserEmail();
  }

  currentUserEmail() async {
    String userName = await AuthService().getCurrentUName();
    currentUserName = userName;
    // setState(() {});
    print("userName => $userName");
  }

  currentUser() async {
    String uid = await AuthService().getCurrentUID();
    currentUserId = uid;
    // setState(() {});
    print("uid => $uid");
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async{
          // await SystemShortcuts.home();
          return false;
        },
        child: Stack(
          children: [
            Scaffold (
              appBar: AppBar (
                automaticallyImplyLeading: false,
                title: Center (
                    child: Text("Moksha", style: TextStyle(fontFamily: "Typewriter", letterSpacing: 4, fontSize: 25))),
                backgroundColor: Colors.black,
              ),
              body: _children![_currentIndex],
              bottomNavigationBar: BottomNavigationBar(
                backgroundColor: Colors.black,
                onTap: onTabTapped,
                currentIndex: _currentIndex,
                selectedLabelStyle: TextStyle(fontSize: 14),
                selectedItemColor: Colors.white,
                unselectedLabelStyle:TextStyle(fontSize: 12),
                unselectedItemColor: Colors.white,
                items: [
                  BottomNavigationBarItem(
                    icon: new Icon(
                      Icons.format_quote,
                      color: Colors.white,
                    ),
                    label: 'Quotes',
                    // title: Text(
                    //   'Quotes',
                    //   style: TextStyle(
                    //       color: Colors.white, fontFamily: "Typewriter", fontSize: 15),
                    // ),
                  ),
                  BottomNavigationBarItem(
                    icon: new Icon(
                      Icons.format_quote,
                      color: Colors.white,
                    ),
                    label: 'My Quotes',
                    // title: Text(
                    //   'My Quotes',
                    //   style: TextStyle(
                    //       color: Colors.white, fontFamily: "Typewriter", fontSize: 15),
                    // ),
                  ),
                  BottomNavigationBarItem(
                    icon: new Icon(Icons.settings, color: Colors.white),
                    label: 'Settings',
                    // title: Text(
                    //   'Settings',
                    //   style: TextStyle(
                    //       color: Colors.white, fontFamily: "Typewriter", fontSize: 15),
                    // ),
                  ),
                ],
              ),
            ),
            (Platform.isIOS && isCallApiLoading)
                ? Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Center(child: CircularProgressIndicator(
                  backgroundColor: Colors.black,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey)
              )),
            )
                : Container()
          ],
        ),
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
