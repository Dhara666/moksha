import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moksha_beta/app_state.dart';
import 'package:moksha_beta/color.dart';
import 'package:moksha_beta/services/auth_service.dart';
import 'package:moksha_beta/services/webview.dart';
import 'package:moksha_beta/shop_screen.dart';
import 'package:moksha_beta/views/favoritesView.dart';
import 'package:moksha_beta/views/newWidgetView.dart';
import 'package:moksha_beta/views/reminder_screen.dart';
import 'package:moksha_beta/views/sign_up.dart';
import 'package:moksha_beta/widgets/provider_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../prefrences.dart';
import 'homeView.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool status = true;
  double iconHeight = 25.0;
  double iconWidth = 25.0;
  double iconPadding = 12.0;
  double iconContainerHeight = 50.0;

  @override
  Widget build(BuildContext context) {
    print("runtime type-->$runtimeType");
    final _width = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: Colors.black),
      width: _width/0.1,
      child:  ListView (
        padding: const EdgeInsets.all(30),
        children: <Widget> [
          InkWell (
            child: Row(
              children: [
                iconWidget("lib/assets/icons/ic_subscription.png"),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration (
                        border: Border.all(width: 0.5, color: Colors.white),
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    child: Padding (
                      padding: const EdgeInsets.all(10.0),
                      child: Text (
                        'Manage subscription',
                        textAlign: TextAlign.start,
                        style: TextStyle (
                            fontFamily: "Typewriter",
                            fontSize: 15,
                            color: Colors.white
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ShopScreen()));
            },
          ),
          SizedBox (height: 40),
          InkWell (
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => ReminderScreen(),));
             },
            child: Row(
              children: [
                iconWidget("lib/assets/icons/ic_nudges.png"),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container (
                    height: 50,
                    padding: EdgeInsets.only(right: 5),
                    decoration: BoxDecoration (
                        border: Border.all(width: 0.5, color: Colors.white),
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    child: Row (
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding (
                          padding: EdgeInsets.only (left: 10),
                          // padding: const EdgeInsets.all(10.0),
                          child: Text('Nudges',
                            textAlign: TextAlign.start,
                            style: TextStyle (
                                fontFamily: "Typewriter",
                                fontSize: 15,
                                color: Colors.white
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox (height: 40),
          InkWell (
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => NewWidgetView(),));
             },
            child: Row(
              children: [
                iconWidget("lib/assets/icons/ic_add_widgets.png"),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container (
                    height: 50,
                    padding: EdgeInsets.only(right: 5),
                    decoration: BoxDecoration (
                        border: Border.all(width: 0.5, color: Colors.white),
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    child: Row (
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding (
                          padding: EdgeInsets.only (left: 10),
                          // padding: const EdgeInsets.all(10.0),
                          child: Text('Add widgets',
                            textAlign: TextAlign.start,
                            style: TextStyle (
                                fontFamily: "Typewriter",
                                fontSize: 15,
                                color: Colors.white
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 40),
          InkWell (
            child: Row(
              children: [
                iconWidget("lib/assets/icons/ic_favourite.png"),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container (
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.5, color: Colors.white),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Padding (
                        padding: const EdgeInsets.all(10.0),
                        child: Text (
                          'Favorites',
                          textAlign: TextAlign.start,
                          style: TextStyle (
                              fontFamily: "Typewriter",
                              fontSize: 15,
                              color: Colors.white
                          ),
                        ),
                      )
                  ),
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => FavoriteView()));
            },
          ),
          SizedBox(height: 40),
          InkWell (
            child: Row(
              children: [
                iconWidget("lib/assets/icons/ic_about.png"),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container (
                    height: 50,
                    decoration: BoxDecoration(
                        border: Border.all(width: 0.5, color: Colors.white),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Padding (
                      padding: const EdgeInsets.all(10.0),
                      child: Text (
                        'About',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontFamily: "Typewriter",
                            fontSize: 15,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=> MyWebView(title:"About", selectedUrl: "https://www.johannagbjackson.com/mobile-app",)));
            },
          ),
          SizedBox (height: 40),
          InkWell (
            child: Row(
              children: [
                iconWidget("lib/assets/icons/ic_privacy.png"),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container (
                    height: 50,
                    decoration: BoxDecoration (
                        border: Border.all(width: 0.5, color: Colors.white),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Padding (
                      padding: const EdgeInsets.all(10.0),
                      child: Text (
                        'Privacy policy',
                        textAlign: TextAlign.start,
                        style: TextStyle (
                            fontFamily: "Typewriter",
                            fontSize: 15,
                            color: Colors.white
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=> MyWebView(title:"Privacy policy", selectedUrl: "https://app.termly.io/document/privacy-policy/3b579330-3628-4ce7-9499-51fa2e18dedb",)));
            },
          ),
          SizedBox(height: 40),
          InkWell (
            child: Row(
              children: [
                iconWidget("lib/assets/icons/ic_terms.png"),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container (
                    height: 50,
                    decoration: BoxDecoration(
                        border: Border.all(width: 0.5, color: Colors.white),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Padding (
                      padding: EdgeInsets.all(10.0),
                      child: Text (
                        'Terms of use',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontFamily: "Typewriter",
                            fontSize: 15,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=> MyWebView(title:"Terms of use", selectedUrl: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/",)));
            },
          ),
          SizedBox(height: 40),
          InkWell (
            child: Row(
              children: [
                iconWidget("lib/assets/icons/ic_contact.png"),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container (
                    height: 50,
                    decoration: BoxDecoration(
                        border: Border.all(width: 0.5, color: Colors.white),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Padding (
                      padding: EdgeInsets.all(10.0),
                      child: Text (
                        'Contact us',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontFamily: "Typewriter",
                            fontSize: 15,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            onTap: () {
              _createEmail();
            },
          ),
          SizedBox(height: 40),
          InkWell (
            child: Row(
              children: [
                iconWidget(currentUserId.isEmpty ? "lib/assets/icons/ic_sign_in.png" : "lib/assets/icons/ic_sign_out.png"),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container (
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.5, color: Colors.white),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Padding (
                        padding: const EdgeInsets.all(10.0),
                        child: Text (
                          currentUserId.isEmpty ? 'Login' : 'Sign out',
                          textAlign: TextAlign.start,
                          style: TextStyle (
                              fontFamily: "Typewriter",
                              fontSize: 15,
                              color: Colors.white
                          ),
                        ),
                      )
                  ),
                ),
              ],
            ),
            onTap: () async {
              if(currentUserId.isEmpty) {
                logInButton();
              } else {
                signOutButton();
                await removeStringValue();
              }
            },
          ),
        ],
      ),
    );
  }

  logInButton() {
    Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (BuildContext context) => SignUpView(authFormType: AuthFormType.signIn)),
      ModalRoute.withName('/'));
  }
  
  signOutButton() async {
    try {
      AuthService? auth = Provider.of(context).auth;
      await auth?.signOut();
      print("Signed OUT");
    } catch (e) {
      print(e);
    }
  }

  planDialogue(String plan, double price) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog (
            title: Column (
              children: [
                Text (
                  "${plan.toUpperCase()}",
                  style: TextStyle(fontSize: 28),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "\$$price",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      " / month",
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),

            insetAnimationCurve: Curves.decelerate,
            actions: <Widget> [
              GestureDetector (
                onTap: () async {
                  appState.settingContext = this.context;
                  int index;

                  if (plan == 'Gold')
                    index = 0;
                  else if (plan == 'Premium')
                    index = 1;
                  else
                    index = 2;

                  // EasyLoading.show();
                  print(index);

                  // final PurchaseParam purchaseParam = PurchaseParam(productDetails: appState.products.where((element) => element.id == appState.productIds![index]).first);
                  // print(purchaseParam.productDetails.title);
                  // InAppPurchaseConnection.instance.buyConsumable(purchaseParam: purchaseParam);
                },
                child: Container (
                  padding: EdgeInsets.all(20.0),
                  color: ColorRes.darkButton,
                  child: Text (
                    "SUBSCRIBE",
                    textAlign: TextAlign.center,
                    style: TextStyle (
                        fontSize: 18,
                        color: ColorRes.white,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none
                    ),
                  ),
                ),
              ),
            ],
          );
        });
    }

  void _createEmail() async {

    final Uri params = Uri (
        scheme: 'mailto',
        path: 'moksha.app2020@gmail.com',
        query: 'subject=App Feedback&body=App Version 1.2'
    );

    var url = params.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  iconWidget(String imagePath) {
    return Container(
      height: iconContainerHeight,
      padding: EdgeInsets.symmetric(horizontal: iconPadding,vertical: iconPadding),
      decoration: BoxDecoration (
          border: Border.all(width: 0.5, color: Colors.white),
          borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      child: Image.asset(imagePath,height: iconHeight,width: iconWidth,color: Colors.white,),
    );
  }
}

