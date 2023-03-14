// To parse this JSON data, do
//
//     final inAppPurchaseInvoiceModel = inAppPurchaseInvoiceModelFromJson(jsonString);

import 'dart:convert';

InAppPurchaseInvoiceModel inAppPurchaseInvoiceModelFromJson(String str) => InAppPurchaseInvoiceModel.fromJson(json.decode(str));

String inAppPurchaseInvoiceModelToJson(InAppPurchaseInvoiceModel data) => json.encode(data.toJson());

class InAppPurchaseInvoiceModel {
  InAppPurchaseInvoiceModel({
    this.environment,
    this.receipt,
    this.latestReceiptInfo,
    this.latestReceipt,
    this.pendingRenewalInfo,
    this.status,
  });

  String? environment;
  Receipt? receipt;
  List<LatestReceiptInfo>? latestReceiptInfo;
  String? latestReceipt;
  List<PendingRenewalInfo>? pendingRenewalInfo;
  int? status;

  factory InAppPurchaseInvoiceModel.fromJson(Map<String, dynamic> json) => InAppPurchaseInvoiceModel(
    environment: json["environment"] == null ? null : json["environment"],
    receipt: json["receipt"] == null ? null : Receipt.fromJson(json["receipt"]),
    latestReceiptInfo: json["latest_receipt_info"] == null ? null : List<LatestReceiptInfo>.from(json["latest_receipt_info"].map((x) => LatestReceiptInfo.fromJson(x))),
    latestReceipt: json["latest_receipt"] == null ? null : json["latest_receipt"],
    pendingRenewalInfo: json["pending_renewal_info"] == null ? null : List<PendingRenewalInfo>.from(json["pending_renewal_info"].map((x) => PendingRenewalInfo.fromJson(x))),
    status: json["status"] == null ? null : json["status"],
  );

  Map<String, dynamic> toJson() => {
    "environment": environment == null ? null : environment,
    "receipt": receipt == null ? null : receipt!.toJson(),
    "latest_receipt_info": latestReceiptInfo == null ? null : List<dynamic>.from(latestReceiptInfo!.map((x) => x.toJson())),
    "latest_receipt": latestReceipt == null ? null : latestReceipt,
    "pending_renewal_info": pendingRenewalInfo == null ? null : List<dynamic>.from(pendingRenewalInfo!.map((x) => x.toJson())),
    "status": status == null ? null : status,
  };
}

class LatestReceiptInfo {
  LatestReceiptInfo({
    this.quantity,
    this.productId,
    this.transactionId,
    this.originalTransactionId,
    this.purchaseDate,
    this.purchaseDateMs,
    this.purchaseDatePst,
    this.originalPurchaseDate,
    this.originalPurchaseDateMs,
    this.originalPurchaseDatePst,
    this.expiresDate,
    this.expiresDateMs,
    this.expiresDatePst,
    this.webOrderLineItemId,
    this.isTrialPeriod,
    this.isInIntroOfferPeriod,
    this.inAppOwnershipType,
    this.subscriptionGroupIdentifier,
  });

  String? quantity;
  ProductId? productId;
  String? transactionId;
  String? originalTransactionId;
  String? purchaseDate;
  String? purchaseDateMs;
  String? purchaseDatePst;
  OriginalPurchaseDate? originalPurchaseDate;
  String? originalPurchaseDateMs;
  OriginalPurchaseDatePst? originalPurchaseDatePst;
  String? expiresDate;
  String? expiresDateMs;
  String? expiresDatePst;
  String? webOrderLineItemId;
  String? isTrialPeriod;
  String? isInIntroOfferPeriod;
  InAppOwnershipType? inAppOwnershipType;
  String? subscriptionGroupIdentifier;

  factory LatestReceiptInfo.fromJson(Map<String, dynamic> json) => LatestReceiptInfo(
    quantity: json["quantity"] == null ? null : json["quantity"],
    productId: json["product_id"] == null ? null : productIdValues.map![json["product_id"]],
    transactionId: json["transaction_id"] == null ? null : json["transaction_id"],
    originalTransactionId: json["original_transaction_id"] == null ? null : json["original_transaction_id"],
    purchaseDate: json["purchase_date"] == null ? null : json["purchase_date"],
    purchaseDateMs: json["purchase_date_ms"] == null ? null : json["purchase_date_ms"],
    purchaseDatePst: json["purchase_date_pst"] == null ? null : json["purchase_date_pst"],
    originalPurchaseDate: json["original_purchase_date"] == null ? null : originalPurchaseDateValues.map![json["original_purchase_date"]],
    originalPurchaseDateMs: json["original_purchase_date_ms"] == null ? null : json["original_purchase_date_ms"],
    originalPurchaseDatePst: json["original_purchase_date_pst"] == null ? null : originalPurchaseDatePstValues.map![json["original_purchase_date_pst"]],
    expiresDate: json["expires_date"] == null ? null : json["expires_date"],
    expiresDateMs: json["expires_date_ms"] == null ? null : json["expires_date_ms"],
    expiresDatePst: json["expires_date_pst"] == null ? null : json["expires_date_pst"],
    webOrderLineItemId: json["web_order_line_item_id"] == null ? null : json["web_order_line_item_id"],
    isTrialPeriod: json["is_trial_period"] == null ? null : json["is_trial_period"],
    isInIntroOfferPeriod: json["is_in_intro_offer_period"] == null ? null : json["is_in_intro_offer_period"],
    inAppOwnershipType: json["in_app_ownership_type"] == null ? null : inAppOwnershipTypeValues.map![json["in_app_ownership_type"]],
    subscriptionGroupIdentifier: json["subscription_group_identifier"] == null ? null : json["subscription_group_identifier"],
  );

