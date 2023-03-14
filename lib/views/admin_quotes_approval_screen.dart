import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moksha_beta/color.dart';
import 'package:moksha_beta/views/homeView.dart';
import 'package:moksha_beta/widgets/common_button.dart';

class AdminQuotesApprovalScreen extends StatefulWidget {
  const AdminQuotesApprovalScreen({Key? key}) : super(key: key);

  @override
  _AdminQuotesApprovalScreenState createState() =>
      _AdminQuotesApprovalScreenState();
}

class _AdminQuotesApprovalScreenState extends State<AdminQuotesApprovalScreen> {
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text("Quotes Request",
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontFamily: "Typewriter"))),
      body: Stack(
        children: [
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('admin')
                  .get()
                  .asStream(),
              builder: (context, AsyncSnapshot snap) {
                print(snap.data);
                List<DocumentSnapshot> slideList = snap.data?.docs ?? [];
                return slideList.length == 0
                    ? Center(
                        child: Text(
                        'No quotes request',
                        style: TextStyle(color: ColorRes.black),
                      ))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: slideList.length,
                        itemBuilder: (context, index) {
                          return Container(
                              padding: EdgeInsets.only(left: 10),
                              margin: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 8,
                                    ),
                                    userQuotesDetails(
                                      title: "User Name : ",
                                      subTitle:
                                          slideList[index]['userName'] ??
                                              '',
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    userQuotesDetails(
                                      title: "Quote : ",
                                      subTitle:
                                          slideList[index]['quote'] ?? '',
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    userQuotesDetails(
                                      title: "Date : ",
                                      subTitle: slideList[index]['create_time']
                                          .toDate()
                                          .toString()
                                          .substring(0, 10),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Row(
                                      children: [
                                        adminButton(
                                            text: 'Approve',
                                            function: () {
                                              showDialog<String>(
                                                context: context,
                                                builder:
                                                    (BuildContext context) =>
                                                        AlertDialog(
                                                  title: Text(
                                                    'Are you sure you want to approve this quote?',
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                    textAlign:
                                                        TextAlign.justify,
                                                  ),
                                                  actions: <Widget>[
                                                    commonTextButton(
                                                        buttonText: 'Yes',
                                                        function: () {
                                                          HapticFeedback
                                                              .heavyImpact();
                                                          DocumentReference
                                                              adminTable =
                                                              FirebaseFirestore.instance
                                                                  .collection(
                                                                      'admin')
                                                                  .doc(
                                                                      "${slideList[index]['doc_id']}");
                                                          adminTable
                                                              .update({
                                                            "isApproval": true
                                                          });
                                                          print(
                                                              "ID------>>${slideList[index]['userId']}");
                                                          DocumentReference
                                                              userTable =
                                                          FirebaseFirestore.instance
                                                                  .collection(
                                                                      'users')
                                                                  .doc(slideList[index]['userId'])
                                                                  .collection(
                                                                      "my_quotes")
                                                                  .doc(
                                                                      "${slideList[index]['doc_id']}");
                                                          userTable.update({
                                                            "isApproval": true
                                                          });
                                                          DocumentReference
                                                              userQuotes =
                                                          FirebaseFirestore.instance
                                                                  .collection(
                                                                      'Stories')
                                                                  .doc(
                                                                      "${slideList[index]['doc_id']}");
                                                          Map<String, dynamic>
                                                              setData = {
                                                            "create_time":
                                                                DateTime.now(),
                                                            "quote":
                                                                "${slideList[index]['quote']}",
                                                            "img":
                                                                'https://images.unsplash.com/photo-1583224874284-c7aeb59863d7?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80'
                                                          };
                                                          userQuotes
                                                              .set(setData);
                                                          DocumentReference
                                                              adminApproval =
                                                              FirebaseFirestore.instance
                                                                  .collection(
                                                                      'admin')
                                                                  .doc(
                                                                      "${slideList[index]['doc_id']}");
                                                          adminApproval
                                                              .delete();
                                                          Navigator.pop(
                                                              context, 'Yes');
                                                          setState(() {});
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        Home(),
                                                              ));
                                                        }),
                                                    commonTextButton(
                                                      buttonText: 'Cancel',
                                                      function: () =>
                                                          Navigator.pop(context,
                                                              'Cancel'),
                                                    )
                                                  ],
                                                ),
                                              );
                                            }),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        adminButton(
                                            text: 'Decline',
                                            function: () {
                                              showDialog<String>(
                                                context: context,
                                                builder:
                                                    (BuildContext context) =>
                                                        AlertDialog(
                                                  title: Text(
                                                    'Are you sure you want to decline this quote?',
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                    textAlign:
                                                        TextAlign.justify,
                                                  ),
                                                  actions: <Widget>[
                                                    commonTextButton(
                                                        buttonText: 'Yes',
                                                        function: () {
                                                          HapticFeedback
                                                              .heavyImpact();
                                                          DocumentReference
                                                              adminTable =
                                                          FirebaseFirestore.instance
                                                                  .collection(
                                                                      'admin')
                                                                  .doc(
                                                                      "${slideList[index]['doc_id']}");
                                                          adminTable.delete();
                                                          DocumentReference
                                                          userTable =
                                                          FirebaseFirestore.instance
                                                              .collection(
                                                              'users')
                                                              .doc(slideList[index]['userId'])
                                                              .collection(
                                                              "my_quotes")
                                                              .doc(
                                                              "${slideList[index]['doc_id']}");
                                                           userTable.update({
                                                            "isApproval": true,
                                                          //  "isDecline": true,
                                                          });
                                                          setState(() {});
                                                          Navigator.pop(
                                                              context, 'Yes');
                                                          //   Navigator.push(context, MaterialPageRoute(builder: (context) => Home(),));
                                                        }),
                                                    commonTextButton(
                                                      buttonText: 'Cancel',
                                                      function: () =>
                                                          Navigator.pop(context,
                                                              'Cancel'),
                                                    )
                                                  ],
                                                ),
                                              );
                                            }),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ));
                        },
                      );
              }),
          isLoading
              ? Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  child: Center(
                      child: CircularProgressIndicator(
                          backgroundColor: Colors.black,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.grey))),
                )
              : Container()
        ],
      ),
    );
  }


  Widget userQuotesDetails({String? title, String? subTitle}){
    return Row(
      children: [
        Text(
          title!,
          style: TextStyle(
              color: ColorRes.white,
              fontWeight: FontWeight.bold),
        ),
        Text(
          subTitle!,
          style:
          TextStyle(color: ColorRes.white),
        ),
      ],
    );
  }

  Widget adminButton({String? text,required Function function}){
    return GestureDetector(
      onTap: (){
        function();
      },
      child: Container(
        height: 25,
        padding: EdgeInsets.symmetric(horizontal: 10),
        margin: EdgeInsets.only(
            right: 10, bottom: 0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(10),
        ),
        child: Text(
          text!,
          style: TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
