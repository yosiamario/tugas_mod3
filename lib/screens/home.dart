import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/app_state.dart';
import 'detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Country>> countries;
  String _searchQuery = '';
  String _selectedRegion = 'Semua';
  String _sortOption = 'A-Z'; // Options: 'A-Z', 'Z-A', 'Benua'

  final List<String> _regions = const [
    'Semua',
    'Africa',
    'Americas',
    'Asia',
    'Europe',
    'Oceania',
    'Polar',
  ];

  @override
  void initState() {
    super.initState();
    countries = fetchCountries();
  }

  Future<List<Country>> fetchCountries() async {
    try {
      final response = await http
          .get(
            Uri.parse('https://www.apicountries.com/countries'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData
            .map((json) => Country.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw Exception('Failed to load countries: ${response.statusCode}');
    } catch (e) {
      throw Exception('Gagal memuat data: $e');
    }
  }

  List<Country> _filterAndSort(List<Country> list) {
    var filtered = list.where((country) {
      final matchesSearch = country.name
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final matchesRegion = _selectedRegion == 'Semua' ||
          country.region.toLowerCase() == _selectedRegion.toLowerCase();
      return matchesSearch && matchesRegion;
    }).toList();

    if (_sortOption == 'A-Z') {
      filtered.sort((a, b) => a.name.compareTo(b.name));
    } else if (_sortOption == 'Z-A') {
      filtered.sort((a, b) => b.name.compareTo(a.name));
    } else if (_sortOption == 'Benua') {
      filtered.sort((a, b) {
        final regionCompare = a.region.compareTo(b.region);
        if (regionCompare != 0) return regionCompare;
        return a.name.compareTo(b.name);
      });
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Negara'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Urutkan',
            onSelected: (value) {
              setState(() {
                _sortOption = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'A-Z',
                child: Text('Urutkan: A - Z'),
              ),
              const PopupMenuItem(
                value: 'Z-A',
                child: Text('Urutkan: Z - A'),
              ),
              const PopupMenuItem(
                value: 'Benua',
                child: Text('Urutkan berdasarkan Benua'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari negara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Filter Benua (Region ChoiceChips)
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _regions.length,
              itemBuilder: (context, index) {
                final region = _regions[index];
                final isSelected = _selectedRegion == region;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(region),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedRegion = region;
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Content List
          Expanded(
            child: FutureBuilder<List<Country>>(
              future: countries,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                countries = fetchCountries();
                              });
                            },
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Data negara tidak ditemukan.'));
                }

                final displayList = _filterAndSort(snapshot.data!);

                if (displayList.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada negara yang sesuai filter/pencarian.'),
                  );
                }

                return ListenableBuilder(
                  listenable: appState,
                  builder: (context, _) {
                    return ListView.builder(
                      itemCount: displayList.length,
                      itemBuilder: (context, index) {
                        final country = displayList[index];
                        final isFav = appState.isFavorite(country);

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
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
                            subtitle: Text('Benua: ${country.region}'),
                            trailing: IconButton(
                              icon: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? Colors.red : Colors.grey,
                              ),
                              onPressed: () {
                                appState.toggleFavorite(country);
                              },
                            ),
                            onTap: () {
                              appState.addToHistory(country);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailPage(country: country),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Country {
  final String name;
  final String region;
  final String? capital;
  final int population;
  final String? flagsPng;
  final List<String>? languages;
  final List<String>? currencies;

  Country({
    required this.name,
    required this.region,
    required this.population,
    this.capital,
    this.flagsPng,
    this.languages,
    this.currencies,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    final List<String>? languages = json['languages'] != null
        ? (json['languages'] as List)
              .map((language) => language['name'].toString())
              .toList()
        : null;

    final List<String>? currencies = json['currencies'] != null
        ? (json['currencies'] as List)
              .map((currency) => currency['name'].toString())
              .toList()
        : null;

    final flags = json['flags'];

    return Country(
      name: json['name']?.toString() ?? 'N/A',
      region: json['region']?.toString() ?? 'N/A',
      population: json['population'] is int ? json['population'] as int : 0,
      capital: json['capital']?.toString(),
      flagsPng: flags is Map<String, dynamic> ? flags['png']?.toString() : null,
      languages: languages,
      currencies: currencies,
    );
  }
}
