import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:money/controllers/money_controller.dart';
import 'package:money/main.dart';

void main() {
  testWidgets('MoneyApp smoke test', (WidgetTester tester) async {
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

    // Verifica se a tela inicial carregou com os componentes principais
    expect(find.text('DISPONÍVEL ESTE MÊS'), findsOneWidget);
    expect(find.text('HOJE'), findsOneWidget);
    expect(find.text('Gasto'), findsOneWidget);
  });
}
