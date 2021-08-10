import 'package:bonus/Locale/Messages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Config/Routes.dart';
import 'package:bot_toast/bot_toast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: Messages(),
      locale: Locale('ca', 'KH'),
      debugShowCheckedModeBanner: false,
      initialRoute: '/loginPage',
      //initialRoute: '/',
      getPages: routes,
      builder: BotToastInit(),
      title: 'CE courier per',

      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: MyHomePage(title: 'Bonus'),
    );
  }
}
