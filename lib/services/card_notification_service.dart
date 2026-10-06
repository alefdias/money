import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/connected_account.dart';

class CardNotificationService {
  CardNotificationService._internal();
  static final CardNotificationService instance = CardNotificationService._internal();

  final _uuid = const Uuid();
  final _detectionController = StreamController<CardTransactionDetection>.broadcast();
  Stream<CardTransactionDetection> get onTransactionDetected => _detectionController.stream;

  final List<CardTransactionDetection> _recentDetections = [];
  List<CardTransactionDetection> get recentDetections => List.unmodifiable(_recentDetections);

  bool _isListening = false;
  bool get isListening => _isListening;

  StreamSubscription? _systemSubscription;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('card_sync_enabled') ?? true;
    if (enabled) {
      await startListening();
    }
  }

  Future<bool> isPermissionGranted() async {
    try {
      return await NotificationListenerService.isPermissionGranted();
    } catch (e) {
      debugPrint('Error checking notification permission: $e');
      return false;
    }
  }

  Future<bool> requestPermission() async {
    try {
      return await NotificationListenerService.requestPermission();
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return false;
    }
  }

  Future<void> setEnabled(bool enable) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('card_sync_enabled', enable);

    if (enable) {
      await startListening();
    } else {
      await stopListening();
    }
  }

  Future<void> startListening() async {
    if (_isListening) return;

    try {
      _systemSubscription?.cancel();
      _systemSubscription = NotificationListenerService.notificationsStream.listen(
        (event) {
          final title = event.title;
          final content = event.content;
          final packageName = event.packageName;

          final detection = parseNotification(
            title: title,
            content: content,
            packageName: packageName,
          );

          if (detection != null) {
            _handleDetection(detection);
          }
        },
        onError: (err) {
          debugPrint('NotificationListenerService error: $err');
        },
      );
      _isListening = true;
    } catch (e) {
      debugPrint('Could not initialize NotificationListenerService: $e');
      _isListening = false;
    }
  }

  Future<void> stopListening() async {
    await _systemSubscription?.cancel();
    _systemSubscription = null;
    _isListening = false;
  }

  void _handleDetection(CardTransactionDetection detection) {
    // Avoid exact duplicate within 15 seconds
    final isDuplicate = _recentDetections.any((d) =>
        d.merchant == detection.merchant &&
        d.amount == detection.amount &&
        d.timestamp.difference(detection.timestamp).inSeconds.abs() < 15);

    if (isDuplicate) return;

    _recentDetections.insert(0, detection);
    if (_recentDetections.length > 30) {
      _recentDetections.removeLast();
    }

    _detectionController.add(detection);
  }

  /// Parser inteligente para notificações de bancos brasileiros
  CardTransactionDetection? parseNotification({
    required String title,
    required String content,
    String packageName = '',
  }) {
    final fullText = '$title $content'.toLowerCase();

    // Palavras-chave que indicam passagem de cartão / transação bancária
    final isCardTransaction = fullText.contains('compra') ||
        fullText.contains('aprovada') ||
        fullText.contains('cartão') ||
        fullText.contains('cartao') ||
        fullText.contains('transação') ||
        fullText.contains('transacao') ||
        fullText.contains('pagamento aprovado') ||
        fullText.contains('compra no');

    if (!isCardTransaction) return null;

    // Extrair Valor monetário (ex: R$ 123,45 ou 123,45)
    final amountRegex = RegExp(r'r\$\s*([0-9]+(?:[\.,][0-9]{2,3})*(?:[\.,][0-9]{2}))', caseSensitive: false);
    final match = amountRegex.firstMatch(fullText);

    double? parsedAmount;
    if (match != null) {
      final rawNum = match.group(1)!;
      // Normalizar número brasileiro (trocar ponto por vazio e vírgula por ponto)
      final normalized = rawNum.contains(',')
          ? rawNum.replaceAll('.', '').replaceAll(',', '.')
          : rawNum;
      parsedAmount = double.tryParse(normalized);
    }

    if (parsedAmount == null || parsedAmount <= 0) {
      return null;
    }

    // Identificar Banco
    String bank = 'Cartão de Banco';
    if (packageName.contains('nu') || fullText.contains('nubank') || fullText.contains('roxinho')) {
      bank = 'Nubank';
    } else if (packageName.contains('itau') || fullText.contains('itaú') || fullText.contains('itau')) {
      bank = 'Itaú';
    } else if (packageName.contains('inter') || fullText.contains('inter')) {
      bank = 'Banco Inter';
    } else if (packageName.contains('bradesco') || fullText.contains('bradesco')) {
      bank = 'Bradesco';
    } else if (packageName.contains('santander') || fullText.contains('santander')) {
      bank = 'Santander';
    } else if (packageName.contains('c6') || fullText.contains('c6 bank') || fullText.contains('c6bank')) {
      bank = 'C6 Bank';
    } else if (packageName.contains('picpay') || fullText.contains('picpay')) {
      bank = 'PicPay';
    } else if (packageName.contains('caixa') || fullText.contains('caixa')) {
      bank = 'Caixa';
    }

    // Extrair Estabelecimento / Loja
    String merchant = 'Estabelecimento';
    final merchantRegex = RegExp(r'(?:em|no|na)\s+([A-Za-z0-9\s\.\-_&]{3,35})(?:[\.,\n]|$)', caseSensitive: false);
    final merchantMatch = merchantRegex.firstMatch('$title $content');
    if (merchantMatch != null) {
      final rawMerchant = merchantMatch.group(1)!.trim();
      if (!rawMerchant.toLowerCase().contains('cartao') &&
          !rawMerchant.toLowerCase().contains('cartão') &&
          !rawMerchant.toLowerCase().contains('valor')) {
        merchant = rawMerchant;
      }
    }

    // Detectar parcelamento mencionado no texto (ex: 3x, 10x, em 6 vezes)
    int? detectedInstallments;
    final installmentRegex = RegExp(r'(\d{1,2})\s*(?:x|vezes)', caseSensitive: false);
    final instMatch = installmentRegex.firstMatch(fullText);
    if (instMatch != null) {
      detectedInstallments = int.tryParse(instMatch.group(1)!);
    }

    // Sugerir Categoria
    final categoryId = _categorizeMerchant(merchant, fullText);

    return CardTransactionDetection(
      id: _uuid.v4(),
      bankName: bank,
      merchant: merchant,
      amount: parsedAmount,
      rawText: '$title - $content',
      timestamp: DateTime.now(),
      suggestedCategoryId: categoryId,
      paymentMethod: 'Cartão de Crédito',
      detectedInstallments: detectedInstallments,
    );
  }

  String _categorizeMerchant(String merchant, String fullText) {
    final text = '$merchant $fullText'.toLowerCase();
    if (text.contains('mercado livre')) {
      return 'others';
    }
    if ((text.contains('mercado') && !text.contains('livre')) ||
        text.contains('supermercado') ||
        text.contains('padaria') ||
        text.contains('restaurante') ||
        text.contains('ifood') ||
        text.contains('burger') ||
        text.contains('pizza') ||
        text.contains('lanchonete') ||
        text.contains('acougue') ||
        text.contains('açougue')) {
      return 'food';
    }
    if (text.contains('uber') ||
        text.contains('99') ||
        text.contains('posto') ||
        text.contains('gasolina') ||
        text.contains('combustivel') ||
        text.contains('combustível') ||
        text.contains('shell') ||
        text.contains('ipiranga') ||
        text.contains('estacionamento')) {
      return 'transport';
    }
    if (text.contains('drogaria') ||
        text.contains('farmacia') ||
        text.contains('farmácia') ||
        text.contains('raia') ||
        text.contains('drogasil') ||
        text.contains('consulta') ||
        text.contains('hospital') ||
        text.contains('saude') ||
        text.contains('saúde')) {
      return 'health';
    }
    if (text.contains('cinema') ||
        text.contains('netflix') ||
        text.contains('spotify') ||
        text.contains('show') ||
        text.contains('ingresso') ||
        text.contains('bar') ||
        text.contains('jogos') ||
        text.contains('steam')) {
      return 'leisure';
    }
    if (text.contains('luz') ||
        text.contains('energia') ||
        text.contains('enel') ||
        text.contains('agua') ||
        text.contains('água') ||
        text.contains('internet') ||
        text.contains('claro') ||
        text.contains('vivo') ||
        text.contains('tim') ||
        text.contains('condominio') ||
        text.contains('aluguel')) {
      return 'housing';
    }
    return 'others';
  }

  /// Permite simular a passagem de cartão e notificação bancária a qualquer momento
  void simulateCardTransaction({
    required String bankName,
    required String merchant,
    required double amount,
    String? cardLastDigits,
    int? installments,
  }) {
    final detection = CardTransactionDetection(
      id: _uuid.v4(),
      bankName: bankName,
      cardLastDigits: cardLastDigits ?? '8842',
      merchant: merchant,
      amount: amount,
      rawText: 'Compra aprovada de R\$ ${amount.toStringAsFixed(2)} em $merchant',
      timestamp: DateTime.now(),
      suggestedCategoryId: _categorizeMerchant(merchant, ''),
      paymentMethod: 'Cartão de Crédito',
      detectedInstallments: installments,
    );

    _handleDetection(detection);
  }
}
