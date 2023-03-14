import 'package:flutter/material.dart';
import 'package:moksha_beta/color.dart';
import 'package:moksha_beta/main.dart';
import 'package:moksha_beta/views/sign_up.dart';
import 'firstView.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  PageController pageController = PageController(initialPage: 0);
  int _i = 0;

  List<String> introScreenName = [
    'lib/assets/images/ONBOARDING-1.png',
    'lib/assets/images/ONBOARDING-2.png',
    'lib/assets/images/ONBOARDING-3.png'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Swiper(
          //   loop: false,
          //   itemBuilder: (BuildContext context, int index) {
          //     return new Image.asset(
          //       introScreenName[index],
          //       fit: BoxFit.fill,
          //     );
          //   },
          //   itemCount: introScreenName.length,
          //   controller: _controller,
          //   pagination: SwiperPagination(
          //      margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 30.0),
          //       builder: DotSwiperPaginationBuilder(
          //           color: ColorRes.black,
          //           activeColor: ColorRes.white,
          //           size: 10.0,
          //           activeSize: 10.0),
          //   ),
          //   //  physics: NeverScrollableScrollPhysics(),
          //   // pagination: new SwiperPagination(),
          //
          //   // control: new SwiperControl(),
          // ),
          PageView.builder(
            controller: pageController,
            itemCount: introScreenName.length,
            onPageChanged: (int value) {
              setState(() {
                _i = value;
              });
            },
            itemBuilder: (BuildContext context, int index) {
              return new Image.asset(
                introScreenName[index],
                fit: BoxFit.fill,
              );
            },
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      isIntroScreenShow = true;
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpView(
                                  authFormType: AuthFormType.signIn)));
                    },
                    child: Container(
                        height: 40,
                        alignment: Alignment.center,
                        // padding: EdgeInsets.only(left: 20),
                        padding: EdgeInsets.only(left: 10, right: 10),
                        margin: EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text("Skip",
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Typewriter"))),
                  ),
                  Container(
                    alignment: Alignment.center,
                    height: 30,
                    decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(15)),
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            for (int i = 0; i < introScreenName.length; i++)
                              _i == i
                                  ? pageIndexIndicator(true)
                                  : pageIndexIndicator(false)
                          ],
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      // _controller.move(++_i,animation: true);
                      pageController.animateToPage(++_i,
                          duration: Duration(milliseconds: 400),
                          curve: Curves.easeIn);
                      print(_i);
                      setState(() {});
                      if (_i == 3) {
                        isIntroScreenShow = true;
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpView(
                                    authFormType: AuthFormType.signIn)));
                      }
                    },
                    child: Container(
                        height: 40,
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(left: 10, right: 10),
                        margin: EdgeInsets.only(right: 10),
                        // padding: EdgeInsets.only(left: 20),
                        decoration: BoxDecoration(
                            color: ColorRes.black,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(_i == 2 ? "Done" : "Next",
                            style: TextStyle(
                                color: ColorRes.white,
                                fontFamily: "Typewriter"))),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget pageIndexIndicator(bool isCurrentPage) => Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        height: isCurrentPage ? 10.0 : 8.0,
        width: isCurrentPage ? 10.0 : 8.0,
        decoration: BoxDecoration(
          color: isCurrentPage ? ColorRes.white : ColorRes.bgButton1,
          borderRadius: BorderRadius.circular(12),
        ),
      );
}
