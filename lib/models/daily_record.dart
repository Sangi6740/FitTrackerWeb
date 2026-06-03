class DailyRecord {
  DateTime date;
  bool gymDone;
  double protein;
  double water;
  double sleep;
  double weight;
  bool preWorkoutDone;
  String preWorkoutFood;
  bool postWorkoutDone;
  String postWorkoutFood;
  bool breakfastDone;
  String breakfastFood;
  bool lunchDone;
  String lunchFood;
  bool snackDone;
  String snackFood;
  bool dinnerDone;
  String dinnerFood;
  double completionPercentage;

  DailyRecord({
    required this.date,
    this.gymDone = false,
    this.protein = 0.0,
    this.water = 0.0,
    this.sleep = 0.0,
    this.weight = 0.0,
    this.preWorkoutDone = false,
    this.preWorkoutFood = '',
    this.postWorkoutDone = false,
    this.postWorkoutFood = '',
    this.breakfastDone = false,
    this.breakfastFood = '',
    this.lunchDone = false,
    this.lunchFood = '',
    this.snackDone = false,
    this.snackFood = '',
    this.dinnerDone = false,
    this.dinnerFood = '',
    this.completionPercentage = 0.0,
  });

  factory DailyRecord.empty(DateTime date) {
    return DailyRecord(
      date: DateTime(date.year, date.month, date.day),
    );
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
      preWorkoutFood: json['preWorkoutFood'] as String? ?? '',
      postWorkoutDone: json['postWorkoutDone'] as bool? ?? false,
      postWorkoutFood: json['postWorkoutFood'] as String? ?? '',
      breakfastDone: json['breakfastDone'] as bool? ?? false,
      breakfastFood: json['breakfastFood'] as String? ?? '',
      lunchDone: json['lunchDone'] as bool? ?? false,
      lunchFood: json['lunchFood'] as String? ?? '',
      snackDone: json['snackDone'] as bool? ?? false,
      snackFood: json['snackFood'] as String? ?? '',
      dinnerDone: json['dinnerDone'] as bool? ?? false,
      dinnerFood: json['dinnerFood'] as String? ?? '',
      completionPercentage: (json['completionPercentage'] as num?)?.toDouble() ?? 0.0,
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
      'preWorkoutFood': preWorkoutFood,
      'postWorkoutDone': postWorkoutDone,
      'postWorkoutFood': postWorkoutFood,
      'breakfastDone': breakfastDone,
      'breakfastFood': breakfastFood,
      'lunchDone': lunchDone,
      'lunchFood': lunchFood,
      'snackDone': snackDone,
      'snackFood': snackFood,
      'dinnerDone': dinnerDone,
      'dinnerFood': dinnerFood,
      'completionPercentage': completionPercentage,
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
