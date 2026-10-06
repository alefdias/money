import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/money_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';

class PlanningScreen extends StatelessWidget {
  const PlanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MoneyController>();
    final summary = controller.summary;
    final incomes = controller.incomes;
    final fixedExpenses = controller.fixedExpenses;
    final debts = controller.debts;
    final goal = controller.goal;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Planejamento Familiar'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Math Breakdown Header Card (Equation from Specification)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cálculo do Orçamento Livre',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildEquationRow('Rendas conjuntas', CurrencyFormatter.format(summary.totalIncome), AppColors.inGoal),
                  _buildEquationRow('Contas fixas', '- ${CurrencyFormatter.format(summary.totalFixedExpenses)}', AppColors.overLimit),
                  _buildEquationRow('Dívidas e parcelas', '- ${CurrencyFormatter.format(summary.totalMonthlyDebts)}', AppColors.attention),
                  _buildEquationRow('Meta para guardar', '- ${CurrencyFormatter.format(summary.monthlySavingsGoal)}', AppColors.primary),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Disponível no Mês:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(summary.monthlyDiscretionaryBudget),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Meta de Economia
            _buildSectionHeader(
              title: '🎯 Meta de Economia',
              subtitle: 'Dinheiro protegido para o futuro',
              trailing: TextButton(
                onPressed: () => _showEditGoalDialog(context, controller, goal?.monthlyTarget ?? 1000.0),
                child: const Text('Alterar meta'),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal?.title ?? 'Reserva do Casal',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Acumulado: ${CurrencyFormatter.format(goal?.currentSaved ?? 0.0)}',
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${CurrencyFormatter.format(goal?.monthlyTarget ?? 1000.0)}/mês',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. Contas Fixas
            _buildSectionHeader(
              title: '🏠 Contas Fixas',
              subtitle: '${fixedExpenses.where((f) => !f.isPaid).length} contas a pagar este mês',
              trailing: IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                onPressed: () => _showAddFixedExpenseDialog(context, controller),
              ),
            ),
            ...fixedExpenses.map((bill) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: bill.isPaid ? AppColors.border : AppColors.attention.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: bill.isPaid,
                      activeColor: AppColors.inGoal,
                      onChanged: (_) => controller.toggleFixedExpensePaid(bill.id),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bill.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              decoration: bill.isPaid ? TextDecoration.lineThrough : null,
                              color: bill.isPaid ? AppColors.textTertiary : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Vence dia ${bill.dueDay} • ${bill.isPaid ? "Pago ✓" : "Pendente"}',
                            style: TextStyle(
                              fontSize: 12,
                              color: bill.isPaid ? AppColors.inGoal : AppColors.attention,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(bill.amount),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: bill.isPaid ? AppColors.textTertiary : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),

            // 4. Dívidas e Parcelamentos
            _buildSectionHeader(
              title: '💳 Dívidas & Parcelamentos',
              subtitle: 'Compras parceladas consideradas no mês',
              trailing: IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                onPressed: () => _showAddDebtDialog(context, controller),
              ),
            ),
            ...debts.map((debt) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          debt.title,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${CurrencyFormatter.format(debt.installmentAmount)}/mês',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: debt.progress,
                        minHeight: 6,
                        backgroundColor: AppColors.surfaceSubtle,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.attention),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${debt.paidInstallments} de ${debt.totalInstallments} pagas (${debt.remainingInstallments} restantes)',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        Text(
                          'Resta: ${CurrencyFormatter.format(debt.remainingDebt)}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),

            // 5. Rendas do Casal
            _buildSectionHeader(
              title: '💰 Rendas da Família',
              subtitle: 'Salários e fontes de renda cadastradas',
              trailing: IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                onPressed: () => _showAddIncomeDialog(context, controller),
              ),
            ),
            ...incomes.map((inc) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          inc.title,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Recebido por ${inc.userName}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    Text(
                      '+ ${CurrencyFormatter.format(inc.amount)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inGoal,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildEquationRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  void _showEditGoalDialog(BuildContext context, MoneyController controller, double current) {
    final textCtrl = TextEditingController(text: current.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Meta de Economia Mensal'),
        content: TextField(
          controller: textCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Valor a guardar por mês (R\$)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(textCtrl.text);
              if (val != null) {
                controller.updateSavingsGoal(val);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showAddFixedExpenseDialog(BuildContext context, MoneyController controller) {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final dayCtrl = TextEditingController(text: '10');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova Conta Fixa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nome (ex: Luz, Internet)')),
            const SizedBox(height: 10),
            TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Valor (R\$)')),
            const SizedBox(height: 10),
            TextField(controller: dayCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Dia do Vencimento')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(amountCtrl.text.replaceAll(',', '.'));
              final day = int.tryParse(dayCtrl.text) ?? 10;
              if (nameCtrl.text.isNotEmpty && amt != null) {
                controller.addFixedExpense(name: nameCtrl.text, amount: amt, dueDay: day);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _showAddDebtDialog(BuildContext context, MoneyController controller) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final totalCtrl = TextEditingController(text: '10');
    final paidCtrl = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Novo Parcelamento / Dívida'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Descrição (ex: Notebook)')),
            const SizedBox(height: 10),
            TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Valor da Parcela (R\$)')),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: TextField(controller: totalCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total Parcelas'))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: paidCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Já Pagas'))),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(amountCtrl.text.replaceAll(',', '.'));
              final total = int.tryParse(totalCtrl.text) ?? 1;
              final paid = int.tryParse(paidCtrl.text) ?? 0;
              if (titleCtrl.text.isNotEmpty && amt != null) {
                controller.addDebt(
                  title: titleCtrl.text,
                  installmentAmount: amt,
                  totalInstallments: total,
                  paidInstallments: paid,
                  dueDay: 10,
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _showAddIncomeDialog(BuildContext context, MoneyController controller) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova Renda'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Descrição (ex: Salário Extra)')),
            const SizedBox(height: 10),
            TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Valor (R\$)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(amountCtrl.text.replaceAll(',', '.'));
              if (titleCtrl.text.isNotEmpty && amt != null) {
                controller.addIncome(
                  title: titleCtrl.text,
                  amount: amt,
                  userId: controller.currentUser?.id ?? 'user_1',
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}
