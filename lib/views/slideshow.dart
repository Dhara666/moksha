import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widgetkit/flutter_widgetkit.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:home_widget/home_widget.dart';
import 'package:moksha_beta/models/FlutterWidgetData.dart';
import 'package:moksha_beta/services/database.dart';
import 'package:moksha_beta/views/admin_quotes_approval_screen.dart';
import 'package:moksha_beta/views/homeView.dart';
import 'package:moksha_beta/widgets/alert_dialog.dart';
import 'package:moksha_beta/widgets/common_button.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

// class HomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(backgroundColor: Colors.white, body: FirestoreSlideshow());
//   }
// }

class FirestoreSlideshow extends StatefulWidget {
  String? quote;
  FirestoreSlideshow({Key? key,this.quote}) : super(key: key);
  createState() => FirestoreSlideshowState();
}

class FirestoreSlideshowState extends State<FirestoreSlideshow> {
  String _adUnitID = Platform.isIOS
      ? 'ca-app-pub-3940256099942544/3986624511'
      : "ca-app-pub-3940256099942544/2247696110";

  static const likedKey = 'liked_key';
  bool? liked;

   PageController? ctrl;

  final FirebaseFirestore db = FirebaseFirestore.instance;
  Stream? slides;
  bool isAdmin = false;

  // QuerySnapshot slides1;

  String activeTag = 'favs';

  // Keep track of current page to avoid unnecessary renders
  int currentPage = 0;

  List<String> documentIdList = [];
  List slideList = [];

  // QuerySnapshot likeGet;
  List<String> giveLikeList = [];

