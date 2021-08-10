import 'package:bonus/Utils/httpData.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:get/get.dart';

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class Api {
  static final CookieJar cookieJar = new CookieJar();
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.arguments}) : super(key: key);
  final arguments;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  num deliveryCount = 0; //派送总数
  var deliveryFreight = 0.0;
  var commissionD = 0.0;
  var jobs = 0; //累计工作日
  var commissionDString = '';
  var deliveryFreightString = '';
  String average = ''; // 日均派送量
  String csrf_token = '';
  int jiangjin = 0;
  @override
  void initState() {
    super.initState();
    print(Get.arguments['username']);
    getHttp();
  }

  List<String> items = ["1", "2", "3", "4", "5", "6", "7", "8"];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() {
    deliveryCount = 0;
    deliveryFreight = 0.0;
    commissionD = 0.0;
    jobs = 0;
    commissionDString = '';
    deliveryFreightString = '';
    average = '';
    jiangjin = 0;
    print('下拉刷新');
    // monitor network fetch
    //await Future.delayed(Duration(milliseconds: 1000));
    getHttp();
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    print('上拉加载..');
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    items.add((items.length + 1).toString());
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('CE courier per'.tr),
          centerTitle: true,
        ),
        body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          header: WaterDropHeader(),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: _body(),
        ));
  }

  _body() {
    if (deliveryCount != 0) {
      average = formartNum(deliveryCount / jobs, 1);

      if (double.parse(average) >= 40 && double.parse(average) < 50) {
        jiangjin = 60;
      } else if (double.parse(average) >= 50 && double.parse(average) < 60) {
        jiangjin = 80;
      } else if (double.parse(average) >= 60) {
        jiangjin = 100;
      }
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            buildPetCategory(Icon(Icons.today_outlined), "累计工作日".tr,
                '$jobs    ', '日'.tr, Colors.orange.shade200, '/Yuyue'),
            buildPetCategory(Icon(Icons.two_wheeler_outlined), "日均派送数量".tr,
                '$average    ', '件'.tr, Colors.orange.shade200, '/Yuyue'),
            GestureDetector(
              onTap: () {},
              child: Container(
                height: 80,
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 31,
                      width: 31,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange.shade200,
                      ),
                      child: Center(
                        child: SizedBox(
                          height: 30,
                          width: 30,
                          child: Icon(Icons.attach_money),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 22,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          _modal();
                        },
                        child: Row(
                          children: [
                            Text(
                              '奖金'.tr,
                              //softWrap: true,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 15,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            Container(
                              //decoration: BoxDecoration(color: Colors.yellow),
                              margin: EdgeInsets.only(left: 5, right: 20),
                              child: Icon(
                                Icons.help,
                                color: Colors.grey,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '\$ $jiangjin',
                        //softWrap: true,
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 25,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            buildPetCategory(Icon(Icons.two_wheeler_outlined), "派送总数".tr,
                '$deliveryCount    ', '件'.tr, Colors.orange.shade200, '/Yuyue'),
            buildPetCategory(
                Icon(Icons.attach_money),
                "运费合计".tr,
                '\$ $deliveryFreightString',
                '',
                Colors.orange.shade200,
                '/Yuyue'),
            buildPetCategory(Icon(Icons.attach_money), "提成合计".tr,
                '\$ $commissionDString', '', Colors.orange.shade200, '/Yuyue'),
          ],
        ),
      ),
    );
  }

  //块视图
  Widget buildPetCategory(Icon icon, String text1, String text2, String text3,
      Color color, String routes) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 80,
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 31,
              width: 31,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.5),
              ),
              child: Center(
                child: SizedBox(
                  height: 30,
                  width: 30,
                  child: icon,
                ),
              ),
            ),
            SizedBox(
              width: 22,
            ),
            Expanded(
              child: Text(
                text1,
                //softWrap: true,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 15,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            Stack(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    text2 + text3,
                    //softWrap: true,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 15,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void getHttp() async {
    BaseOptions options = BaseOptions();
    options.contentType = "application/x-www-form-urlencoded; charset=UTF-8";
    //options.method = "POST";
    options.connectTimeout = 60000;

    Dio dio = new Dio(options);
    var cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));

    List timeDay = [];
    DateTime now = new DateTime.now();
    // now.day
    for (var i = 1; i <= now.day; i++) {
      timeDay.add({
        'startTime': '${now.year}-${now.month}-$i 00:00:00',
        'endTime': '${now.year}-${now.month}-$i 23:59:59'
      });
    }
    try {
      print('用户名');
      print(Get.arguments['username']);
      var response = await dio.post(
        'http://tms.cambodianexpress.com/login',
        data: {
          'username': Get.arguments['username'],
          'password': Get.arguments['password']
        },
        options: Options(
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );
      // print('返回内容2');
      // print(response.headers.value('set-cookie'));
    } catch (e) {
      print('错1');
      Http.errorType(e);
      //print(e);
    }
    // 保存COOKIE
    await cookieJar.loadForRequest(Uri.parse(options.baseUrl));
    print('3333');
    try {
      //dio.options.headers['cookie'] = cookies[0];
      var res = await dio.get('http://tms.cambodianexpress.com');
      // print(res.data);
      String csrf = res.data;
      //csrf_token = csrf.substring(480, 516);
      csrf_token = csrf.substring(468, 504);
      //print(csrf_token);
    } on DioError catch (e) {
      print('错2');
      Http.errorType(e);
    }
    BotToast.showLoading();
    timeDay.forEach(
      (v) async {
        Map data = {
          'lateDeliveryDateFrom': v['startTime'],
          'lateDeliveryDateTo': v['endTime'],
          //'shopCode': 'PNH009',
          'courierCode': Get.arguments['username'],
          //'courierCode': 'CE000304',
        };

        try {
          print(csrf_token);
          dio.options.headers['X-CSRF-TOKEN'] = csrf_token;
          var response = await dio.post(
              'http://tms.cambodianexpress.com/tms/courier/provison/query',
              data: data);

          //print(response.data['rows'].length );
          if (response.data['rows'].length > 0) {
            // print('还能进来..');
            if (response.data['rows'][0]['deliveryCount'] != 0) {
              jobs++;
              deliveryCount += response.data['rows'][0]['deliveryCount'];
              deliveryFreight += response.data['rows'][0]['deliveryFreight'];
              deliveryFreightString = formartNum(deliveryFreight, 2);
              commissionD += response.data['rows'][0]['commissionD'];
              commissionDString = formartNum(commissionD, 2);
              setState(() {});
            }
          }

          BotToast.closeAllLoading();
          // print('工作了多少天:$jobs');
          // print('派送总数:$deliveryCount');
          // print('派送运费:$deliveryFreight');
          // print('佣金:$commissionD');
        } on DioError catch (e) {
          BotToast.closeAllLoading();
          print('错3');
          print(e);
          Http.errorType(e);
        }
      },
    );
  }

  // 底部弹出 说明信息
  _modal() {
    return showCupertinoModalBottomSheet(
      expand: false,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SingleChildScrollView(
        controller: ModalScrollController.of(context),
        child: Material(
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Icon(Icons.clear)),
                      Text(
                        '绩效说明'.tr,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text('       '),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '日均派送数量'.tr,
                            //style: TextStyle(color: Colors.black54),
                          ),
                          Text('奖励金额'.tr),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '> 40',
                            //style: TextStyle(color: Colors.grey[800]),
                          ),
                          Text('\$ 60'),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('> 50'),
                          Text('\$ 80'),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('> 60'),
                          Text('\$ 100'),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                // Container(
                //   //decoration: BoxDecoration(color: Colors.yellow),
                //   child: Text(
                //     '计费规则 >',
                //     style: TextStyle(color: Colors.grey),
                //   ),
                // ),
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: slash_for_doc_comments
/**
   * target  要转换的数字
   * postion 要保留的位数
   * isCrop  true 直接裁剪 false 四舍五入
   */
String formartNum(num target, int postion, {bool isCrop = false}) {
  String t = target.toString();
  // 如果要保留的长度小于等于0 直接返回当前字符串
  if (postion < 0) {
    return t;
  }
  if (t.contains(".")) {
    String t1 = t.split(".").last;
    if (t1.length >= postion) {
      if (isCrop) {
        // 直接裁剪
        return t.substring(0, t.length - (t1.length - postion));
      } else {
        // 四舍五入
        return target.toStringAsFixed(postion);
      }
    } else {
      // 不够位数的补相应个数的0
      String t2 = "";
      for (int i = 0; i < postion - t1.length; i++) {
        t2 += "0";
      }
      return t + t2;
    }
  } else {
    // 不含小数的部分补点和相应的0
    String t3 = postion > 0 ? "." : "";

    for (int i = 0; i < postion; i++) {
      t3 += "0";
    }
    return t + t3;
  }
}
