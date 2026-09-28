import 'package:flutter/material.dart';

import '../models/app_state.dart';
import 'home.dart';

class DetailPage extends StatelessWidget {
  final Country country;

  const DetailPage({super.key, required this.country});

  @override
  Widget build(BuildContext context) {
    final appState = AppState();

    return Scaffold(
      appBar: AppBar(
        title: Text(country.name),
        actions: [
          ListenableBuilder(
            listenable: appState,
            builder: (context, _) {
              final isFav = appState.isFavorite(country);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : null,
                ),
                tooltip: isFav ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                onPressed: () {
                  appState.toggleFavorite(country);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFav
                            ? '${country.name} dihapus dari favorit.'
                            : '${country.name} ditambahkan ke favorit.',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (country.flagsPng != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    country.flagsPng!,
                    width: 200,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.flag_outlined, size: 100),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nama: ${country.name}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(),
                    Text('Ibu Kota: ${country.capital ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Benua / Region: ${country.region}',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Populasi: ${country.population}',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                        'Bahasa: ${country.languages?.join(', ') ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                        'Mata Uang: ${country.currencies?.join(', ') ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
