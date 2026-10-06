import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/money_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/expense.dart';
import '../../models/category.dart';
import '../widgets/expense_card.dart';

enum PeriodFilter { today, sevenDays, thisMonth, all }

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  PeriodFilter _selectedPeriod = PeriodFilter.thisMonth;
  String? _selectedCategory;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Expense> _filterExpenses(List<Expense> expenses) {
    final now = DateTime.now();
    return expenses.where((exp) {
      // 1. Filtro de Período
      bool matchesPeriod = true;
      switch (_selectedPeriod) {
        case PeriodFilter.today:
          matchesPeriod = DateUtils.isSameDay(exp.date, now);
          break;
        case PeriodFilter.sevenDays:
          matchesPeriod = exp.date.isAfter(now.subtract(const Duration(days: 7)));
          break;
        case PeriodFilter.thisMonth:
          matchesPeriod = exp.date.year == now.year && exp.date.month == now.month;
          break;
        case PeriodFilter.all:
          matchesPeriod = true;
          break;
      }
      if (!matchesPeriod) return false;

      // 2. Filtro de Categoria
      if (_selectedCategory != null && exp.categoryId != _selectedCategory) {
        return false;
      }

      // 3. Filtro de Busca
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesDesc = exp.description.toLowerCase().contains(query);
        final matchesUser = exp.userName.toLowerCase().contains(query);
        if (!matchesDesc && !matchesUser) return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MoneyController>();
    final filteredExpenses = _filterExpenses(controller.expenses);
    final totalFiltered = filteredExpenses.fold<double>(0.0, (acc, e) => acc + e.amount);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gastos Registrados'),
      ),
      body: Column(
        children: [
          // Filter Bar & Search
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                // Period Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildPeriodChip(PeriodFilter.today, 'Hoje'),
                      _buildPeriodChip(PeriodFilter.sevenDays, '7 dias'),
                      _buildPeriodChip(PeriodFilter.thisMonth, 'Este mês'),
                      _buildPeriodChip(PeriodFilter.all, 'Todos'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Search bar
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Buscar gasto ou pessoa...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
                const SizedBox(height: 10),
                // Category Pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _selectedCategory = null),
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _selectedCategory == null ? AppColors.primary : AppColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Todas',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _selectedCategory == null ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      ...ExpenseCategory.defaultCategories.map((cat) {
                        final isSel = _selectedCategory == cat.id;
                        return GestureDetector(
                          onTap: () => setState(() {
                            _selectedCategory = isSel ? null : cat.id;
                          }),
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.primary : AppColors.surfaceSubtle,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Text(cat.emoji, style: const TextStyle(fontSize: 12)),
                                const SizedBox(width: 4),
                                Text(
                                  cat.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                    color: isSel ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Total Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: AppColors.surfaceSubtle,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredExpenses.length} lançamentos',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Total: ${CurrencyFormatter.format(totalFiltered)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Expenses List
          Expanded(
            child: filteredExpenses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.textTertiary),
                        SizedBox(height: 12),
                        Text(
                          'Nenhum gasto encontrado',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final item = filteredExpenses[index];
                      return ExpenseCard(
                        expense: item,
                        onDelete: () => controller.deleteExpense(item.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(PeriodFilter filter, String label) {
    final isSelected = _selectedPeriod == filter;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = filter),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
