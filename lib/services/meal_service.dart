import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/category.dart';
import '../models/meal.dart';
import '../models/meal_detail.dart';


class MealService {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  static Future<List<Category>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Category> categories = (data['categories'] as List)
          .map((cat) => Category.fromJson(cat))
          .toList();
      return categories;
    }
    throw Exception('Грешка при вчитување на категории');
  }

  static Future<List<Meal>> getMealsByCategory(String category) async {
    final response = await http.get(Uri.parse('$baseUrl/filter.php?c=$category'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] != null) {
        return (data['meals'] as List)
            .map((meal) => Meal.fromJson(meal))
            .toList();
      }
      return [];
    }
    throw Exception('Грешка при вчитување на јадења');
  }

  static Future<List<Meal>> searchMeals(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/search.php?s=$query'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] != null) {
        return (data['meals'] as List)
            .map((meal) => Meal.fromJson(meal))
            .toList();
      }
      return [];
    }
    return [];
  }

  static Future<MealDetail> getMealDetail(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/lookup.php?i=$id'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] != null && data['meals'].isNotEmpty) {
        return MealDetail.fromJson(data['meals'][0]);
      }
    }
    throw Exception('Грешка при вчитување на детали');
  }

  static Future<MealDetail> getRandomMeal() async {
    final response = await http.get(Uri.parse('$baseUrl/random.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] != null && data['meals'].isNotEmpty) {
        return MealDetail.fromJson(data['meals'][0]);
      }
    }
    throw Exception('Грешка при вчитување на рандом рецепт');
  }
}
