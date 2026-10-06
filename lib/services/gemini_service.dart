import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/budget_summary.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../core/utils/currency_formatter.dart';

class GeminiMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  GeminiMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class GeminiService {
  final String? apiKey;
  final String? cloudFunctionUrl;

  GeminiService({this.apiKey, this.cloudFunctionUrl});

  /// Gera um insight automático contextual para o topo da Home
  String generateQuickInsight(BudgetSummary summary, List<Expense> expenses) {
    if (summary.status == DailyStatus.overLimit) {
      final excess = summary.todaySpent - summary.dailyRecommendedLimit;
      return '⚠️ Hoje os gastos ultrapassaram a meta diária em ${CurrencyFormatter.format(excess)}. O limite dos próximos ${summary.daysRemainingInMonth - 1} dias foi recalculado para equilibrar o mês.';
    }

    if (summary.todayRemaining > 0) {
      return '✨ Hoje vocês ainda têm ${CurrencyFormatter.format(summary.todayRemaining)} disponíveis para gastar mantendo a meta de guardar ${CurrencyFormatter.format(summary.monthlySavingsGoal)}!';
    }

    if (summary.monthRemaining > 0) {
      return '🎉 Ritmo excelente! Restam ${summary.daysRemainingInMonth} dias e vocês têm ${CurrencyFormatter.format(summary.monthRemaining)} livres.';
    }

    return '💡 Dica: Revise as contas fixas não pagas para garantir que todas estejam quitadas antes de novos gastos.';
  }