  Map<String, dynamic> toJson() => {
    "quantity": quantity == null ? null : quantity,
    "product_id": productId == null ? null : productIdValues.reverse[productId],
    "transaction_id": transactionId == null ? null : transactionId,
    "original_transaction_id": originalTransactionId == null ? null : originalTransactionId,
    "purchase_date": purchaseDate == null ? null : purchaseDate,
    "purchase_date_ms": purchaseDateMs == null ? null : purchaseDateMs,
    "purchase_date_pst": purchaseDatePst == null ? null : purchaseDatePst,
    "original_purchase_date": originalPurchaseDate == null ? null : originalPurchaseDateValues.reverse[originalPurchaseDate],
    "original_purchase_date_ms": originalPurchaseDateMs == null ? null : originalPurchaseDateMs,
    "original_purchase_date_pst": originalPurchaseDatePst == null ? null : originalPurchaseDatePstValues.reverse[originalPurchaseDatePst],
    "expires_date": expiresDate == null ? null : expiresDate,
    "expires_date_ms": expiresDateMs == null ? null : expiresDateMs,
    "expires_date_pst": expiresDatePst == null ? null : expiresDatePst,
    "web_order_line_item_id": webOrderLineItemId == null ? null : webOrderLineItemId,
    "is_trial_period": isTrialPeriod == null ? null : isTrialPeriod,
    "is_in_intro_offer_period": isInIntroOfferPeriod == null ? null : isInIntroOfferPeriod,
    "in_app_ownership_type": inAppOwnershipType == null ? null : inAppOwnershipTypeValues.reverse[inAppOwnershipType],
    "subscription_group_identifier": subscriptionGroupIdentifier == null ? null : subscriptionGroupIdentifier,
  };
}

enum InAppOwnershipType { PURCHASED }

final inAppOwnershipTypeValues = EnumValues({
  "PURCHASED": InAppOwnershipType.PURCHASED
});

enum OriginalPurchaseDate { THE_20220713094926_ETC_GMT }

final originalPurchaseDateValues = EnumValues({
  "2022-07-13 09:49:26 Etc/GMT": OriginalPurchaseDate.THE_20220713094926_ETC_GMT
});

enum OriginalPurchaseDatePst { THE_20220713024926_AMERICA_LOS_ANGELES }

final originalPurchaseDatePstValues = EnumValues({
  "2022-07-13 02:49:26 America/Los_Angeles": OriginalPurchaseDatePst.THE_20220713024926_AMERICA_LOS_ANGELES
});

enum ProductId { WEEKLY, YEARLY, MONTHLY }

final productIdValues = EnumValues({
  "monthly": ProductId.MONTHLY,
  "weekly": ProductId.WEEKLY,
  "yearly": ProductId.YEARLY
});

class PendingRenewalInfo {
  PendingRenewalInfo({
    this.expirationIntent,
    this.autoRenewProductId,
    this.isInBillingRetryPeriod,
    this.productId,
    this.originalTransactionId,
    this.autoRenewStatus,
  });

  String? expirationIntent;
  ProductId? autoRenewProductId;
  String? isInBillingRetryPeriod;
  ProductId? productId;
  String? originalTransactionId;
  String? autoRenewStatus;

  factory PendingRenewalInfo.fromJson(Map<String, dynamic> json) => PendingRenewalInfo(
    expirationIntent: json["expiration_intent"] == null ? null : json["expiration_intent"],
    autoRenewProductId: json["auto_renew_product_id"] == null ? null : productIdValues.map![json["auto_renew_product_id"]],
    isInBillingRetryPeriod: json["is_in_billing_retry_period"] == null ? null : json["is_in_billing_retry_period"],
    productId: json["product_id"] == null ? null : productIdValues.map![json["product_id"]],
    originalTransactionId: json["original_transaction_id"] == null ? null : json["original_transaction_id"],
    autoRenewStatus: json["auto_renew_status"] == null ? null : json["auto_renew_status"],
  );

