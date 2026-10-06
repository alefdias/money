import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/connected_account.dart';
import '../../services/card_notification_service.dart';
import '../modals/card_transaction_detected_modal.dart';

class ConnectedAccountsScreen extends StatefulWidget {
  const ConnectedAccountsScreen({super.key});

  @override
  State<ConnectedAccountsScreen> createState() => _ConnectedAccountsScreenState();
}

class _ConnectedAccountsScreenState extends State<ConnectedAccountsScreen> {
  bool _isServiceEnabled = true;
  bool _hasAndroidPermission = false;
  final List<ConnectedAccount> _accounts = ConnectedAccount.defaultCards();

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final granted = await CardNotificationService.instance.isPermissionGranted();
    if (mounted) {
      setState(() {
        _hasAndroidPermission = granted;
        _isServiceEnabled = CardNotificationService.instance.isListening;
      });
    }
  }

  Future<void> _requestPermission() async {
    final granted = await CardNotificationService.instance.requestPermission();
    if (mounted) {
      setState(() {
        _hasAndroidPermission = granted;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            granted
                ? 'Permissão de notificação concedida com sucesso!'
                : 'Por favor, autorize o Money nas configurações de acesso a notificações do Android.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showAddCardDialog() {
    final bankCtrl = TextEditingController(text: 'Nubank');
    final digitsCtrl = TextEditingController();
    String type = 'Crédito';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Conectar Novo Cartão'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bankCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome do Banco / Cartão',
                  hintText: 'Ex: Nubank, C6, Santander...',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: digitsCtrl,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(
                  labelText: 'Últimos 4 dígitos (opcional)',
                  hintText: '1234',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(labelText: 'Tipo de Cartão'),
                items: ['Crédito', 'Débito', 'Múltiplo'].map((t) {
                  return DropdownMenuItem(value: t, child: Text(t));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setDlgState(() => type = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (bankCtrl.text.trim().isNotEmpty) {
                  setState(() {
                    _accounts.add(
                      ConnectedAccount(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        bankName: bankCtrl.text.trim(),
                        cardTitle: '${bankCtrl.text.trim()} Card',
                        lastFourDigits: digitsCtrl.text.trim().isEmpty ? '0000' : digitsCtrl.text.trim(),
                        cardType: type,
                        brandColor: AppColors.primary,
                        emoji: '💳',
                      ),
                    );
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Conectar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTestNotificationSimulator() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              const Text(
                'Simular Passagem de Cartão',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Selecione uma compra abaixo para simular a chegada de uma notificação bancária e testar o cadastro automático com pergunta de parcelamento:',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              _buildSimulatorTile(
                bank: 'Nubank',
                store: 'Mercado Livre',
                amount: 329.90,
                icon: Icons.shopping_bag_rounded,
                color: const Color(0xFF820AD1),
              ),
              const SizedBox(height: 8),
              _buildSimulatorTile(
                bank: 'Itaú',
                store: 'Supermercado Pão de Açúcar',
                amount: 184.50,
                icon: Icons.local_grocery_store_rounded,
                color: const Color(0xFFEC7000),
              ),
              const SizedBox(height: 8),
              _buildSimulatorTile(
                bank: 'Banco Inter',
                store: 'Posto Shell Combustíveis',
                amount: 95.00,
                icon: Icons.local_gas_station_rounded,
                color: const Color(0xFFFF7A00),
              ),
              const SizedBox(height: 8),
              _buildSimulatorTile(
                bank: 'C6 Bank',
                store: 'iFood Restaurante',
                amount: 48.00,
                icon: Icons.restaurant_rounded,
                color: const Color(0xFF242424),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSimulatorTile({
    required String bank,
    required String store,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        CardNotificationService.instance.simulateCardTransaction(
          bankName: bank,
          merchant: store,
          amount: amount,
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  Text(
                    'Notificação de $bank',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Text(
              CurrencyFormatter.format(amount),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recentDetections = CardNotificationService.instance.recentDetections;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Contas & Cartões Conectados'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _hasAndroidPermission
                      ? [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)]
                      : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _hasAndroidPermission ? const Color(0xFF86EFAC) : const Color(0xFFFCD34D),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _hasAndroidPermission ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                        color: _hasAndroidPermission ? AppColors.primaryDark : const Color(0xFFD97706),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _hasAndroidPermission
                            ? 'Leitor de Cartão em Tempo Real Ativo'
                            : 'Permissão de Notificação Pendente',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _hasAndroidPermission ? AppColors.primaryDark : const Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _hasAndroidPermission
                        ? 'Toda vez que você passar o cartão no Nubank, Itaú, Inter ou outros bancos e a notificação chegar, o Money detectará a compra, perguntará se é parcelada e em quantas vezes para cadastrar na hora!'
                        : 'Para que o Money detecte as passagens de cartão dos seus bancos automaticamente, é necessário conceder acesso às notificações no Android.',
                    style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  if (!_hasAndroidPermission)
                    ElevatedButton.icon(
                      onPressed: _requestPermission,
                      icon: const Icon(Icons.security_rounded, size: 18),
                      label: const Text('Ativar Acesso a Notificações no Android'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD97706),
                        foregroundColor: Colors.white,
                      ),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sincronização Automática',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        Switch(
                          value: _isServiceEnabled,
                          activeColor: AppColors.primary,
                          onChanged: (val) async {
                            await CardNotificationService.instance.setEnabled(val);
                            setState(() => _isServiceEnabled = val);
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Botão Simular Notificação de Teste
            OutlinedButton.icon(
              onPressed: _showTestNotificationSimulator,
              icon: const Icon(Icons.flash_on_rounded, color: AppColors.primary),
              label: const Text(
                'Testar Passagem de Cartão (Simulador)',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 24),

            // Cartões Conectados
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Cartões & Bancos da Família',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showAddCardDialog,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Adicionar'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ..._accounts.map((account) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: account.brandColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(account.emoji, style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.cardTitle,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${account.bankName} • ${account.cardType} • Final ${account.lastFourDigits}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Monitorando',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),

            // Histórico de Notificações Detectadas
            const Text(
              'Últimas Compras Detectadas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            if (recentDetections.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Column(
                    children: const [
                      Icon(Icons.notifications_none_rounded, size: 36, color: AppColors.textTertiary),
                      SizedBox(height: 8),
                      Text(
                        'Nenhuma notificação capturada recentemente.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Use o botão de teste acima para simular!',
                        style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...recentDetections.map((detection) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.credit_card, color: AppColors.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detection.merchant,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            Text(
                              '${detection.bankName} • ${CurrencyFormatter.format(detection.amount)}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                        tooltip: 'Cadastrar manualmente',
                        onPressed: () {
                          CardTransactionDetectedModal.show(context, detection);
                        },
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
