import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/money_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/category.dart';
import '../../models/connected_account.dart';

class CardTransactionDetectedModal extends StatefulWidget {
  final CardTransactionDetection detection;

  const CardTransactionDetectedModal({
    super.key,
    required this.detection,
  });

  static Future<void> show(BuildContext context, CardTransactionDetection detection) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => CardTransactionDetectedModal(detection: detection),
    );
  }

  @override
  State<CardTransactionDetectedModal> createState() => _CardTransactionDetectedModalState();
}

class _CardTransactionDetectedModalState extends State<CardTransactionDetectedModal> {
  late TextEditingController _descriptionController;
  late String _selectedCategoryId;
  late String _selectedUserId;

  bool _isInstallment = false;
  int _installmentsCount = 2;
  bool _createAllMonths = true;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.detection.merchant);
    _selectedCategoryId = widget.detection.suggestedCategoryId;

    if (widget.detection.detectedInstallments != null && widget.detection.detectedInstallments! > 1) {
      _isInstallment = true;
      _installmentsCount = widget.detection.detectedInstallments!;
    }

    final controller = context.read<MoneyController>();
    _selectedUserId = controller.currentUser?.id ?? 'user_1';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    final controller = context.read<MoneyController>();
    final description = _descriptionController.text.trim().isEmpty
        ? widget.detection.merchant
        : _descriptionController.text.trim();

    final notes = 'Passagem de cartão detectada via notificação (${widget.detection.bankName})';

    controller.addExpense(
      description: description,
      amount: widget.detection.amount,
      categoryId: _selectedCategoryId,
      userId: _selectedUserId,
      paymentMethod: 'Cartão de Crédito',
      date: widget.detection.timestamp,
      notes: notes,
      isInstallment: _isInstallment,
      installmentsCount: _isInstallment ? _installmentsCount : 1,
      installmentNumber: 1,
      createAllInstallments: _isInstallment && _createAllMonths,
    );

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isInstallment
              ? 'Compra de ${CurrencyFormatter.format(widget.detection.amount)} parcelada em ${_installmentsCount}x cadastrada!'
              : 'Compra de ${CurrencyFormatter.format(widget.detection.amount)} cadastrada com sucesso!',
        ),
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

    final installmentValue = _isInstallment && _installmentsCount > 0
        ? widget.detection.amount / _installmentsCount
        : widget.detection.amount;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Banner
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.credit_card_rounded, color: AppColors.primary, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Compra no Cartão Detectada!',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Notificação de ${widget.detection.bankName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Destaque do Valor e Estabelecimento
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.detection.merchant,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Passagem aprovada no cartão',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(widget.detection.amount),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Pergunta 1: Essa compra é parcelada?
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Essa compra é parcelada?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isInstallment = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !_isInstallment ? AppColors.surface : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: !_isInstallment ? AppColors.primary : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: !_isInstallment
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 4,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                'Não, à vista',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: !_isInstallment ? AppColors.primaryDark : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isInstallment = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _isInstallment ? AppColors.surface : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _isInstallment ? AppColors.primary : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: _isInstallment
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 4,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                'Sim, parcelada',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _isInstallment ? AppColors.primaryDark : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Pergunta 2: Em quantas vezes? (Se parcelada)
                  if (_isInstallment) ...[
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 14),
                    const Text(
                      'Em quantas vezes?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Seletor de parcelas rápidas
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [2, 3, 4, 5, 6, 10, 12, 18, 24].map((count) {
                        final isSelected = _installmentsCount == count;
                        return ChoiceChip(
                          label: Text('${count}x'),
                          selected: isSelected,
                          selectedColor: AppColors.primaryLight,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          ),
                          onSelected: (selected) {
                            if (selected) setState(() => _installmentsCount = count);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    // Resumo das parcelas
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primaryDark),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '$_installmentsCount parcelas de ${CurrencyFormatter.format(installmentValue)} / mês',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      value: _createAllMonths,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text(
                        'Lançar as parcelas nos próximos meses automaticamente',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      onChanged: (val) {
                        setState(() => _createAllMonths = val ?? true);
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quem gastou?
            const Text(
              'Quem realizou esta compra?',
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
                              fontSize: 13,
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

            // Categoria
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
              height: 44,
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                          Text(cat.emoji, style: const TextStyle(fontSize: 15)),
                          const SizedBox(width: 6),
                          Text(
                            cat.name,
                            style: TextStyle(
                              fontSize: 12,
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
            const SizedBox(height: 24),

            // Botão Confirmar
            ElevatedButton.icon(
              onPressed: _saveTransaction,
              icon: const Icon(Icons.check_circle_rounded),
              label: Text(
                _isInstallment
                    ? 'Cadastrar Compra (${_installmentsCount}x de ${CurrencyFormatter.format(installmentValue)})'
                    : 'Cadastrar Despesa (${CurrencyFormatter.format(widget.detection.amount)})',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 8),

            // Botão Ignorar
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ignorar esta notificação', style: TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}
