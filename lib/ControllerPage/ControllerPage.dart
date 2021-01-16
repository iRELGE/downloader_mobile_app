/*
*  iphone_xxs11_pro1_widget.dart
*  plantb
*
*  Created by rabie.
*  Copyright © 2018 irelg. All rights reserved.
    */

// AppLocalizations.of(context).iphonexxs11pro1widgetLabelText

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:clipboard/clipboard.dart';
import 'package:video_downloader/directory_values/static_directories.dart';
import 'package:video_downloader/i18n/i18n.dart';
import 'package:connectivity/connectivity.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_downloader/values/borders.dart';
import 'package:video_downloader/values/colors.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ControllerPage extends StatefulWidget {
  ControllerPage({Key key}) : super(key: key);

  @override
  _ControllerPageState createState() => _ControllerPageState();
}

class _ControllerPageState extends State<ControllerPage> {
  String paste = '';
  TextEditingController inputValue = new TextEditingController();
  bool _isDisabled = true;
  var _fbScaffoldKey = GlobalKey<ScaffoldState>();
  bool validateURL(List<String> urls) {
    // Pattern pattern = r'^(http(s)?:\/\/)?((w){3}.)?facebook?(\.com)?\/(watch\/\?v=.+|.+\/videos\/.+)$';
    Pattern pattern = r'^(http(s)?:\/\/)?((w){3}.)?facebook?(\.com)?\/.+$';
    RegExp regex = new RegExp(pattern);

    for (var url in urls) {
      if (!regex.hasMatch(url)) {
        return false;
      }
    }
    return true;
  }

  Future<String> _loadthumb(String videoUrl) async {
    var thumb = await VideoThumbnail.thumbnailFile(
      video: videoUrl,
      thumbnailPath: StaticRepots.facebookDirectorythumbs.path,
      imageFormat: ImageFormat.PNG,
    );
    var rep = thumb.toString();
    File thumbname = File(thumb.toString());
    //thumbname.rename(thumbDir.path + '$rep.png');

    print(StaticRepots.facebookDirectorythumbs.path + '$rep.png');
    return (rep);
  }

  void getButton(String url) {
    if (validateURL([url])) {
      setState(() {
        _isDisabled = false;
      });
    } else {
      setState(() {
        _isDisabled = true;
      });
    }
  }

  Widget mySnackBar(BuildContext context, String msg) {
    return SnackBar(
      content: Text(msg),
      backgroundColor: Theme.of(context).accentColor,
      duration: Duration(seconds: 1),
    );
  }

