import 'package:flutter/material.dart';

import '../models/app_state.dart';
import 'detail.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  void _showClearConfirmation(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Semua Riwayat?'),
          content: const Text(
            'Tindakan ini akan menghapus seluruh riwayat penelusuran secara permanen (hard delete).',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                appState.clearHistory();
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Seluruh riwayat berhasil dihapus!'),
                  ),
                );
              },
              child: const Text('Hapus Semua'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Terakhir'),
        actions: [
          ListenableBuilder(
            listenable: appState,
            builder: (context, _) {
              if (appState.history.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                tooltip: 'Hapus Semua Riwayat',
                onPressed: () => _showClearConfirmation(context, appState),
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final history = appState.history;

          if (history.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat penelusuran.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              final country = item.country;
              final formattedTime =
                  '${item.timestamp.day}/${item.timestamp.month}/${item.timestamp.year} ${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}';

              return Dismissible(
                key: Key('${country.name}_${item.timestamp.millisecondsSinceEpoch}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  appState.removeFromHistory(index);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${country.name} dihapus dari riwayat.'),
                    ),
                  );
                },
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                    subtitle: Text('${country.region} • $formattedTime'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Hapus Item',
                      onPressed: () {
                        appState.removeFromHistory(index);
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(country: country),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
