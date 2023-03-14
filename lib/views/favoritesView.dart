import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widgetkit/flutter_widgetkit.dart';
import 'package:home_widget/home_widget.dart';
import 'package:moksha_beta/models/FlutterWidgetData.dart';
import 'package:moksha_beta/services/auth_service.dart';
import 'package:moksha_beta/services/database.dart';
import 'package:moksha_beta/widgets/alert_dialog.dart';
import 'package:moksha_beta/widgets/common_button.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteView extends StatelessWidget {
  const FavoriteView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text("Favorites",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontFamily: "Typewriter"))),
        body: FavoriteListView());
  }
}

class FavoriteListView extends StatefulWidget {
  createState() => FavoriteListViewState();
}

class FavoriteListViewState extends State<FavoriteListView> {
  String currentUserId = '';
  static const likedKey = 'liked_key';

  bool? liked;

  final PageController ctrl = PageController(viewportFraction: 0.8);

  final FirebaseFirestore db = FirebaseFirestore.instance;
  Stream? slides;
  String activeTag = 'favs';
  int currentPage = 0;

  List<String> documentIdList = [];
  List slideList = [];
  List<String> giveLikeList = [];
  List likeList = [];
  bool isLoading = true;
  String? uid;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
    getCurrentUserId();
    _restorePersistedPreference();

    initPlatformState();

    getStoriesDocument();

    //get all likes
    getUserWiseLike();

