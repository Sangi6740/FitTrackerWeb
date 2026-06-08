import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gemini_provider.dart';
import '../models/chat_message.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class GeminiTestScreen extends StatefulWidget {
  const GeminiTestScreen({super.key});

  @override
  State<GeminiTestScreen> createState() => _GeminiTestScreenState();
}

class _GeminiTestScreenState extends State<GeminiTestScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();

    context.read<GeminiProvider>().sendMessage(text, onScrollToBottom: _scrollToBottom);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Coach')),
      body: Consumer<GeminiProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              Expanded(
                child: provider.messages.isEmpty && !provider.isLoading
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome, size: 64, color: Colors.tealAccent),
                            SizedBox(height: 16),
                            Text(
                              'AI Coach',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'How can I help you today?',
                              style: TextStyle(fontSize: 16, color: Colors.white54),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(top: 16, bottom: 20),
                        itemCount: provider.messages.length + (provider.isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == provider.messages.length && provider.isLoading) {
                            return _buildLoadingBubble();
                          }
                          final message = provider.messages[index];
                          return _buildChatBubble(message);
                        },
                      ),
              ),
              _buildInputArea(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? Colors.teal : const Color(0xFF1A1A2E), // Teal for user, dark glass for AI
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(0),
          ),
          border: isUser ? null : Border.all(color: Colors.white12),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: MarkdownBody(
          data: message.text,
          styleSheet: MarkdownStyleSheet(
            p: const TextStyle(color: Colors.white, fontSize: 16),
            strong: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            listBullet: const TextStyle(color: Colors.white, fontSize: 16),
            h1: const TextStyle(color: Colors.tealAccent, fontSize: 24, fontWeight: FontWeight.bold),
            h2: const TextStyle(color: Colors.tealAccent, fontSize: 20, fontWeight: FontWeight.bold),
            h3: const TextStyle(color: Colors.tealAccent, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20).copyWith(bottomLeft: const Radius.circular(0)),
          border: Border.all(color: Colors.white12),
        ),
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.tealAccent),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100), // 100 padding for nav bar clearance
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F1E),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Ask AI...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
