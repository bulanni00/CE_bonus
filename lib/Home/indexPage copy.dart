import 'package:bonus/Utils/httpData.dart';
import 'package:flutter/material.dart';
//import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:get/get.dart';

class Api {
  static final CookieJar cookieJar = new CookieJar();
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  num deliveryCount = 0;
  var deliveryFreight = 0.0;
  var commissionD = 0.0;
  var jobs = 0;
  var commissionDString = '';
  var deliveryFreightString = '';

  String csrf_token = '';
  @override
  void initState() {
    super.initState();
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
          title: Text('奖金'),
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
    var average = formartNum(deliveryCount / jobs, 1);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.all(9),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      '月任务奖励',
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      '累计24个工作日, 日均派送数量达到40件, 即可获得 \$ 60 奖金',
                      style: TextStyle(color: Colors.blue.shade400),
                    )
                  ],
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
            ),
            buildPetCategory(Icon(Icons.two_wheeler_outlined), "日均派送数量",
                '$average    件', Colors.orange.shade200, '/Yuyue'),
            buildPetCategory(Icon(Icons.two_wheeler_outlined), "派送总数",
                '$deliveryCount    件', Colors.orange.shade200, '/Yuyue'),
            buildPetCategory(Icon(Icons.attach_money), "运费合计",
                '\$ $deliveryFreightString', Colors.orange.shade200, '/Yuyue'),
            buildPetCategory(Icon(Icons.attach_money), "提成合计",
                '\$ $commissionDString', Colors.orange.shade200, '/Yuyue'),
            buildPetCategory(Icon(Icons.today_outlined), "累计工作日", '$jobs    日',
                Colors.orange.shade200, '/Yuyue'),
          ],
        ),
      ),
    );
  }

  //块视图
  Widget buildPetCategory(
      Icon icon, String text1, String text2, Color color, String routes) {
    return GestureDetector(
      onTap: () {
        //Get.toNamed(routes);
        // if (routes == '/Yuyue') {
        //   LIU_tool.showAlert(context, '提示'.tr, '敬请期待..'.tr);
        // } else {
        //   Get.toNamed(routes);
        // }
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //       //builder: (context) => CategoryList(category: category)),
        // );
      },
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
                  //child: Image.network('https://cdn.pixabay.com/photo/2016/11/22/07/09/spruce-1848543__340.jpg'),
                  // child: Image.asset(
                  //   "assets/images/" +
                  //       (category == Category.HAMSTER
                  //           ? "hamster"
                  //           : category == Category.CAT
                  //               ? "cat"
                  //               : category == Category.BUNNY
                  //                   ? "bunny"
                  //                   : "dog") +
                  //       ".png",
                  //   fit: BoxFit.fitHeight,
                  // ),
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
            Expanded(
              child: Text(
                text2,
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
      ),
    );
  }

  void getHttp() async {
    // var options = BaseOptions(
    //   //baseUrl: 'https://www.xx.com/api',
    //   connectTimeout: 50000,
    //   receiveTimeout: 30000,
    //   headers: {
    //     'Cookie':
    //       '_ga=GA1.2.743124396.1602756677; loginKey=d2b8b3c1-53d2-41e3-966b-51a3149a2723; SESSIONID_HAP=af5ee870-3170-4b82-8cb3-8b2a9111384b',
    //   'X-CSRF-TOKEN': 'fcabc8e5-99c5-4c9a-8a85-3ec1ba266ab1'
    //   }
    // );
    // BaseOptions options = BaseOptions();
    // options.contentType = "application/x-www-form-urlencoded; charset=UTF-8";
    // //options.method = "POST";
    // options.connectTimeout = 60000;

    //  Dio dio = new Dio(options);
    //  var cookieJar = CookieJar();
    //  dio.interceptors.add(CookieManager(cookieJar));

    List timeDay = [];
    DateTime now = new DateTime.now();

    for (var i = 1; i <= now.day; i++) {
      timeDay.add({
        'startTime': '${now.year}-${now.month}-$i 00:00:00',
        'endTime': '${now.year}-${now.month}-$i 23:59:59'
      });
    }
    // Http()
    //     .getUrl(url: 'https://a2put.chinaz.com/slot/callback?id=s1696812498069624&fromUrl=http://ip.tool.chinaz.com/203.80.170.62')
    //     .then((val) {
    //   print('httpurl:$val');
    // });
    Http().postLogin(
        url: '/login',
        data: {'username': 'CE000063', 'password': '123456'}).then((val) {
      print('返回的请求内容:$val');
      return;
    });
    return;
    try {
      // dio.interceptors.add(InterceptorsWrapper(
      // onRequest: (options, handler) {
      //   print("请求之前");
      //   //print()
      //   //return;
      //   return handler.resolve(Response(
      //     requestOptions: options,
      //     data: 'fake data',
      //   ));
      // },
      // onResponse: (Response response, handler) {
      //   //response.requestOptions.validateStatus = true as ValidateStatus;
      //   print("响应之前");
      //   //dio.options.validateStatus = true as ValidateStatus;
      //   // return handler.resolve(Response(
      //   //   requestOptions: options,
      //   //   data: 'fake data',
      //   // ));
      // },
      // onError: (DioError e, handler) {
      //   //response.requestOptions.validateStatus = true as ValidateStatus;
      //   print("错误之前");
      //   // dio.options.validateStatus = (int status) {
      //   //   return 220 >= 200;
      //   // };
      //   return;
      // },
      //));

      var response = await dio.post(
        'http://tms.cambodianexpress.com/login',
        data: {'username': 'CE000063', 'password': '123456'},
        options: Options(
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );
      print('返回内容2');
      print(response.data);
      print(response.headers.value('set-cookie'));

      print(response.statusCode);
      print(response);
    } catch (e) {
      print('错误');
      print(e);
    }
    print('保存的cookie');
    print(await cookieJar
        .loadForRequest(Uri.parse("http://tms.cambodianexpress.com/")));
    //获取cookies
//List<Cookie> cookies = cookieJar.loadForRequest(Uri.parse(BaseUrl.url));
    // print(cookies);

    try {
      print('000');
      var res = await dio.get('http://tms.cambodianexpress.com/');
      //print(res.data.subString());
      String csrf = res.data.toString();
      csrf_token = csrf.substring(480, 516);
    } catch (e) {
      print(e);
    }

    timeDay.forEach((v) async {
      Map data = {
        'lateDeliveryDateFrom': v['startTime'],
        'lateDeliveryDateTo': v['endTime'],
        //'shopCode': 'PNH009',
        'courierCode': 'CE000933',
      };

      //print(data);
      try {
        dio.options.headers['X-CSRF-TOKEN'] = csrf_token;
        print('1111');
        //print(csrf_token);
        var response = await dio.post(
            'http://tms.cambodianexpress.com/tms/courier/provison/query',
            data: data);
        //print(response.data['rows'][0]['deliveryCount']);
        //print(response.data['rows'][0]['deliveryCount'] == 0);
        if (response.data['rows'][0]['deliveryCount'] != 0) {
          jobs++;
          deliveryCount += response.data['rows'][0]['deliveryCount'];
          deliveryFreight += response.data['rows'][0]['deliveryFreight'];
          deliveryFreightString = formartNum(deliveryFreight, 2);
          commissionD += response.data['rows'][0]['commissionD'];
          commissionDString = formartNum(commissionD, 2);
          setState(() {});
        }
        // print('工作了多少天:$jobs');
        // print('派送总数:$deliveryCount');
        // print('派送运费:$deliveryFreight');
        // print('佣金:$commissionD');
      } catch (e) {
        print(e);
      }
    });

    // try {
    //   dio.options.headers['X-CSRF-TOKEN'] = csrf_token;
    //   print('1111');
    //   //print(csrf_token);
    //   var response = await dio.post(
    //       'http://tms.cambodianexpress.com/tms/courier/provison/query',
    //       data: data);
    //   print(response.data['rows'][0]['deliveryCount']);
    // } catch (e) {
    //   print(e);
    // }
  }
}

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
