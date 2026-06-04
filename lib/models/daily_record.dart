class MealEntry {
  final String name;
  final double quantity;
  final String unit;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;

  MealEntry({
    required this.name,
    this.quantity = 0.0,
    this.unit = 'g',
    this.calories = 0.0,
    this.protein = 0.0,
    this.carbs = 0.0,
    this.fats = 0.0,
  });

  factory MealEntry.empty() => MealEntry(name: '');

  factory MealEntry.fromJson(dynamic json) {
    if (json == null) return MealEntry.empty();
    if (json is String) {
      return MealEntry(name: json);
    }
    if (json is Map<String, dynamic>) {
      return MealEntry(
        name: json['name'] ?? '',
        quantity: (json['quantity'] ?? 0).toDouble(),
        unit: json['unit'] ?? 'g',
        calories: (json['calories'] ?? 0).toDouble(),
        protein: (json['protein'] ?? 0).toDouble(),
        carbs: (json['carbs'] ?? 0).toDouble(),
        fats: (json['fats'] ?? 0).toDouble(),
      );
    }
    return MealEntry.empty();
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
    };
  }
}

class DailyRecord {
  DateTime date;
  bool gymDone;
  double protein;
  double water;
  double sleep;
  double weight;
  
  bool preWorkoutDone;
  List<MealEntry> preWorkoutEntries;
  
  bool postWorkoutDone;
  List<MealEntry> postWorkoutEntries;
  
  bool breakfastDone;
  List<MealEntry> breakfastEntries;
  
  bool lunchDone;
  List<MealEntry> lunchEntries;
  
  bool snackDone;
  List<MealEntry> snackEntries;
  
  bool dinnerDone;
  List<MealEntry> dinnerEntries;
  
  double completionPercentage;
  
  // Daily totals
  double totalCalories;
  double totalCarbs;
  double totalFats;

  DailyRecord({
    required this.date,
    this.gymDone = false,
    this.protein = 0.0,
    this.water = 0.0,
    this.sleep = 0.0,
    this.weight = 0.0,
    this.preWorkoutDone = false,
    List<MealEntry>? preWorkoutEntries,
    this.postWorkoutDone = false,
    List<MealEntry>? postWorkoutEntries,
    this.breakfastDone = false,
    List<MealEntry>? breakfastEntries,
    this.lunchDone = false,
    List<MealEntry>? lunchEntries,
    this.snackDone = false,
    List<MealEntry>? snackEntries,
    this.dinnerDone = false,
    List<MealEntry>? dinnerEntries,
    this.completionPercentage = 0.0,
    this.totalCalories = 0.0,
    this.totalCarbs = 0.0,
    this.totalFats = 0.0,
  })  : preWorkoutEntries = preWorkoutEntries ?? [],
        postWorkoutEntries = postWorkoutEntries ?? [],
        breakfastEntries = breakfastEntries ?? [],
        lunchEntries = lunchEntries ?? [],
        snackEntries = snackEntries ?? [],
        dinnerEntries = dinnerEntries ?? [];

  factory DailyRecord.empty(DateTime date) {
    return DailyRecord(date: DateTime(date.year, date.month, date.day));
  }

  static List<MealEntry> _parseEntries(dynamic json) {
    if (json == null) return [];
    if (json is List) {
      return json.map((e) => MealEntry.fromJson(e)).toList();
    }
    // Backward compatibility for when it was a single String or Map
    final entry = MealEntry.fromJson(json);
    if (entry.name.isEmpty) return [];
    return [entry];
  }

  factory DailyRecord.fromJson(Map<String, dynamic> json) {
    return DailyRecord(
      date: DateTime.parse(json['date'] as String),
      gymDone: json['gymDone'] as bool? ?? false,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      water: (json['water'] as num?)?.toDouble() ?? 0.0,
      sleep: (json['sleep'] as num?)?.toDouble() ?? 0.0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      
      preWorkoutDone: json['preWorkoutDone'] as bool? ?? false,
      preWorkoutEntries: _parseEntries(json['preWorkoutEntries'] ?? json['preWorkoutEntry'] ?? json['preWorkoutFood']),
      
      postWorkoutDone: json['postWorkoutDone'] as bool? ?? false,
      postWorkoutEntries: _parseEntries(json['postWorkoutEntries'] ?? json['postWorkoutEntry'] ?? json['postWorkoutFood']),
      
      breakfastDone: json['breakfastDone'] as bool? ?? false,
      breakfastEntries: _parseEntries(json['breakfastEntries'] ?? json['breakfastEntry'] ?? json['breakfastFood']),
      
      lunchDone: json['lunchDone'] as bool? ?? false,
      lunchEntries: _parseEntries(json['lunchEntries'] ?? json['lunchEntry'] ?? json['lunchFood']),
      
      snackDone: json['snackDone'] as bool? ?? false,
      snackEntries: _parseEntries(json['snackEntries'] ?? json['snackEntry'] ?? json['snackFood']),
      
      dinnerDone: json['dinnerDone'] as bool? ?? false,
      dinnerEntries: _parseEntries(json['dinnerEntries'] ?? json['dinnerEntry'] ?? json['dinnerFood']),
      
      completionPercentage: (json['completionPercentage'] as num?)?.toDouble() ?? 0.0,
      totalCalories: (json['totalCalories'] as num?)?.toDouble() ?? 0.0,
      totalCarbs: (json['totalCarbs'] as num?)?.toDouble() ?? 0.0,
      totalFats: (json['totalFats'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'gymDone': gymDone,
      'protein': protein,
      'water': water,
      'sleep': sleep,
      'weight': weight,
      'preWorkoutDone': preWorkoutDone,
      'preWorkoutEntries': preWorkoutEntries.map((e) => e.toJson()).toList(),
      'postWorkoutDone': postWorkoutDone,
      'postWorkoutEntries': postWorkoutEntries.map((e) => e.toJson()).toList(),
      'breakfastDone': breakfastDone,
      'breakfastEntries': breakfastEntries.map((e) => e.toJson()).toList(),
      'lunchDone': lunchDone,
      'lunchEntries': lunchEntries.map((e) => e.toJson()).toList(),
      'snackDone': snackDone,
      'snackEntries': snackEntries.map((e) => e.toJson()).toList(),
      'dinnerDone': dinnerDone,
      'dinnerEntries': dinnerEntries.map((e) => e.toJson()).toList(),
      'completionPercentage': completionPercentage,
      'totalCalories': totalCalories,
      'totalCarbs': totalCarbs,
      'totalFats': totalFats,
    };
  }

  void calculateScore() {
    double score = 0;
    if (gymDone) score += 20;
    if (protein >= 90) score += 20;
    if (water >= 3.0) score += 20;
    if (sleep >= 7.0) score += 20;

    int mealsDone = 0;
    if (preWorkoutDone) mealsDone++;
    if (postWorkoutDone) mealsDone++;
    if (breakfastDone) mealsDone++;
    if (lunchDone) mealsDone++;
    if (snackDone) mealsDone++;
    if (dinnerDone) mealsDone++;

    if (mealsDone == 6) {
      score += 20;
    } else {
      score += (20 * (mealsDone / 6));
    }

    completionPercentage = score;
  }
}
