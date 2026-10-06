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
  final bool isInstallment;
  final int installmentsCount;
  final int installmentNumber;
  final String? installmentGroupId;

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
    this.isInstallment = false,
    this.installmentsCount = 1,
    this.installmentNumber = 1,
    this.installmentGroupId,
  });

  String get installmentLabel {
    if (!isInstallment || installmentsCount <= 1) return '';
    return '($installmentNumber/${installmentsCount}x)';
  }

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
      'isInstallment': isInstallment,
      'installmentsCount': installmentsCount,
      'installmentNumber': installmentNumber,
      'installmentGroupId': installmentGroupId,
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
      isInstallment: map['isInstallment'] ?? false,
      installmentsCount: (map['installmentsCount'] as num?)?.toInt() ?? 1,
      installmentNumber: (map['installmentNumber'] as num?)?.toInt() ?? 1,
      installmentGroupId: map['installmentGroupId'],
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
    bool? isInstallment,
    int? installmentsCount,
    int? installmentNumber,
    String? installmentGroupId,
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
      isInstallment: isInstallment ?? this.isInstallment,
      installmentsCount: installmentsCount ?? this.installmentsCount,
      installmentNumber: installmentNumber ?? this.installmentNumber,
      installmentGroupId: installmentGroupId ?? this.installmentGroupId,
    );
  }
}
