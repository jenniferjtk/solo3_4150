import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../models/dog.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Dog> _favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // load all saved dogs from sqlite
  Future<void> _loadFavorites() async {
    final dogs = await DbService.getFavorites();
    setState(() {
      _favorites = dogs;
      _loading = false;
    });
  }

  // delete a single dog and refresh
  Future<void> _deleteDog(int id) async {
    await DbService.deleteDog(id);
    _loadFavorites();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('removed from diary')),
      );
    }
  }

  // clear all dogs and refresh
  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('clear all?'),
        content: const Text('this will delete all saved dogs.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('clear all')),
        ],
      ),
    );
    if (confirm == true) {
      await DbService.clearAll();
      _loadFavorites();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('diary cleared')),
        );
      }
    }
  }

  // edit caption inline
  Future<void> _editCaption(Dog dog) async {
    final controller = TextEditingController(text: dog.caption);
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('edit caption'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('cancel')),
          TextButton(
            onPressed: () async {
              await DbService.updateCaption(dog.id!, controller.text.trim());
              if (mounted) Navigator.pop(context);
              _loadFavorites();
            },
            child: const Text('save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('my dog diary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'clear all',
            onPressed: _clearAll,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? const Center(
                  child: Text(
                    'no dogs saved yet!\ngo find some 🐾',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    final dog = _favorites[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12)),
                            child: Image.network(
                              dog.imageUrl,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const SizedBox(
                                  height: 200,
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dog.breed,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(dog.caption),
                                const SizedBox(height: 4),
                                Text(
                                  dog.savedAt.substring(0, 10),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => _editCaption(dog),
                                      icon: const Icon(Icons.edit, size: 16),
                                      label: const Text('edit'),
                                    ),
                                    TextButton.icon(
                                      onPressed: () => _deleteDog(dog.id!),
                                      icon: const Icon(Icons.delete, size: 16),
                                      label: const Text('delete'),
                                      style: TextButton.styleFrom(
                                          foregroundColor: Colors.red),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
