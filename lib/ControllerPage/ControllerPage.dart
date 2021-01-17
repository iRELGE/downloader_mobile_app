/*
*  iphone_xxs11_pro1_widget.dart
*  plantb
*
*  Created by rabie.
*  Copyright © 2018 irelg. All rights reserved.
    */

// AppLocalizations.of(context).iphonexxs11pro1widgetLabelText

import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:simple_url_preview/simple_url_preview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_downloader/data/facebookData.dart';
import 'package:video_downloader/service/interceptor/initial_dio.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:clipboard/clipboard.dart';
import 'package:video_downloader/directory_values/static_directories.dart';

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
  PermissionStatus status;
  FacebookProfile _fbProfile;
  final _client = InitielDio(Dio());
  ReceivePort _receivePort = ReceivePort();
  bool _isLoadingHtml = false;
  bool _isLoadinThumbReady = false;
  double progressdownload = 0;
  int denyCnt = 0;
  TextEditingController inputValue = new TextEditingController();
  bool _isDisabled = true;
  String _postThumbnail = '';
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

  static downloadCallback(String id, DownloadTaskStatus status, int progress) {
    SendPort sendPort = IsolateNameServer.lookupPortByName("downloading");

    ///ssending the data
    sendPort.send([id, status, progress]);
  }

  void downloadFile(String mediaUrl, dynamic dirPath) async {
    String name =
        'FB-${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().second}${DateTime.now().millisecond}.mp4';

    FlutterDownloader.enqueue(
      url: mediaUrl,
      savedDir: dirPath.path,
      fileName: name,
      showNotification: true,
      openFileFromNotification: true,
    );

    // _client.dio.download(mediaUrl, "${dirPath.path}/$name",
    //     onReceiveProgress: (received, total) {
    //   int percentage = ((received / total) * 100).floor();
    //   print(percentage);
    //   setState(() {
    //     progressdownload = (percentage / 100);
    //   });
    // });
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

  void _getPermission() async {
    status = await Permission.storage.request();

    if (status == PermissionStatus.permanentlyDenied) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('Storage Permission Requried'),
            content: Text('Enable Storage Permission from App Setting'),
            actions: <Widget>[
              FlatButton(
                child: Text('Open Setting'),
                onPressed: () async {
                  openAppSettings();
                  exit(0);
                },
              )
            ],
          );
        },
      );
    } else {
      while (!status.isGranted) {
        if (denyCnt > 20) {
          exit(0);
        }
        status = await Permission.storage.request();
        denyCnt++;
      }
    }
  }

  void getButton(String url) {
    if (validateURL([url])) {
      setState(() {
        _isDisabled = false;
      });
      setState(() {
        this.paste = url;
        inputValue.text = url;
      });
      sheckConnectivity();
      posteFromUrl(url);
    } else {
      setState(() {
        _isDisabled = true;
      });
      _fbScaffoldKey.currentState.showSnackBar(
          mySnackBar(context, "is not a valid facebook or instagram url"));
    }
  }

  void posteFromUrl(String url) async {
    setState(() {
      _isLoadingHtml = true;
    });
    _fbProfile = await FacebookData.postFromUrl('$paste');
    if (_fbProfile.postData.videoHdUrl != "") {
      _postThumbnail =
          await _loadthumb(_fbProfile.postData.videoHdUrl.toString());
    } else if (_fbProfile.postData.videoSdUrl != "" &&
        _fbProfile.postData.videoHdUrl == "") {
      _postThumbnail =
          await _loadthumb(_fbProfile.postData.videoSdUrl.toString());
    } else if (_fbProfile.postData.videoMp3Url != "" &&
        _fbProfile.postData.videoSdUrl == "" &&
        _fbProfile.postData.videoHdUrl == "") {
      _postThumbnail =
          await _loadthumb(_fbProfile.postData.videoSdUrl.toString());
    }

    setState(() {
      _isLoadinThumbReady = true;
      _isLoadingHtml = false;
    });
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
    FlutterDownloader.registerCallback(downloadCallback);
    IsolateNameServer.registerPortWithName(
        _receivePort.sendPort, "downloading");

    ///Listening for the data is comming other isolataes
    _receivePort.listen((message) {
      setState(() {
        progressdownload = message[2] / 100;
      });

      if (message[2] >= 100) {
        setState(() {
          _isLoadinThumbReady = false;
          inputValue.text = "";
          progressdownload = 0.0;
        });
      }
    });

    _getPermission();
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
                            "...${progressdownload * 100}%",
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
                      percent: progressdownload,
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
                        Visibility(
                            visible: _isLoadinThumbReady == false,
                            child: Container(
                              height: 30,
                              child: TextField(
                                textAlignVertical: TextAlignVertical.center,
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(5),
                                    labelStyle: TextStyle(
                                        color: Colors.white, fontSize: 100),
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
                                          child: _isLoadingHtml == false
                                              ? InkWell(
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
                                                        await FlutterClipboard
                                                            .paste();
                                                    getButton(value);
                                                  },
                                                )
                                              : Container(
                                                  height: 30,
                                                  width: 30,
                                                  child:
                                                      CircularProgressIndicator(
                                                    backgroundColor: AppColors
                                                        .indicatorValueColor,
                                                  ),
                                                )),
                                    )),
                                controller: inputValue,
                                autocorrect: false,
                              ),
                            )),
                        Visibility(
                            visible: _isLoadinThumbReady == true,
                            child: ListTile(
                              leading: Container(
                                decoration: new BoxDecoration(
                                    borderRadius:
                                        new BorderRadius.circular(15)),
                                height: 50,
                                width: 50,
                                child: ProgressiveImage(
                                  placeholder: AssetImage(
                                      'assets/images/placeholder_image.png'),
                                  thumbnail: FileImage(File(_postThumbnail)),
                                  image: FileImage(File(_postThumbnail)),
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                              title: SimpleUrlPreview(
                                url: _fbProfile != null
                                    ? _fbProfile.postData.description
                                    : "",
                                textColor: Colors.white,
                                bgColor: Colors.red,
                                isClosable: true,
                                previewHeight: 150,
                              ),
                              subtitle: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.download_sharp),
                                    onPressed: () {
                                      downloadFile(
                                          _fbProfile.postData.videoHdUrl,
                                          StaticRepots.facebookDirectory);
                                    },
                                  )
                                ],
                              ),
                            ))
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
