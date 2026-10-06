import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:money/controllers/money_controller.dart';
import 'package:money/main.dart';

void main() {
  testWidgets('MoneyApp LoginScreen smoke test', (WidgetTester tester) async {
    final controller = MoneyController();
    await controller.init();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<MoneyController>.value(value: controller),
        ],
        child: const MoneyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verifica se a tela de login carregou
    expect(find.text('Money'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Criar Conta'), findsOneWidget);
    expect(find.text('Entrar no Modo Demonstração'), findsOneWidget);
  });
}
