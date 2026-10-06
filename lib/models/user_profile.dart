class UserProfile {
  final String id;
  final String name;
  final String email;
  final String avatarEmoji;
  final String? familyId;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarEmoji,
    this.familyId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarEmoji': avatarEmoji,
      'familyId': familyId,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, {String? id}) {
    return UserProfile(
      id: id ?? map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      avatarEmoji: map['avatarEmoji'] ?? '👤',
      familyId: map['familyId'],
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarEmoji,
    String? familyId,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      familyId: familyId ?? this.familyId,
    );
  }
}
