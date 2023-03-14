import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:home_widget/home_widget.dart';
import 'package:http/http.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:moksha_beta/models/inapp_purchase_invoice_model.dart';
import 'package:moksha_beta/prefrences.dart';
import 'package:moksha_beta/services/auth_service.dart';
import 'package:moksha_beta/services/iap_service.dart';
import 'package:moksha_beta/views/firstView.dart';
import 'package:moksha_beta/views/homeView.dart';
import 'package:moksha_beta/views/sign_up.dart';
import 'package:moksha_beta/widgets/provider_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:workmanager/workmanager.dart';
import 'app_state.dart';
import 'views/intro_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

// void main() => runApp(MyApp());

// List<ProductDetails> products = [];
// List<String> productIds = <String>['gold_sub', 'premium_sub', 'plus_sub'];

bool isIntroScreenShow = false;
bool isSubscription = false;
String? verificationData;
String? appSecretKey = "c359ab52d73f4eaf854ca8d2bb14eb11";
bool isCallApiLoading = false;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey();
String? selectedNotificationPayload;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final NotificationAppLaunchDetails? notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      selectedNotificationPayload = notificationAppLaunchDetails!.payload;
  }
  await init();
  MobileAds.instance.initialize();
  // Workmanager.initialize(callbackDispatcher, isInDebugMode: kDebugMode);
  runApp(MyApp());
}

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) {
    debugPrint("Native called background task: $taskName");
    final now = DateTime.now();
    return Future.wait<bool?>([
      HomeWidget.saveWidgetData('title', 'Updated from Background'),
      HomeWidget.saveWidgetData('message',
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}'),
      HomeWidget.updateWidget(
          name: 'HomeWidgetExampleProvider', iOSName: 'HomeWidgetExample'),
    ]).then((value) {
      return !value.contains(false);
    });
  });
}
// final FirebaseMessaging _fcm = FirebaseMessaging();

Future<void> init() async {
  sharedPreferences = await SharedPreferences.getInstance();

  // WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: kDebugMode);
  // await _fcm.requestNotificationPermissions();
  // await _fcm.configure (
  //     onMessage: (Map<String, dynamic> message) async {
  //       print('onMessage: $message');
  //     },
  //     // called when app has been closed completely
  //     onLaunch: (Map<String, dynamic> message) async {
  //       print('onMessage: $message');
  //     },
  //     // called when app is running in background
  //     onResume: (Map<String, dynamic> message) async {
  //       print('onMessage: $message');
  //     }
  // );
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    ToastContext().init(context);
    return Provider(
      auth: AuthService(),
      child: MaterialApp (
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: "Moksha",
        // home: FirstView(),
        home: HomeController(),
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: Theme.of(context).textTheme.apply(
                fontFamily: 'Typewriter',
              ),
        ),
        // home: ShopScreen(),
        routes: <String, WidgetBuilder>{
          // '/intro': (BuildContext context) => SignUpView(authFormType: AuthFormType.signUp),
          '/signUp': (BuildContext context) =>
              SignUpView(authFormType: AuthFormType.signUp),
          '/signIn': (BuildContext context) =>
              SignUpView(authFormType: AuthFormType.signIn),
          '/home': (BuildContext context) => HomeController(),
          '/Intro': (BuildContext context) => IntroPage(),
        },
      ),
    );
  }
}

class HomeController extends StatefulWidget {
  @override
  _HomeControllerState createState() => _HomeControllerState();
}

class _HomeControllerState extends State<HomeController> {

  DateTime dateTime = DateTime.now();
  SharedPreferences? pref;
  String? reminderTime;
  String? reminderDefaultTime;
  List<DateTime> dateTimeList = [];
  List<DateTime> defaultDateTimeList = [];
  List slideList = [];
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  int hours = 11;
  int minutes = 11;

  getReminderList() async {
    pref = await SharedPreferences.getInstance();
    bool getData = pref!.containsKey('reminderData');
    if (getData) {
      reminderTime = pref!.getString("reminderData");
      List<String> splitTime = reminderTime!.split(':');
      setDateArray(splitTime[0].trim(), splitTime[1].trim());
      await showNotification(splitTime);
       setState(() {});
    } else {
      reminderDefaultTime = '$hours : $minutes';
      pref!.setString('reminderDefaultData', reminderDefaultTime!);
      reminderDefaultTime = pref!.getString("reminderDefaultData");
      List<String> splitTime = reminderDefaultTime!.split(':');
      setDefaultDateArray(splitTime[0].trim(), splitTime[1].trim());
      await showDefaultNotification(splitTime);
       setState(() {});
    }
  }