  Map<String, dynamic> toJson() => {
    "expiration_intent": expirationIntent == null ? null : expirationIntent,
    "auto_renew_product_id": autoRenewProductId == null ? null : productIdValues.reverse[autoRenewProductId],
    "is_in_billing_retry_period": isInBillingRetryPeriod == null ? null : isInBillingRetryPeriod,
    "product_id": productId == null ? null : productIdValues.reverse[productId],
    "original_transaction_id": originalTransactionId == null ? null : originalTransactionId,
    "auto_renew_status": autoRenewStatus == null ? null : autoRenewStatus,
  };
}

class Receipt {
  Receipt({
    this.receiptType,
    this.adamId,
    this.appItemId,
    this.bundleId,
    this.applicationVersion,
    this.downloadId,
    this.versionExternalIdentifier,
    this.receiptCreationDate,
    this.receiptCreationDateMs,
    this.receiptCreationDatePst,
    this.requestDate,
    this.requestDateMs,
    this.requestDatePst,
    this.originalPurchaseDate,
    this.originalPurchaseDateMs,
    this.originalPurchaseDatePst,
    this.originalApplicationVersion,
    this.inApp,
  });

  String? receiptType;
  int? adamId;
  int? appItemId;
  String? bundleId;
  String? applicationVersion;
  int? downloadId;
  int? versionExternalIdentifier;
  String? receiptCreationDate;
  String? receiptCreationDateMs;
  String? receiptCreationDatePst;
  String? requestDate;
  String? requestDateMs;
  String? requestDatePst;
  String? originalPurchaseDate;
  String? originalPurchaseDateMs;
  String? originalPurchaseDatePst;
  String? originalApplicationVersion;
  List<LatestReceiptInfo>? inApp;

  factory Receipt.fromJson(Map<String, dynamic> json) => Receipt(
    receiptType: json["receipt_type"] == null ? null : json["receipt_type"],
    adamId: json["adam_id"] == null ? null : json["adam_id"],
    appItemId: json["app_item_id"] == null ? null : json["app_item_id"],
    bundleId: json["bundle_id"] == null ? null : json["bundle_id"],
    applicationVersion: json["application_version"] == null ? null : json["application_version"],
    downloadId: json["download_id"] == null ? null : json["download_id"],
    versionExternalIdentifier: json["version_external_identifier"] == null ? null : json["version_external_identifier"],
    receiptCreationDate: json["receipt_creation_date"] == null ? null : json["receipt_creation_date"],
    receiptCreationDateMs: json["receipt_creation_date_ms"] == null ? null : json["receipt_creation_date_ms"],
    receiptCreationDatePst: json["receipt_creation_date_pst"] == null ? null : json["receipt_creation_date_pst"],
    requestDate: json["request_date"] == null ? null : json["request_date"],
    requestDateMs: json["request_date_ms"] == null ? null : json["request_date_ms"],
    requestDatePst: json["request_date_pst"] == null ? null : json["request_date_pst"],
    originalPurchaseDate: json["original_purchase_date"] == null ? null : json["original_purchase_date"],
    originalPurchaseDateMs: json["original_purchase_date_ms"] == null ? null : json["original_purchase_date_ms"],
    originalPurchaseDatePst: json["original_purchase_date_pst"] == null ? null : json["original_purchase_date_pst"],
    originalApplicationVersion: json["original_application_version"] == null ? null : json["original_application_version"],
    inApp: json["in_app"] == null ? null : List<LatestReceiptInfo>.from(json["in_app"].map((x) => LatestReceiptInfo.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "receipt_type": receiptType == null ? null : receiptType,
    "adam_id": adamId == null ? null : adamId,
    "app_item_id": appItemId == null ? null : appItemId,
    "bundle_id": bundleId == null ? null : bundleId,
    "application_version": applicationVersion == null ? null : applicationVersion,
    "download_id": downloadId == null ? null : downloadId,
    "version_external_identifier": versionExternalIdentifier == null ? null : versionExternalIdentifier,
    "receipt_creation_date": receiptCreationDate == null ? null : receiptCreationDate,
    "receipt_creation_date_ms": receiptCreationDateMs == null ? null : receiptCreationDateMs,
    "receipt_creation_date_pst": receiptCreationDatePst == null ? null : receiptCreationDatePst,
    "request_date": requestDate == null ? null : requestDate,
    "request_date_ms": requestDateMs == null ? null : requestDateMs,
    "request_date_pst": requestDatePst == null ? null : requestDatePst,
    "original_purchase_date": originalPurchaseDate == null ? null : originalPurchaseDate,
    "original_purchase_date_ms": originalPurchaseDateMs == null ? null : originalPurchaseDateMs,
    "original_purchase_date_pst": originalPurchaseDatePst == null ? null : originalPurchaseDatePst,
    "original_application_version": originalApplicationVersion == null ? null : originalApplicationVersion,
    "in_app": inApp == null ? null : List<dynamic>.from(inApp!.map((x) => x.toJson())),
  };
}

class EnumValues<T> {
  Map<String, T>? map;
  Map<T, String>? reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map!.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap!;
  }
}