  BannerAd? _bannerAd;
  bool _bannerAdIsLoaded = false;
  static final AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  @override
  void initState() {
    super.initState();


   // print("--->widget.currentIndex ${widget.currentIndex}");

    _restorePersistedPreference();
    // _queryDb();
    _createInterstitialAd();
    initPlatformState();

    getStoriesDocument();

    //get all likes
    // getUserWiseLike();

    // HomeWidget.setAppGroupId('group.com.fasky');

    // Set state when page changes
    // ctrl.addListener(() {
    //   int next = ctrl.page!.round();
    //
    //   if (currentPage != next) {
    //     setState(() {
    //       currentPage = next;
    //     });
    //   }
    // });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Create the ad objects and load ads.
    _bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-3940256099942544/6300978111'
            : 'ca-app-pub-7666557347398781/4986783278',
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            print('$BannerAd loaded.');
            setState(() {
              _bannerAdIsLoaded = true;
            });
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('$BannerAd failedToLoad: $error');
            ad.dispose();
          },
          onAdOpened: (Ad ad) => print('$BannerAd onAdOpened.'),
          onAdClosed: (Ad ad) => print('$BannerAd onAdClosed.'),
        ),
        request: AdRequest())
      ..load();
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
  }

  getStoriesDocument() async {
    documentIdList.clear();
    var docReference = await FirebaseFirestore.instance
        .collection("Stories")
        .orderBy('create_time', descending: true)
        .get();
    docReference.docs.forEach((result) {
      documentIdList.add(result.id);
      slideList.add(result.data());
    });

    if(widget.quote != null && slideList.isNotEmpty) {
      print("----> widget.quote ${widget.quote} ");
      print("----> slideList ${slideList.length} ");
      var index;
      slideList.forEach((element) {
        print("--->element ${element}");
        // int index = slideList.indexWhere((item) => item["quote"] == payload);
        index = slideList.indexWhere((element) =>
        element['quote'] == widget.quote);
      });
      print("----->index quote $index");
      ctrl = PageController(viewportFraction: 0.8, initialPage: index);
    }
    else{
      print("----> widget.quote ${widget.quote} ");
      ctrl = PageController(viewportFraction: 0.8, initialPage: 0);
    }
    if (currentUserId.isNotEmpty) {
      await getUserWiseLike();
      await getAdmin();
    } else {
      setState(() {});
    }
  }

  Future<void> getUserWiseLike() async {
    giveLikeList.clear();
    OurDatabase().getAllLikes().then((value) {
      if (value?.docs != null) {
        value!.docs.forEach((result) {
          // documentId.add(result.documentID);
          // slideList.add(result.data);
          giveLikeList.add(result.id);
        });
        isLoaderShow = false;
        Future.delayed(Duration(seconds: 1), () {
          if (mounted) {
            setState(() {});
          }
        });
      }
    });
  }

  Future<void> getAdmin() async {
    DocumentSnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();
    if (querySnapshot.data() != null &&
        (querySnapshot.data() as Map<String, dynamic>).containsKey('isAdmin')) {
      var data = querySnapshot.data() as Map<String, dynamic>;
      isAdmin = data['isAdmin'];
      print("-->isAdmin $isAdmin");
    } else {
      isAdmin = false;
    }
  }

  void _restorePersistedPreference() async {
    var preferences = await SharedPreferences.getInstance();
    var liked = preferences.getBool(likedKey) ?? false;
    setState(() {
      this.liked = liked;
    });
  }

  // void _persistPreference() async {
  //   setState(() {
  //     liked = !liked!;
  //   });
  //   var preferences = await SharedPreferences.getInstance();
  //   preferences.setBool(likedKey, liked!);
  // }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-3940256099942544/1033173712'
            : 'ca-app-pub-7666557347398781/4795211588',
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < 3) {
              _createInterstitialAd();
            }
          },
        ));
  }

  _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return CircularProgressIndicator();
    }
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(

      onAdShowedFullScreenContent: (InterstitialAd ad) => print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
    return Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    final BannerAd? bannerAd = _bannerAd;
    return SafeArea(
      child: Stack(
        children: [
          slideList.length == 0 ?
          Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Center(child: CircularProgressIndicator(
                backgroundColor: Colors.black,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey)
            )),
          ) :
          Column(
            children: [
              isAdmin
                  ? InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AdminQuotesApprovalScreen()));
                },
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                      height: 40,
                      width: 40,
                      margin: EdgeInsets.only(right: 5, top: 5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.black),
                      child: Icon(Icons.approval,
                          color: Colors.white, size: 20)),
                ),
              )
                  : SizedBox(),
              Expanded(
                child: PageView.builder(
                    controller: ctrl,
                    itemCount: slideList.length,
                    onPageChanged: (page) {
                      print("--->currentPage :----->$currentPage");
                      setState(() {
                        currentPage = page;
                      });
                    },
                    itemBuilder: (context, int currentIdx) {
                      if (slideList.length >= currentIdx) {
                        print("--->isSubscription ${isSubscription}");
                        // Active page
                        bool active = currentIdx == currentPage;
                        return (isSubscription == false &&
                            currentPage != 0 &&
                            currentPage % 3 == 0 &&
                            _interstitialAd != null)
                            ? _showInterstitialAd()
                            : _buildStoryPage(
                            slideList[currentIdx], active, currentIdx);
                      } else {
                        return Container();
                      }
                    }),
              ),
              if (isSubscription == false && _bannerAdIsLoaded && bannerAd != null)
                Container(
                    height: bannerAd.size.height.toDouble(),
                    width: bannerAd.size.width.toDouble(),
                    child: AdWidget(ad: bannerAd))
            ],
          ),
        ],
      ),
    );

    /*return StreamBuilder(
        // stream: slides,
        stream: Firestore.instance.collection('stories').getDocuments().asStream(),
        initialData: [],
        builder: (context, AsyncSnapshot snap) {
          // List slideList = snap.data.toList();

          if(snap.data != null){
            return Container();
          }

          print(snap.data);

          return Container();*/ /*PageView.builder(
              controller: ctrl,
              itemCount: slideList.length,
              itemBuilder: (context, int currentIdx) {
                // if (slideList.length >= currentIdx) {
                //   // Active page
                //   bool active = currentIdx == currentPage;
                //   return _buildStoryPage(slideList[currentIdx], active);
                // } else {
                  return Container();
                // }
              })*/ /*;
        });*/
  }

  _queryDb({String tag = 'favs'}) async {
    // Make a Query
    Query query = db.collection('Stories').where('tags', arrayContains: tag);

    // Map the documents to the data payload
    slides = query.snapshots().map((list) => list.docs.map((doc) => doc.data));

    Stream slides1 = query.snapshots();

    print(slides1);
    // <DocumentSnapshot> items1 = slides1.;

    // DocumentReference doc_ref = Firestore.instance.collection("Stories").document();
    // DocumentSnapshot docSnap = await doc_ref.get();
    // var doc_id2 = docSnap.reference.documentID;
    // print(doc_id2);

    var documentReference =
    await FirebaseFirestore.instance.collection('Stories').snapshots();
    print(documentReference);

    // Update the active tag
    setState(() {
      activeTag = tag;
    });
  }

  _buildStoryPage(Map data, bool active, int currentIdx) {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    Future<String> getCurrentUID() async {
      String uid = (await _firebaseAuth.currentUser!).uid;
      return uid;
    }

    print(data);

    void share(String quote) {
      // final String text = "Download Moksha to receive messages from the Universe: https://www.johannagbjackson.com/mobile-app";
      //
      // final String quote = data['quote'] ?? '' + " \n - " + data['author'] + " \n\n\n" + text;

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
    final double top = active ? 35 : 120;
    final BannerAd? bannerAd = _bannerAd;
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
        child:
        //(currentIdx+1) % 4 == 0 && currentIdx != 0 && _bannerAdIsLoaded && bannerAd != null ?
        // Align(
        //   alignment: Alignment.bottomCenter,
        //   child: Container(
        //       margin: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
        //       height: bannerAd.size.height.toDouble(),
        //       width: bannerAd.size.width.toDouble(),
        //       child: AdWidget(ad: bannerAd)),
        // )

        //   Container(
        //    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
        //    child: NativeAdmob(
        //        // Your ad unit id
        //        adUnitID: _adUnitID,
        //        controller: _nativeAdController,
        //        type: NativeAdmobType.full,
        //        // Don't show loading widget when in loading state
        //        // loading: Container(),
        //      ),
        //  )
        //   :
        Column(
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
                      // data['author'].toString()
                      _sendAndUpdate(
                          data['author'].toString() != 'null'
                              ? data['author'].toString()
                              : '',
                          data['quote'].toString());
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text(
                            'This quote is now on your home widget!',
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.justify,
                          ),
                          actions: <Widget>[
                            commonTextButton(
                              buttonText: 'OK',
                              function: () => Navigator.pop(context, 'OK'),
                            )
                          ],
                        ),
                      );
                    } else {
                      print("ios click");
                      WidgetKit.setItem(
                          'widgetData',
                          jsonEncode(FlutterWidgetData(data['author']
                              .toString() !=
                              null &&
                              data['author'].toString().isNotEmpty &&
                              data['author'].toString() != 'null'
                              ? "${data['quote'].toString()}\n\n - ${data['author'].toString()}"
                              : data['quote'].toString())),
                          'group.app.moksha');
                      WidgetKit.reloadAllTimelines();
                      HapticFeedback.heavyImpact();
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text(
                            'This quote is now on your home widget!',
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.justify,
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'OK'),
                              child: const Text(
                                'OK',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    // WidgetKit.setItem('widgetData', jsonEncode(FlutterWidgetData(data['quote'])), 'group.com.fasky');
                    // WidgetKit.reloadAllTimelines();
                    /*HomeWidget.updateWidget(
                        name: 'HomeWidgetExampleProvider',
                        androidName: 'HomeWidgetExampleProvider',
                        iOSName: 'HomeWidgetExample',
                      );
*/
                    // HomeWidget.saveWidgetData<String>('id', "Set data");
                    /*  bool isTrue = await  Navigator.push(context, MaterialPageRoute(builder: (context) => AddMyQuotes(quotesData: data['quote'], docId: data['doc_id'])));
                      if(isTrue) {
                        refresh();
                      }*/
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
    // data['author'].toString() != null && data['author'].toString().isNotEmpty ?
    // "Author : - ${data['author'].toString()}\n${data['quote'].toString()}" : data['quote'].toString())

    String data = "";
    if (author != null && author.isNotEmpty) {
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
    print("------>currentUserId $currentUserId");
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
          icon: Icon(
            /*liked*/
              giveLikeList.contains(documentIdList[currentIdx])
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: /*liked*/ giveLikeList
                  .contains(documentIdList[currentIdx])
                  ? Colors.red
                  : Colors.grey[50]),
          onPressed: () {
            //dynamic  uid = getCurrentUID();
            //db.collection('Stories').document(data['likedBy']).updateData(uid);
            // _persistPreference();

            HapticFeedback.heavyImpact();
            print("hello ${documentIdList[currentIdx]}");
            isLoaderShow = true;

            bool isLiked =
            giveLikeList.contains(documentIdList[currentIdx]);

            if (isLiked) {
              OurDatabase().deleteLikes(documentIdList[currentIdx]);
              getUserWiseLike();
              setState(() {});
            } else {
              OurDatabase().addLikes(documentIdList[currentIdx]);
              getUserWiseLike();
              setState(() {});
            }
          });
    }
  }
}