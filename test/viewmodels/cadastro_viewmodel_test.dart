import 'package:flutter_test/flutter_test.dart';
import 'package:fala_comigo_app/app/app.locator.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('CadastroViewModel Tests -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());
  });
}
