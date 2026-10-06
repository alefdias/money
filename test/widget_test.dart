import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:money/controllers/money_controller.dart';
import 'package:money/core/theme/app_theme.dart';
import 'package:money/views/screens/login_screen.dart';

void main() {
  testWidgets('MoneyApp LoginScreen smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final controller = MoneyController();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<MoneyController>.value(value: controller),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LoginScreen(),
        ),
      ),
    );

    await tester.pump();

    // Verifica se a tela de login carregou com elementos principais
    expect(find.text('Money'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Criar Conta'), findsOneWidget);
    expect(find.text('Continuar com o Google'), findsOneWidget);
  });
}
