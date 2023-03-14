import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:moksha_beta/views/slideshow.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../main.dart';
import 'favoritesView.dart';
import 'homeView.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({Key? key}) : super(key: key);

  @override
  _ReminderScreenState createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  int hours = 0;
  int minute = 0;
  int second = 1;
  int deleteHour =11;
  int deleteMinute =11;
  SharedPreferences? pref;
  List slideList = [];
  String? reminderTime;
  List<DateTime> dateTimeList = [];
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  List<DateTime> defaultDateTimeList = [];

  @override
  void initState() {
    // TODO: implement initState
    prefGetInstance();
    localNotificationTimeWise();
    super.initState();
  }

  prefGetInstance() async {
    pref = await SharedPreferences.getInstance();
    reminderTime = pref!.getString('reminderData');
    print('reminderTime --> $reminderTime');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Nudges',
          textAlign: TextAlign.start,
          style: TextStyle(fontFamily: 'Typewriter', color: Colors.white),
        ),
        actions: [
          if (reminderTime == null || reminderTime!.isEmpty)
            InkWell(
              onTap: () => timeDialogShow(),
              child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(Icons.add_circle_outline),
              ),
            ),
        ],
      ),
      body: (reminderTime == null || reminderTime!.isEmpty)
          ? Center(
              child: Text(
                'No nudges added yet! \nTap + to select a time to nudge',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            )
          : Padding(
              padding: EdgeInsets.all(5.0),
              child: Slidable(
                key: ValueKey(0),
                startActionPane: ActionPane(
                  motion: ScrollMotion(),
                  extentRatio: 0.25,
                  children: [
                    SlidableAction(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                      onPressed: (BuildContext context) async {
                        reminderTime = null;
                        pref!.remove('reminderData');
                        await flutterLocalNotificationsPlugin.cancelAll();
                        String reminderDefaultTime = '$deleteHour : $deleteMinute';
                        pref!.setString(
                            'reminderDefaultData', reminderDefaultTime);
                        reminderDefaultTime =
                            pref!.getString("reminderDefaultData")!;
                        List<String> splitTime = reminderDefaultTime.split(':');
                        setDefaultDateArray(
                            splitTime[0].trim(), splitTime[1].trim());
                        await showDefaultNotification(splitTime);
                        setState(() {});
                      },
                    ),
                  ],
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50.0,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(5),
                        child: Text(
                          'Nudge me at $reminderTime',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () => timeDialogShow(),
                          child: Icon(
                            Icons.edit,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  timeDialogShow() async {
    showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: hours, minute: minute),
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            ),
          );
        }).then((value) async {
      if (value != null) {
        await flutterLocalNotificationsPlugin.cancelAll();
        print('TimeDialog Show Value --> $value');
        TimeOfDay pickedTime = value;
        hours = pickedTime.hour;
        minute = pickedTime.minute;
        reminderTime = '$hours : $minute';
        pref!.setString('reminderData', reminderTime!);
        setState(() {});
        showNotification();
      }
    });
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
    flutterLocalNotificationsPlugin.initialize(platform, onSelectNotification : onSelectNotification);
  }

  Future<dynamic> onSelectNotification(payload) async {
    print("--->>>>>>payload is $payload");
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

  showNotification() async {
    await setDateArray();
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

    var iOS = new IOSNotificationDetails(sound: 'notification_sound.aiff',presentSound: true,);
    var platform = new NotificationDetails(android: android, iOS: iOS);
    int i = 0;
    do {
      Random range = new Random();
      int random = range.nextInt(slideList.length);
      await Future.delayed(Duration(microseconds: 300), () async {
        await flutterLocalNotificationsPlugin.schedule(
          int.parse('$hours$minute$i'),
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

    var iOS = new IOSNotificationDetails(sound: 'notification_sound.aiff',presentSound: true);
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

  setDateArray() {
    dateTimeList.clear();
    DateTime dateTime = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, hours, minute, second);
    for (int i = 0; i < 50; i++) {
      dateTimeList.add(dateTime.add(Duration(days: i)));
    }
    print('Set day --> $dateTimeList');
  }

  setDefaultDateArray(hour, minute) {
    defaultDateTimeList.clear();
    DateTime dateTime = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, int.parse(hour), int.parse(minute), 0);
    for (int i = 0; i < 50; i++) {
      Duration date = dateTime.difference(DateTime.now());
      bool isBefore = date.isNegative;
      if (!isBefore) {
        defaultDateTimeList.add(dateTime);
      }
      dateTime = DateTime(dateTime.year, dateTime.month, dateTime.day + 1,
          int.parse(hour), int.parse(minute), 0);
    }
    print('Set Delete Default day --> $defaultDateTimeList');
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
}
