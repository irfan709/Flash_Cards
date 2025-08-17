import 'package:flutter/material.dart';
import 'package:flash_cards/models/deck_model.dart';
import 'card_screen.dart';

class DeckPageViewScreen extends StatefulWidget {
  final List<DeckModel> decks;
  final int initialPage;

  const DeckPageViewScreen({
    super.key,
    required this.decks,
    required this.initialPage,
  });

  @override
  State<DeckPageViewScreen> createState() => _DeckPageViewScreenState();
}

class _DeckPageViewScreenState extends State<DeckPageViewScreen> {
  late PageController controller;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    controller = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final decks = widget.decks;

    return Scaffold(
      appBar: AppBar(
        title: Text(decks[_currentPage].deckName ?? ''),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: controller,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemCount: decks.length,
        itemBuilder: (context, index) => CardScreen(deck: decks[index]),
      ),
    );
  }
}