  setDateArray(hours, minute) {
    dateTimeList.clear();
    DateTime dateTime = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, int.parse(hours), int.parse(minute), 0);
    for (int i = 0; i < 50; i++) {
      Duration date = dateTime.difference(this.dateTime);
      bool isBefore = date.isNegative;
      if (!isBefore) {
        dateTimeList.add(dateTime);
      }
      dateTime = DateTime(dateTime.year, dateTime.month, dateTime.day + 1,
          int.parse(hours), int.parse(minute), 0);
    }
    print('Set day --> $dateTimeList');
  }

  setDefaultDateArray(hour, minute) {
    defaultDateTimeList.clear();
    DateTime dateTime = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, int.parse(hour), int.parse(minute), 0);
    for (int i = 0; i < 50; i++) {
      Duration date = dateTime.difference(this.dateTime);
      bool isBefore = date.isNegative;
      if (!isBefore) {
        defaultDateTimeList.add(dateTime);
      }
      dateTime = DateTime(dateTime.year, dateTime.month, dateTime.day + 1,
          int.parse(hour), int.parse(minute), 0);
    }
    print('Set Default day --> $defaultDateTimeList');
  }

  getStoriesDocument() async {
    slideList.clear();
    var docRef = await FirebaseFirestore.instance
        .collection("Stories")
        .where('tags', arrayContains: 'favs')
        .get();
    docRef.docs.forEach((result) {
      slideList.add(result.data());
    });
    setState(() {});
  }

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  IapService iapService = IapService();
  var userToken;
  @override
  initState() {
    print("----->home screen init.....");
     if(Platform.isIOS){
      getSubscriptionTokenValue();
     }
    flutterLocalNotificationsPlugin.cancelAll();
    getReminderList();
    localNotificationTimeWise();
     InAppPurchase.instance.restorePurchases();
    // TODO: implement initState
    super.initState();
  }

  getSubscriptionTokenValue() async {
  String uid = await AuthService().getCurrentUID();
  print("--->uid $uid");
   if(uid.isNotEmpty) {
     isCallApiLoading = true;
     setState(() {});
     userToken = await getPrefStringValue();
     // print("---->userData $userToken");
    if (userToken == null || userToken == '') {
      print("---->userToken call with null");
      _subscription = InAppPurchase.instance.purchaseStream.listen(
              (List<PurchaseDetails> purchaseDetailsList) {
            print("---->purchaseStream length is: ${purchaseDetailsList.length}");
            iapService.listenToPurchaseUpdated(
                purchaseDetailsList: purchaseDetailsList,
                updatePlan: () {
                  if (mounted) {
                    print("---->call setState");
                    setState(() {});
                  }
                },
                context: context);
          }, onDone: () {
        _subscription?.cancel();
      }, onError: (Object error) {});
    }
    else {
      print("---->userToken call");
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request(
          'POST', Uri.parse('https://sandbox.itunes.apple.com/verifyReceipt'));
      request.body = json
          .encode({"receipt-data": userToken, "password": appSecretKey});
      request.headers.addAll(headers);
      http.StreamedResponse response1 = await request.send();
      Response response = await http.Response.fromStream(response1);
      if (response.statusCode == 200) {
        InAppPurchaseInvoiceModel inAppPurchaseInvoiceModel = inAppPurchaseInvoiceModelFromJson(
            response.body);
        var epochTime = int.parse(
            inAppPurchaseInvoiceModel.latestReceiptInfo!.first.expiresDateMs!);
        print("---->epochTime $epochTime");
        DateTime convertDate = DateTime.fromMillisecondsSinceEpoch(epochTime);
        DateTime nowDate = DateTime.now();

        var inMinutes = nowDate
            .difference(convertDate)
            .inMinutes;
        print("---->convertDate $convertDate");
        print("---->nowDate $nowDate");
        print("difference inMinutes==> $inMinutes");
        if (inMinutes >= 0) {
          print("==> plan Deactivated");
          isSubscription = false;
        } else {
          print("==> fully plan activated");
          isSubscription = true;
        }
      } else {
        print("error: --->${response.reasonPhrase}");
      }
    }
     isCallApiLoading = false;
     setState(() {});
  }
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
      InAppPurchase.instance
          .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    if(userToken == null) {
    _subscription?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthService auth = Provider.of(context).auth!;
    return StreamBuilder<User>(
        stream: auth.onAuthStateChanged,
        builder: (context, AsyncSnapshot<User> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            bool signedIn = false;
            if (snapshot.hasData) {
              print("--->snapData: ${snapshot.data}");
              signedIn =
                  snapshot.data!.uid != null && snapshot.data!.emailVerified;
            }
            return moveToScreen(signedIn);
            // return signedIn ? Home() : IntroPage();
          }
          return Center(child: CircularProgressIndicator());
        });
  }

  moveToScreen(bool signedIn) {
    if (signedIn == false && isIntroScreenShow) {
      return SignUpView(authFormType: AuthFormType.signIn, isHide: false);
    } else if (signedIn) {
      return Home(quote: selectedNotificationPayload);
    } else {
      return FirstView();
    }
  }

  showNotification(List<String> time) async {
    await getStoriesDocument();
    var android = new AndroidNotificationDetails(
      'sdffds dsffds',
      "CHANNLE NAME",
      channelDescription: "channelDescription",
      importance: Importance.max,
      priority: Priority.max,
      enableLights: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );

    var iOS = new IOSNotificationDetails(
        sound: 'notification_sound.aiff', presentSound: true);
    var platform = new NotificationDetails(android: android, iOS: iOS);
    int i = 0;
    do {
      int? dateTimeId = int.tryParse('${time[0].trim()}${time[1].trim()}$i');
      Random range = new Random();
      int random = range.nextInt(slideList.length);
      await Future.delayed(Duration(microseconds: 300), () async {
        await flutterLocalNotificationsPlugin.schedule(
          dateTimeId!,
          'Today’s message',
          '${slideList[random]['quote'].toString()}',
          dateTimeList[i],
          platform,
          payload:'${slideList[random]['quote'].toString()}'
        );
        i++;
      });
    } while (i < 50);
  }

  showDefaultNotification(List<String> time) async {
    await flutterLocalNotificationsPlugin.cancelAll();
    await getStoriesDocument();
    var android = new AndroidNotificationDetails(
      'sdffds dsffds',
      "CHANNLE NAME",
      channelDescription: "channelDescription",
      importance: Importance.max,
      priority: Priority.max,
      enableLights: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );

    var iOS = new IOSNotificationDetails(
      sound: 'notification_sound.aiff',
      presentSound: true,
    );
    var platform = new NotificationDetails(android: android, iOS: iOS);
    int i = 0;
    do {
      int? dateTimeId = int.tryParse('${time[0].trim()}${time[1].trim()}$i');
      Random range = new Random();
      int random = range.nextInt(slideList.length);
      await Future.delayed(Duration(microseconds: 300), () async {
        await flutterLocalNotificationsPlugin.schedule(
          dateTimeId!,
          'Today’s message',
          '${slideList[random]['quote'].toString()}',
          defaultDateTimeList[i],
          platform,
          payload:'${slideList[random]['quote'].toString()}'
        );
        i++;
      });
    } while (i < 50);
  }

  localNotificationTimeWise() {
    var android =
        new AndroidInitializationSettings('@mipmap/ic_launcher'); //app_icon
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            requestSoundPermission: true,
            requestBadgePermission: true,
            requestAlertPermission: true,
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var platform = new InitializationSettings(
        android: android, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(platform,onSelectNotification: onSelectNotification);
  }

  Future<dynamic> onSelectNotification(payload) async {
    print("--->>>>>>payload $payload");
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => Home(quote: payload)),
          (Route<dynamic> route) => false,
    );
  }

  Future onDidReceiveLocalNotification(
      int? id, String? title, String? body, String? payload) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title!),
        content: Text(body!),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
            },
          )
        ],
      ),
    );
  }

