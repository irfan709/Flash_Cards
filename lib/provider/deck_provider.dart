import 'package:flash_cards/database/deck_helper.dart';
import 'package:flash_cards/models/deck_model.dart';
import 'package:flash_cards/provider/deck_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeckProvider extends StateNotifier<DeckState> {
  final DeckHelper deckHelper;

  DeckProvider(this.deckHelper) : super(DeckState.initial());

  Stream<List<DeckModel>> getDecks() {
    return deckHelper.getDecks();
  }

  // Future<void> addDeck(DeckModel deck) async {
  //   state = state.copyWith(isLoading: true, error: null);
  //
  //   try {
  //     await deckHelper.addDeck(deck);
  //   } catch (e) {
  //     state = state.copyWith(isLoading: false, error: e.toString());
  //   } finally {
  //     state = state.copyWith(isLoading: false);
  //   }
  // }

  Future<void> addDeck(DeckModel deck) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await deckHelper.addDeck(deck);
      debugPrint('✅ Deck added: ${deck.deckName}');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      debugPrint('❌ Error adding deck: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updateDeck(DeckModel deck) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await deckHelper.updateDeck(deck);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> deleteDeck(String deckId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await deckHelper.deleteDeck(deckId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final deckHelperProvider = Provider((ref) {
  final client = ref.read(supabaseClientProvider);
  return DeckHelper(client: client);
});

final deckStateProvider = StateNotifierProvider<DeckProvider, DeckState>((ref) {
  final deckHelper = ref.read(deckHelperProvider);
  return DeckProvider(deckHelper);
});

final decksStreamProvider = StreamProvider.autoDispose((ref) {
  final deckNotifier = ref.read(deckStateProvider.notifier);
  return deckNotifier.getDecks();
});
