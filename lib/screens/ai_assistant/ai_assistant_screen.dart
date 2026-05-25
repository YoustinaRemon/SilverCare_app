import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../theme/app_theme.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});
  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_Message> _messages = [];
  bool _isLoading = false;

  final FlutterTts _flutterTts = FlutterTts();

  static const _groqModel = 'llama-3.1-70b-versatile';

  @override
  void initState() {
    super.initState();
    _initTts();
    _messages.add(const _Message(
      role: 'assistant',
      content:
          'Hello! I am your SilverCare AI health assistant. There are many delicious and nutritious options for your health. How can I help you today?',
    ));
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
      _messages.add(_Message(role: 'user', content: text));
      _isLoading = true;
    });
    _msgCtrl.clear();
    _scrollToBottom();

    try {
      final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';

      if (apiKey.isEmpty) {
        throw Exception("API Key is missing in .env file");
      }

      final response = await http.post(
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
              'content':
                  'You are a compassionate AI health assistant for elderly users of SilverCare platform. Provide helpful, clear, and empathetic health advice. Use simple sentences.',
            },
            ..._messages.map((m) => {'role': m.role, 'content': m.content}),
          ],
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] as String? ?? '';
        setState(() {
          _messages.add(_Message(role: 'assistant', content: reply));
          _isLoading = false;
        });
      } else {
        setState(() {
          _messages.add(const _Message(
            role: 'assistant',
            content:
                '⚠️ I\'m having trouble connecting. Please check your connection or try again later.',
          ));
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _messages.add(const _Message(
            role: 'assistant',
            content:
                '⚠️ Error connecting to the AI. Please make sure your network is working.',
          ));
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
                    return Row(children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                              3,
                              (j) =>
                                  _Dot(delay: Duration(milliseconds: j * 200))),
                        ),
                      ),
                    ]);
                  }
                  return _MessageBubble(
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

class _Message {
  final String role, content;
  const _Message({required this.role, required this.content});
}

class _MessageBubble extends StatelessWidget {
  final _Message msg;
  final VoidCallback? onPlayAudio;

  const _MessageBubble({required this.msg, this.onPlayAudio});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.role == 'user';
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primary : theme.cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser
                    ? null
                    : const Border.fromBorderSide(
                        BorderSide(color: AppTheme.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isUser
                          ? Colors.white
                          : theme.textTheme.bodyLarge?.color,
                      height: 1.6,
                      fontSize: 15,
                    ),
                  ),
                  if (!isUser && onPlayAudio != null) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: onPlayAudio,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.secondary.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.volume_up_rounded,
                                  size: 16, color: AppTheme.secondary),
                              SizedBox(width: 4),
                              Text('Listen',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.secondary,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final Duration delay;
  const _Dot({required this.delay});
  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: FadeTransition(
          opacity: _anim,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
                color: AppTheme.mutedFg, shape: BoxShape.circle),
          ),
        ),
      );
}
