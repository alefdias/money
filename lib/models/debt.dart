class Debt {
  final String id;
  final String familyId;
  final String title;
  final double installmentAmount;
  final int totalInstallments;
  final int paidInstallments;
  final int dueDay;

  const Debt({
    required this.id,
    required this.familyId,
    required this.title,
    required this.installmentAmount,
    required this.totalInstallments,
    required this.paidInstallments,
    required this.dueDay,
  });

  int get remainingInstallments => totalInstallments - paidInstallments;
  double get totalDebt => installmentAmount * totalInstallments;
  double get remainingDebt => installmentAmount * remainingInstallments;
  double get progress => totalInstallments > 0 ? (paidInstallments / totalInstallments).clamp(0.0, 1.0) : 1.0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'title': title,
      'installmentAmount': installmentAmount,
      'totalInstallments': totalInstallments,
      'paidInstallments': paidInstallments,
      'dueDay': dueDay,
    };
  }

  factory Debt.fromMap(Map<String, dynamic> map, {String? id}) {
    return Debt(
      id: id ?? map['id'] ?? '',
      familyId: map['familyId'] ?? '',
      title: map['title'] ?? '',
      installmentAmount: (map['installmentAmount'] as num?)?.toDouble() ?? 0.0,
      totalInstallments: map['totalInstallments'] ?? 1,
      paidInstallments: map['paidInstallments'] ?? 0,
      dueDay: map['dueDay'] ?? 10,
    );
  }

  Debt copyWith({
    String? id,
    String? familyId,
    String? title,
    double? installmentAmount,
    int? totalInstallments,
    int? paidInstallments,
    int? dueDay,
  }) {
    return Debt(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      title: title ?? this.title,
      installmentAmount: installmentAmount ?? this.installmentAmount,
      totalInstallments: totalInstallments ?? this.totalInstallments,
      paidInstallments: paidInstallments ?? this.paidInstallments,
      dueDay: dueDay ?? this.dueDay,
    );
  }
}
