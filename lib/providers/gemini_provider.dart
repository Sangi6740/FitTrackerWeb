import 'package:flutter/material.dart';
import '../services/gemini_services.dart';
import '../models/chat_message.dart';

class GeminiProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String text, {VoidCallback? onScrollToBottom}) async {
    if (text.isEmpty) return;

    _messages.add(ChatMessage(text: text, isUser: true, timestamp: DateTime.now()));
    _isLoading = true;
    notifyListeners();
    
    if (onScrollToBottom != null) {
      onScrollToBottom();
    }

    final response = await _geminiService.askGemini(text);

    _isLoading = false;
    _messages.add(ChatMessage(text: response, isUser: false, timestamp: DateTime.now()));
    notifyListeners();
    
    if (onScrollToBottom != null) {
      onScrollToBottom();
    }
  }
}
