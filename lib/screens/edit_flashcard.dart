import 'package:flash_cards/provider/flashcard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/flash_card_model.dart';

class EditFlashcard extends ConsumerStatefulWidget {
  final FlashCardModel? flashcard;
  final String? deckId;

  const EditFlashcard({super.key, this.flashcard, this.deckId});

  @override
  ConsumerState<EditFlashcard> createState() => _EditFlashcardState();
}

class _EditFlashcardState extends ConsumerState<EditFlashcard> {
  late final TextEditingController _frontTextController;
  late final TextEditingController _backTextController;

  @override
  void initState() {
    super.initState();

    _frontTextController = TextEditingController(
      text: widget.flashcard?.frontText ?? '',
    );
    _backTextController = TextEditingController(
      text: widget.flashcard?.backText ?? '',
    );
  }

  @override
  void dispose() {
    _frontTextController.dispose();
    _backTextController.dispose();
    super.dispose();
  }

  Future<void> _saveFlashcard() async {
    final frontText = _frontTextController.text.trim();
    final backText = _backTextController.text.trim();

    if (frontText.isEmpty || backText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Both sides must be filled')),
      );
      return;
    }

    if (widget.flashcard == null) {
      if (widget.deckId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Deck ID is missing')));
        return;
      }
      final flashcard = FlashCardModel(
        deckId: widget.deckId ?? '',
        frontText: frontText,
        backText: backText,
        imageUrl: widget.flashcard?.imageUrl ?? '',
        createdAt: widget.flashcard?.createdAt ?? DateTime.now(),
      );

      await ref.read(flashCardStateProvider.notifier).addFlashCard(flashcard);
    } else {
      final flashcard = FlashCardModel(
        id: widget.flashcard?.id,
        deckId: widget.flashcard?.deckId ?? '',
        frontText: frontText,
        backText: backText,
        imageUrl: widget.flashcard?.imageUrl ?? '',
        createdAt: widget.flashcard?.createdAt ?? DateTime.now(),
      );

      await ref
          .read(flashCardStateProvider.notifier)
          .updateFlashCard(flashcard);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.flashcard != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Card" : "New Card"),
        actions: [
          IconButton(onPressed: _saveFlashcard, icon: const Icon(Icons.save)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _frontTextController,
              decoration: const InputDecoration(
                labelText: 'Front Text',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _backTextController,
              decoration: const InputDecoration(
                labelText: 'Back Text',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
