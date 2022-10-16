import 'package:server/server.dart';

Future main() async {
  final int port = int.parse(Platform.environment["PORT"] ?? "8080");
  final service = Application<AppService>()..options.port = port;
  await service.start(
    numberOfInstances: 1,
    consoleLogging: true,
  );
}
// final app = Application<ServerChannel>()
  //   ..options.configurationFilePath = "config.yaml"
  //   ..options.port = 8888;

  // await app.startOnCurrentIsolate();

  // print("Application started on port: ${app.options.port}.");
  // print("Use Ctrl-C (SIGINT) to stop running the application.");