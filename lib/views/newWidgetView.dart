import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class NewWidgetView extends StatefulWidget {
  const NewWidgetView({Key? key}) : super(key: key);

  @override
  _NewWidgetViewState createState() => _NewWidgetViewState();
}

class _NewWidgetViewState extends State<NewWidgetView> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      'assets/video/addWidget.mp4',
    );

    _controller!.addListener(() {
      setState(() {});
    });
    _controller!.setLooping(true);
    _controller!.initialize().then((_) {
      _controller!.setVolume(0);
      setState(() {});
    });
    _controller!.play();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text("Add widgets",
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontFamily: "Typewriter"))),
      body: ListView(
        children: [
          Container(
              // height: MediaQuery.of(context).size.height * 0.15,
              margin: EdgeInsets.all(10),
               padding: EdgeInsets.symmetric(horizontal:8,vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  commonText("• Long press on app icon"),
                  commonText("• Tap + on the top left corner"),
                  commonText("• Search for moksha"),
                  commonText("• Select the size & placement of your widget"),
                  commonText("• Tap on the home icon within the app to \n\t\tsee the quotes in your widgets!"),
                ],
              )),
          Container(
            height: MediaQuery.of(context).size.height * 0.66,
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: _controller!.value.isInitialized
                ? Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: VideoPlayer(_controller!)),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                          icon: _controller!.value.isPlaying
                              ? Icon(
                                  Icons.pause,
                                  size: 30,
                                )
                              : Icon(
                                  Icons.play_arrow,
                                  size: 30,
                                ),
                          onPressed: () {
                            setState(() {
                              _controller!.value.isPlaying
                                  ? _controller!.pause()
                                  : _controller!.play();
                            });
                          },
                          color: Colors.white),
                    )
                  ],
                )
                : Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.black,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                    ),
                  ),
          )
        ],
      ),
    );
  }
  Widget commonText(String text){
    return Text(
      text,
      textAlign: TextAlign.left,
      style: TextStyle(
        fontSize: 13,
        letterSpacing: 0.2,
        color: Colors.white,
      ),
    );
  }
}
