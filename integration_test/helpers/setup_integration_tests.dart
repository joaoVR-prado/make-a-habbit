import 'package:flutter_test/flutter_test.dart';

import 'hive_test_environment.dart';

void setupIntegrationTests() {
  setUpAll(() async {
    await HiveTestEnvironment.initialize();
  });

  setUp(() async {
    await HiveTestEnvironment.clear();
  });

  tearDownAll(() async {
    await HiveTestEnvironment.dispose();
  });
}
