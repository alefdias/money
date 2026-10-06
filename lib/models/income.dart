class Income {
  final String id;
  final String familyId;
  final String userId;
  final String userName;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final bool isRecurring;

  const Income({
    required this.id,
    required this.familyId,
    required this.userId,
    required this.userName,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.isRecurring = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'userId': userId,
      'userName': userName,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'isRecurring': isRecurring,
    };
  }

  factory Income.fromMap(Map<String, dynamic> map, {String? id}) {
    return Income(
      id: id ?? map['id'] ?? '',
      familyId: map['familyId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Membro',
      title: map['title'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] ?? 'Salário',
      date: map['date'] != null
          ? DateTime.tryParse(map['date']) ?? DateTime.now()
          : DateTime.now(),
      isRecurring: map['isRecurring'] ?? true,
    );
  }
}
