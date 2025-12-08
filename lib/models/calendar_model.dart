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
    // Las columnas created_at y eat_date son DATE en la BD, suelen venir como 'YYYY-MM-DD'
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      final s = value.toString();
      // Acepta tanto 'YYYY-MM-DD' como 'YYYY-MM-DDTHH:mm:ss...'
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

  // Método para convertir un objeto MealDay a Map (para INSERT o UPDATE)
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
