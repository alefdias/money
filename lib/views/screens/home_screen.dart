import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/money_controller.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/daily_limit_card.dart';
import '../widgets/month_budget_card.dart';
import '../widgets/couple_spent_card.dart';
import '../widgets/gemini_insight_card.dart';
import '../widgets/expense_card.dart';
import 'connected_accounts_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigateTab;

  const HomeScreen({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MoneyController>();

    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final summary = controller.summary;
    final expenses = controller.expenses;
    final recentExpenses = expenses.take(5).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Image.asset('assets/images/logo.png', width: 22, height: 22),
                  const SizedBox(width: 8),
                  Text(
                    controller.family?.name ?? 'Money',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.credit_card_rounded, color: AppColors.primary),
            tooltip: 'Contas & Cartões',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ConnectedAccountsScreen()),
              );
            },
          ),
          // Active User Badge
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                // Quick switch user for demo/testing
                final otherUser = controller.members.firstWhere(
                  (m) => m.id != controller.currentUser?.id,
                  orElse: () => controller.currentUser!,
                );
                controller.switchActiveUser(otherUser.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Alternado para: ${otherUser.name}'),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Text(
                      controller.currentUser?.avatarEmoji ?? '👤',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      controller.currentUser?.name ?? 'Você',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.swap_horiz, size: 16, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.init(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Available This Month Hero Card
              MonthBudgetCard(summary: summary),
              const SizedBox(height: 16),

              // 2. Today's Dynamic Limit Card (Core of Money)
              DailyLimitCard(summary: summary),
              const SizedBox(height: 16),

              // 3. Gemini Smart Insight
              GeminiInsightCard(
                insight: controller.quickInsight,
                onTap: () => onNavigateTab(3), // Switch to Gemini tab
              ),
              const SizedBox(height: 16),

              // 4. Couple Split Card
              CoupleSpentCard(summary: summary),
              const SizedBox(height: 24),

              // 5. Recent Expenses Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Últimos Gastos',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => onNavigateTab(1), // Switch to Gastos tab
                    child: const Text('Ver todos'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Recent Expenses List
              if (recentExpenses.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Column(
                      children: const [
                        Text('✨', style: TextStyle(fontSize: 32)),
                        SizedBox(height: 8),
                        Text(
                          'Nenhum gasto registrado ainda!',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...recentExpenses.map(
                  (expense) => ExpenseCard(
                    expense: expense,
                    onDelete: () => controller.deleteExpense(expense.id),
                  ),
                ),

              const SizedBox(height: 80), // Padding for FAB
            ],
          ),
        ),
      ),
    );
  }
}
