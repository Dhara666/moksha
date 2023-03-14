import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moksha_beta/services/webview.dart';
import 'package:moksha_beta/widgets/alert_dialog.dart';
import 'package:moksha_beta/widgets/provider_widget.dart';
import 'package:flutter/material.dart';
import 'package:moksha_beta/services/auth_service.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:toast/toast.dart';
import '../models/User.dart';
import '../services/database.dart';
import 'homeView.dart';


final primaryColor = Colors.black;

enum AuthFormType { signIn, signUp, reset }

class SignUpView extends StatefulWidget {

  final bool isHide;
  final AuthFormType authFormType;

  SignUpView({Key? key, required this.authFormType, this.isHide = false}) : super(key: key);

  @override
  _SignUpViewState createState() => _SignUpViewState(authFormType: this.authFormType);
}

class _SignUpViewState extends State<SignUpView> {

  AuthFormType? authFormType;

  _SignUpViewState({this.authFormType});

  final formKey = GlobalKey<FormState>();
  String? _email, _password, _username, _warning;

  void switchFormState(String state) {
    formKey.currentState!.reset();
    if (state == "signUp") {
      setState(() {
        authFormType = AuthFormType.signUp;
      });
    } else {
      setState(() {
        authFormType = AuthFormType.signIn;
      });
    }
  }

  bool validate() {
    final form = formKey.currentState;
    form!.save();
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

// on press validation

  void submit() async {
    if (validate()) {
      try {
        final auth = Provider.of(context).auth!;
        if (authFormType == AuthFormType.signIn) {
          var uid = await auth.signInWithEmailAndPassword(_email!, _password!,context);
          print("--->uid ${uid}");
          if (uid.user != null && uid.user.emailVerified) {
            print("Signed In with ID  $uid");
            Toast.show("Login successfully",
                backgroundColor: Colors.black,
                backgroundRadius: 10,
                border: Border.all(color: Colors.white,width: 1.5),
                duration: 2, gravity: Toast.top
            );
            Navigator.of(context).pushReplacementNamed('/home');
          } else if (uid.user != null && !uid.user.emailVerified) {
            showAlertEmailVerification(
                context: context,
                title: 'Your Email Not Verified',
                content: 'Please click the button below to verify your email address.',
                buttonTitle: 'Send Verification Link',
                function: () async {
              await uid.user.sendEmailVerification().then((value) {
                    print('Link send sign up----->>>');
                    Navigator.pop(context);
                    Toast.show("Verification link sent successfully. Please check your email.",
                        backgroundColor: Colors.black,
                        backgroundRadius: 10,
                        border: Border.all(color: Colors.white,width: 1.5),
                        duration: 4, gravity: Toast.top);
               });
                });
          } else{
            print('null----->>>');
          }
        } else if (authFormType == AuthFormType.reset) {
          await auth.sendPasswordResetEmail(_email!);
          print('password reset email sent');
          _warning = "A password reset link has been sent to $_email";
          setState(() {
            authFormType = AuthFormType.signIn;
          });
        } else {
          String uid = await auth.createUserWithEmailAndPassword(_email!, _password!, _username!,context);
          print("Signed Up with New UID $uid");
          //Navigator.of(context).pushReplacementNamed('/signIn');
        }
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
     ToastContext().init(context);
    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;

    // onWillPop: () async {
    //   await SystemShortcuts.home();
    //   return false;
    // },

    return Scaffold (
      body: SingleChildScrollView (
        child: Container (
          color: primaryColor,
          height: _height,
          width: _width,
          child: SafeArea (
            child: Column (
              children: <Widget> [
                SizedBox (
                  height: _height * 0.025,
                ),

                //handling error alerts

                showAlert(),

                SizedBox(
                  height: _height * 0.025,
                ),

                topLabel(),

                SizedBox(
                  height: _height * 0.025,
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: buildInputs() + buildButtons() + appleLoginButton() +guestLoginButton(),
                    ),
                  ),
                )

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget showAlert() {
    if (_warning != null) {
      return Container(
        color: Colors.amberAccent,
        width: double.infinity,
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.error_outline),
            ),
            Expanded(
              child: AutoSizeText(
                _warning!,
                maxLines: 3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _warning = '';
                  });
                },
              ),
            )
          ],
        ),
      );
    }
    return SizedBox(
      height: 0,
    );
  }

  Text topLabel() {
    String _headerText;
    if (authFormType == AuthFormType.signUp) {
      _headerText = "Create New Account";
    } else if (authFormType == AuthFormType.reset) {
      _headerText = "Reset Password";
    } else {
      _headerText = "Sign In";
    }
    return Text(
      _headerText,
      maxLines: 1,
      textAlign: TextAlign.center,
      style: TextStyle(
          fontSize: 20, fontFamily: "Typewriter", color: Colors.white),
    );
  }

//input fields for email //password
  List<Widget> buildInputs() {
    List<Widget> textFields = [];

    if (authFormType == AuthFormType.reset) {
      textFields.add(
        TextFormField(
          validator: EmailValidator.validate,
          style: TextStyle(fontSize: 22.0, fontFamily: "Typewriter"),
          textAlign: TextAlign.center,
          decoration: signUpInputDecoration("Email"),
          onSaved: (value) => _email = value!,
        ),
      );

      textFields.add(SizedBox(height: 15));
      return textFields;
    }

    if (authFormType == AuthFormType.signUp) {
      textFields.add(
        TextFormField(
          validator: UsernameValidator.validate,
          style: TextStyle(fontSize: 22.0, fontFamily: "Typewriter"),
          textAlign: TextAlign.center,
          decoration: signUpInputDecoration("Username"),
          onSaved: (value) => _username = value!,
        ),
      );
      textFields.add(SizedBox(height: 15));
    }

    textFields.add(
      TextFormField(
        validator: EmailValidator.validate,
        style: TextStyle(fontSize: 22.0, fontFamily: "Typewriter"),
        textAlign: TextAlign.center,
        decoration: signUpInputDecoration("Email"),
        onSaved: (value) => _email = value!,
      ),
    );

    textFields.add(SizedBox(height: 15));

    textFields.add(
      TextFormField(
        validator: PasswordValidator.validate,
        style: TextStyle(fontSize: 22.0, fontFamily: "Typewriter"),
        textAlign: TextAlign.center,
        decoration: signUpInputDecoration("Password"),
        obscureText: true,
        onSaved: (value) => _password = value!,
      ),
    );

    textFields.add(SizedBox(height: 15));

    return textFields;
  }

  InputDecoration signUpInputDecoration(String hint) {
    return InputDecoration (
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        focusColor: Colors.white,
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 0)),
        contentPadding: EdgeInsets.only(left: 14, top: 10, bottom: 10)
    );
  }

