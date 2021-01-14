/*
*  iphone_xxs11_pro1_widget.dart
*  plantb
*
*  Created by rabie.
*  Copyright © 2018 irelg. All rights reserved.
    */

// AppLocalizations.of(context).iphonexxs11pro1widgetLabelText

import 'package:flutter/material.dart';

import 'package:video_downloader/i18n/i18n.dart';
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
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryBackground,
          elevation: 0,
        ),
        backgroundColor: AppColors.primaryBackground,
        body: Container(
          padding: EdgeInsets.only(left: 15, right: 15, top: 15),
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
                            fontSize: 20,
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
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ),
                    )),
              ]),
              Container(
                margin: EdgeInsets.only(top: 30),
                child: LinearPercentIndicator(
                  lineHeight: 12.0,
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
                padding: EdgeInsets.all(50),
                width: double.infinity,
                margin: EdgeInsets.only(top: 20),
                decoration: new BoxDecoration(
                    color: Colors.blue,
                    borderRadius: new BorderRadius.circular(15)),
                child: Text("hi"),
              ),
              Container(
                  margin: EdgeInsets.only(top: 20),
                  height: 120,
                  child: Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: Container(
                            alignment: Alignment.center,
                            height: 80,
                            decoration: new BoxDecoration(
                                color: Colors.blue,
                                borderRadius: new BorderRadius.circular(15)),
                            child: FaIcon(FontAwesomeIcons.facebook),
                          )),
                      Spacer(),
                      Expanded(
                          flex: 2,
                          child: Container(
                            alignment: Alignment.center,
                            height: 80,
                            decoration: new BoxDecoration(
                                color: Colors.blue,
                                borderRadius: new BorderRadius.circular(15)),
                            child: FaIcon(FontAwesomeIcons.instagram),
                          )),
                      Spacer(),
                      Expanded(
                          flex: 2,
                          child: Container(
                            alignment: Alignment.center,
                            height: 80,
                            decoration: new BoxDecoration(
                                color: Colors.blue,
                                borderRadius: new BorderRadius.circular(15)),
                            child: FaIcon(FontAwesomeIcons.tiktok),
                          )),
                      Spacer(),
                      Expanded(
                          flex: 2,
                          child: Container(
                              alignment: Alignment.center,
                              height: 80,
                              decoration: new BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: new BorderRadius.circular(15)),
                              child: FaIcon(FontAwesomeIcons.whatsapp))),
                    ],
                  )),
              Container(
                  height: 100,
                  child: BottomNavigationBar(
                    items: const <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.business),
                        label: 'Business',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.school),
                        label: 'School',
                      ),
                    ],
                    currentIndex: _selectedIndex,
                    selectedItemColor: Colors.amber[800],
                    onTap: _onItemTapped,
                  )),
            ],
          ),
        ));
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
