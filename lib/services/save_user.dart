// import 'package:flutter/material.dart';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class AddUser extends StatelessWidget {
//   final String _username;
//   final String _email;
//
//
//   AddUser(this._username, this._email);
//
//   @override
//   Widget build(BuildContext context){
//     CollectionReference users = Firestore.instance.collection('users');
//     Future<void> addUser() {
//       // Call the user's CollectionReference to add a new user
//       return users
//           .add({
//            "username":_username,
//            "email":_email
//           })
//           .then((value) => print("User Added"))
//           .catchError((error) => print("Failed to add user: $error"));
//     }
//
//   }
// }