import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'controllers/money_controller.dart';
import 'views/screens/login_screen.dart';
import 'views/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase
  User? initialUser;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    initialUser = FirebaseAuth.instance.currentUser;
  } catch (e) {
    debugPrint('Firebase offline fallback: $e');
  }

  // Inicializa o Controller de Dados 100% conectado à conta real
  final moneyController = MoneyController();
  if (initialUser != null) {
    await moneyController.initWithFirebaseUser(initialUser);
  } else {
    await moneyController.init();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MoneyController>.value(value: moneyController),
      ],
      child: MoneyApp(initialUser: initialUser),
    ),
  );
}

class MoneyApp extends StatelessWidget {
  final User? initialUser;
  const MoneyApp({super.key, this.initialUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: initialUser != null
          ? const MainNavigationScreen()
          : const LoginScreen(),
    );
  }
}
