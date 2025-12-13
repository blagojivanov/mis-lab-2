import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/meal_detail.dart';
import '../services/favorites_service.dart';
import '../widgets/favorite_card.dart';


class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MealDetail>>(
      stream: FavoritesService.getFavorites(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Грешка: ${snapshot.error}'));
        }

        final favorites = snapshot.data ?? [];

        if (favorites.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Немате омилени рецепти',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final meal = favorites[index];
            return FavoriteCard(meal: meal);
          },
        );
      },
    );
  }
}