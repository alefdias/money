import 'package:flutter_test/flutter_test.dart';
import 'package:money/core/engine/money_calculator.dart';
import 'package:money/models/expense.dart';
import 'package:money/models/income.dart';
import 'package:money/models/fixed_expense.dart';
import 'package:money/models/debt.dart';
import 'package:money/models/financial_goal.dart';
import 'package:money/models/user_profile.dart';
import 'package:money/models/budget_summary.dart';

void main() {
  group('MoneyCalculator Tests', () {
    const user1 = UserProfile(id: 'u1', name: 'Você', email: 'v@m.app', avatarEmoji: '🧑‍💻');
    const user2 = UserProfile(id: 'u2', name: 'Amor', email: 'a@m.app', avatarEmoji: '👩‍🎨');

    test('Cálculo do orçamento livre mensal conforme especificação', () {
      final now = DateTime(2026, 10, 5); // 31 days in October

      final incomes = [
        Income(
          id: '1',
          familyId: 'f1',
          userId: 'u1',
          userName: 'Você',
          title: 'Salário Você',
          amount: 4000.0,
          category: 'Salário',
          date: now,
        ),
        Income(
          id: '2',
          familyId: 'f1',
          userId: 'u2',
          userName: 'Amor',
          title: 'Salário Amor',
          amount: 2500.0,
          category: 'Salário',
          date: now,
        ),
      ];

      final fixed = [
        FixedExpense(
          id: '1',
          familyId: 'f1',
          name: 'Contas Gerais',
          amount: 2800.0,
          dueDay: 10,
        ),
      ];

      final debts = [
        const Debt(
          id: '1',
          familyId: 'f1',
          title: 'Parcelamentos',
          installmentAmount: 700.0,
          totalInstallments: 10,
          paidInstallments: 3,
          dueDay: 10,
        ),
      ];

      const goal = FinancialGoal(
        id: 'g1',
        familyId: 'f1',
        title: 'Meta Reserva',
        monthlyTarget: 1000.0,
      );

      final expenses = [
        Expense(
          id: 'e1',
          familyId: 'f1',
          userId: 'u1',
          userName: 'Você',
          description: 'Gasto teste',
          amount: 100.0,
          categoryId: 'food',
          date: now,
          paymentMethod: 'Pix',
        ),
      ];

      final summary = MoneyCalculator.calculate(
        incomes: incomes,
        fixedExpenses: fixed,
        debts: debts,
        goal: goal,
        expenses: expenses,
        user1: user1,
        user2: user2,
        referenceDate: now,
      );

      // Total Renda: 6500
      expect(summary.totalIncome, 6500.0);
      // Contas: 2800
      expect(summary.totalFixedExpenses, 2800.0);
      // Dívidas: 700
      expect(summary.totalMonthlyDebts, 700.0);
      // Meta: 1000
      expect(summary.monthlySavingsGoal, 1000.0);
      // Disponível total mensal: 6500 - 2800 - 700 - 1000 = 2000
      expect(summary.monthlyDiscretionaryBudget, 2000.0);

      // Já gasto no mês: 100
      expect(summary.monthSpent, 100.0);
      // Restante no mês: 2000 - 100 = 1900
      expect(summary.monthRemaining, 1900.0);

      // Dias restantes em 05/10 (outubro tem 31 dias): 31 - 5 + 1 = 27 dias
      expect(summary.daysRemainingInMonth, 27);

      // Limite recomendado diário: 2000 / 27 ≈ 74.07
      expect(summary.dailyRecommendedLimit, closeTo(74.07, 0.02));

      // Hoje gastou 100 (maior que 74.07) -> status overLimit
      expect(summary.status, DailyStatus.overLimit);
    });
  });
}
