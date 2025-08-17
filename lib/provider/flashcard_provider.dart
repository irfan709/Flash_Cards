import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flash_cards/database/flashcard_helper.dart';
import 'package:flash_cards/models/flash_card_model.dart';
import 'package:flash_cards/provider/flashcard_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FlashCardProvider extends StateNotifier<FlashCardDataState> {
  final FlashCardHelper flashCard;

  FlashCardProvider(this.flashCard) : super(FlashCardDataState.initial());

  Stream<List<FlashCardModel>> getFlashcards(String deckId) {
    return flashCard.getFlashCards(deckId);
  }

  Future<void> addFlashCard(FlashCardModel flashcard) async {
    debugPrint('🌟 Adding flashcard: ${flashcard.frontText} → ${flashcard.backText}');
    state = state.copyWith(isLoading: true, error: null);

    try {
      await flashCard.addFlashCard(flashcard);
      debugPrint('✅ Flashcard added successfully!');
    } catch (e) {
      state = state.copyWith(error: e.toString());
      debugPrint('❌ Error adding flashcard: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updateFlashCard(FlashCardModel flashcard) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await flashCard.updateFlashCard(flashcard);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> deleteFlashCard(String flashcardId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await flashCard.deleteFlashCard(flashcardId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final flashCardHelperProvider = Provider<FlashCardHelper>((ref) {
  final client = ref.read(supabaseClientProvider);
  return FlashCardHelper(client: client);
});

final flashCardStateProvider =
    StateNotifierProvider<FlashCardProvider, FlashCardDataState>((ref) {
      final link = ref.keepAlive();

      ref.onDispose(() {
        link.close();
      });
      final flashCardHelper = ref.read(flashCardHelperProvider);
      return FlashCardProvider(flashCardHelper);
    });

final flashCardsProvider = StreamProvider.family.autoDispose<List<FlashCardModel>, String>((
  ref,
  deckId,
) {
  final flashCardNotifier = ref.read(flashCardStateProvider.notifier);
  return flashCardNotifier.getFlashcards(deckId);
});

final flashcardCountProvider = FutureProvider.family<int, String>((
  ref,
  deckId,
) async {
  final helper = ref.read(flashCardHelperProvider);
  final stream = helper.getFlashCards(deckId);
  final flashcards = await stream.first;
  return flashcards.length;
});
