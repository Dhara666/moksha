import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:moksha_beta/widgets/custom_dialog.dart';

class FirstView extends StatelessWidget {
  final primaryColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: _width,
            height: _height,
            child:Image.asset('lib/assets/images/bg-1.jpeg',fit: BoxFit.fill),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15),
              // width: _width,
              // height: _height,
              //color: primaryColor,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // SizedBox(
                    //   height: _height * 0.15,
                    // ),
                    AutoSizeText(
                      "MOKSHA",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontFamily: 'Typewriter',
                      ),
                    ),
                    SizedBox(
                      height: _height * 0.06,
                    ),
                    AutoSizeText(
                      "Let's begin our journey to freedom from what doesn't serve you.",
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontFamily: 'Typewriter'),
                    ),
                    SizedBox(
                      height: _height * 0.05,
                    ),
                    MaterialButton(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(80.0)),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 15.0, bottom: 15.0, left: 30.0, right: 30),
                        child: Text(
                          'Get Started',
                          style: TextStyle(fontFamily: 'Typewriter', fontSize: 20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed("/Intro");
                        // showDialog(
                        //     context: context,
                        //     builder: (BuildContext context) => CustomDialog(
                        //           title: "Would you like to create a free account?",
                        //           description:
                        //               "With an account, your data will be securely saved, allowing you to access Moksha from multiple devices",
                        //           primaryButtonText: "Create my account",
                        //           primaryButtonRoute: "/signUp",
                        //           //  secondaryButtonText: "Maybe Later",
                        //           //  secondaryButtonRoute: "/home",
                        //         ));
                      },
                    ),
                    // SizedBox(
                    //   height: _height * 0.05,
                    // ),
                    // AutoSizeText(
                    //   "Already have an account?",
                    //   maxLines: 2,
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(
                    //       fontSize: 20,
                    //       color: Colors.white,
                    //       fontFamily: 'Typewriter'),
                    // ),
                    // SizedBox(
                    //   height: _height * 0.05,
                    // ),
                    // RaisedButton(
                    //   color: Colors.white,
                    //   shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(80.0)),
                    //   child: Padding(
                    //     padding: const EdgeInsets.only(
                    //         top: 15.0, bottom: 15.0, left: 30.0, right: 30),
                    //     child: Text(
                    //       'Sign In',
                    //       style: TextStyle(fontFamily: 'Typewriter', fontSize: 20),
                    //     ),
                    //   ),
                    //   onPressed: () {
                    //     Navigator.of(context).pushReplacementNamed("/signIn");
                    //   },
                    // ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}



