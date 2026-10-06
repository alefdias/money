import 'dart:math';
import '../../models/budget_summary.dart';
import '../../models/expense.dart';
import '../../models/income.dart';
import '../../models/fixed_expense.dart';
import '../../models/debt.dart';
import '../../models/financial_goal.dart';
import '../../models/user_profile.dart';

class MoneyCalculator {
  /// Retorna o número de dias no mês da data fornecida
  static int getDaysInMonth(DateTime date) {
    final beginningOfNextMonth = (date.month < 12)
        ? DateTime(date.year, date.month + 1, 1)
        : DateTime(date.year + 1, 1, 1);
    return beginningOfNextMonth.subtract(const Duration(days: 1)).day;
  }

  /// Retorna os dias restantes no mês a partir da data de referência (inclusive hoje)
  static int getRemainingDaysInMonth(DateTime now) {
    final totalDays = getDaysInMonth(now);
    final remaining = totalDays - now.day + 1;
    return max(1, remaining);
  }

  /// Realiza o cálculo financeiro completo do Money
  static BudgetSummary calculate({
    required List<Income> incomes,
    required List<FixedExpense> fixedExpenses,
    required List<Debt> debts,
    required FinancialGoal? goal,
    required List<Expense> expenses,
    required UserProfile user1,
    required UserProfile user2,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();

    // 1. Rendas totais cadastradas
    final totalIncome = incomes.fold<double>(0.0, (acc, item) => acc + item.amount);

    // 2. Contas fixas do mês (e quantas ainda não foram pagas)
    final totalFixedExpenses = fixedExpenses.fold<double>(0.0, (acc, item) => acc + item.amount);
    final unpaidFixedExpenses = fixedExpenses
        .where((item) => !item.isPaid)
        .fold<double>(0.0, (acc, item) => acc + item.amount);

    // 3. Dívidas e parcelas deste mês
    final totalMonthlyDebts = debts.fold<double>(0.0, (acc, item) {
      if (item.remainingInstallments > 0) {
        return acc + item.installmentAmount;
      }
      return acc;
    });

    // 4. Meta de economia (dinheiro reservado)
    final monthlySavingsGoal = goal?.monthlyTarget ?? 0.0;

    // 5. Orçamento discricionário mensal inicial planejado
    // Disponível = Renda - Contas Fixas - Parcelas Dívidas - Meta de Economia
    final monthlyDiscretionaryBudget = max(
      0.0,
      totalIncome - totalFixedExpenses - totalMonthlyDebts - monthlySavingsGoal,
    );

    // 6. Gastos do mês atual
    final currentMonthExpenses = expenses.where((exp) {
      return exp.date.year == now.year && exp.date.month == now.month;
    }).toList();

    final monthSpent = currentMonthExpenses.fold<double>(0.0, (acc, exp) => acc + exp.amount);

    // 7. Quanto ainda podemos gastar no restante do mês
    final monthRemaining = monthlyDiscretionaryBudget - monthSpent;

    // 8. Gastos de hoje
    final todayExpenses = currentMonthExpenses.where((exp) {
      return exp.date.year == now.year &&
          exp.date.month == now.month &&
          exp.date.day == now.day;
    }).toList();

    final todaySpent = todayExpenses.fold<double>(0.0, (acc, exp) => acc + exp.amount);

    // 9. Limite diário dinâmico
    // Dias restantes no mês (incluindo hoje)
    final daysRemainingInMonth = getRemainingDaysInMonth(now);

    // O dinheiro disponível para os próximos dias é o que resta no mês.
    // Para calcular a cota de hoje: consideramos o que sobrava no início do dia de hoje
    // (saldo restante + o que já foi gasto hoje) dividido pelos dias restantes.
    final availableForRemainingPeriod = max(0.0, monthRemaining + todaySpent);
    final dailyRecommendedLimit = availableForRemainingPeriod / daysRemainingInMonth;

    final todayRemaining = dailyRecommendedLimit - todaySpent;

    // 10. Divisão de gastos do casal no mês
    final user1Spent = currentMonthExpenses
        .where((exp) => exp.userId == user1.id)
        .fold<double>(0.0, (acc, exp) => acc + exp.amount);

    final user2Spent = currentMonthExpenses
        .where((exp) => exp.userId == user2.id)
        .fold<double>(0.0, (acc, exp) => acc + exp.amount);

    return BudgetSummary(
      totalIncome: totalIncome,
      totalFixedExpenses: totalFixedExpenses,
      unpaidFixedExpenses: unpaidFixedExpenses,
      totalMonthlyDebts: totalMonthlyDebts,
      monthlySavingsGoal: monthlySavingsGoal,
      monthlyDiscretionaryBudget: monthlyDiscretionaryBudget,
      monthSpent: monthSpent,
      monthRemaining: monthRemaining,
      todaySpent: todaySpent,
      dailyRecommendedLimit: dailyRecommendedLimit,
      todayRemaining: todayRemaining,
      daysRemainingInMonth: daysRemainingInMonth,
      user1Spent: user1Spent,
      user2Spent: user2Spent,
      user1Name: user1.name,
      user2Name: user2.name,
    );
  }
}
