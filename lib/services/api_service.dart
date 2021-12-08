import 'dart:core';
import 'dart:math';
import 'dart:convert';
import 'dart:developer';

import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import './session_service.dart';
import '../utils/http_client.dart';

class ApiService {
  static String getUrl() {
    if (kReleaseMode) {
      return 'http://work.emshomeservices.com/api/mobile/v2';
    }
    return 'http://ems-wo-flow-dev.us-west-2.elasticbeanstalk.com/api/mobile/v2';
  }
  static String API_URL = ApiService.getUrl();

  static Future<String> login(String username, String password) async {
    var formData = FormData.fromMap({
      'username': username,
      'password': password,
    });
    Response response =
        await HttpClient.instance.dio.post("$API_URL/login", data: formData);
    Map responseBody = response.data;
    await SessionService.setToken(responseBody['token']);
    return responseBody['token'];
  }

  static Future<bool> isConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  static Future<bool> isLoggedIn({String token}) async {
    bool connected = await ApiService.isConnected();
    // Assume we're connected and authorized if the device has no service
    if (!connected) {
      return true;
    }
    try {
      Response response = await HttpClient.instance.dio.get(
          "$API_URL/test-session",
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        return false;
      } else {
        return false;
      }
    } catch (error) {
      print(error);
      return false;
    }
  }

  static String getRandomString(int len) {
    var random = Random.secure();
    var values = List<int>.generate(len, (i) =>  random.nextInt(255));
    return base64UrlEncode(values);
  }

  static Future<int> getConnectionQuality() async {
    String string = getRandomString(1024 * 200);
    bool connected = await ApiService.isConnected();
    if (!connected) {
      return 0;
    }

    FormData formData = FormData.fromMap({
      "data": string
    });

    try {
      Stopwatch stopwatch = new Stopwatch()..start();
      Response responsePost = await HttpClient.instance.dio
          .post("$API_URL/test-bytes", data: formData);
      Response responseGet = await HttpClient.instance.dio
          .get("$API_URL/test-bytes");

      Map responseBodyGet = responseGet.data;

      print('[CONN] Round-Trip Time: ${stopwatch.elapsed.inSeconds} sec');
      return responseBodyGet['data'] == string ? 1 : 0;
    } catch (error) {
      print(error);
      return 0;
    }

  }

  static Future<dynamic> fetchTechnicianWorkorders() async {
    try {
      Response response =
          await HttpClient.instance.dio.get("$API_URL/technician/-/workorders");

      Map responseBody = response.data;

      return responseBody['data'];
    } catch (error) {
      print(error);
      return [];
    }
  }

  static Future<dynamic> searchWorkorders(query) async {
    try {
      Response response =
          await HttpClient.instance.dio.get(
            '$API_URL/workorders/search',
            queryParameters: {
              'search': query,
            }
          );

      dynamic responseBody = response.data;
      return responseBody;
    } catch (error) {
      print(error);
      return [];
    }

  }

  static Future<dynamic> fetchUserFeatureFlags() async {
    try {
      Response response =
          await HttpClient.instance.dio.get("$API_URL/feature-flags");

      Map responseBody = response.data;

      return responseBody['data'];
    } catch (error) {
      print(error);
      return [];
    }
  }

  static Future<dynamic> setWorkorderTechnicianStatus(
      int id, String status) async {
    var formData = FormData.fromMap({
      'status': status,
    });
    Response response = await HttpClient.instance.dio
        .put("$API_URL/workorders/$id/status", data: formData);
    Map responseBody = response.data;
    return responseBody['data'];
  }

  static Future<dynamic> fetchSiteDiagnoses(int siteId) async {
    try {
      Response response =
          await HttpClient.instance.dio.get("$API_URL/sites/$siteId/diagnoses");

      Map responseBody = response.data;

      return responseBody['data'];
    } catch (error) {
      print(error);
      return [];
    }
  }

  static Future<dynamic> fetchWorkorderPhotos(int id) async {
    try {
      Response response =
          await HttpClient.instance.dio.get("$API_URL/workorders/$id/photos");

      Map responseBody = response.data;

      return responseBody['data'];
    } catch (error) {
      print(error);
      return [];
    }
  }

