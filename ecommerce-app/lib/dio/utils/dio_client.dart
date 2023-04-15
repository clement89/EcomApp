import 'dart:async';
import 'dart:io';

import 'package:Nesto/dio/models/header_model.dart';
import 'package:Nesto/utils/util.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class DioClient {
  DioClient() {
    initClient();
  }
  //for api client testing only
  DioClient.test({@required this.dio});

  String appName, packageName, version, buildNumber;

  Future getPackageDetails() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
  }

  Dio dio;
  BaseOptions _baseOptions;

  initClient() async {
    getPackageDetails();
    _baseOptions = new BaseOptions(
        baseUrl: "baseUrl",
        connectTimeout: 20000,
        receiveTimeout: 20000,
        followRedirects: false,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
          "appname": appName,
          "packagename": packageName,
          "storeid": storeId,
          "language": "en",
          "country": "AE",
          "version": version.toString(),
          "versioncode": buildNumber.toString(),
          "devtype": "phone/tablet"
        },
        responseType: ResponseType.json,
        receiveDataWhenStatusError: true);

    dio = Dio(_baseOptions);

    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
    };

    dio.interceptors.add(CookieManager(new CookieJar()));
  }

  ///dio get
  Future<Response> get({String url, HeaderModel header}) async {
    if (header != null) {
      dio.options.headers.addAll({"Authorization": header.authorization});
      logNesto("header is " + header.authorization);
    }
    logNesto("url is " + url);
    return dio.get(url);
  }

  ///dio  post
  Future<Response> post({String url, HeaderModel header, var data}) async {
    // dio.options.headers.addAll({
    //   "Content-Type": 'application/json'
    //  });

    Map<String, dynamic> headers = {
      "Content-Type": 'application/json',
      "access-token": header?.accessToken ?? "",
    };

    headers.removeWhere(
        (String key, dynamic value) => value == null || key == null);

    dio.options.headers.addAll(headers);

    return dio.post(
      url,
      data: data,
    );
  }

  ///dio  put
  Future<Response> put({String url, HeaderModel header, var data}) async {
    dio.options.headers.addAll({"Authorization": header.authorization});
    logNesto("url is " + url);

    return dio.put(url, data: data);
  }
}