  void sheckConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _fbScaffoldKey.currentState
          .showSnackBar(mySnackBar(context, 'No Internet'));
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    if (!StaticRepots.facebookDirectory.existsSync()) {
      StaticRepots.facebookDirectory.createSync(recursive: true);
    }
    if (!StaticRepots.facebookDirectorythumbs.existsSync()) {
      StaticRepots.facebookDirectorythumbs.createSync(recursive: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            key: _fbScaffoldKey,
            backgroundColor: AppColors.primaryBackground,
            body: Container(
              padding:
                  EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 10),
              child: Column(
                children: [
                  Row(children: [
                    Expanded(
                        flex: 2,
                        child: Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Downloading",
                            style: TextStyle(
                                color: AppColors.boldText,
                                fontSize: 15,
                                fontWeight: FontWeight.w800),
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: Container(
                          alignment: Alignment.topRight,
                          child: Text(
                            "...50% / 10 M",
                            style: TextStyle(
                                color: AppColors.tinyText,
                                fontSize: 10,
                                fontWeight: FontWeight.w500),
                          ),
                        )),
                  ]),
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    child: LinearPercentIndicator(
                      lineHeight: 10.0,
                      animation: true,
                      animateFromLastPercent: true,
                      percent: 0.75,
                      backgroundColor: Colors.white,
                      progressColor: AppColors.indicatorValueColor,
                    ),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowColor.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(15),
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    decoration: new BoxDecoration(
                        color: Colors.blue,
                        borderRadius: new BorderRadius.circular(15)),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Container(
                              height: 30,
                              child: TextField(
                                textAlignVertical: TextAlignVertical.center,
                                style: TextStyle(fontSize: 15),
                                scrollPadding: EdgeInsets.all(10),
                                decoration: InputDecoration(
                                    labelStyle: TextStyle(
                                        color: Colors.white, fontSize: 10),
                                    filled: true,
                                    enabled: true,
                                    fillColor: AppColors.primaryBackground,
                                    hoverColor: Colors.white,
                                    focusColor: Colors.white,
                                    border: new OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(15.0),
                                    ),
                                    icon: ClipOval(
                                      child: Material(
                                        color: AppColors
                                            .primaryBackground, // button color
                                        child: InkWell(
                                          splashColor: AppColors
                                              .hoverButton, // inkwell color
                                          child: SizedBox(
                                              width: 30,
                                              height: 30,
                                              child: Icon(
                                                Icons.link,
                                                size: 20,
                                              )),
                                          onTap: () async {
                                            final value =
                                                await FlutterClipboard.paste();
                                            getButton(value);
                                            setState(() async {
                                              this.paste = value;
                                              inputValue.text = value;
                                              sheckConnectivity();
                                            });
                                          },
                                        ),
                                      ),
                                    )),
                                controller: inputValue,
                                autocorrect: false,
                              ),
                            )),
                          ],
                        )
                      ],
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 20, bottom: 10),
                      height: 40,
                      child: Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.center,
                                height: 40,
                                decoration: new BoxDecoration(
                                    color: Colors.blueAccent,
                                    borderRadius:
                                        new BorderRadius.circular(40)),
                                child: FaIcon(FontAwesomeIcons.facebook),
                              )),
                          Spacer(),
                          Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.center,
                                height: 40,
                                decoration: new BoxDecoration(
                                    color: Colors.pinkAccent,
                                    borderRadius:
                                        new BorderRadius.circular(40)),
                                child: FaIcon(FontAwesomeIcons.instagram),
                              )),

                          // Expanded(
                          //     flex: 2,
                          //     child: Container(
                          //       alignment: Alignment.center,
                          //       height: 60,
                          //       decoration: new BoxDecoration(
                          //           color: Colors.grey,
                          //           borderRadius: new BorderRadius.circular(15)),
                          //       child: FaIcon(FontAwesomeIcons.tiktok),
                          //     )),
                          Spacer(),
                          Expanded(
                              flex: 1,
                              child: Container(
                                  alignment: Alignment.center,
                                  height: 40,
                                  decoration: new BoxDecoration(
                                      color: Colors.green,
                                      borderRadius:
                                          new BorderRadius.circular(40)),
                                  child: FaIcon(FontAwesomeIcons.whatsapp))),
                        ],
                      )),
                  Container(
                      margin: EdgeInsets.only(top: 20, bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  "All videos",
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: AppColors.boldText,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800),
                                ),
                              )),
                          Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  "facebook",
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: AppColors.boldText,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800),
                                ),
                              )),
                          Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.center,
                                child: Text("instagram",
                                    style: TextStyle(
                                        decorationThickness: 1,
                                        decoration: TextDecoration.underline,
                                        color: AppColors.boldText,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800)),
                              )),
                          Expanded(
                              flex: 1,
                              child: Container(
                                  alignment: Alignment.center,
                                  child: Text("whatsapp",
                                      style: TextStyle(
                                          decorationThickness: 1,
                                          decoration: TextDecoration.underline,
                                          color: AppColors.boldText,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800)))),
                        ],
                      )),
                  Expanded(
                      child: ListView.builder(
                    itemCount: 30,
                    itemBuilder: (constext, index) {
                      return Container(
                          padding: EdgeInsets.only(top: 20),
                          child: Container(
                              decoration: new BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: new BorderRadius.circular(15)),
                              padding: EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text("titl"),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("titl"),
                                        Text("des orem lorem lorem lorem")
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                        alignment: Alignment.centerRight,
                                        child:
                                            FaIcon(FontAwesomeIcons.whatsapp)),
                                  ),
                                ],
                              )));
                    },
                  ))
                ],
              ),
            )));
  }
}

Widget cardView(BuildContext context) {
  return Stack(
    children: <Widget>[
      Column(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1.2,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.5, 1),
                  end: Alignment(4, 1),
                  stops: [
                    0,
                    1,
                  ],
                  colors: [
                    Color.fromARGB(254, 27, 58, 129),
                    Color.fromARGB(176, 59, 114, 243),
                  ],
                ),
                border: Border.fromBorderSide(Borders.primaryBorder),
              ),
              child: Container(),
            ),
          ),
        ],
      ),
      Positioned(
        top: (MediaQuery.of(context).size.width / 1.6) - 24.0,
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
            decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
        )),
      ),
    ],
  );
}