// sign up & sign in buttons

  List<Widget> buildButtons() {

    String _switchButtonText, _newFormState, _submitButtonText;

    bool _showForgotPassword = false;

    if (authFormType == AuthFormType.signIn) {
      _switchButtonText = "New User? Create an account";
      _newFormState = "signUp";
      _submitButtonText = "Sign In";
      _showForgotPassword = true;
    } else if (authFormType == AuthFormType.reset) {
      _switchButtonText = "Return to Sign in";
      _newFormState = "signIn";
      _submitButtonText = "Submit";
    } else {
      _switchButtonText = "Already have an account? Sign in";
      _newFormState = "signIn";
      _submitButtonText = "Sign Up";

    }
    return [
      Container(
        width: MediaQuery.of(context).size.width * 0.7,
        child: RaisedButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          color: Colors.white,
          textColor: primaryColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _submitButtonText,
              style: TextStyle(fontFamily: "Typewriter", fontSize: 20),
            ),
          ),
          onPressed: submit,
        ),
      ),
      showForgotPassword(_showForgotPassword),
      if (authFormType == AuthFormType.signUp)
        Padding(
          padding: const EdgeInsets.only(top: 30,bottom: 13),
          child: Text(
            "By clicking on sign up, you agree to our terms of service & privacy policy",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      if (authFormType == AuthFormType.signUp)
      Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          // padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          MyWebView(
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
              Text(' | '),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          MyWebView(
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
            ],
          )),
      FlatButton (
          child: Text (
            _switchButtonText,
            style: TextStyle(color: Colors.white, fontFamily: "Typewriter"),
          ),
          onPressed: () {
            switchFormState(_newFormState);
          }),
    ];
  }

  List<Widget> appleLoginButton(){
    return [
      if (authFormType == AuthFormType.signIn)
        SignInWithAppleButton(
        onPressed: signInWithApple,
        style: SignInWithAppleButtonStyle.white,
      ),
    ];
  }

  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

 signInWithApple() async {
    try {
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final oAuthProvider = OAuthProvider('apple.com');
    final AuthCredential credential = oAuthProvider.credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );
     print("------>oauthCredential is $credential");
     UserCredential myUser = await FirebaseAuth.instance.signInWithCredential(credential);
     print("----->UserCredential ${myUser.user?.email}");
     UserData _user = UserData(email:myUser.user?.email,uid: myUser.user?.uid,username:myUser.user?.displayName,);
     await OurDatabase().createUser(_user);
      Toast.show("Login successfully",
        backgroundColor: Colors.black,
        backgroundRadius: 10,
        border: Border.all(color: Colors.white,width: 1.5),
        duration: 2, gravity: Toast.top
      );
     Navigator.of(context).pushReplacementNamed('/home');
      return myUser;
     } catch (e) {
      print('Catch error in sign In With Apple --> $e');
    }
  }

  Widget showForgotPassword(bool visible) {
    return Visibility (
      child: FlatButton (
        child: Text (
          'Forgot password?',
          style: TextStyle(color: Colors.white, fontFamily: "Typewriter"),
        ),
        onPressed: () {
          setState(() {
            authFormType = AuthFormType.reset;
          });
        },
      ),
      visible: visible,
    );
  }

  List<Widget> guestLoginButton() {
    return widget.isHide ? [] : [

      Padding(
        padding: const EdgeInsets.only(top: 5,bottom: 2),
        child: Text("Or", style: TextStyle(color: Colors.white, fontFamily: "Typewriter", fontSize: 20)),
      ),

      Container (
        width: MediaQuery.of(context).size.width * 0.7,
        margin: EdgeInsets.only(top: 10),
        child: RaisedButton (
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          color: Colors.white,
          textColor: primaryColor,
          child: Padding (
            padding: EdgeInsets.all(8.0),
            child: Text("Login as Guest", style: TextStyle(fontFamily: "Typewriter", fontSize: 20),
            ),
          ),
          onPressed: () async {
            String uid = await AuthService().getCurrentUID();
            print("---->my uid $uid");
            if(uid != null){
              await FirebaseAuth.instance.signOut();
              currentUserId = "";
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (BuildContext context) => Home()),
                ModalRoute.withName('/'),
              );
            }else{
              currentUserId = "";
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (BuildContext context) => Home()),
                ModalRoute.withName('/'),
              );
            }

          },
        ),
      ),

      // InkWell (
      //      onTap: () {
      //        IAP().initStoreInfo();
      //      },
      //      child: Text("SunScription", style: TextStyle(color: Colors.white, fontFamily: "Typewriter", fontSize: 20))),
    ];



  }
}
