import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/db_service.dart';
import '../models/dog.dart';
import 'favorites_screen.dart';

class BrowseScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeToggle;

  const BrowseScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  List<String> _breeds = [];
  String? _selectedBreed;
  String? _imageUrl;
  bool _loadingBreeds = true;
  bool _loadingImage = false;
  String? _error;
  final TextEditingController _captionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBreeds();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  // load all breeds on startup
  Future<void> _loadBreeds() async {
    try {
      final breeds = await ApiService.fetchBreeds();
      setState(() {
        _breeds = breeds;
        _loadingBreeds = false;
      });
    } catch (e) {
      setState(() {
        _error = 'failed to load breeds. tap retry.';
        _loadingBreeds = false;
      });
    }
  }

  // fetch a random image for the selected breed
  Future<void> _fetchImage() async {
    if (_selectedBreed == null) return;
    setState(() {
      _loadingImage = true;
      _error = null;
      _imageUrl = null;
    });
    try {
      final url = await ApiService.fetchRandomImage(_selectedBreed!);
      setState(() {
        _imageUrl = url;
        _loadingImage = false;
      });
    } catch (e) {
      setState(() {
        _error = 'failed to load image. tap retry.';
        _loadingImage = false;
      });
    }
  }

  // save current dog to sqlite with caption
  Future<void> _saveDog() async {
    if (_imageUrl == null || _selectedBreed == null) return;
    final caption = _captionController.text.trim();
    final dog = Dog(
      breed: _selectedBreed!,
      imageUrl: _imageUrl!,
      caption: caption.isEmpty ? 'no caption' : caption,
      savedAt: DateTime.now().toIso8601String(),
    );
    await DbService.insertDog(dog);
    _captionController.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('saved to your diary!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🐶 Dog Breed Diary'),
        actions: [
          // dark/light theme toggle
          Switch(
            value: widget.isDarkMode,
            onChanged: widget.onThemeToggle,
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
          ),
        ],
      ),
      body: _loadingBreeds
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error != null && _breeds.isEmpty)
                    Column(
                      children: [
                        Text(_error!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _loadBreeds,
                          child: const Text('retry'),
                        ),
                      ],
                    ),
                  // breed dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'select a breed',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedBreed,
                    items: _breeds
                        .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedBreed = val),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _fetchImage,
                    child: const Text('fetch a dog!'),
                  ),
                  const SizedBox(height: 16),
                  if (_loadingImage)
                    const Center(child: CircularProgressIndicator()),
                  if (_error != null && _breeds.isNotEmpty)
                    Center(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  if (!_loadingImage && _error == null && _imageUrl == null)
                    const Expanded(
                      child: Center(
                        child: Text(
                          'select a breed above and tap fetch a dog! 🐾',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    ),
                  if (_imageUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _imageUrl!,
                        height: 250,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const SizedBox(
                            height: 250,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _captionController,
                      decoration: const InputDecoration(
                        labelText: 'add a caption',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _saveDog,
                      icon: const Icon(Icons.favorite),
                      label: const Text('save to diary'),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
