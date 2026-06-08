import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final GenerativeModel _model = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: dotenv.env['GCP_API_KEY'] ?? '',
  );

  Future<String> askGemini(String prompt) async {
    try {
      final response = await _model.generateContent([
        Content.text("""
You are FitTrack Pro AI Coach.

You ONLY answer questions about:
- Fitness
- Gym workouts
- Exercise techniques
- Nutrition
- Protein intake
- Weight loss
- Weight gain
- Muscle building
- Healthy lifestyle
- Sleep and recovery
- Hydration

If the question is unrelated to fitness, respond exactly with:

"I am FitTrack Pro AI and can only assist with fitness, workouts, nutrition, and healthy lifestyle topics."

User Question:
$prompt
"""),
      ]);

      return response.text ?? 'No response';
    } catch (e) {
      return 'Error: $e';
    }
  }
}
