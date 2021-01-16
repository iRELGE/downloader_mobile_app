import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';

import 'dio-connectivity-retry-interceptor.dart';
import 'retry_interceptor.dart';

class InitielDio {
  final Dio dio;

  InitielDio(this.dio) {
    initState();
  }
  void initState() {
    dio.interceptors.add(
      RetryOnConnectionChangeInterceptor(
        requestRetrier: DioConnectivityRequestRetrier(
          dio: Dio(),
          connectivity: Connectivity(),
        ),
      ),
    );
  }
}
