class FixedExpense {
  final String id;
  final String familyId;
  final String name;
  final double amount;
  final int dueDay;
  final bool isPaid;
  final String? responsibleUserId;
  final String category;

  const FixedExpense({
    required this.id,
    required this.familyId,
    required this.name,
    required this.amount,
    required this.dueDay,
    this.isPaid = false,
    this.responsibleUserId,
    this.category = 'Contas Fixas',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'name': name,
      'amount': amount,
      'dueDay': dueDay,
      'isPaid': isPaid,
      'responsibleUserId': responsibleUserId,
      'category': category,
    };
  }

  factory FixedExpense.fromMap(Map<String, dynamic> map, {String? id}) {
    return FixedExpense(
      id: id ?? map['id'] ?? '',
      familyId: map['familyId'] ?? '',
      name: map['name'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      dueDay: map['dueDay'] ?? 10,
      isPaid: map['isPaid'] ?? false,
      responsibleUserId: map['responsibleUserId'],
      category: map['category'] ?? 'Contas Fixas',
    );
  }

  FixedExpense copyWith({
    String? id,
    String? familyId,
    String? name,
    double? amount,
    int? dueDay,
    bool? isPaid,
    String? responsibleUserId,
    String? category,
  }) {
    return FixedExpense(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      dueDay: dueDay ?? this.dueDay,
      isPaid: isPaid ?? this.isPaid,
      responsibleUserId: responsibleUserId ?? this.responsibleUserId,
      category: category ?? this.category,
    );
  }
}
