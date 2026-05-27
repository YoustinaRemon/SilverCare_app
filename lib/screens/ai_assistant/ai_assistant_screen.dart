import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/app_theme.dart';
import '../../models/chat_message.dart';
import "../../widgets/typing_indicator.dart";
import "../../widgets/message_bubble.dart";

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});
  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  final FlutterTts _flutterTts = FlutterTts();
  static const _groqModel = 'llama-3.3-70b-versatile';

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadMessages();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMsgs = prefs.getStringList('chat_messages');

    if (savedMsgs != null && savedMsgs.isNotEmpty) {
      setState(() {
        _messages.addAll(
            savedMsgs.map((e) => ChatMessage.fromJson(jsonDecode(e))).toList());
      });
      _scrollToBottom();
    } else {
      setState(() {
        _messages.add(const ChatMessage(
          role: 'assistant',
          content:
              'Hello! I am your SilverCare AI health assistant. There are many delicious and nutritious options for your health. How can I help you today?',
        ));
      });
      _saveMessages();
    }
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedList = _messages.map((m) => jsonEncode(m.toJson())).toList();
    await prefs.setStringList('chat_messages', encodedList);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(ChatMessage(role: 'user', content: text));
      _isLoading = true;
    });
    _saveMessages();
    _msgCtrl.clear();
    _scrollToBottom();

    try {
      final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
      if (apiKey.isEmpty) throw Exception("API Key missing");

      // ⬅️ إضافة Timeout للطلب (مثلاً 20 ثانية)
      final response = await http
          .post(
            Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode({
              'model': _groqModel,
              'max_tokens': 1024,
              'messages': [
                {
                  'role': 'system',
                  'content': 'You are a compassionate AI health assistant...'
                },
                ..._messages.map((m) => {'role': m.role, 'content': m.content}),
              ],
            }),
          )
          .timeout(
              const Duration(seconds: 20)); // ⬅️ إذا زاد الوقت عن 20 ثانية يوقف

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] as String? ?? '';
        setState(() {
          _messages.add(ChatMessage(role: 'assistant', content: reply));
          _isLoading = false;
        });
        _saveMessages();
      } else {
        // طباعة الخطأ في الكونسول عشان نعرف السبب
        debugPrint('🚨 Error: ${response.statusCode} - ${response.body}');
        setState(() {
          _messages.add(const ChatMessage(
              role: 'assistant',
              content: '⚠️ Server error. Please try again.'));
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('🚨 Exception: $e'); // ⬅️ طباعة الخطأ
      if (mounted) {
        setState(() {
          _messages.add(const ChatMessage(
              role: 'assistant',
              content: '⚠️ Connection timeout or network error.'));
          _isLoading = false;
        });
      }
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.secondary.withValues(alpha: .15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: AppTheme.secondary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SilverCare AI Assistant',
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontSize: 18, color: AppTheme.primary)),
                  const SizedBox(height: 2),
                  Text('Context-aware health & companionship',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: AppTheme.mutedFg)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('Online',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('chat_messages');
              setState(() {
                _messages.clear();
                _messages.add(const ChatMessage(
                  role: 'assistant',
                  content:
                      'Hello! I am your SilverCare AI health assistant. There are many delicious and nutritious options for your health. How can I help you today?',
                ));
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(20),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == _messages.length) {
                    return const TypingIndicator(); // ⬅️ استدعاء الـ Widget الجديدة
                  }
                  return MessageBubble(
                    // ⬅️ استدعاء الـ Widget الجديدة
                    msg: _messages[i],
                    onPlayAudio: _messages[i].role == 'assistant'
                        ? () => _speak(_messages[i].content)
                        : null,
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: const Border(top: BorderSide(color: AppTheme.border)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Voice input coming soon!')),
                      );
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppTheme.amber,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mic_none_rounded,
                          color: Colors.white, size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      onSubmitted: (_) => _send(),
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Type or speak how you are feeling...',
                        hintStyle: const TextStyle(color: AppTheme.mutedFg),
                        filled: true,
                        fillColor: theme.scaffoldBackgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppTheme.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppTheme.border),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _isLoading ? null : _send,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _isLoading
                            ? AppTheme.secondary.withValues(alpha: .5)
                            : AppTheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
