import 'package:flash_cards/models/deck_model.dart';
import 'package:flash_cards/provider/deck_provider.dart';
import 'package:flash_cards/screens/card_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../provider/flashcard_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _openBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Add Flash Card",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                      _controller.clear();
                    },
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text("Choose your Deck name below:"),
              SizedBox(height: 8),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Deck name",
                ),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  final deckName = _controller.text.trim();
                  if (deckName.isEmpty) return;
                  final now = DateTime.now();

                  final user = Supabase.instance.client.auth.currentUser;

                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('⚠️ No user logged in')),
                    );
                    debugPrint('⚠️ No user logged in');
                    return;
                  }

                  await ref
                      .read(deckStateProvider.notifier)
                      .addDeck(
                        DeckModel(
                          deckName: deckName,
                          userId: user.id,
                          createdAt: now,
                        ),
                      );

                  if (!context.mounted) return;
                  Navigator.pop(context);
                  _controller.clear();
                },
                child: Text("Add Deck"),
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final decksStream = ref.watch(decksStreamProvider);
    return Scaffold(
      appBar: AppBar(title: Text("Flash Cards")),
      body: decksStream.when(
        data: (decks) {
          return ListView.builder(
            itemCount: decks.length,
            itemBuilder: (context, index) {
              final deck = decks[index];
              final countAsync = ref.watch(
                flashcardCountProvider(deck.id ?? ''),
              );
              return ListTile(
                title: Text(deck.deckName ?? ''),
                subtitle: countAsync.when(
                  data: (count) => Text('$count flashcards'),
                  loading: () => const Text('Loading...'),
                  error: (e, _) => const Text('Error loading'),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    await ref
                        .read(deckStateProvider.notifier)
                        .deleteDeck(deck.id!);
                    ref.invalidate(decksStreamProvider);
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CardScreen(deck: deck),
                    ),
                  );
                },
              );
            },
          );
        },
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        loading: () => Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openBottomSheet,
        child: Icon(Icons.add),
      ),
    );
  }
}
