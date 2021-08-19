import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfconverter/UI/Screens/SecondaryScreens/aboutScreenUi.dart';
import 'package:pdfconverter/UI/Screens/SecondaryScreens/settingsScreenUi.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomAnimatedList extends StatefulWidget {
  @override
  _CustomAnimatedListState createState() => _CustomAnimatedListState();
}

class _CustomAnimatedListState extends State<CustomAnimatedList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  Tween<Offset> _offset = Tween(begin: Offset(0, 1), end: Offset(0, 0));
  List<Widget> _items = [];

  void _addItems() {
    List<Widget> list = [
      ListTile(
        onTap: () {
          // Navigator.pop(context);
          Navigator.of(context)
              .pushReplacement(new MaterialPageRoute(builder: (context) {
            return SettingsScreenUi();
          }));
        },
        contentPadding: EdgeInsets.all(3),
        title: textWidget(text: "Settings", icon: Icons.settings),
      ),
      ListTile(
        onTap: () async {
          String appPackageName = 'com.hack.imagesplayer';
          try {
            launch("market://details?id=" + appPackageName);
          } on PlatformException catch (e) {
            launch("https://play.google.com/store/apps/details?id=" +
                appPackageName);
          } finally {
            launch("https://play.google.com/store/apps/details?id=" +
                appPackageName);
          }
        },
        contentPadding: EdgeInsets.all(3),
        title: textWidget(text: "Rate Us", icon: Icons.star_rate),
      ),
      ListTile(
        onTap: () async {
          String appPackageName = 'com.hack.imagesplayer';

          Share.share(
              'Rejoice your memories with all new Image Player Gallery app. Download the app now! https://play.google.com/store/apps/details?id=' +
                  appPackageName, subject: 'Download the app now!');
        },
        contentPadding: EdgeInsets.all(3),
        title: textWidget(text: "Share", icon: Icons.share),
      ),
      ListTile(
        onTap: () async {
          const uri =
              'mailto:pratyushtiwarimj@gmail.com?subject=Bug%20Report@ImagesPlayer&body=Describe%20bug/feature%20request%20here..';
          if (await canLaunch(uri)) {
            await launch(uri);
          } else {
            throw 'Could not launch $uri';
          }
        },
        contentPadding: EdgeInsets.all(3),
        title: textWidget(text: "Report Bug", icon: Icons.bug_report),
      ),
      ListTile(
        onTap: () async {
          String url = 'https://github.com/UnHired-Coder/Images-player';
          await canLaunch(url)
              ? await launch(url)
              : throw 'Could not launch $url';
        },
        contentPadding: EdgeInsets.all(3),
        title: textWidget(text: "Contribute", icon: Icons.code_sharp),
      ),
      ListTile(
        onTap: () async {
          String appPackageName = 'com.hack.imagesplayer';
          try {
            launch("market://details?id=" + appPackageName);
          } on PlatformException catch (e) {
            launch("https://play.google.com/store/apps/details?id=" +
                appPackageName);
          } finally {
            launch("https://play.google.com/store/apps/details?id=" +
                appPackageName);
          }
        },
        contentPadding: EdgeInsets.all(3),
        title: textWidget(text: "Check Update!", icon: Icons.system_update),
      ),
      ListTile(
        onTap: () {
          Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
            return AboutScreenUi();
          }));
        },
        contentPadding: EdgeInsets.all(3),
        title: textWidget(text: "About", icon: Icons.info_outline),
      ),
    ];

    Future _future = Future(() {});
    list.forEach((element) {
      _future = _future.then((value) {
        return Future.delayed(Duration(milliseconds: 60), () {
          _items.add(element);
          _listKey.currentState.insertItem(_items.length - 1);
        });
      });
    });
  }

  textWidget({String text, IconData icon}) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconTheme(
            data: Theme.of(context).iconTheme,
            child: Icon(
              icon,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            text,
            style: Theme.of(context).textTheme.headline2,
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _addItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      itemBuilder: (context, index, animation) {
        return SlideTransition(
          position: animation.drive(_offset),
          child: _items[index],
        );
      },
      initialItemCount: _items.length,
    );
  }
}
