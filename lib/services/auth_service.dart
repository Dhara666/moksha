import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moksha_beta/models/User.dart';
import 'package:moksha_beta/services/database.dart';
import 'package:toast/toast.dart';

class AuthService {
  UserData _currentUser = UserData();

  UserData get getCurrentUser => _currentUser;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<User> get onAuthStateChanged => _firebaseAuth.authStateChanges().map(
        (User? user) => user!,
      );

  // saving userData

  Future<String> onStartUp() async {
    String retVal = "error";

    try {
      User _firebaseUser = await _firebaseAuth.currentUser!;
      _currentUser.uid = _firebaseUser.uid;
      _currentUser.email = _firebaseUser.email;
      retVal = "success";
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  // get UID

  String getCurrentUID() {
    String uid;
    var user =  _firebaseAuth.currentUser;
    if(user != null){
      uid = user.uid;
    }
    else{
      uid = '';
    }

    print("auth_service $uid");
    return uid;
  }
  Future<String> getCurrentUName() async {
    String userName;
    User user = await  _firebaseAuth.currentUser!;
    if(user != null){
      userName = user.email ??' ';
    }
    else{
      userName = '';
    }

    print("auth_service $userName");
    return userName;
  }

  // Email Password sign up
  Future<String> createUserWithEmailAndPassword(String email, String password, String username,BuildContext context) async {

    String retVal = "error";
    UserData _user = UserData();

    try {
      print("---->email: $email");
      var _authResult = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      _user.uid = _authResult.user!.uid;
      _user.email = _authResult.user!.email;
      _user.username = username;
      print("--->auth ${_authResult.user!.emailVerified}");
      print("--->_authResult user ${_authResult.user!.email}");
      if (_authResult.user != null && !_authResult.user!.emailVerified) {
        await _authResult.user!.sendEmailVerification().then((value) {
          Toast.show("Verification link sent successfully. Please check your email.",
              backgroundColor: Colors.black,
              textStyle: TextStyle(color: Colors.white),
              backgroundRadius: 10,
              border: Border.all(color: Colors.white,width: 1.5),
              duration: 4, gravity: Toast.top);
          Navigator.of(context).pushReplacementNamed('/signIn');
          print('Link send----->>>');
        });
      }
      String _returnString = await OurDatabase().createUser(_user);
      if(_returnString == "success"){
        retVal = "success";
      }
    } catch (e) {
      print(e);
      Toast.show(e.toString(),
          backgroundColor: Colors.black,
          textStyle: TextStyle(color: Colors.white),
          backgroundRadius: 10,
          border: Border.all(color: Colors.white,width: 1.5),
          duration: 3, gravity: Toast.top);

    }
    return _user.uid!;
  }

  // Email password sign in
 signInWithEmailAndPassword (String email, String password,BuildContext context) async {
    try {
      var _authResult = await _firebaseAuth.signInWithEmailAndPassword(email: email.trim(), password: password);
      print("uid------>>>${_authResult.user!.uid}");
      return _authResult;
    } catch(e) {
      print("e======>$e");
      print(e);
      Toast.show(e.toString(),
          backgroundColor: Colors.black,
          textStyle:  TextStyle(color: Colors.white),
          backgroundRadius: 10,
          border: Border.all(color: Colors.white,width: 1.5),
          duration: 3);
    }
  }

// Sign Out
  Future<String> signOut() async {
    String retVal = "error";

    try {
      await _firebaseAuth.signOut();
      _currentUser = UserData();
      retVal = "successfully signed out";
    } catch (e) {
      print(e);
    }
    return retVal;
  }

// password reset handling

  Future sendPasswordResetEmail(String email) async {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}

class EmailValidator {
  static String? validate(String? value) {
    if (value!.isEmpty) {
      return "Email cannot be empty";
    }
    return null;
  }
}

class UsernameValidator {
  static String? validate(String? value) {
    if (value!.isEmpty) {
      return "Username cannot be empty";
    }
    if (value.length < 2) {
      return "Username must be at least 2 characters long";
    }
    if (value.length > 50) {
      return "Username must be less than 50 characters";
    }
    return null;
  }
}

class PasswordValidator {
  static String? validate(String? value) {
    if (value!.isEmpty) {
      return "Password cannot be empty";
    }
    return null;
  }
}