/*/// inAppPurchase
  InAppPurchaseConnection _connection;

  StreamSubscription<List<PurchaseDetails>> _subscription;
  List<String> _notFoundIds = [];
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  List<String> _consumables = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String _queryProductError;

  Future<void> initStoreInfo() async {
    _connection = InAppPurchaseConnection.instance;

    final bool isAvailable = await _connection.isAvailable();
    print("inAppPurchase avail $isAvailable");
    if (!isAvailable) {
      // setState(() {
      _isAvailable = isAvailable;
      _products = [];
      appState.products = [];
      _purchases = [];
      _notFoundIds = [];
      _consumables = [];
      _purchasePending = false;
      _loading = false;
      // });
      return;
    }

    Stream purchaseUpdated = _connection.purchaseUpdatedStream;
    purchaseUpdated.listen((purchaseDetailsList) {
      print(purchaseDetailsList.length);
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      print("Listening Done");
      _subscription.cancel();
    }, onError: (error) {
      print("inAppPurchase error: $error");
    });

    ProductDetailsResponse productDetailResponse = await _connection.queryProductDetails(appState.productIds.toSet());
    productDetailResponse.productDetails.forEach((element) {
      print("inAppPurchase ${element.title} -- ${element.price}");
    });
    if (productDetailResponse.error != null) {
      // setState(() {
      _queryProductError = productDetailResponse.error.message;
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      appState.products = productDetailResponse.productDetails;
      _purchases = [];
      _notFoundIds = productDetailResponse.notFoundIDs;
      _consumables = [];
      _purchasePending = false;
      _loading = false;
      // });
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      // setState(() {
      _queryProductError = null;
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      appState.products = productDetailResponse.productDetails;
      _purchases = [];
      _notFoundIds = productDetailResponse.notFoundIDs;
      _consumables = [];
      _purchasePending = false;
      _loading = false;
      // });
      return;
    }

    await subscriptionStatus();

    print("Status Done");

    List<String> consumables = await ConsumableStore.load();
    setState(() {
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      appState.products = productDetailResponse.productDetails;
      _notFoundIds = productDetailResponse.notFoundIDs;
      _consumables = consumables;
      _purchasePending = false;
      _loading = false;
    });
  }

  // Future<void> consume(String id) async {
  //   await ConsumableStore.consume(id);
  //   final List<String> consumables = await ConsumableStore.load();
  //   print("inAppPurchase consumables $consumables");
  //   setState(() {
  //     _consumables = consumables;
  //   });
  // }
  //
  // void showPendingUI() {
  //   setState(() {
  //     _purchasePending = true;
  //   });
  // }

  void deliverProduct(PurchaseDetails purchaseDetails) async {
    /// IMPORTANT!! Always verify a purchase purchase details before delivering the product.
    print("Delivering");
    // setState(() {
    _purchases.add(purchaseDetails);
    _purchasePending = false;
    // });

    // USER META UPDATE IN API
  */ /*  String check = await RestApi.updateUserDetails({
      'id': appState.id,
      'subscription_name': purchaseDetails.productID,
      'subscription_date': purchaseDetails.transactionDate
    });
    if (check == 'success') {
      appState.subscriptionName = purchaseDetails.productID;
      appState.subscriptionDate = DateTime.fromMillisecondsSinceEpoch(int.parse(purchaseDetails.transactionDate));
      appState.userDetailsModel.meta.subscriptionDate = appState.subscriptionDate;
      appState.userDetailsModel.meta.subscriptionName = appState.subscriptionName;

      print(appState.userDetailsModel.meta.toJson());
      await sharedPreferences.setString(Preferences.metaData, jsonEncode(appState.userDetailsModel.toJson()));

      // EasyLoading.dismiss();
      getSharedDetails();
    }*/ /*
  }

  void handleError(IAPError error) {
    print("inAppPurchase IAPError ${error.message} -- ${error.details}");
    Navigator.pop(appState.settingContext);
    source();
    // setState(() {
    _purchasePending = false;
    // });
  }

  source() {
    return showDialog(
        context: appState.settingContext,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(
              "Something went wrong! your purchase is not verified! if you paid then please wait for sometime and check again",
            ),
            insetAnimationCurve: Curves.decelerate,
            actions: <Widget>[
              GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  color: ColorRes.redButton,
                  child: Text(
                    "OKAY",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        color: ColorRes.white,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none),
                  ),
                ),
              ),
            ],
          );
        });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    print("Verifying");
    print(
        "inAppPurchase purchaseDetails ${DateTime.fromMillisecondsSinceEpoch(int.parse(purchaseDetails.transactionDate))}");
    print("inAppPurchase purchaseDetails ${purchaseDetails.productID}");
    print("inAppPurchase purchaseDetails ${purchaseDetails.status}");
    if (purchaseDetails != null &&
        purchaseDetails.purchaseID != null &&
        purchaseDetails.purchaseID.isNotEmpty &&
        purchaseDetails.status == PurchaseStatus.purchased) {
      return Future<bool>.value(true);
    } else {
      return Future<bool>.value(false);
    }
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
    print("inAppPurchase purchaseResponse error ${purchaseDetails.error.message} -- ${purchaseDetails.error.code} -- ${purchaseDetails.error.details}");
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    print("Listening");
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        print("inAppPurchase purchaseDetails.status ${purchaseDetails.status}");
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          print("inAppPurchase purchaseDetails.status ${purchaseDetails.status}");
          handleError(purchaseDetails.error);
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          print("inAppPurchase purchaseDetails.status ${purchaseDetails.status}");
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchaseConnection.instance
              .completePurchase(purchaseDetails);
        }
      }
    });
  }

  subscriptionStatus() async {
    if (Platform.isIOS) {
      final QueryPurchaseDetailsResponse purchaseResponse =
      await _connection.queryPastPurchases();
      if (purchaseResponse.error != null) {
        print(
            "inAppPurchase purchaseResponse error ${purchaseResponse.error.message} -- ${purchaseResponse.error.code} -- ${purchaseResponse.error.details}");
      }

      var history = purchaseResponse.pastPurchases;
      final List<PurchaseDetails> verifiedPurchases = [];

      for (var purchase in history) {
        Duration difference = DateTime.now().difference(
            DateTime.fromMillisecondsSinceEpoch(
                int.parse(purchase.transactionDate)));
        if (difference.inMinutes <= (Duration(days: 30)).inMinutes &&
            purchase.status == PurchaseStatus.purchased) {
          print("--------");
          print("inAppPurchase purchaseDetails ${difference.inMinutes}");
          print("inAppPurchase purchaseDetails ${purchase.productID}");
          verifiedPurchases.add(purchase);
        }
      }
      _purchases = verifiedPurchases;
      if (_purchases.isNotEmpty) {
        appState.subscriptionName = _purchases[0].productID;
        appState.subscriptionDate = DateTime.fromMillisecondsSinceEpoch(
            int.parse(_purchases[0].transactionDate));
        appState.userDetailsModel.meta.subscriptionDate =
            appState.subscriptionDate;
        appState.userDetailsModel.meta.subscriptionName =
            appState.subscriptionName;

        print(appState.userDetailsModel.meta.toJson());
        await sharedPreferences.setString(Preferences.metaData,
            jsonEncode(appState.userDetailsModel.toJson()));
      }
    } else if (Platform.isAndroid) {
      final QueryPurchaseDetailsResponse purchaseResponse =
      await _connection.queryPastPurchases();
      if (purchaseResponse.error != null) {
        print(
            "inAppPurchase purchaseResponse error ${purchaseResponse.error.message} -- ${purchaseResponse.error.code} -- ${purchaseResponse.error.details}");
      }
      final List<PurchaseDetails> verifiedPurchases = [];
      for (PurchaseDetails purchase in purchaseResponse.pastPurchases) {
        if (await _verifyPurchase(purchase)) {
          verifiedPurchases.add(purchase);
        }
      }
      _purchases = verifiedPurchases;
      if (_purchases.isNotEmpty) {
        appState.subscriptionName = _purchases[0].productID;
        appState.subscriptionDate = DateTime.fromMillisecondsSinceEpoch(
            int.parse(_purchases[0].transactionDate));
        appState.userDetailsModel.meta.subscriptionDate =
            appState.subscriptionDate;
        appState.userDetailsModel.meta.subscriptionName =
            appState.subscriptionName;

        print(appState.userDetailsModel.meta.toJson());
        await sharedPreferences.setString(Preferences.metaData,
            jsonEncode(appState.userDetailsModel.toJson()));
      }
    }
  } */

}
