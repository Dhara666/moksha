import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class getDocument extends StatelessWidget{
  final String documentID;

  getDocument(this.documentID);

  @override 
  Widget build (BuildContext context){
    CollectionReference stories = FirebaseFirestore.instance.collection("Stories");

    return FutureBuilder<DocumentSnapshot> (
      future: stories.doc(documentID).get(),
      builder: 
      (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
        if(snapshot.hasError){
          return Text("Something went wrong");
        }
        if (snapshot.connectionState == ConnectionState.done){
         // Map<String, dynamic> data = snapshot.data!.data();
          print(snapshot.data!.id);
          return const Text("Retrieved fam");
        }
        else{
          return Container();
        }
      }
    );
  }
}