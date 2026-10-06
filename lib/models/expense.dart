class Expense {
  final String id;
  final String familyId;
  final String userId;
  final String userName;
  final String description;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String paymentMethod;
  final String? notes;

  const Expense({
    required this.id,
    required this.familyId,
    required this.userId,
    required this.userName,
    required this.description,
    required this.amount,
    required this.categoryId,
    required this.date,
    required this.paymentMethod,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'userId': userId,
      'userName': userName,
      'description': description,
      'amount': amount,
      'categoryId': categoryId,
      'date': date.toIso8601String(),
      'paymentMethod': paymentMethod,
      'notes': notes,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map, {String? id}) {
    return Expense(
      id: id ?? map['id'] ?? '',
      familyId: map['familyId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Membro',
      description: map['description'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      categoryId: map['categoryId'] ?? 'others',
      date: map['date'] != null
          ? DateTime.tryParse(map['date']) ?? DateTime.now()
          : DateTime.now(),
      paymentMethod: map['paymentMethod'] ?? 'Pix',
      notes: map['notes'],
    );
  }

  Expense copyWith({
    String? id,
    String? familyId,
    String? userId,
    String? userName,
    String? description,
    double? amount,
    String? categoryId,
    DateTime? date,
    String? paymentMethod,
    String? notes,
  }) {
    return Expense(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
    );
  }
}
