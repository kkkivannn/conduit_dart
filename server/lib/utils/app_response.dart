import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:server/models/response_model.dart';
import 'package:server/server.dart';

class AppResponse extends Response {
  AppResponse.ok({dynamic body, String? message})
      : super.ok(
          ResponseModel(data: body, message: message),
        );
  AppResponse.serverError(dynamic error, {String? message})
      : super.serverError(
          body: _getReponseModel(error, message),
        );

  static ResponseModel _getReponseModel(error, String? message) {
    if (error is QueryException) {
      return ResponseModel(
        error: error.toString(),
        message: message ?? error.message,
      );
    }
    if (error is JwtException) {
      return ResponseModel(
        error: error.toString(),
        message: message ?? error.message,
      );
    }
    return ResponseModel(
      error: error.toString(),
      message: message ?? "Неизвестная ошибка",
    );
  }
}
