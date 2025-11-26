import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/meal_detail.dart';
import '../services/meal_service.dart';

class RandomMealScreen extends StatefulWidget {
  const RandomMealScreen({Key? key}) : super(key: key);

  @override
  State<RandomMealScreen> createState() => _RandomMealScreenState();
}

class _RandomMealScreenState extends State<RandomMealScreen> {
  MealDetail? randomMeal;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRandomMeal();
  }

  Future<void> loadRandomMeal() async {
    setState(() => isLoading = true);
    try {
      final meal = await MealService.getRandomMeal();
      setState(() {
        randomMeal = meal;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Грешка: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Рандом рецепт на денот')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (randomMeal == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Рандом рецепт на денот')),
        body: const Center(child: Text('Грешка при вчитување')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: loadRandomMeal,
                tooltip: 'Нов рандом рецепт',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                randomMeal!.strMeal,
                style: const TextStyle(
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: Image.network(
                randomMeal!.strMealThumb,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(
                        label: Text(randomMeal!.strCategory),
                        avatar: const Icon(Icons.restaurant_menu, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(randomMeal!.strArea),
                        avatar: const Icon(Icons.public, size: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Состојки:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(
                    randomMeal!.ingredients.length,
                        (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, size: 16, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            '${randomMeal!.ingredients[index]} - ${randomMeal!.measures[index]}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Инструкции:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    randomMeal!.strInstructions,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  if (randomMeal!.strYoutube.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('YouTube: ${randomMeal!.strYoutube}')),
                        );
                      },
                      icon: const Icon(Icons.play_circle_outline),
                      label: const Text('Гледај на YouTube'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
