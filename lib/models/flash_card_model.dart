class FlashCardModel {
  final String? id;
  final String deckId;
  final String frontText;
  final String backText;
  final String? imageUrl;
  final DateTime? createdAt;

  FlashCardModel({
    this.id,
    required this.deckId,
    required this.frontText,
    required this.backText,
    this.imageUrl,
    this.createdAt,
  });

  factory FlashCardModel.fromMap(Map<String, dynamic> map) {
    return FlashCardModel(
      id: map['id'],
      deckId: map['deck_id'],
      frontText: map['front_text'],
      backText: map['back_text'],
      imageUrl: map['image_url'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  // Map<String, dynamic> toMap() {
  //   return {
  //     'id': id,
  //     'deck_id': deckId,
  //     'front_text': frontText,
  //     'back_text': backText,
  //     'image_url': imageUrl,
  //     'created_at': createdAt?.toIso8601String(),
  //   };
  // }

  Map<String, dynamic> toMap() {
    final map = {
      'deck_id': deckId,
      'front_text': frontText,
      'back_text': backText,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
    };
    if (id != null && id!.isNotEmpty) {
      map['id'] = id;
    }
    return map;
  }

  FlashCardModel copyWith({
    String? id,
    String? deckId,
    String? frontText,
    String? backText,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return FlashCardModel(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      frontText: frontText ?? this.frontText,
      backText: backText ?? this.backText,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
