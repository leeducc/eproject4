import 'package:flutter/material.dart';
import 'favorite_manager.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {

  final manager = FavoriteManager();

  @override
  void initState() {
    super.initState();
    manager.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {

    final favorites = manager.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Từ yêu thích"),
      ),

      body: favorites.isEmpty
          ? const Center(child: Text("Chưa có từ nào"))
          : ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {

          final w = favorites[index];

          return ListTile(
            title: Text(w["word"]),
            subtitle: Text(w["meaning"] ?? ""),
            trailing: IconButton(
              icon: const Icon(Icons.star, color: Colors.amber),
              onPressed: () {
                manager.toggleFavorite(w);
              },
            ),
          );
        },
      ),
    );
  }
}