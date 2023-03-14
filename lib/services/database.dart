import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moksha_beta/models/User.dart';
import '../views/homeView.dart';

class OurDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createUser(UserData user) async {
    String retVal = "Error";

    try {

      await _firestore.collection("users").doc(user.uid).set({
        'Username': user.username,
        'email': user.email,
        'accountCreated': Timestamp.now(),
        'likes': user.likes
      });
      retVal = "success";
    } catch (e) {
      print(e);
    }
    return retVal;
  }


  Future <void> addLikes(String documentId) async {
    CollectionReference users = _firestore.collection('users').doc(currentUserId).collection('my_like');
    try {
      final data = await users.doc(documentId);
      print("hello $data");
      data.set({"stories_doc_id":documentId});
    } catch (e) {
      print(e);
    }
  }

  Future <QuerySnapshot?> getAllLikes() async {
    CollectionReference users = _firestore.collection('users').doc(currentUserId).collection('my_like');
    try {
      final data = await users.get();
      print("like documents $data");
      return data;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String> deleteLikes(String documentId) async {
    CollectionReference users = _firestore.collection('users').doc(currentUserId).collection('my_like');
    try {
      final data = await users.doc(documentId).delete();
      return "success";
      // print("hello $data");
      // data.setData({"stories_doc_id":documentId});
    } catch (e) {
      print(e);
      return "error";
    }
  }



    Future <String> addMyQuotes(Map<String, dynamic> myQuotes) async{

    if(currentUserId != null && currentUserId.isNotEmpty) {
      DocumentReference users = _firestore.collection('users').doc(currentUserId).collection("my_quotes").doc();
      // CollectionReference users = _firestore.collection('users').document(currentUserId).collection("my_quotes");
      try{

        Map<String, dynamic> _data = {};
        _data = {"doc_id" : users.id,"isApproval": false,/*"isDecline": false,*/};
        _data.addAll(myQuotes);
        print(_data);
        users.set(_data);
        return "success";
      }
      catch (e){
        print(e);
        return "error";
      }
    } else {
      return "uid null";
    }
  }

  Future <String> updateMyQuotes(Map<String, dynamic> myQuotes, String docId) async {

    if(currentUserId != null && currentUserId.isNotEmpty) {
      CollectionReference users = _firestore.collection('users').doc(currentUserId).collection("my_quotes");
      try {
        users.doc(docId).update(myQuotes);
        return "success";
      }
      catch (e){
        print(e);
        return "error";
      }
    } else {
      return "uid null";
    }

  }

   Future<QuerySnapshot?> getMyQuotes() async{

    if(currentUserId != null && currentUserId.isNotEmpty) {
      // CollectionReference users =
      Query query =
      _firestore.collection('users').doc(currentUserId).collection("my_quotes");

      try{
        var _data = await query.get();
         print(_data);
        return _data;
      }
      catch (e){
        print(e);
        return null;
      }
    } else {
      return null;
    }
  }




}
