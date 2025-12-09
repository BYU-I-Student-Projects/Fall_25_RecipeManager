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

  // Factory constructor to create a MealDay from a Supabase row
  factory MealDay.fromMap(Map<String, dynamic> json) {
    // The created_at and eat_date columns are DATE in the DB, usually coming as 'YYYY-MM-DD'
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      final s = value.toString();
      // Accepts both 'YYYY-MM-DD' and 'YYYY-MM-DDTHH:mm:ss...'
      return DateTime.parse(s);
    }

    return MealDay(
      idMeal: json['id_meal'],
      createdAt: parseDate(json['created_at']),
      mealCategory: json['meal_category'],
      ingredients: json['ingredients'],
      eatDate: json['eat_date'] != null ? parseDate(json['eat_date']) : null,
      userId: json['user_id'],
    );
  }

  // Method to convert a MealDay object to a Map (for INSERT or UPDATE)
  Map<String, dynamic> toMap() {
    String formatDate(DateTime dt) => dt.toIso8601String().split('T').first;

    return {
      'created_at': formatDate(createdAt),
      'meal_category': mealCategory,
      'ingredients': ingredients,
      'eat_date': eatDate != null ? formatDate(eatDate!) : null,
      'user_id': userId,
    };
  }
}