import 'package:bonus/Home/indexPage.dart';
import 'package:bonus/Login/loginPage.dart';
import 'package:get/get.dart';

final routes = [
  GetPage(name: '/', page: () => MyHomePage()),
  GetPage(name: '/loginPage', page: () => LoginPage()),

];

abstract class AppRoutes {
  static const Home = '/home';
  static const Order = '/Order';
  static const HuoKuan = '/HuoKuan';
}
