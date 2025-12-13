import 'package:flutter/material.dart';

import '../models/category.dart';
import '../services/meal_service.dart';
import '../services/notification_service.dart';
import '../widgets/category_card.dart';
import 'favorites_screen.dart';
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
  int _selectedIndex = 0;

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
    final List<Widget> screens = [
      _buildCategoriesScreen(),
      const FavoritesScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Категории на јадења' : 'Омилени рецепти'),
        actions: [
          IconButton(
            icon: const Icon(Icons.casino),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RandomMealScreen()),
              );
            },
            tooltip: 'Рандом рецепт',
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () async {
              await NotificationService.sendTestNotification();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Тест нотификација испратена!')),
              );
            },
            tooltip: 'Тест нотификација',
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Почетна',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Омилени',
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesScreen() {
    return Column(
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
    );
  }
}
