import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../services/meal_service.dart';
import '../widgets/meal_card.dart';

class MealsScreen extends StatefulWidget {
  final String category;

  const MealsScreen({Key? key, required this.category}) : super(key: key);

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  List<Meal> meals = [];
  List<Meal> filteredMeals = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadMeals();
  }

  Future<void> loadMeals() async {
    try {
      final mealsList = await MealService.getMealsByCategory(widget.category);
      setState(() {
        meals = mealsList;
        filteredMeals = mealsList;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Грешка: $e')),
      );
    }
  }

  Future<void> searchMeals(String query) async {
    if (query.isEmpty) {
      setState(() {
        filteredMeals = meals;
        searchQuery = '';
      });
      return;
    }

    setState(() {
      searchQuery = query;
      isLoading = true;
    });

    try {
      final results = await MealService.searchMeals(query);
      final categoryFiltered = results
          .where((meal) => meals.any((m) => m.idMeal == meal.idMeal))
          .toList();

      setState(() {
        filteredMeals = categoryFiltered.isEmpty ? [] : categoryFiltered;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: searchMeals,
              decoration: InputDecoration(
                hintText: 'Пребарувај јадења...',
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
                : filteredMeals.isEmpty
                ? const Center(child: Text('Нема резултати'))
                : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filteredMeals.length,
              itemBuilder: (context, index) {
                final meal = filteredMeals[index];
                return MealCard(meal: meal);
              },
            ),
          ),
        ],
      ),
    );
  }
}
