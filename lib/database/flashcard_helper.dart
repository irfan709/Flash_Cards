import 'package:flash_cards/models/flash_card_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A helper class for performing CRUD operations on the 'flashcards' table
/// with ownership verification enforced by RLS and pre-check queries.
class FlashCardHelper {
  final SupabaseClient _client;

  FlashCardHelper({required SupabaseClient client}) : _client = client;

  /// Fetch all flashcards for a given deck owned by the current user.
  // Future<List<FlashCardModel>> getFlashCards(String deckId) async {
  //   final userId = _client.auth.currentUser?.id;
  //   if (userId == null) throw Exception("User not authenticated");
  //
  //   final response = await _client
  //       .from("flashcards")
  //       // Select all columns from flashcards and also join with decks to check ownership
  //       .select('*, decks!inner(user_id)')
  //       .eq('deck_id', deckId)
  //       .eq(
  //         'decks.user_id',
  //         userId,
  //       ) // Ensures only current user's deck flashcards are returned
  //       .order('created_at');
  //
  //   final data = response as List;
  //   return data.map((item) => FlashCardModel.fromMap(item)).toList();
  // }

  Stream<List<FlashCardModel>> getFlashCards(String deckId) {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return Stream.value([]);
    }

    return _client
        .from("flashcards")
        .stream(primaryKey: ['id'])
        .eq('deck_id', deckId)
        .order('created_at')
        .map((data) => data
        .map((item) => FlashCardModel.fromMap(item))
        .toList());
  }

  /// Add a new flashcard to a deck that the current user owns.
  Future<void> addFlashCard(FlashCardModel flashCard) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception("User not authenticated");

    // Check if the deck exists and is owned by the current user
    final deckCheck =
        await _client
            .from('decks')
            .select('id')
            .eq('id', flashCard.deckId)
            .eq('user_id', userId)
            .maybeSingle();

    if (deckCheck == null) {
      throw Exception("Unauthorized: You don't have access to this deck");
    }

    // Insert flashcard
    await _client.from('flashcards').insert(flashCard.toMap());
  }

  /// Update an existing flashcard that belongs to the current user.
  Future<void> updateFlashCard(FlashCardModel flashcard) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception("User not authenticated");

    // ✅ BUG FIX:
    // We now check using flashcard.id (previously used deckId by mistake)
    final check =
        await _client
            .from("flashcards")
            .select('deck_id, decks!inner(user_id)')
            .eq(
              'id',
              flashcard.id!,
            ) // Check ownership of this specific flashcard
            .eq('decks.user_id', userId)
            .maybeSingle();

    if (check == null) {
      throw Exception("Unauthorized: You don't have access to this deck");
    }

    // Perform the update
    await _client
        .from('flashcards')
        .update(flashcard.toMap())
        .eq('id', flashcard.id!);
  }

  /// Delete a flashcard if it belongs to the current user.
  Future<void> deleteFlashCard(String flashcardId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception("User not authenticated");

    // Check ownership
    final check =
        await _client
            .from('flashcards')
            .select('deck_id, decks!inner(user_id)')
            .eq('id', flashcardId)
            .maybeSingle();

    if (check == null) {
      throw Exception("Unauthorized: You don't have access to this deck");
    }

    // Delete the flashcard
    await _client.from('flashcards').delete().eq('id', flashcardId);
  }
}
