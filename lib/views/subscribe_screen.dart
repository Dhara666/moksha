import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:moksha_beta/services/webview.dart';

class SubscriptionDetailsPage extends StatefulWidget {
  final Function? subScribeQuotes;
  final ProductDetails? productDetails;
  final bool? isLoading;

  const SubscriptionDetailsPage(
      {Key? key, @required this.subScribeQuotes,this.productDetails, this.isLoading})
      : super(key: key);

  @override
  SubscriptionDetailsPageState createState() => SubscriptionDetailsPageState();
}

class SubscriptionDetailsPageState extends State<SubscriptionDetailsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Subscription Details',
            style: TextStyle(color: Colors.white, fontFamily: "Typewriter")),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: [
            SizedBox(
              height: 10,
            ),
            Text('Payments',
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Typewriter",
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            SizedBox(
              height: 10,
            ),
            Text(
                'Your payment will be charged to your iTunes Account once you confirm your purchase.\n',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "Typewriter",
                  fontSize: 13,
                )),
            SizedBox(
              height: 10,
            ),
            Text(
                'Your iTunes account will be charged again when your subscription automatically renews at the end of your current subscription period unless auto-renew is turned off at least 24 hours prior to end of the current period.\n',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "Typewriter",
                  fontSize: 13,
                )),
            SizedBox(
              height: 10,
            ),
            Text(
                'You can manage or turn off auto-renew in your Apple ID Account Setting any time after purchase.\n',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "Typewriter",
                  fontSize: 13,
                )),
            SizedBox(
              height: 20,
            ),
            Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                // padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
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
                    Text(' | '),
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
                  ],
                ))
          ],
        ),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () async {
          widget.subScribeQuotes!.call(widget.productDetails);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
          child: Container(
            height: 50,
            width: MediaQuery.of(context).size.width * 1,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.black, borderRadius: BorderRadius.circular(8)),
            child: Text('Continue',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Typewriter",
                    fontSize: 17)),
          ),
        ),
      ),
    );
  }
}
