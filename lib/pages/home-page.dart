// Copyright (c) 2023 Sendbird, Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:chat_app_sendbird/widgets/main-widget.dart';
import 'package:chat_app_sendbird/pages/chat-page.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';
import "package:flutter_sizer/flutter_sizer.dart";

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  SendbirdSdk? sendbird;
  User? user;
  Widgets widgets = Widgets();
  bool loading = true;
  bool error = false;

  void reloadPage() {
    // Replace this logic with the actual logic to reload your page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    await _login("faiz-test1");
  }

  _login(String userId) async {

    try{
      sendbird = SendbirdSdk(
            appId: "BC823AD1-FBEA-4F08-8F41-CF0D9D280FBF",
            apiToken: "f93b05ff359245af400aa805bafd2a091a173064",
          );
      if (sendbird == null) {
        throw Exception("Couldn't initializ sendbird");
      }

      User tempUser = await sendbird!.connect("faiz-test2", accessToken: "ef24ece9503f56ef2fbe9311e4b346abc38dafdd");
      
      setState(() {
        if (tempUser != null){
          user = tempUser;
        }
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = true;
      });
    }

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 14, 13, 13),
        title: Text(
          "Sendbird Flutter Chat App",
          style: TextStyle(fontSize: 5.w, color: Color.fromARGB(255, 244, 240, 240)),
            maxLines: 1,),
      ),
      body: _mainBox(context),
    );
  }

  Widget _mainBox(BuildContext context) {

    return Container(
        color: Color.fromARGB(255, 14, 13, 13),
        child:Center(
          child: loading ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            CircularProgressIndicator( color: Color.fromARGB(255, 168, 168, 168),),
            Text(
              "Connecting to sandbird server",
              style: TextStyle(fontSize: 5.w, color: Color.fromARGB(255, 244, 240, 240)),
                maxLines: 1,),
              ],
            ) : error ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Container(
              constraints: BoxConstraints(maxWidth: 70.w),
              child: Text(
                "Failed to connect server",
                style: TextStyle(fontSize: 5.w, color: Color.fromARGB(255, 244, 240, 240)),
                  maxLines: 1,),
            ),
                ElevatedButton(
                  onPressed: () {
                    reloadPage();
                  },
                  child: Text('try again'),
                ),
              ],
            ) : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Container(
              constraints: BoxConstraints(maxWidth: 70.w),
              child: Text(
                "Connected to server SendBird",
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 5.w,
                  color: Color.fromARGB(255, 51, 189, 120)
                ),
                  maxLines: 3,),
            ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OpenChannelPage(Key("channel-page"), sendbird, user)),
                    );
                  },
                  child: Text('Open Public Channel'),
                ),
              ],
            ),
          ),
    );
  }
}