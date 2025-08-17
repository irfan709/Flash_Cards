import 'package:flash_cards/models/flash_card_model.dart';

class FlashCardDataState {
  final List<FlashCardModel> flashcards;
  final bool isLoading;
  final String? error;

  const FlashCardDataState({
    this.flashcards = const [],
    this.isLoading = false,
    this.error,
  });

  FlashCardDataState copyWith({
    List<FlashCardModel>? flashcards,
    bool? isLoading,
    String? error,
  }) {
    return FlashCardDataState(
      flashcards: flashcards ?? this.flashcards,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  factory FlashCardDataState.initial() {
    return const FlashCardDataState(
      flashcards: [],
      isLoading: false,
      error: null,
    );
  }
}
