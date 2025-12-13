import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meal_detail.dart';

class FavoritesService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String COLLECTION = 'favorites';
  static String userId = 'user_default';

  static Future<void> addFavorite(MealDetail meal) async {
    try {
      await _firestore
          .collection(COLLECTION)
          .doc(userId)
          .collection('meals')
          .doc(meal.idMeal)
          .set(meal.toJson());
    } catch (e) {
      throw Exception('Грешка при додавање: $e');
    }
  }

  static Future<void> removeFavorite(String mealId) async {
    try {
      await _firestore
          .collection(COLLECTION)
          .doc(userId)
          .collection('meals')
          .doc(mealId)
          .delete();
    } catch (e) {
      throw Exception('Грешка при отстранување: $e');
    }
  }

  static Future<bool> isFavorite(String mealId) async {
    try {
      final doc = await _firestore
          .collection(COLLECTION)
          .doc(userId)
          .collection('meals')
          .doc(mealId)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  static Stream<List<MealDetail>> getFavorites() {
    return _firestore
        .collection(COLLECTION)
        .doc(userId)
        .collection('meals')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MealDetail.fromJson(doc.data()))
        .toList());
  }
}
