import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/money_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/category.dart';
import 'package:intl/intl.dart';

class AddExpenseModal extends StatefulWidget {
  const AddExpenseModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddExpenseModal(),
    );
  }

  @override
  State<AddExpenseModal> createState() => _AddExpenseModalState();
}

class _AddExpenseModalState extends State<AddExpenseModal> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategoryId = 'food';
  late String _selectedUserId;
  String _selectedPaymentMethod = 'Pix';
  DateTime _selectedDate = DateTime.now();

  bool _isInstallment = false;
  int _installmentsCount = 2;
  bool _createAllMonths = true;

  final List<String> _paymentMethods = [
    'Pix',
    'Cartão de Crédito',
    'Cartão de Débito',
    'Dinheiro',
  ];

  @override
  void initState() {
    super.initState();
    final controller = context.read<MoneyController>();
    _selectedUserId = controller.currentUser?.id ?? 'user_1';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveExpense() {
    final amountText = _amountController.text.replaceAll(',', '.').trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe um valor válido.')),
      );
      return;
    }

    final description = _descriptionController.text.trim().isEmpty
        ? ExpenseCategory.findById(_selectedCategoryId).name
        : _descriptionController.text.trim();

    final isCardInstallment = _isInstallment || _selectedPaymentMethod == 'Cartão de Crédito' && _isInstallment;

    context.read<MoneyController>().addExpense(
      description: description,
      amount: amount,
      categoryId: _selectedCategoryId,
      userId: _selectedUserId,
      paymentMethod: _selectedPaymentMethod,
      date: _selectedDate,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      isInstallment: isCardInstallment,
      installmentsCount: isCardInstallment ? _installmentsCount : 1,
      createAllInstallments: isCardInstallment && _createAllMonths,
    );

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gasto adicionado com sucesso!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MoneyController>();
    final members = controller.members;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Adicionar Gasto',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Large Amount Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Text(
                    'R\$',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      autofocus: true,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        hintText: '0,00',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Description
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                hintText: 'Ex: Mercado, Farmácia, Combustível...',
                prefixIcon: Icon(Icons.edit_note_rounded),
              ),
            ),
            const SizedBox(height: 16),

            // Quem gastou? (Couple toggle)
            const Text(
              'Quem gastou?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: members.map((member) {
                final isSelected = _selectedUserId == member.id;
                final isUserOne = member.id == 'user_1';
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedUserId = member.id),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isUserOne ? AppColors.userOneLight : AppColors.userTwoLight)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? (isUserOne ? AppColors.userOne : AppColors.userTwo)
                              : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(member.avatarEmoji, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Text(
                            member.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? (isUserOne ? AppColors.userOne : AppColors.userTwo)
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Category Selector
            const Text(
              'Categoria',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: ExpenseCategory.defaultCategories.length,
                itemBuilder: (context, index) {
                  final cat = ExpenseCategory.defaultCategories[index];
                  final isSelected = _selectedCategoryId == cat.id;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategoryId = cat.id),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryLight : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(cat.emoji, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            cat.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Payment Method & Date
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedPaymentMethod,
                    decoration: const InputDecoration(labelText: 'Pagamento'),
                    items: _paymentMethods.map((m) {
                      return DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 14)));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedPaymentMethod = val);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data',
                        suffixIcon: Icon(Icons.calendar_month, size: 20),
                      ),
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Pergunta de Parcelamento (Ativa se Cartão de Crédito ou opção selecionada)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.credit_card_rounded, size: 18, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(
                            'É compra parcelada?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isInstallment,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          setState(() {
                            _isInstallment = val;
                            if (val && _selectedPaymentMethod != 'Cartão de Crédito') {
                              _selectedPaymentMethod = 'Cartão de Crédito';
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  if (_isInstallment) ...[
                    const Divider(height: 16),
                    const Text(
                      'Em quantas vezes?',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [2, 3, 4, 5, 6, 10, 12].map((count) {
                        final isSel = _installmentsCount == count;
                        return ChoiceChip(
                          label: Text('${count}x'),
                          selected: isSel,
                          selectedColor: AppColors.primaryLight,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: isSel ? AppColors.primaryDark : AppColors.textPrimary,
                            fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                          ),
                          onSelected: (selected) {
                            if (selected) setState(() => _installmentsCount = count);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      value: _createAllMonths,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text(
                        'Criar despesas das próximas parcelas nos meses seguintes',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      onChanged: (val) {
                        setState(() => _createAllMonths = val ?? true);
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _saveExpense,
              child: const Text('Salvar Gasto'),
            ),
          ],
        ),
      ),
    );
  }
}
