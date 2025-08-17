import '../models/deck_model.dart';

class DeckState {
  final List<DeckModel> decks;
  final bool isLoading;
  final String? error;

  DeckState({required this.decks, required this.isLoading, this.error});

  DeckState copyWith({List<DeckModel>? decks, bool? isLoading, String? error}) {
    return DeckState(
      decks: decks ?? this.decks,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  factory DeckState.initial() {
    return DeckState(decks: [], isLoading: false, error: null);
  }
}
