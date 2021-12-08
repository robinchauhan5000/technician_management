import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';

import './http_interceptors/auth_interceptor.dart';
import './http_interceptors/error_interceptor.dart';

// FIXME: Use a legit dependency injector instead of a Singleton
class HttpClient {
  static final CacheConfig cacheConfig = CacheConfig();
  static final HttpClient _singleton = HttpClient._();

  static HttpClient get instance => _singleton;
  Dio _dio;

  HttpClient._();

  Dio get dio {
    if (_dio == null) {
      _dio = Dio();

      var cookieJar=CookieJar();
      dio.interceptors
        ..add(AuthInterceptor())
        ..add(ErrorInterceptor())
        ..add(CookieManager(cookieJar));
      // ..add(DioCacheManager(cacheConfig).interceptor);

      if (kDebugMode || false) {
        // dio.interceptors.add(
        //   PrettyDioLogger(
        //     requestHeader: true,
        //     requestBody: false,
        //     responseHeader: true,
        //     responseBody: true,
        //   ),
        // );
      }
    }
    return _dio;
  }
}

class HttpClientNoAuth {
  static final CacheConfig cacheConfig = CacheConfig();
  static final HttpClientNoAuth _singleton = HttpClientNoAuth._();

  static HttpClientNoAuth get instance => _singleton;
  Dio _dio;

  HttpClientNoAuth._();

  Dio get dio {
    if (_dio == null) {
      _dio = Dio();

      dio.interceptors
        // ..add(AuthInterceptor())
        ..add(ErrorInterceptor());
      // ..add(DioCacheManager(cacheConfig).interceptor);

      if (kDebugMode || false) {
        // dio.interceptors.add(
        //   PrettyDioLogger(
        //     requestHeader: true,
        //     requestBody: false,
        //     responseHeader: true,
        //     responseBody: true,
        //   ),
        // );
      }
    }
    return _dio;
  }
}
