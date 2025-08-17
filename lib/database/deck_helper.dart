import 'package:flash_cards/models/deck_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeckHelper {
  final SupabaseClient _client;

  DeckHelper({required SupabaseClient client}) : _client = client;

  // Future<List<DeckModel>> getDecks() async {
  //   final userId = _client.auth.currentUser?.id;
  //   if (userId == null) throw Exception("User not authenticated");
  //
  //   final response = await _client
  //       .from('decks')
  //       .select()
  //       .eq('user_id', userId)
  //       .order('created_at', ascending: false);
  //
  //   final data = response as List;
  //   return data.map((item) => DeckModel.fromMap(item)).toList();
  // }

  Stream<List<DeckModel>> getDecks() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return Stream.value([]);
    }

    return _client
        .from('decks')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data.map((item) => DeckModel.fromMap(item)).toList());
  }

  Future<void> addDeck(DeckModel deck) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception("User not authenticated");

    await _client.from('decks').insert(deck.toMap());
  }

  Future<void> updateDeck(DeckModel deck) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception("User not authenticated");

    final check =
        await _client
            .from('decks')
            .select('user_id')
            .eq('id', deck.id as Object)
            .eq('user_id', userId)
            .maybeSingle();

    if (check == null) {
      throw Exception("Unauthorized: You cannot update this deck");
    }

    await _client
        .from('decks')
        .update(deck.toMap())
        .eq('id', deck.id as Object);
  }

  Future<void> deleteDeck(String deckId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception("User not authenticated");

    final check =
        await _client
            .from('decks')
            .select('user_id')
            .eq('id', deckId)
            .eq('user_id', userId)
            .maybeSingle();

    if (check == null) {
      throw Exception("Unauthorized: You cannot update this deck");
    }

    await _client.from('decks').delete().eq('id', deckId);
  }
}
