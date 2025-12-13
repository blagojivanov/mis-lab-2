import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/meal_detail.dart';
import '../services/meal_service.dart';
import '../services/favorites_service.dart';


class MealDetailScreen extends StatefulWidget {
  final String mealId;

  const MealDetailScreen({Key? key, required this.mealId}) : super(key: key);

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  MealDetail? mealDetail;
  bool isLoading = true;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    loadMealDetail();
    checkFavoriteStatus();
  }

  Future<void> loadMealDetail() async {
    try {
      final detail = await MealService.getMealDetail(widget.mealId);
      setState(() {
        mealDetail = detail;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Грешка: $e')),
      );
    }
  }

  Future<void> checkFavoriteStatus() async {
    final status = await FavoritesService.isFavorite(widget.mealId);
    setState(() => isFavorite = status);
  }

  Future<void> toggleFavorite() async {
    if (mealDetail == null) return;

    try {
      if (isFavorite) {
        await FavoritesService.removeFavorite(widget.mealId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Отстрането од омилени')),
        );
      } else {
        await FavoritesService.addFavorite(mealDetail!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Додадено во омилени')),
        );
      }
      setState(() => isFavorite = !isFavorite);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Грешка: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (mealDetail == null) {
      return Scaffold(
        appBar: AppBar(),
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
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                onPressed: toggleFavorite,
                tooltip: isFavorite ? 'Отстрани од омилени' : 'Додај во омилени',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                mealDetail!.strMeal,
                style: const TextStyle(
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: Image.network(
                mealDetail!.strMealThumb,
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
                        label: Text(mealDetail!.strCategory),
                        avatar: const Icon(Icons.restaurant_menu, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(mealDetail!.strArea),
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
                    mealDetail!.ingredients.length,
                        (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, size: 16, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            '${mealDetail!.ingredients[index]} - ${mealDetail!.measures[index]}',
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
                    mealDetail!.strInstructions,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  if (mealDetail!.strYoutube.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('YouTube: ${mealDetail!.strYoutube}')),
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