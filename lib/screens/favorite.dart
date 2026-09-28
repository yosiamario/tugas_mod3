import 'package:flutter/material.dart';

import '../models/app_state.dart';
import 'detail.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorit Saya'),
      ),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final favorites = appState.favorites;

          if (favorites.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada negara favorit.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final country = favorites[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: country.flagsPng != null
                      ? Image.network(
                          country.flagsPng!,
                          width: 50,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.flag_outlined, size: 50),
                        )
                      : const SizedBox(width: 50),
                  title: Text(country.name),
                  subtitle: Text(country.region),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      appState.toggleFavorite(country);
                    },
                  ),
                  onTap: () {
                    appState.addToHistory(country);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(country: country),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
