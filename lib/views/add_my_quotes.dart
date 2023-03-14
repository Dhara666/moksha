import 'package:flutter/material.dart';

import '../services/database.dart';

class AddMyQuotes extends StatefulWidget {

  final String? quotesData;
  final String? docId;
  const AddMyQuotes({Key? key, this.quotesData, this.docId}) : super(key: key);

  @override
  _AddMyQuotesState createState() => _AddMyQuotesState();
}

class _AddMyQuotesState extends State<AddMyQuotes> {

  TextEditingController quotesTxt = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if(widget.quotesData != null && widget.quotesData!.isNotEmpty ) {
      quotesTxt.text = widget.quotesData!;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.quotesData != null && widget.quotesData!.isNotEmpty ? "Update My Quotes" : "Add My Quotes", style: TextStyle (
        fontSize: 20,
        color: Colors.white,
        fontFamily: "Typewriter"))
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              Container(
                  width: MediaQuery.of(context).size.width,
                  // height: MediaQuery.of(context).size.height / 2.3,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  margin: EdgeInsets.only(left: 8, right: 8, bottom: 10, top: 5),
                  decoration:
                  BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: Colors.black, blurRadius: 1)]
                    // border: Border.all(width: 1, color: Colors.black12)
                  ),
                  child: TextField(
                    maxLines: 10,
                    controller: quotesTxt,
                    // keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.newline,
                    style: TextStyle (
                      fontSize: 20,
                      color: Colors.black,
                      fontFamily: "Typewriter"),
                    decoration: new InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding:
                        EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                        hintText: "Enter Quote",
                        hintStyle: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontFamily: "Typewriter")
                    ),
                  )),

              InkWell(
                onTap: () async {

                  if(widget.quotesData != null && widget.quotesData!.isNotEmpty) {
                    Map<String, dynamic> myQuotes = {
                      "quote": quotesTxt.text.trim()
                    } ;
                    String _returnString = await OurDatabase().updateMyQuotes(myQuotes, widget.docId!);
                    print("my quotes add in $_returnString");

                    if (_returnString == "success") {
                      Navigator.pop(context, true);
                      quotesTxt.clear();
                    }
                  } else {
                      Map<String, dynamic> myQuotes = {
                        "quote": quotesTxt.text.trim()
                      };
                      String _returnString =
                          await OurDatabase().addMyQuotes(myQuotes);
                      print("my quotes add in $_returnString");

                      if (_returnString == "success") {
                        Navigator.pop(context, true);
                        quotesTxt.clear();
                      }
                   }
                },
              child: Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration (
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Text(widget.quotesData != null && widget.quotesData!.isNotEmpty ? "Update Quote" : "Add Quote", style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontFamily: "Typewriter"))))


            ],
          ),
        ),
      ),
    );
  }
}

