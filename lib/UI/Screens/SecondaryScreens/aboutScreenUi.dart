import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreenUi extends StatefulWidget {
  @override
  _AboutScreenUiState createState() => _AboutScreenUiState();
}

class _AboutScreenUiState extends State<AboutScreenUi> {
  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
                icon: IconTheme(
                  data: Theme.of(context).appBarTheme.iconTheme,
                  child: Icon(
                    FontAwesomeIcons.arrowCircleLeft,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            SizedBox(
              width: 20,
            ),
            Text(
              "About",
              style: Theme.of(context).textTheme.headline3,
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 100,
            ),
            Container(
              height: screenHeight * 0.05,
              width: screenHeight * 0.05,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('lib/assets/images/logo.png'))),
            ),
            Container(
              height: screenHeight*0.02,
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              child: Text(
                'Images Player',
                style: Theme.of(context).textTheme.headline2,
              ),
            ),
            SizedBox(
              height: screenHeight*0.1,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              alignment: Alignment.center,
              child: Text(
                'Images Player app is a simple Gallery app that allows you to pick up your old memories and remember the good old days. \n \nWe do not collect or share any of your personal data, we value your privacy. We are not responsible in any kind of data loss due to users mistake, use app at your own risk',
                style: Theme.of(context).textTheme.headline2,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: screenHeight*0.1,
            ),
            Container(
              height: screenHeight*0.05,
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              child: InkWell(
                onTap: () async {
                  const uri =
                      'https://github.com/UnHired-Coder/Images-player/blob/main/pdf_converter/LICENSE.txt';
                  if (await canLaunch(uri)) {
                    await launch(uri);
                  } else {
                    throw 'Could not launch $uri';
                  }
                },
                child: Text(
                  'License 🔗',
                  style: Theme.of(context).textTheme.headline3,
                ),
              ),
            ),
            Container(
              height: screenHeight*0.05,
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              child: InkWell(
                onTap: () async {
                  const uri = 'https://github.com/UnHired-Coder/Images-player';
                  if (await canLaunch(uri)) {
                    await launch(uri);
                  } else {
                    throw 'Could not launch $uri';
                  }
                },
                child: Text(
                  'Privacy Policy and T&C 🔗',
                  style: Theme.of(context).textTheme.headline3,
                ),
              ),
            ),
            SizedBox(height: 20,),
            Container(
            height: screenHeight*0.05,
            width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              child: InkWell(
                onTap: () async {
                  const uri = 'https://github.com/UnHired-Coder/Images-player/blob/main/pdf_converter/README.md';
                  if (await canLaunch(uri)) {
                    await launch(uri);
                  } else {
                    throw 'Could not launch $uri';
                  }
                },
                child: Text(
                  'Tutorial walk through 🔗',
                  style: Theme.of(context).textTheme.headline3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
