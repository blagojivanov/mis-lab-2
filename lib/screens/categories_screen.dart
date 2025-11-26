import 'package:flutter/material.dart';

import '../models/category.dart';
import '../services/meal_service.dart';
import '../widgets/category_card.dart';
import 'random_meal_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Category> categories = [];
  List<Category> filteredCategories = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final cats = await MealService.getCategories();
      setState(() {
        categories = cats;
        filteredCategories = cats;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Грешка: $e')),
      );
    }
  }

  void filterCategories(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredCategories = categories;
      } else {
        filteredCategories = categories
            .where((cat) => cat.strCategory.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Категории на јадења'),
        actions: [
          IconButton(
            icon: const Icon(Icons.casino),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RandomMealScreen()),
              );
            },
            tooltip: 'Рандом рецепт',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: filterCategories,
              decoration: InputDecoration(
                hintText: 'Пребарувај категории...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredCategories.isEmpty
                ? const Center(child: Text('Нема резултати'))
                : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: filteredCategories.length,
              itemBuilder: (context, index) {
                final category = filteredCategories[index];
                return CategoryCard(category: category);
              },
            ),
          ),
        ],
      ),
    );
  }
}
