import 'package:flutter/material.dart';

class ConnectedAccount {
  final String id;
  final String bankName;
  final String cardTitle;
  final String lastFourDigits;
  final String cardType; // 'Crédito', 'Débito', 'Múltiplo'
  final Color brandColor;
  final String emoji;
  final bool isSyncEnabled;
  final String packageIdentifier;

  const ConnectedAccount({
    required this.id,
    required this.bankName,
    required this.cardTitle,
    required this.lastFourDigits,
    required this.cardType,
    required this.brandColor,
    required this.emoji,
    this.isSyncEnabled = true,
    this.packageIdentifier = '',
  });

  static List<ConnectedAccount> defaultCards() {
    return [
      const ConnectedAccount(
        id: 'nubank_main',
        bankName: 'Nubank',
        cardTitle: 'Roxinho Principal',
        lastFourDigits: '8842',
        cardType: 'Crédito',
        brandColor: Color(0xFF820AD1),
        emoji: '💜',
        isSyncEnabled: true,
        packageIdentifier: 'com.nu.production',
      ),
      const ConnectedAccount(
        id: 'itau_card',
        bankName: 'Itaú',
        cardTitle: 'Itaú Click',
        lastFourDigits: '3410',
        cardType: 'Crédito',
        brandColor: Color(0xFFEC7000),
        emoji: '🧡',
        isSyncEnabled: true,
        packageIdentifier: 'com.itau',
      ),
      const ConnectedAccount(
        id: 'inter_card',
        bankName: 'Banco Inter',
        cardTitle: 'Inter Gold',
        lastFourDigits: '9012',
        cardType: 'Múltiplo',
        brandColor: Color(0xFFFF7A00),
        emoji: '💳',
        isSyncEnabled: true,
        packageIdentifier: 'br.com.intermedium',
      ),
    ];
  }
}

class CardTransactionDetection {
  final String id;
  final String bankName;
  final String? cardLastDigits;
  final String merchant;
  final double amount;
  final String rawText;
  final DateTime timestamp;
  final String suggestedCategoryId;
  final String paymentMethod;
  final int? detectedInstallments;

  const CardTransactionDetection({
    required this.id,
    required this.bankName,
    this.cardLastDigits,
    required this.merchant,
    required this.amount,
    required this.rawText,
    required this.timestamp,
    required this.suggestedCategoryId,
    this.paymentMethod = 'Cartão de Crédito',
    this.detectedInstallments,
  });
}
