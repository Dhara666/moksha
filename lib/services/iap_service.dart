import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:moksha_beta/models/inapp_purchase_invoice_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import '../prefrences.dart';
import '../widgets/alert_dialog.dart';

class IapService {
  final InAppPurchase inAppPurchase = InAppPurchase.instance;

  final List<String> productIds = [];
  List<PurchaseDetails> purchases = <PurchaseDetails>[];
  List<ProductDetails> availableProducts = <ProductDetails>[];

  bool purchasePending = false;
  bool autoConsume = true;

  String _kConsumableId = 'moksha_monthly';
  String _kConsumableId1 = 'moksha_yearly';

  /// in app purchase
  Future<List<ProductDetails>> initStoreInfo({
    bool? isAvailable,
    required List<String> id,
    List<String>? noFoundId,
  }) async {
    isAvailable = await inAppPurchase.isAvailable();
    print("isAvailable");
    if (!isAvailable) {
      return [];
    }

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
      InAppPurchase.instance
          .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    try {
      final ProductDetailsResponse productDetailsResponse =
          await inAppPurchase.queryProductDetails(id.toSet());

      if (productDetailsResponse.productDetails.isNotEmpty) {
        availableProducts = productDetailsResponse.productDetails;

        for (var element in availableProducts) {
          log('availableProducts is:  ${element.id} --> ${element.title} : ${element.description}');
        }
      }
      if (productDetailsResponse.notFoundIDs.isNotEmpty) {
        noFoundId = productDetailsResponse.notFoundIDs;
      }
      if (productDetailsResponse.error != null) {}
    } on InAppPurchaseException catch (e) {
      log('Error in InAppPurchase --> ${e.message}');
    }
    print("--->availableProducts ${availableProducts.length}");
    availableProducts.forEach((element) {
      print(
          "--->availableProducts Id: ${element.id + "Title:  " + element.title}");
    });
    return availableProducts;
  }


  listenToPurchaseUpdated({
    List<PurchaseDetails>? purchaseDetailsList,
    Function? updatePlan,
    BuildContext? context
  }) async {
    log("PurchaseStatus length-----> ${purchaseDetailsList!.length}");
    for (PurchaseDetails purchaseDetails in purchaseDetailsList) {
      log("PurchaseStatus -----> ${purchaseDetails.status}");
      if (purchaseDetails.status == PurchaseStatus.pending) {
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
        }
        else if (purchaseDetails.status == PurchaseStatus.purchased) {}

        if (purchaseDetails.pendingCompletePurchase) {
          log("---->pendingCompletePurchase ${purchaseDetails.pendingCompletePurchase}");
          await inAppPurchase.completePurchase(purchaseDetails);
        }
        if (purchaseDetails.status == PurchaseStatus.canceled) {
        }
      }
    }

    if(purchaseDetailsList.length > 0){
      print("---->call Api First Time:---->");
      verificationData = purchaseDetailsList.last.verificationData.localVerificationData;
      await setPrefStringValue(verificationData);
      await getInAppPurchaseList();
      isCallApiLoading = false;
      updatePlan?.call();
    }
  }

  listenToPurchase({
    List<PurchaseDetails>? purchaseDetailsList,
    Function? updatePlan,
    BuildContext? context
  }) async {
    log("PurchaseStatus length-----> ${purchaseDetailsList!.length}");
    for (PurchaseDetails purchaseDetails in purchaseDetailsList) {
      log("PurchaseStatus -----> ${purchaseDetails.status}");
      if (purchaseDetails.status == PurchaseStatus.pending) {
        //showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          //handleError(purchaseDetails.error!);
        }
        else if (purchaseDetails.status == PurchaseStatus.purchased) {
          verificationData = purchaseDetails.verificationData.localVerificationData;
          showSuccessAlert(context!, "You have subscribed Successfully");
          isSubscription = true;
          updatePlan?.call();
        }
        if (purchaseDetails.pendingCompletePurchase) {
          log("---->pendingCompletePurchase ${purchaseDetails.pendingCompletePurchase}");
          await inAppPurchase.completePurchase(purchaseDetails);
        }
        if (purchaseDetails.status == PurchaseStatus.canceled) {
        }
      }
    }
  }

  getInAppPurchaseList() async {
    if(verificationData != null) {
      var headers = {
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'POST', Uri.parse('https://sandbox.itunes.apple.com/verifyReceipt'));
      request.body = json.encode({
        "receipt-data": verificationData,
        "password": appSecretKey
      });
      request.headers.addAll(headers);

      http.StreamedResponse response1 = await request.send();
      Response response = await http.Response.fromStream(response1);

      if (response.statusCode == 200) {
        InAppPurchaseInvoiceModel inAppPurchaseInvoiceModel = inAppPurchaseInvoiceModelFromJson(response.body);
        if(inAppPurchaseInvoiceModel.latestReceiptInfo != null){
        var epochTime = int.parse(inAppPurchaseInvoiceModel.latestReceiptInfo!.first.expiresDateMs!);
        DateTime convertDate = DateTime.fromMillisecondsSinceEpoch(epochTime);
        DateTime nowDate = DateTime.now();
        var inMinutes = nowDate.difference(convertDate).inMinutes;

        print("---->epochTime $epochTime");
        print("---->convertDate $convertDate");
        print("---->nowDate $nowDate");
        print("difference inMinutes: ==> $inMinutes");
        if (inMinutes >= 0) {
          print("==> plan De_activated........");
          isSubscription = false;
        } else{
          print("==> plan activated........");
          isSubscription = true;
         }
       }
      }
      else {
        print("error: --->${response.reasonPhrase}");
      }
    }
  }
  void handleInvalidPurchase(PurchaseDetails purchaseDetails) {}

  Future<void> deliverProduct(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.productID == _kConsumableId ||
        purchaseDetails.productID == _kConsumableId1) {
      await IapPlanDataStore.save(purchaseDetails.purchaseID!);
      List<String> consumables = await IapPlanDataStore.load();
      print("consumables ====> $consumables");
      purchasePending = false;
    } else {
      purchases.add(purchaseDetails);
      purchasePending = false;
    }
  }

  Future<bool> verifyPurchase(PurchaseDetails purchaseDetails) {
    return Future<bool>.value(true);
  }
}

class IapPlanDataStore {
  static const String _kPrefKey = 'consumables';
  static Future<void> _writes = Future<void>.value();

  static Future<void> save(String id) {
    _writes = _writes.then((void _) => _doSave(id));
    print("_writes ${_writes.then((void _) {
      return _doSave(id);
    })}");
    return _writes;
  }

  static Future<void> consume(String id) {
    _writes = _writes.then((void _) => _doConsume(id));
    return _writes;
  }

  /// Returns the list of consumables from the store.
  static Future<List<String>> load() async {
    return (await SharedPreferences.getInstance()).getStringList(_kPrefKey) ??
        <String>[];
  }

  static Future<void> _doSave(String id) async {
    final List<String> cached = await load();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    cached.add(id);
    await prefs.setStringList(_kPrefKey, cached);
  }

  static Future<void> _doConsume(String id) async {
    final List<String> cached = await load();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    cached.remove(id);
    await prefs.setStringList(_kPrefKey, cached);
  }
}

class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
@override
bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
  return true;
}

@override
bool shouldShowPriceConsent() {
  return false;
}
}

