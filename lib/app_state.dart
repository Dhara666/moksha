import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/mediamodel.dart';
import 'models/profile_detail.dart';
import 'models/user_detail_model.dart';

AppState appState = AppState();
SharedPreferences? sharedPreferences;

class AppState {
  static final AppState _singleton = AppState._internal();

  factory AppState() {
    return _singleton;
  }

  AppState._internal();

  String SUPPORTER_SMALL = "supportersmall";
  String SUPPORTER_MEDIUM = "supportermedium";
  String SUPPORTER_LARGE = "supporterlarge";

  ProfileDetail? currentUserData;
  UserDetailsModel userDetailsModel = UserDetailsModel();
  List<MediaModel>? medialList;
  List<String>? productIds = <String>['001'];

  // List<String> productIds = <String>['MOKSHA.BETA.APP','1527890240','first_sub_app'];
    // List<String> productIds = <String>['gold_sub', 'premium_sub', 'plus_sub'];

  String fcmToken = '';

  int? id;
  String accessToken = '';
  String name = '';
  String gender = '';

  // USER META
  String relation = '';
  String children = '';
  String livingIn = '';
  String jobTitle = '';
  String about = '';
  String dateOfBirth = '';

  // USER SUBSCRIPTION
  String? subscriptionName;
  DateTime? subscriptionDate ;

  // SUPERLIKE & LIKE
  int? superLikeCount;
  DateTime? superLikeTime;
  int? likeCount;
  DateTime? likeTime;

  BuildContext? settingContext;

}
