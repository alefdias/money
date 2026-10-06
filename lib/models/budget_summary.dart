enum DailyStatus {
  inGoal,      // Verde - Dentro da meta
  attention,   // Laranja - Próximo do limite
  overLimit,   // Vermelho - Acima do limite planejado
}

class BudgetSummary {
  final double totalIncome;
  final double totalFixedExpenses;
  final double unpaidFixedExpenses;
  final double totalMonthlyDebts;
  final double monthlySavingsGoal;

  final double monthlyDiscretionaryBudget; // Disponível total planejado para o mês
  final double monthSpent;                 // Total já gasto no mês
  final double monthRemaining;              // Quanto ainda podemos gastar este mês

  final double todaySpent;                 // Gastos registrados hoje
  final double dailyRecommendedLimit;      // Limite diário dinâmico recomendado para hoje
  final double todayRemaining;             // Saldo do dia (dailyLimit - todaySpent)
  final int daysRemainingInMonth;          // Dias restantes no mês

  final double user1Spent;                 // Gastos do Usuário 1
  final double user2Spent;                 // Gastos do Usuário 2
  final String user1Name;
  final String user2Name;

  const BudgetSummary({
    required this.totalIncome,
    required this.totalFixedExpenses,
    required this.unpaidFixedExpenses,
    required this.totalMonthlyDebts,
    required this.monthlySavingsGoal,
    required this.monthlyDiscretionaryBudget,
    required this.monthSpent,
    required this.monthRemaining,
    required this.todaySpent,
    required this.dailyRecommendedLimit,
    required this.todayRemaining,
    required this.daysRemainingInMonth,
    required this.user1Spent,
    required this.user2Spent,
    required this.user1Name,
    required this.user2Name,
  });

  DailyStatus get status {
    if (todaySpent <= dailyRecommendedLimit) {
      if (dailyRecommendedLimit > 0 && (todaySpent / dailyRecommendedLimit) >= 0.85) {
        return DailyStatus.attention;
      }
      return DailyStatus.inGoal;
    }
    return DailyStatus.overLimit;
  }

  String get statusMessage {
    switch (status) {
      case DailyStatus.inGoal:
        return '✓ Dentro da meta';
      case DailyStatus.attention:
        return '⚠️ Próximo do limite';
      case DailyStatus.overLimit:
        return '🚨 Acima do limite de hoje';
    }
  }

  double get monthlyProgress {
    if (monthlyDiscretionaryBudget <= 0) return 1.0;
    return (monthSpent / monthlyDiscretionaryBudget).clamp(0.0, 1.0);
  }

  double get dailyProgress {
    if (dailyRecommendedLimit <= 0) return todaySpent > 0 ? 1.0 : 0.0;
    return (todaySpent / dailyRecommendedLimit).clamp(0.0, 1.0);
  }
}
