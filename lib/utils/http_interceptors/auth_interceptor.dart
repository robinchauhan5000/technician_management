import 'dart:io';

import 'package:dio/dio.dart';
import '../../services/session_service.dart';

class AuthInterceptor extends Interceptor {
  @override
  Future<RequestOptions> onRequest(RequestOptions options) async {
    String token = await SessionService.getToken();
    if (!options.path.contains('/login')) {
      options.headers[HttpHeaders.authorizationHeader] =
          "Bearer ${token ?? ''}";
    }
    return options;
  }
}
