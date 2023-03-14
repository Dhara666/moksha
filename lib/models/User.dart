import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  String? uid;
  String? username;
  String? email;
  Timestamp? accountCreated;
  List? likes;


  UserData({
    this.uid, this.username, this.email, this.likes, this.accountCreated
  }
  );

  
}