  static Future<dynamic> fetchWorkorderSite(int id) async {
    print('fetchWorkorderSite()');
    try {
      Response response =
          await HttpClient.instance.dio.get("$API_URL/workorders/$id/site");
      Map responseBody = response.data;
      return responseBody['data'];
    } catch (error) {
      print(error);
    }
  }

  static Future<dynamic> fetchSiteServiceHistory(int id) async {
    print('fetchSiteServiceHistory()');
    try {
      Response response =
      await HttpClient.instance.dio.get("$API_URL/sites/$id/service-history");
      Map responseBody = response.data;
      // print('responseBody:');
      // inspect(responseBody);
      return responseBody['data'];
    } catch (error, s) {
      print(error);
      print(s);

    }
  }

  static Future<dynamic> updateDiagnosis(id, Map diagnosisData) async {
    FormData formData = FormData.fromMap(diagnosisData);
    try {
      Response response = await HttpClient.instance.dio
          .put("$API_URL/diagnoses/$id", data: formData);
      Map responseBody = response.data;
      return responseBody['data'];
    } catch (error) {
      print(error);
    }

  }

  static Future<dynamic> updateComponent(id, Map componentData) async {
    FormData formData = FormData.fromMap(componentData);
    try {
      Response response = await HttpClient.instance.dio
          .put("$API_URL/components/$id", data: formData);
      Map responseBody = response.data;
      return responseBody['data'];
    } catch (error) {
      print(error);
    }

  }

  static Future<dynamic> updateSite(Map site) async {
    print('fetchWorkorderSite()');
    int id = site['id'];
    site.remove('id');
    FormData formData = FormData.fromMap(site);
    try {
      Response response = await HttpClient.instance.dio
          .put("$API_URL/sites/$id", data: formData);
      Map responseBody = response.data;
      return responseBody['data'];
    } catch (error) {
      print(error);
    }
  }

  static Future<dynamic> fetchSiteSystems(int id) async {
    try {
      Response response =
          await HttpClient.instance.dio.get("$API_URL/sites/$id/systems");

      Map responseBody = response.data;

      return responseBody['data'];
    } catch (error) {
      print(error);
      return [];
    }
  }

  static Future<void> logOut() async {
    return SessionService.deleteToken();
  }

  static Future<dynamic> fetchConfigs() async {
    Response response = await HttpClient.instance.dio.get("$API_URL/configs");
    Map responseBody = response.data;

    return responseBody['data'];
  }

  static Future<dynamic> createComponent(Map component) async {
    component.remove('id');
    FormData formData = FormData.fromMap(component);
    try {
      Response response = await HttpClient.instance.dio
          .post("$API_URL/components", data: formData);
      Map responseBody = response.data;
      return responseBody['data'];
    } catch (error) {
      print(error);
    }
  }

  static Future<dynamic> createSystem(Map system) async {
    system.remove('id');
    FormData formData = FormData.fromMap(system);
    try {
      Response response = await HttpClient.instance.dio
          .post("$API_URL/systems", data: formData);
      Map responseBody = response.data;
      return responseBody['data'];
    } catch (error) {
      print(error);
    }
  }

  static Future<dynamic> updateSystem(Map system) async {
    FormData formData = FormData.fromMap(system);
    try {
      Response response = await HttpClient.instance.dio
          .put("$API_URL/systems/${system['id']}", data: formData);
      system.remove('id');
      Map responseBody = response.data;
      return responseBody['data'];
    } catch (error) {
      print(error);
    }
  }

  static Future<dynamic> createDiagnosis(Map diagnosis) async {
    diagnosis.remove('id');
    FormData formData = FormData.fromMap(diagnosis);
    try {
      Response response = await HttpClient.instance.dio
          .post("$API_URL/diagnoses", data: formData);
      Map responseBody = response.data;
      return responseBody['data'];
    } catch (error) {
      print(error);
    }
  }

}
