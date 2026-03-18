import 'package:flutter_test/flutter_test.dart';
import 'package:logdash_frontend_mobile/app/app.dart';
import 'package:logdash_frontend_mobile/app/app_module.dart';

void main() {
  testWidgets('Home exibe Bem-vindo', (WidgetTester tester) async {
    setupInjector();
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('Bem-vindo'), findsOneWidget);
  });
}
