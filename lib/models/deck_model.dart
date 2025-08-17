class DeckModel {
  final String? id;
  final String? userId;
  final String? deckName;
  final DateTime? createdAt;

  DeckModel({
    this.id,
    this.userId,
    this.deckName,
    this.createdAt,
  });

  // factory DeckModel.fromMap(Map<String, dynamic> map) {
  //   return DeckModel(
  //     id: map['id'],
  //     userId: map['user_id'],
  //     deckName: map['deck_name'],
  //     createdAt: map['created_at'] != null
  //         ? DateTime.parse(map['created_at'])
  //         : null,
  //   );
  // }

  factory DeckModel.fromMap(Map<String, dynamic> json) {
    return DeckModel(
      id: json['id'],
      userId: json['user_id'],
      deckName: json['deck_name'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  // Map<String, dynamic> toMap() {
  //   return {
  //     'id': id,
  //     'deck_name': deckName,
  //     'user_id': userId,
  //     'created_at': createdAt?.toIso8601String(),
  //   };
  // }

  Map<String, dynamic> toMap() {
    final data = {
      'user_id': userId,
      'deck_name': deckName,
      'created_at': createdAt?.toIso8601String(),
    };

    if (id != null) {
      data['id'] = id;
    }

    return data;
  }

  DeckModel copyWith({
    String? id,
    String? userId,
    String? deckName,
    DateTime? createdAt,
  }) {
    return DeckModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deckName: deckName ?? this.deckName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
