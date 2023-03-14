import 'package:flutter/material.dart';
import 'package:moksha_beta/views/homeView.dart';
import 'package:moksha_beta/views/sign_up.dart';

import '../views/settingsView.dart';

void showAlert(BuildContext context, String title) {
  showDialog (
      context: context,
      builder: (context) => AlertDialog (
        content: Text(title, style: TextStyle(
            fontSize: 17,
            color: Colors.black,
            fontFamily: "Typewriter")
        ),
        actions: <Widget>[
          FlatButton (
            child: const Text('Cancel', style: TextStyle(color: Colors.red, fontFamily: "Typewriter")),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: const Text('Login', style: TextStyle(color: Colors.black, fontFamily: "Typewriter")),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpView(authFormType: AuthFormType.signIn, isHide: true)));
            },
          )
        ],
      ));
}

void showSuccessAlert(BuildContext context, String title) {
  showDialog (
      context: context,
      builder: (context) => AlertDialog (
        content: Text(title, style: TextStyle(
            fontSize: 17,
            color: Colors.black,
            fontFamily: "Typewriter")
        ),
        actions: <Widget>[
          MaterialButton(
            child: const Text('ok', style: TextStyle(color: Colors.black, fontFamily: "Typewriter")),
            onPressed: () {
              print("----->MaterialPageRoute ok button");
              Navigator.push(context, MaterialPageRoute(builder: (context)=>Home()));
              // Navigator.of(context).pop();
             // Navigator.push(context, MaterialPageRoute(builder: (context) => Home(),));
            },
          )
        ],
      ));
}

void showAlertEmailVerification(
    {BuildContext? context,
      String? title,
      String? content,
      String? buttonTitle,
      Function? function}) {
  showDialog(
      context: context!,
      builder: (context) => AlertDialog(
        title: Text(title!,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: "Typewriter")),
        content: Text(content!,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontFamily: "Typewriter")),
        contentPadding:
        EdgeInsets.only(top: 15, right: 15, left: 15, bottom: 5),
        actions: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(buttonTitle!,
                        style: TextStyle(
                            color: Colors.white, fontFamily: "Typewriter")),
                  ),
                  onPressed: () {
                    function!();
                  },
                ),
              ],
            ),
          )
        ],
      ));
}