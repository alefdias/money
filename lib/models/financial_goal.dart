class FinancialGoal {
  final String id;
  final String familyId;
  final String title;
  final double monthlyTarget;
  final double currentSaved;

  const FinancialGoal({
    required this.id,
    required this.familyId,
    required this.title,
    required this.monthlyTarget,
    this.currentSaved = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'title': title,
      'monthlyTarget': monthlyTarget,
      'currentSaved': currentSaved,
    };
  }

  factory FinancialGoal.fromMap(Map<String, dynamic> map, {String? id}) {
    return FinancialGoal(
      id: id ?? map['id'] ?? '',
      familyId: map['familyId'] ?? '',
      title: map['title'] ?? 'Reserva Familiar',
      monthlyTarget: (map['monthlyTarget'] as num?)?.toDouble() ?? 1000.0,
      currentSaved: (map['currentSaved'] as num?)?.toDouble() ?? 0.0,
    );
  }

  FinancialGoal copyWith({
    String? id,
    String? familyId,
    String? title,
    double? monthlyTarget,
    double? currentSaved,
  }) {
    return FinancialGoal(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      title: title ?? this.title,
      monthlyTarget: monthlyTarget ?? this.monthlyTarget,
      currentSaved: currentSaved ?? this.currentSaved,
    );
  }
}
