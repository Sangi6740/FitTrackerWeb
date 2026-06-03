import 'dart:math';
import '../models/daily_record.dart';
import 'storage_service.dart';

class SampleDataGenerator {
  static Future<void> generateSampleData(StorageService storageService) async {
    final rand = Random();
    DateTime today = DateTime.now();
    
    // Generate data for the last 90 days
    for (int i = 0; i < 90; i++) {
      DateTime date = today.subtract(Duration(days: i));
      
      // Don't overwrite if it already exists
      if (storageService.getRecord(date) != null) {
        continue;
      }

      bool gymDone = rand.nextDouble() > 0.3; // 70% chance of gym
      double protein = 60 + rand.nextDouble() * 60; // 60g - 120g
      double water = 1.0 + rand.nextDouble() * 3.0; // 1L - 4L
      double sleep = 4.0 + rand.nextDouble() * 5.0; // 4hrs - 9hrs
      double weight = 75.0 + (rand.nextDouble() * 4 - 2); // 73kg - 77kg
      
      bool pre = rand.nextBool();
      bool post = rand.nextBool();
      bool breakfast = rand.nextDouble() > 0.2;
      bool lunch = rand.nextDouble() > 0.1;
      bool snack = rand.nextBool();
      bool dinner = rand.nextDouble() > 0.1;

      DailyRecord record = DailyRecord(
        date: date,
        gymDone: gymDone,
        protein: protein,
        water: water,
        sleep: sleep,
        weight: weight,
        preWorkoutDone: pre,
        postWorkoutDone: post,
        breakfastDone: breakfast,
        lunchDone: lunch,
        snackDone: snack,
        dinnerDone: dinner,
      );
      record.calculateScore();
      await storageService.saveRecord(record);
    }
  }
}
