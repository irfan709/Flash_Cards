import 'dart:math';
import 'package:flash_cards/screens/edit_flashcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flash_cards/models/deck_model.dart';
import 'package:flash_cards/provider/flashcard_provider.dart';

class CardScreen extends ConsumerStatefulWidget {
  final DeckModel deck;

  const CardScreen({super.key, required this.deck});

  @override
  ConsumerState<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends ConsumerState<CardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late PageController _pageController;

  bool isFront = true;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      isFront = !isFront;
    });
  }

  void _jumpToFlashcard(int index) {
    if (_pageController.hasClients) {
      _pageController.jumpToPage(index);
    }
  }

  Widget _frontCard(String question) {
    return _buildCard(text: question, color: Colors.blue);
  }

  Widget _backCard(String answer) {
    return _buildCard(text: answer, color: Colors.orange);
  }

  Widget _buildCard({required String text, required Color color}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      width: MediaQuery.of(context).size.width * 0.70,
      height: MediaQuery.of(context).size.height * 0.60,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(20),
      child: Text(
        text,
        style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flashcardStream =
        widget.deck.id != null
            ? ref.watch(flashCardsProvider(widget.deck.id!))
            : const AsyncValue.data([]);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deck.deckName ?? 'Deck'),
        actions: flashcardStream.maybeWhen(
          data:
              (flashcards) => [
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: () {
                    if (_currentPage + 1 < flashcards.length) {
                      _jumpToFlashcard(_currentPage + 1);
                    }
                  },
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => EditFlashcard(deckId: widget.deck.id),
                      ),
                    );
                  },
                  icon: Icon(Icons.add),
                ),
              ],
          orElse: () => [],
        ),
      ),
      body: flashcardStream.when(
        data: (flashcards) {
          if (flashcards.isEmpty) {
            return const Center(child: Text("No flashcards in this deck"));
          }

          return PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
                isFront = true;
                _controller.reset();
              });
            },
            itemCount: flashcards.length,
            itemBuilder: (context, index) {
              final flashcard = flashcards[index];

              return GestureDetector(
                onTap: _flipCard,
                onLongPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => EditFlashcard(
                            flashcard: flashcard,
                            deckId: widget.deck.id,
                          ),
                    ),
                  );
                },
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    final angle = _animation.value * pi;
                    final showFront = angle <= pi / 2;

                    return Transform(
                      alignment: Alignment.center,
                      transform:
                          Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(angle),
                      child:
                          showFront
                              ? _frontCard(flashcard.frontText)
                              : Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(pi),
                                child: _backCard(flashcard.backText),
                              ),
                    );
                  },
                ),
              );
            },
          );
        },
        error: (err, _) => Center(child: Text("Error: $err")),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