  /// Responde a perguntas financeiras do usuário
  Future<String> askAssistant({
    required String question,
    required BudgetSummary summary,
    required List<Expense> expenses,
  }) async {
    // 1. Se houver Cloud Function ou chave de API configurada, podemos chamar o endpoint remoto
    if (cloudFunctionUrl != null && cloudFunctionUrl!.isNotEmpty) {
      try {
        final payload = {
          'prompt': question,
          'summary': {
            'renda': summary.totalIncome,
            'contas_fixas': summary.totalFixedExpenses,
            'contas_pendentes': summary.unpaidFixedExpenses,
            'dividas': summary.totalMonthlyDebts,
            'meta_economia': summary.monthlySavingsGoal,
            'disponivel_mes': summary.monthlyDiscretionaryBudget,
            'gasto_mes': summary.monthSpent,
            'saldo_restante_mes': summary.monthRemaining,
            'gasto_hoje': summary.todaySpent,
            'limite_diario_recomendado': summary.dailyRecommendedLimit,
            'saldo_hoje': summary.todayRemaining,
            'dias_restantes': summary.daysRemainingInMonth,
            'gasto_user1': summary.user1Spent,
            'gasto_user2': summary.user2Spent,
          },
        };

        final response = await http.post(
          Uri.parse(cloudFunctionUrl!),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['answer'] ?? data['reply'] ?? 'Sem resposta da IA.';
        }
      } catch (_) {
        // Fallback para o motor inteligente local
      }
    }

    // 2. Motor de Inteligência Financeira Contextual Integrado
    final lower = question.toLowerCase();

    // Pergunta: "Podemos gastar R$ X ...?"
    final matchAmount = RegExp(r'(\d+([\.,]\d+)?)').firstMatch(question);
    if (lower.contains('gastar') && matchAmount != null) {
      final valueStr = matchAmount.group(1)!.replaceAll(',', '.');
      final val = double.tryParse(valueStr) ?? 0.0;

      if (val <= summary.todayRemaining) {
        return 'Sim! Vocês ainda têm ${CurrencyFormatter.format(summary.todayRemaining)} disponíveis para gastar hoje. O gasto de ${CurrencyFormatter.format(val)} cabe perfeitamente na meta diária sem comprometer a economia.';
      } else if (val <= summary.monthRemaining) {
        final impactDays = (summary.monthRemaining - val) / (summary.daysRemainingInMonth > 1 ? summary.daysRemainingInMonth - 1 : 1);
        return 'Vocês podem gastar ${CurrencyFormatter.format(val)}, mas isso consumirá mais que a cota de hoje. Se fizerem essa compra, o limite diário recomendado para os próximos ${summary.daysRemainingInMonth - 1} dias diminuirá para cerca de ${CurrencyFormatter.format(impactDays)}/dia para ainda atingirem a meta de guardar ${CurrencyFormatter.format(summary.monthlySavingsGoal)}.';
      } else {
        return '⚠️ Não é recomendado gastar ${CurrencyFormatter.format(val)} agora. Vocês têm ${CurrencyFormatter.format(summary.monthRemaining)} disponíveis no restante do mês. Fazer essa despesa faria o casal entrar no negativo ou comprometer a meta de economia.';
      }
    }

    // Pergunta: "Como estamos este mês?"
    if (lower.contains('como estamos') || lower.contains('situação') || lower.contains('resumo')) {
      return 'Aqui está o panorama de vocês:\n'
          '• Renda conjunta: ${CurrencyFormatter.format(summary.totalIncome)}\n'
          '• Contas + Dívidas: ${CurrencyFormatter.format(summary.totalFixedExpenses + summary.totalMonthlyDebts)}\n'
          '• Meta guardada: ${CurrencyFormatter.format(summary.monthlySavingsGoal)}\n'
          '• Orçamento livre no mês: ${CurrencyFormatter.format(summary.monthlyDiscretionaryBudget)}\n'
          '• Já gastaram: ${CurrencyFormatter.format(summary.monthSpent)} (${(summary.monthlyProgress * 100).toStringAsFixed(0)}%)\n'
          '• Ainda disponível: ${CurrencyFormatter.format(summary.monthRemaining)} para os próximos ${summary.daysRemainingInMonth} dias (${CurrencyFormatter.format(summary.dailyRecommendedLimit)}/dia).';
    }

    // Pergunta: "Onde gastamos mais?"
    if (lower.contains('onde gastamos') || lower.contains('categoria') || lower.contains('maior gasto')) {
      final Map<String, double> catTotals = {};
      for (final e in expenses) {
        catTotals[e.categoryId] = (catTotals[e.categoryId] ?? 0.0) + e.amount;
      }
      if (catTotals.isEmpty) {
        return 'Ainda não há gastos registrados este mês.';
      }
      final sorted = catTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      final topCat = ExpenseCategory.findById(sorted.first.key);
      return 'O maior gasto do casal este mês foi com ${topCat.emoji} ${topCat.name}, totalizando ${CurrencyFormatter.format(sorted.first.value)}.\n'
          'Logo em seguida vem ${sorted.length > 1 ? ExpenseCategory.findById(sorted[1].key).name : "nenhum outro"}.';
    }

    // Pergunta: "Quanto economizar por dia / quanto vai sobrar?"
    if (lower.contains('sobrar') || lower.contains('projeção') || lower.contains('ritmo')) {
      if (summary.status == DailyStatus.inGoal) {
        return '🔥 Se continuarem gastando dentro do limite recomendado de ${CurrencyFormatter.format(summary.dailyRecommendedLimit)}/dia, vocês cumprirão a meta de economia de ${CurrencyFormatter.format(summary.monthlySavingsGoal)} e terminarão o mês no azul!';
      } else {
        return '⚠️ No ritmo de hoje (${CurrencyFormatter.format(summary.todaySpent)}/dia), o orçamento livre acabará antes do fim do mês. Reduzir gastos não essenciais nos próximos dias equilibrará a conta.';
      }
    }

    // Resposta geral do assistente
    return 'Entendido! Analisando os dados financeiros de vocês: vocês têm ${CurrencyFormatter.format(summary.monthRemaining)} livres até o fim do mês, o que dá uma média recomendada de ${CurrencyFormatter.format(summary.dailyRecommendedLimit)} por dia. Como posso te ajudar mais detalhadamente?';
  }
}
