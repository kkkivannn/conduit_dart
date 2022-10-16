import 'package:server/models/response_model.dart';
import 'package:server/server.dart';

class AppAuthController extends ResourceController {
  AppAuthController(this.managedContext);
  final ManagedContext managedContext;
  @Operation.post()
  Future<Response> signIn() async {
    return Response.ok(
      ResponseModel(
        data: {
          'id': '1',
          'refreshToken': 'refreshToken',
          'accessToken': 'accessToken',
        },
        message: 'SignIn ok!',
      ).toJson(),
    );
  }

  @Operation.put()
  Future<Response> signUp() async {
    return Response.ok(
      ResponseModel(
        data: {
          'id': '1',
          'refreshToken': 'refreshToken',
          'accessToken': 'accessToken',
        },
        message: 'SignUp ok!',
      ).toJson(),
    );
  }

  @Operation.post('refresh')
  Future<Response> refreshToken() async {
    return Response.unauthorized(
      body: ResponseModel(error: 'Token is not valid!').toJson(),
    );
  }
}