    // Set state when page changes
    ctrl.addListener(() {
      int next = ctrl.page!.round();

      if (currentPage != next) {
        setState(() {
          currentPage = next;
        });
      }
    });
  }

  getStoriesDocument() async {
    documentIdList.clear();
    var doc_ref = await FirebaseFirestore.instance
        .collection("Stories")
        .where('tags', arrayContains: 'favs')
        .get();
    doc_ref.docs.forEach((result) {
      documentIdList.add(result.id);
      slideList.add(result.data());
    });
    setState(() {});
  }

  void getUserWiseLike() {
    giveLikeList.clear();
    OurDatabase().getAllLikes().then((value) {
      if (value!.docs != null) {
        value.docs.forEach((result) {
          giveLikeList.add(result.id);
        });
        isLoaderShow = false;
        Future.delayed(Duration(seconds: 1), () {
          setState(() {});
        });
        getLikedStories();
      }
    });
  }

  void _restorePersistedPreference() async {
    var preferences = await SharedPreferences.getInstance();
    var liked = preferences.getBool(likedKey) ?? false;
    setState(() {
      this.liked = liked;
    });
  }

  void getCurrentUserId() async {
  uid = await AuthService().getCurrentUID();
    currentUserId = uid!;
    setState(() {});
  }

  getLikedStories() async {
    likeList.clear();
    giveLikeList.forEach((element) async {
      var doc_ref =
      await FirebaseFirestore.instance.collection("Stories").doc(element);
      doc_ref.snapshots().forEach((result) {
        likeList.add(result.data());
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      likeList.length == 0
          ? Center(
              child: Text(
                  "“No quotes liked yet! Tap the ❤️ heart icon to find your liked quotes here”",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontFamily: "Typewriter")))
          : PageView.builder(
          controller: ctrl,
          itemCount: likeList.length,
          itemBuilder: (context, int currentIdx) {
            if (likeList.length >= currentIdx) {
              // Active page
              bool active = currentIdx == currentPage;
              return _buildStoryPage(likeList[currentIdx], active, currentIdx);
            } else {
              return Container();
            }
          }),
      if (uid != null)
        isLoading
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
    ]);
  }


  _buildStoryPage(Map data, bool active, int currentIdx) {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    Future<String> getCurrentUID() async {
      String uid = (await _firebaseAuth.currentUser!).uid;
      return uid;
    }

    print(data);

    void share(String quote) {
      // final String text =
      //     "Download Moksha to receive messages from the Universe: https://www.johannagbjackson.com/mobile-app";
      //
      // final String quote =
      //     data['quote'] + " \n - " + data['author'] + " \n\n\n" + text;

      // Share.share(
      //   quote,
      //   subject: text,
      // );
      Share.share(
        "$quote \n\nDownload Moksha from App Store: \nhttps://apps.apple.com/in/app/moksha-liberation/id1600413009",
        subject: 'Moksha - Liberation',
      );
    }

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    // Animated Properties
    final double blur = active ? 20 : 0;
    final double offset = active ? 20 : 0;
    final double top = active ? 75 : 150;

    return AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOutQuint,
        width: _width / 2,
        height: _height,
        margin: EdgeInsets.only(top: top, bottom: 20, right: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            image: DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage(data['img']),
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black87,
                  blurRadius: blur,
                  offset: Offset(offset, offset))
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(data['quote'],
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontFamily: "Typewriter")),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(data['author'] ?? '',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontFamily: "Typewriter")),
            ),
            SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              InkWell(
                  onTap: () async {
                    if (Platform.isAndroid) {
                      HapticFeedback.heavyImpact();
                      _sendAndUpdate(
                          data['author'].toString() != 'null' ? data['author'].toString() : '',data['quote'].toString());
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('This quote is now on your home widget!',style: TextStyle(fontSize: 14),textAlign: TextAlign.justify,),
                          actions: <Widget>[
                            commonTextButton(
                              buttonText: 'OK',
                              function: () => Navigator.pop(context, 'OK'),
                            )
                          ],
                        ),
                      );
                      // data['author'].toString()
                    } else {
                      print("ios click");
                      WidgetKit.setItem(
                          'widgetData',
                          jsonEncode(FlutterWidgetData(data['author']
                                          .toString() !=
                                      null &&
                                  data['author'].toString().isNotEmpty
                          && data['author'].toString() != 'null'
                              ? "${data['quote'].toString()}\n\n - ${data['author'].toString()}"
                              : data['quote'].toString())),
                          'group.app.moksha');
                      WidgetKit.reloadAllTimelines();
                      HapticFeedback.heavyImpact();
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('This quote is now on your home widget!',style: TextStyle(fontSize: 14),textAlign: TextAlign.justify,),
                          actions: <Widget>[
                            commonTextButton(
                              buttonText: 'OK',
                              function: () => Navigator.pop(context, 'OK'),
                            )
                          ],
                        ),
                      );
                      print("ios click");
                    }
                  },
                  child: Container(
                      margin: EdgeInsets.only(right: 10, top: 0),
                      child: Icon(Icons.home, color: Colors.white, size: 25))),
              likeButtonShow(currentIdx),
              IconButton(
                  icon: Icon(
                    Icons.share,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    share(data['quote']);
                  })
            ])
          ],
        ));
  }

  bool isLoaderShow = false;

  Future<void> _sendAndUpdate(String author, String quotes) async {
    await _sendData(author, quotes);
    await _updateWidget();
    _loadData();
  }

 _sendData(String author, String quotes) async {
    String data = "";
    if (author != null && author.isNotEmpty) {
      data = "$quotes \n\n - $author";
    } else {
      data = quotes;
    }

    try {
      return Future.wait<bool?>([
        HomeWidget.saveWidgetData<String>('title', ""),
        HomeWidget.saveWidgetData<String>('message', data),
      ]);
    } on PlatformException catch (exception) {
      debugPrint('Error Sending Data. $exception');
    }
  }

 _updateWidget() async {
    try {
      return HomeWidget.updateWidget(
          name: 'HomeWidgetExampleProvider', iOSName: 'HomeWidgetExample');
    } on PlatformException catch (exception) {
      debugPrint('Error Updating Widget. $exception');
    }
  }

 _loadData() async {
    try {
      return Future.wait([
        HomeWidget.getWidgetData<String>('title', defaultValue: 'Default Title')
            .then((value) => "_titleController.text"),
        HomeWidget.getWidgetData<String>('message',
            defaultValue: 'Default Message')
            .then((value) => "_messageController.text"),
      ]);
    } on PlatformException catch (exception) {
      debugPrint('Error Getting Data. $exception');
    }
  }

  Future<void> initPlatformState() async {
    WidgetKit.reloadAllTimelines();
    WidgetKit.reloadTimelines('test');

    final data = FlutterWidgetData('Hello From Flutter');
    final resultString =
        await WidgetKit.getItem('testString', 'group.app.moksha');
    final resultBool = await WidgetKit.getItem('testBool', 'group.app.moksha');
    final resultNumber =
        await WidgetKit.getItem('testNumber', 'group.app.moksha');
    final resultJsonString =
        await WidgetKit.getItem('testJson', 'group.app.moksha');

    var resultData;
    if (resultJsonString != null) {
      resultData = FlutterWidgetData.fromJson(jsonDecode(resultJsonString));
    }

    WidgetKit.setItem('testString', 'Hello World', 'group.app.moksha');
    WidgetKit.setItem('testBool', false, 'group.app.moksha');
    WidgetKit.setItem('testNumber', 10, 'group.app.moksha');
    WidgetKit.setItem('testJson', jsonEncode(data), 'group.app.moksha');
  }

  likeButtonShow(int currentIdx) {
    if (currentUserId.isEmpty) {
      return IconButton(
          icon: Icon(Icons.favorite_border, color: Colors.grey[50]),
          onPressed: () {
            showAlert(context, "Please login/signup to favorite quotes");
          });
    } else {
      return isLoaderShow
          ? Container(
              height: 25,
              width: 25,
              margin: EdgeInsets.only(left: 12, right: 11),
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                  backgroundColor: Colors.red,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black)))
          : IconButton(
              icon: Icon(Icons.favorite, color: Colors.red),
              onPressed: () async {
                print("hello ${giveLikeList[currentIdx]}");
                HapticFeedback.heavyImpact();
                isLoaderShow = true;
                await OurDatabase().deleteLikes(giveLikeList[currentIdx]);
                getUserWiseLike();
                setState(() {});
              });
    }
  }
}
