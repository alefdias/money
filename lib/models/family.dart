class Family {
  final String id;
  final String name;
  final String inviteCode;
  final List<String> memberIds;
  final DateTime createdAt;

  const Family({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.memberIds,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'inviteCode': inviteCode,
      'memberIds': memberIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Family.fromMap(Map<String, dynamic> map, {String? id}) {
    return Family(
      id: id ?? map['id'] ?? '',
      name: map['name'] ?? 'Nossa Família',
      inviteCode: map['inviteCode'] ?? '',
      memberIds: List<String>.from(map['memberIds'] ?? []),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
