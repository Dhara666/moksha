import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:moksha_beta/services/iap_service.dart';
import 'package:moksha_beta/services/webview.dart';
import 'package:moksha_beta/views/subscribe_screen.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

const bool _kAutoConsume = true;

const String _kConsumableId = 'moksha_monthly';
const String _kConsumableId1 = 'moksha_yearly';

const List<String> _kProductIds = <String>[
  _kConsumableId,
  _kConsumableId1,
];

// const String _kConsumableId2 = 'android.test.purchased';
// const String _kConsumableId3 = 'subscription_silver';
// const List<String> _kProductId = <String>[
//   _kConsumableId2,
//   _kConsumableId3,
// ];

class ShopScreen extends StatefulWidget {
  @override
  ShopScreenState createState() => ShopScreenState();
}

class ShopScreenState extends State<ShopScreen> {
  IapService iapService = IapService();
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  List<PurchaseDetails> _purchases = <PurchaseDetails>[];
  bool isAvailable = false;
  List<String> noFoundId = [];
  String selectSubscription = '';
  bool basicPlan = false;
  bool premiumPlan = false;
  List<ProductDetails> _products = <ProductDetails>[];

  @override
  void initState() {
    print("---->initState");
    _subscription = InAppPurchase.instance.purchaseStream.listen(
        (List<PurchaseDetails> purchaseDetailsList) {
      iapService.listenToPurchase(
          purchaseDetailsList: purchaseDetailsList,
          updatePlan: () {
            if (mounted) {
              setState(() {});
            }
          },context: context);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (Object error) {});

    initStoreInfo();
    super.initState();
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
      InAppPurchase.instance
          .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _subscription.cancel();
    super.dispose();
  }

  Future<void> initStoreInfo() async {
    _products = await iapService.initStoreInfo(
        isAvailable: isAvailable, id: _kProductIds, noFoundId: noFoundId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('MOKSHA PREMIUM',
            style: TextStyle(color: Colors.white, fontFamily: "Typewriter")),
      ),
      body: ListView(
        children: [
          Container(
            alignment: Alignment.center,
            height: 70,
            width: MediaQuery.of(context).size.width * 1,
            color: Colors.black,
            child: Text(
              'experience full capabilities of \nMoksha by upgrading to premium',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ),
          noFoundId.isNotEmpty
              ? ListTile(
                  title: Text('[${noFoundId.join(", ")}] not found',
                      style: TextStyle(color: ThemeData.light().errorColor)),
                  subtitle: Text('This app needs special configuration to run'))
              : Column(
                  children: [
                    commonContainer(
                      text: 'Sync across all devices',
                      color: Colors.white,
                    ),
                    commonContainer(
                      text: 'Save unlimited  quotes',
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    commonContainer(
                      text: 'Unlock & customise widgets',
                      color: Colors.white,
                    ),
                    commonContainer(
                      text: '& much more',
                      color: Colors.grey.withOpacity(0.5),
                    ),
                  ],
                ),
          _subscriptionList(),
        ],
      ),
    );
  }

  Container commonContainer({
    String? text,
    Color? color,
  }) {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width * 1,
      color: color ?? Colors.grey.withOpacity(0.5),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text!),
          Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.black54.withOpacity(0),
                  ],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.done,
                color: Colors.white,
              )),
        ],
      ),
    );
  }

  _subscriptionList() {
    print("--->productsList.length is ---> ${_products.length}");
    return _products.isNotEmpty
        ? Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 30, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(width: 26),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          basicPlan = true;
                          premiumPlan = false;
                          // selectSubscription = productDetails[0].id;
                          setState(() {});
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SubscriptionDetailsPage(
                                    productDetails: _products[0],
                                    subScribeQuotes: subScribeQuotes)),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black, width: 2),
                                shape: BoxShape.circle,
                              ),
                              child: basicPlan
                                  ? const Icon(
                                      Icons.done,
                                      size: 30,
                                      color: Colors.black,
                                    )
                                  : SizedBox(),
                            ),
                            SizedBox(height: 10),
                            Text(
                              _products[0].id,
                              // productDetails[0].id,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Image.asset(
                          'lib/assets/icons/ic_arrow.png',
                          height: 22,
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          premiumPlan = true;
                          basicPlan = false;
                          // selectSubscription = productDetails[1].id;
                          setState(() {});
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SubscriptionDetailsPage(
                                      productDetails: _products[1],
                                      subScribeQuotes: subScribeQuotes)));
                        },
                        child: Column(
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black, width: 2),
                                shape: BoxShape.circle,
                              ),
                              child: premiumPlan
                                  ? const Icon(
                                      Icons.done,
                                      size: 30,
                                      color: Colors.black,
                                    )
                                  : SizedBox(),
                            ),
                            SizedBox(height: 10),
                            Text(
                              // 'Moksha Premium',
                              _products[1].id,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 26),
                  ],
                ),
              ),
              Row(
                children: [
                  SizedBox(width: 20),
                  Expanded(
                    child: commonPaymentBox(price: _products[0].price),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 14),
                      child: Text(
                        'or',
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Expanded(
                    child: commonPaymentBox(
                        price: _products[1].price, isYear: true),
                  ),
                  SizedBox(width: 20),
                ],
              ),
              Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  // padding: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) => MyWebView(
                                title: "Privacy policy",
                                selectedUrl:
                                    "https://app.termly.io/document/privacy-policy/3b579330-3628-4ce7-9499-51fa2e18dedb",
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            'Privacy policy',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Text(' | '),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) => MyWebView(
                                title: "Terms of use",
                                selectedUrl:
                                    "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/",
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            'Terms of Service',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ))
            ],
          )
        : Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(Platform.isAndroid ? "No id Found..": "Fetching Product..."),
            ),
          );
  }

  // Future<void> clearIOSTransactions() async {
  //   // clear the transaction queue for failed completeTransaction or finishTransaction
  //   final transactions = await SKPaymentQueueWrapper().transactions();
  //   print("SkTransactionCount: ${transactions.length}");
  //   for (final transaction in transactions) {
  //     if (transaction.transactionState !=
  //         SKPaymentTransactionStateWrapper.purchasing) {
  //       await SKPaymentQueueWrapper().finishTransaction(transaction);
  //     }
  //   }
  // }

  Future<void> clearIOSTransactions() async {
    // clear the transaction queue for failed completeTransaction or finishTransaction
    var transactions = await SKPaymentQueueWrapper().transactions();
    for (var skPaymentTransactionWrapper in transactions) {
      SKPaymentQueueWrapper().finishTransaction(skPaymentTransactionWrapper);
    }
  }

  subScribeQuotes(ProductDetails productDetails) async {
    await clearIOSTransactions();
    PurchaseParam purchaseParam;
    purchaseParam = PurchaseParam(
      productDetails: productDetails,
      applicationUserName: null,
    );
    print("---->purchaseParam detail : ${purchaseParam.productDetails}");
    print("---->purchaseParam detail : ${purchaseParam.productDetails.id}");
    await InAppPurchase.instance.buyConsumable(
        purchaseParam: purchaseParam);
  }

  Column commonPaymentBox({required String price, isYear = false}) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            isYear ? '$price / \nyear' : '$price / \nmonth',
            textAlign: TextAlign.center,
          ),
        ),
        Text(
          '\$1.67/mo billed \nannually',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: isYear ? Colors.black : Colors.white,
          ),
        ),
      ],
    );
  }
}