import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widgetkit/flutter_widgetkit.dart';
import 'package:home_widget/home_widget.dart';
import 'package:moksha_beta/models/FlutterWidgetData.dart';
import 'package:moksha_beta/services/webview.dart';
import 'package:moksha_beta/views/add_my_quotes.dart';
import 'package:moksha_beta/views/sign_up.dart';
import 'package:moksha_beta/widgets/alert_dialog.dart';
import 'package:moksha_beta/widgets/common_button.dart';
import 'package:share/share.dart';
import 'package:toast/toast.dart';
import '../main.dart';
import '../services/database.dart';
import '../shop_screen.dart';
import 'homeView.dart';


class MyQuotes extends StatefulWidget {
  @override
  _MyQuotesState createState() => _MyQuotesState();
}

class _MyQuotesState extends State<MyQuotes> {

  final PageController ctrl = PageController(viewportFraction: 0.8);
  int currentPage = 0;
  Stream? myQuotes;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  bool checkBox = false;
  String noDataTitle = "";
  bool isLoading = true;
  int? selectedIndex;
  late List slideList;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _getQuotes();

    ctrl.addListener(() {
      int next = ctrl.page!.round();

      if (currentPage != next) {
        setState(() {
          currentPage = next;
        });
      }
    });


    // print(currentUserId == null);
    // print(currentUserId.isEmpty);

    // Future.delayed(Duration(milliseconds: 500), () {
    //   print("Data");
    //   if(currentUserId.isEmpty) {
    //     showAlert(context, "Please login/sign up to add your own quotes");
    //   }
    //   noDataTitle = "No data available";
    //   setState(() {});
    // });

