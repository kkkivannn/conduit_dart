import 'package:server/models/response_model.dart';
import 'package:server/server.dart';

import '../models/user_data.dart';

class AppAuthController extends ResourceController {
  AppAuthController(this.managedContext);
  final ManagedContext managedContext;

  @Operation.post()
  Future<Response> signIn(@Bind.body() User user) async {
    if (user.password == null || user.username == null) {
      return Response.badRequest(
        body: ResponseModel(message: "Поля Password и Username обязательны!"),
      );
    }
    final User fetchedUser = User();
    return Response.ok(
      ResponseModel(
        data: {
          'id': fetchedUser.id,
          'refreshToken': fetchedUser.refreshToken,
          'accessToken': fetchedUser.accessToken,
        },
        message: 'Успешная авторизация!',
      ).toJson(),
    );
  }

  @Operation.put()
  Future<Response> signUp(@Bind.body() User user) async {
    if (user.password == null || user.username == null || user.email == null) {
      return Response.badRequest(
        body: ResponseModel(
            message: "Поля Password и Username, и Email обязательны!"),
      );
    }
    final User fetchedUser = User();
    return Response.ok(
      ResponseModel(
        data: {
          'id': fetchedUser.id,
          'refreshToken': fetchedUser.refreshToken,
          'accessToken': fetchedUser.accessToken,
        },
        message: 'Успешная регистрация!',
      ).toJson(),
    );
  }

  @Operation.post('refresh')
  Future<Response> refreshToken(
      @Bind.path('refresh') String refreshToken) async {
    final User fetchedUser = User();
    return Response.ok(
      ResponseModel(
        data: {
          'id': fetchedUser.id,
          'refreshToken': fetchedUser.refreshToken,
          'accessToken': fetchedUser.accessToken,
        },
        message: 'Успешное обновление!',
      ).toJson(),
    );
  }
}
