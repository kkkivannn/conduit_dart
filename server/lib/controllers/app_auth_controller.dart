import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:server/models/response_model.dart';
import 'package:server/server.dart';
import 'package:server/utils/app_utils.dart';

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
    try {
      final qFindUser = Query<User>(managedContext)
        ..where((table) => table.username).equalTo(user.username)
        ..returningProperties((table) => [
              table.id,
              table.salt,
              table.hashPassword,
            ]);
      final findUser = await qFindUser.fetchOne();
      if (findUser == null) {
        throw QueryException.conflict("Пользователь не найден", []);
      }
      final requestHashPassword = AuthUtility.generatePasswordHash(
          user.password ?? '', findUser.salt ?? '');
      if (requestHashPassword == findUser.hashPassword) {
        await _updateTokens(findUser.id ?? -1, managedContext);

        final newUser =
            await managedContext.fetchObjectWithID<User>(findUser.id);
        return Response.ok(
          ResponseModel(
              data: newUser?.backing.contents,
              message: "Успешная авторизация!"),
        );
      } else {
        throw QueryException.conflict("Пароль не верный", []);
      }
    } on QueryException catch (error) {
      return Response.serverError(
        body: ResponseModel(message: error.message),
      );
    }
  }

  @Operation.put()
  Future<Response> signUp(@Bind.body() User user) async {
    if (user.password == null || user.username == null || user.email == null) {
      return Response.badRequest(
        body: ResponseModel(
            message: "Поля Password и Username, и Email обязательны!"),
      );
    }
    final salt = AuthUtility.generateRandomSalt();
    final hashPassword =
        AuthUtility.generatePasswordHash(user.password ?? "", salt);
    try {
      late final int id;
      await managedContext.transaction((transaction) async {
        final qCreateUser = Query<User>(transaction)
          ..values.username = user.username
          ..values.email = user.email
          ..values.salt = salt
          ..values.hashPassword = hashPassword;
        final createdUser = await qCreateUser.insert();
        id = createdUser.asMap()["id"] as int;
        await _updateTokens(id, transaction);
      });
      final User? userData = await managedContext.fetchObjectWithID<User>(id);
      return Response.ok(
        ResponseModel(
            data: userData?.backing.contents, message: "Успешная регистрация"),
      );
    } on QueryException catch (error) {
      return Response.serverError(
        body: ResponseModel(message: error.message),
      );
    }
  }

  Future<void> _updateTokens(int id, ManagedContext transaction) async {
    final Map<String, dynamic> tokens = _getTokens(id);
    final qUpdateTokens = Query<User>(transaction)
      ..where((user) => user.id).equalTo(id)
      ..values.accessToken = tokens["access"] as String
      ..values.refreshToken = tokens["refresh"] as String;
    await qUpdateTokens.updateOne();
  }

  @Operation.post('refresh')
  Future<Response> refreshToken(
      @Bind.path('refresh') String refreshToken) async {
    try {
      final id = AppUtils.getIdFromToken(refreshToken);
    } catch (error) {
      return Response.serverError(
        body: ResponseModel(message: error.toString()),
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
        message: 'Успешное обновление!',
      ).toJson(),
    );
  }

  Map<String, dynamic> _getTokens(id) {
    //TODO remove when release
    final key = Platform.environment['SECRET_KEY'] ?? 'SECRET_KEY';
    final accessClaimSet = JwtClaim(
      maxAge: const Duration(hours: 1),
      otherClaims: {"id": id},
    );
    final refreshClaimSet = JwtClaim(
      otherClaims: {"id": id},
    );
    final tokens = <String, dynamic>{};
    tokens["access"] = issueJwtHS256(accessClaimSet, key);
    tokens["refresh"] = issueJwtHS256(refreshClaimSet, key);
    return tokens;
  }
}
