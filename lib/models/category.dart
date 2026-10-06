import 'package:flutter/material.dart';

class ExpenseCategory {
  final String id;
  final String name;
  final String emoji;
  final int colorValue;

  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.colorValue,
  });

  Color get color => Color(colorValue);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'colorValue': colorValue,
    };
  }

  factory ExpenseCategory.fromMap(Map<String, dynamic> map, {String? id}) {
    return ExpenseCategory(
      id: id ?? map['id'] ?? '',
      name: map['name'] ?? '',
      emoji: map['emoji'] ?? '📌',
      colorValue: map['colorValue'] ?? 0xFF64748B,
    );
  }

  static const List<ExpenseCategory> defaultCategories = [
    ExpenseCategory(id: 'food', name: 'Alimentação', emoji: '🛒', colorValue: 0xFFF97316),
    ExpenseCategory(id: 'home', name: 'Casa', emoji: '🏠', colorValue: 0xFF0EA5E9),
    ExpenseCategory(id: 'transport', name: 'Transporte', emoji: '🚗', colorValue: 0xFF3B82F6),
    ExpenseCategory(id: 'fuel', name: 'Combustível', emoji: '⛽', colorValue: 0xFFEF4444),
    ExpenseCategory(id: 'health', name: 'Saúde', emoji: '💊', colorValue: 0xFFEC4899),
    ExpenseCategory(id: 'leisure', name: 'Lazer', emoji: '🎮', colorValue: 0xFFA855F7),
    ExpenseCategory(id: 'clothing', name: 'Roupas', emoji: '👕', colorValue: 0xFF8B5CF6),
    ExpenseCategory(id: 'subscriptions', name: 'Assinaturas', emoji: '📱', colorValue: 0xFF06B6D4),
    ExpenseCategory(id: 'debts', name: 'Dívidas', emoji: '💳', colorValue: 0xFFF43F5E),
    ExpenseCategory(id: 'education', name: 'Educação', emoji: '🎓', colorValue: 0xFF10B981),
    ExpenseCategory(id: 'pets', name: 'Animais', emoji: '🐶', colorValue: 0xFFD97706),
    ExpenseCategory(id: 'gifts', name: 'Presentes', emoji: '🎁', colorValue: 0xFFF472B6),
    ExpenseCategory(id: 'shopping', name: 'Compras', emoji: '📦', colorValue: 0xFFEAB308),
    ExpenseCategory(id: 'others', name: 'Outros', emoji: '📌', colorValue: 0xFF64748B),
  ];

  static ExpenseCategory findById(String id) {
    return defaultCategories.firstWhere(
      (cat) => cat.id == id,
      orElse: () => defaultCategories.last,
    );
  }
}