    // if(currentUserId.isEmpty) {
    //   showAlert(context, "You will login after add you quotes");
    // }
  }

  // void showAlert(BuildContext context) {
  //   showDialog (
  //       context: context,
  //       builder: (context) => AlertDialog (
  //         content: Text('You will login after add you quotes'),
  //         actions: <Widget>[
  //           FlatButton(
  //             child: const Text('Cancel', style: TextStyle(color: Colors.red)),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           FlatButton(
  //             child: const Text('Login', style: TextStyle(color: Colors.black)),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpView(authFormType: AuthFormType.signIn)));
  //             },
  //           )
  //         ],
  //       ));
  // }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return
    //   currentUserId.isEmpty ?
    //
    // Container (
    //   alignment: Alignment.center,
    //   child: Text(noDataTitle, style: TextStyle(fontFamily: "Typewriter", fontSize: 18)),
    // ) :
      Column (
      children: [

        InkWell (
          onTap: () async {
            if(currentUserId.isEmpty) {
              showAlert(context, "Please login/sign up to add your own quotes");
            } else if(isSubscription == false  && slideList.length >= 2){
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Free users cannot add more than 2 my quotes.',style: TextStyle(fontSize: 14),textAlign: TextAlign.justify,),
                  actions: <Widget>[
                    commonTextButton(
                      buttonText: ' Upgrade to premium',
                      function: () {
                        Navigator.pop(context, 'OK');
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ShopScreen()));
                      },
                    ),
                    commonTextButton(
                      buttonText: 'Ok',
                      function: () => Navigator.pop(context, 'OK'),
                    )
                  ],
                ),
              );
            }
            else{
              print("---->slideList length ${slideList.length}");
              bool isTrue = await  Navigator.push(context, MaterialPageRoute(builder: (context) => AddMyQuotes()));
              if(isTrue) {
                refresh();
              }
            }
            // showAlert(context, "You will login after add you quotes");

          },
          child: Align (
            alignment: Alignment.centerRight,
            child: Container (
                height: 40,
                width: 40,
                margin: EdgeInsets.only(right: 5, top: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black
                ),
                child: Icon(Icons.add, color: Colors.white, size: 27)),
          ),
        ),

        Expanded (
          child: StreamBuilder (
              // stream: myQuotes,
              stream: FirebaseFirestore.instance.collection('users').doc(currentUserId).collection("my_quotes").get().asStream(),
              // stream: Firestore.instance.collection('users').getDocuments().asStream(),

              // initialData: [],

              builder: (context, AsyncSnapshot snap) {
                // List slideList = snap.data.toList();
                // print("---->>"+snap.data);
                // var slideList = snap.data ?? [];
                slideList = snap.data?.docs ?? [];
                print(slideList);
                // snap.data?.documents[0].data['quote']
                if(snap.data == null) return Container();

                return slideList != null && slideList.length != 0 ? PageView.builder(
                    controller: ctrl,
                    itemCount: slideList.length,
                    itemBuilder: (context, index) {
                      if (slideList.length >= index) {
                        // Active page
                        bool active = index == currentPage;
                        return
                        _buildStoryPage(slideList[index].data(), active, index);
                      } else {
                        return Container();
                      }
                    }) : Container(
                    alignment: Alignment.center,
                    child: Text("“No quotes added yet! Tap + icon to add your own quotes!”",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontFamily: "Typewriter"))
                );
              }),
        ),
      ],
    );
  }

  Future removeQuote(
    String currentId,
    String id,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentId)
          .collection("my_quotes")
          .doc(id)
          .delete();
      setState(() {

      });
    } catch (e) {
      return false;
    }
  }

  _buildStoryPage(Map data, bool active, int index) {

    print(data);

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

    Future<String> getCurrentUID() async {
      String uid = (await _firebaseAuth.currentUser!).uid;
      return uid;
    }

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    // Animated Properties
    final double blur = active ? 20 : 0;
    final double offset = active ? 20 : 0;
    final double top = active ? 35 : 120;

    return AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOutQuint,
        width: _width / 2,
        height: _height,
        margin: EdgeInsets.only(top: top, bottom: 20, right: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
          /*  image: DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage(data['img']),
            ),*/
            color: Colors.black,
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
            /*SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(data['author'],
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontFamily: "Typewriter")),
            ),*/
            SizedBox(height: 20),
            Row (
              mainAxisAlignment: MainAxisAlignment.end,
              children: [

                InkWell (
                    onTap: () async {

                      // _sendAndUpdate(data['quote'].toString());

                      if(Platform.isAndroid) {
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
                        HapticFeedback.heavyImpact();
                        // data['author'].toString()
                        _sendAndUpdate(data['author'].toString() != 'null' ? data['author'].toString() : '', data['quote'].toString());

                      } else {

                        print("ios click");
                        WidgetKit.setItem('widgetData', jsonEncode(FlutterWidgetData(data['author'].toString() != null && data['author'].toString().isNotEmpty  && data['author'].toString() != 'null' ?
                        "${data['quote'].toString()}\n\n - ${data['author'].toString()}" : data['quote'].toString())), 'group.app.moksha');
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

                      // WidgetKit.setItem('widgetData', jsonEncode(FlutterWidgetData(data['quote'])), 'group.com.fasky');
                      // WidgetKit.reloadAllTimelines();


                      /*HomeWidget.updateWidget(
                        name: 'HomeWidgetExampleProvider',
                        androidName: 'HomeWidgetExampleProvider',
                        iOSName: 'HomeWidgetExample',
                      );  */

                      // HomeWidget.saveWidgetData<String>('id', "Set data");

                      /*  bool isTrue = await  Navigator.push(context, MaterialPageRoute(builder: (context) => AddMyQuotes(quotesData: data['quote'], docId: data['doc_id'])));
                      if(isTrue) {
                        refresh();
                      }*/
                    },
                    child: Container(
                        margin: EdgeInsets.only(right: 10, top: 10),
                        child: Icon(Icons.home, color: Colors.white, size: 25)
                    )
                ),

                InkWell (
                    onTap: () async {
                      bool isTrue = await  Navigator.push(context, MaterialPageRoute(builder: (context) => AddMyQuotes(quotesData: data['quote'], docId: data['doc_id'])));
                      if(isTrue) {
                        refresh();
                      }
                    },
                    child: Container (
                      margin: EdgeInsets.only(right: 10, top: 10),
                        child: Icon(Icons.edit, color: Colors.white, size: 25)
                    )),

                InkWell (
                    onTap: ()  {
                      /*bool isTrue = await  Navigator.push(context, MaterialPageRoute(builder: (context) => AddMyQuotes(quotesData: data['quote'], docId: data['doc_id'])));
                      if(isTrue) {
                        refresh();
                      }*/
                      print('data quotes-->>${data['quote']}');
                      share(data['quote']);
                    },

                    child: Container(
                        margin: EdgeInsets.only(right: 10, top: 10),
                        child: Icon(Icons.share, color: Colors.white, size: 25)
                    )),
                InkWell(
                    onTap: () {
                      isLoading = true;
                      setState(() {});
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => StatefulBuilder(
                          builder: (context, setState) => AlertDialog(
                            title: const Text(
                              'Are you sure you want to remove this quote?',
                              style: TextStyle(fontSize: 14),
                              textAlign: TextAlign.justify,
                            ),
                            actions: <Widget>[
                              commonTextButton(
                                buttonText: 'Cancel',
                                function: () =>
                                    Navigator.pop(context, 'Cancel'),
                              ),
                              isLoading
                                  ? commonTextButton(
                                      buttonText: 'Yes',
                                      function: () async {
                                        isLoading = false;
                                        setState(() {});
                                        await removeQuote(
                                            currentUserId, data['doc_id']);
                                        Navigator.pop(context);
                                      },
                                    )
                                  : Container(
                                      alignment: Alignment.center,
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        backgroundColor: Colors.black,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.grey,
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                        margin: EdgeInsets.only(right: 10, top: 10),
                        child:
                            Icon(Icons.delete, color: Colors.white, size: 25))),
              ],
            ),
            SizedBox(height: 30,),
            isSubscription == false ? Container() :
            data['isApproval'] == true || data['isApproval'] == null  ? SizedBox() :
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 25),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                        // if(selectedIndex == index){
                        //   // checkBox = !checkBox;
                        // }
                        print("selectedIndex$selectedIndex");
                        print("checkBox: $checkBox");
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                          border: Border.all(color: Colors.white)),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: selectedIndex == index
                            ? Icon(
                                Icons.check,
                                size: 15.0,
                                color: Colors.white,
                              )
                            : Icon(
                                Icons.check,
                                size: 15.0,
                                color: Colors.black,
                              ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15,),
                  data['isApproval'] == true || data['isApproval'] == null  ? SizedBox() : Expanded(
                    child: RichText(
                      textAlign: TextAlign.start,
                        text: TextSpan(
                            text: 'I agree that I have read the ',
                            style: TextStyle(color: Colors.white,fontSize: 10, fontFamily: 'Typewriter',),
                            children: [
                              TextSpan(
                                  text: 'quote release',
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  MyWebView(
                                                    title: "About",
                                                    selectedUrl:
                                                        "https://www.johannagbjackson.com/moksha-quote-release-and-standards",
                                                  )));
                                    },
                                  style: TextStyle(
                                      decoration: TextDecoration.underline
                                  )
                              ),
                          TextSpan(
                            text: ' & my quote adheres to ',
                          ),
                          TextSpan(
                            text: 'community quote standards',
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  MyWebView(
                                                    title: "About",
                                                    selectedUrl:
                                                        "https://www.johannagbjackson.com/moksha-quote-release-and-standards",
                                                  )));
                                },
                              style: TextStyle(
                                  decoration: TextDecoration.underline
                              )
                          ),
                        ])),
                  )
                ],
              ),
            ),
            isSubscription == false ? Container() :
            data['isApproval'] == true || data['isApproval'] == null  ? SizedBox() : Container(
                width: MediaQuery.of(context).size.width * 0.4,
                margin: EdgeInsets.symmetric(horizontal: 60),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: GestureDetector(
                  onTap: () {
                    print('checkBox--->>${selectedIndex == index}');
                        if (selectedIndex == index) {
                          HapticFeedback.heavyImpact();
                          DocumentReference adminTable = FirebaseFirestore.instance
                              .collection('admin')
                              .doc(data['doc_id']);
                          Map<String, dynamic> _data = {};
                          _data = {
                            "doc_id": data['doc_id'],
                            "isApproval": false,
                            "create_time": DateTime.now(),
                            "userName": currentUserName,
                            "quote": data['quote'],
                            "userId": currentUserId
                          };
                          adminTable.set(_data);
                          print('data---->>$_data');
                        } else {
                          Toast.show("Please, read and accept the quote release and standards before you make your quotes public",
                              backgroundColor: Colors.black,
                              textStyle:  TextStyle(color: Colors.white),
                              backgroundRadius: 10,
                              border:
                                  Border.all(color: Colors.white, width: 1.5),
                              duration: 3,
                              gravity: Toast.top);
                        }
                      },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Make it public',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )),
            // data['isDecline'] == false || data['isDecline'] == null ? SizedBox() : Container(
            //     width: MediaQuery.of(context).size.width * 0.4,
            //     margin: EdgeInsets.symmetric(horizontal: 60),
            //     decoration: BoxDecoration(
            //       color: Colors.white,
            //       borderRadius: BorderRadius.circular(30),
            //     ),
            //     child: GestureDetector(
            //       onTap: (){
            //         showDialog<String>(
            //           context: context,
            //           builder:
            //               (BuildContext context) =>
            //               AlertDialog(
            //                 title: Text(
            //                   'This quote was declined by the admin. You can’t resubmit the same quote again.',
            //                   style:
            //                   TextStyle(fontSize: 16),
            //                   textAlign:
            //                   TextAlign.justify,
            //                 ),
            //                 actions: <Widget>[
            //                   commonTextButton(
            //                     buttonText: 'Ok',
            //                     function: () =>
            //                         Navigator.pop(context,
            //                             'Ok'),
            //                   )
            //                 ],
            //               ),
            //         );
            //       },
            //       child: Padding(
            //         padding: EdgeInsets.symmetric(vertical: 10),
            //         child: Text(
            //           'Declined quote',
            //           textAlign: TextAlign.center,
            //         ),
            //       ),
            //     ))
          ],
        ));
  }

  refresh() {
    setState(() {});
  }

  void share(String quote) {
    // final String text = "Download Moksha to receive messages from the Universe: https://www.johannagbjackson.com/mobile-app";
    //
    // final String quote = data + " \n - " + " \n\n\n" + text;

    Share.share(
      "$quote \n\nDownload Moksha from App Store: \nhttps://apps.apple.com/in/app/moksha-liberation/id1600413009",
      subject: 'Moksha - Liberation',
    );
  }

  /*Future<void> _sendAndUpdate(String data) async {
    await _sendData(data);
    await _updateWidget();
  }

  Future<void> _sendData(String data) async {
    try {
      return Future.wait([
        HomeWidget.saveWidgetData<String>('title', "Nots"),
        HomeWidget.saveWidgetData<String>('message', data),
      ]);
    } on PlatformException catch (exception) {
      debugPrint('Error Sending Data. $exception');
    }
  }

  Future<void> _updateWidget() async {
    try {
      return HomeWidget.updateWidget(
          name: 'HomeWidgetExampleProvider', iOSName: 'HomeWidgetExample');
    } on PlatformException catch (exception) {
      debugPrint('Error Updating Widget. $exception');
    }
  }*/




  Future<void> _sendAndUpdate(String author, String quotes) async {

    print(author);

    bool sarta = author != null;

    print(sarta);

    await _sendData(author, quotes);
    await _updateWidget();
    _loadData();
  }

 _sendData(String author, String quotes) async {

    // data['author'].toString() != null && data['author'].toString().isNotEmpty ?
    // "Author : - ${data['author'].toString()}\n${data['quote'].toString()}" : data['quote'].toString())

    String data = "";
    if(author != null && author.isNotEmpty) {
      data = "$quotes \n\n - $author";
    } else {
      data = quotes;
    }

    try {
      return Future.wait([
        HomeWidget.saveWidgetData<String>('title', ""),
        // HomeWidget.saveWidgetData<String>('message', _messageController.text),
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

}
