import 'package:conduit_core/conduit_core.dart';
import 'package:server/server.dart';

Future main() async {
  final int port = int.parse(Platform.environment["PORT"] ?? "8080");
  final service = Application<AppService>()..options.port = port;
  await service.start(
    numberOfInstances: 1,
    consoleLogging: true,
  );
}

