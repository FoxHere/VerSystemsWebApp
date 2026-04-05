import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:versystems_app/config/constants/local_storage_constants.dart';


class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // faço uma desestruturação de options para pegar as variaveis headers e extra
    final RequestOptions(:headers, :extra) = options;

    // crio uma variavel authHeaderKey para remover do headers
    const authHeaderKey = 'Authorization';
    // remove authorization dos headers
    headers.remove(authHeaderKey);

    if (extra case {'DIO_AUTH_KEY': true}) {
      final sp = await SharedPreferences.getInstance();
      headers.addAll({
        authHeaderKey:
            'Bearer ${sp.getString(LocalStorageConstants.accessToken)}'
      });
    }

    handler.next(options);
    //super.onRequest(options, handler);
  }
}
