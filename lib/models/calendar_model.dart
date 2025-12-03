class MealDay {
  final String idMeal;
  final DateTime createdAt;
  final String? mealCategory;
  final String? ingredients;
  final DateTime? eatDate;
  final String userId;

  MealDay({
    required this.idMeal,
    required this.createdAt,
    required this.userId,
    this.mealCategory,
    this.ingredients,
    this.eatDate,
  });

  // Factory constructor para crear MealDay desde una fila de Supabase
  factory MealDay.fromMap(Map<String, dynamic> json) {
    return MealDay(
      idMeal: json['id_meal'],
      createdAt: DateTime.parse(json['created_at']),
      mealCategory: json['meal_category'],
      ingredients: json['ingredients'],
      eatDate: json['eat_date'] != null ? DateTime.parse(json['eat_date']) : null,
      userId: json['user_id'],
    );
  }

  // Método para convertir un objeto MealDay a Map (para INSERT o UPDATE)
  Map<String, dynamic> toMap() {
    return {
      'created_at': createdAt.toIso8601String(),
      'meal_category': mealCategory,
      'ingredients': ingredients,
      'eat_date': eatDate?.toIso8601String(),
      'user_id': userId,
    };
  }
}
