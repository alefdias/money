import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/card_notification_service.dart';
import 'screens/home_screen.dart';
import 'screens/expenses_screen.dart';
import 'screens/planning_screen.dart';
import 'screens/gemini_screen.dart';
import 'screens/profile_screen.dart';
import 'modals/add_expense_modal.dart';
import 'modals/card_transaction_detected_modal.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  StreamSubscription? _cardTransactionSub;

  @override
  void initState() {
    super.initState();
    // Inicia monitoramento de notificações de cartões de bancos
    CardNotificationService.instance.init();

    _cardTransactionSub = CardNotificationService.instance.onTransactionDetected.listen((detection) {
      if (mounted) {
        CardTransactionDetectedModal.show(context, detection);
      }
    });
  }

  @override
  void dispose() {
    _cardTransactionSub?.cancel();
    super.dispose();
  }

  void _onNavigateTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(onNavigateTab: _onNavigateTab),
      const ExpensesScreen(),
      const PlanningScreen(),
      const GeminiScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddExpenseModal.show(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          'Gasto',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primaryLight,
          elevation: 0,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: AppColors.primaryDark),
              label: 'Início',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart_rounded, color: AppColors.primaryDark),
              label: 'Gastos',
            ),
            NavigationDestination(
              icon: Icon(Icons.track_changes_outlined),
              selectedIcon: Icon(Icons.track_changes_rounded, color: AppColors.primaryDark),
              label: 'Metas',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome_rounded, color: AppColors.primaryDark),
              label: 'Gemini',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline_rounded),
              selectedIcon: Icon(Icons.people_rounded, color: AppColors.primaryDark),
              label: 'Família',
            ),
          ],
        ),
      ),
    );
  }
}
