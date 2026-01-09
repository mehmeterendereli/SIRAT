import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/config/injection.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/islam_ai_service.dart';
import '../../l10n/app_localizations.dart';
import '../bloc/islam_ai_bloc.dart';

/// İslam-AI Chat Sayfası
/// Gemini Pro ile entegre akıllı İslami asistan arayüzü.

class IslamAIPage extends StatefulWidget {
  const IslamAIPage({super.key});

  @override
  State<IslamAIPage> createState() => _IslamAIPageState();
}

class _IslamAIPageState extends State<IslamAIPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  AIMode _selectedMode = AIMode.fetva;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => getIt<IslamAIBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.goldGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.psychology, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text('İslam-AI'),
            ],
          ),
          actions: [
            PopupMenuButton<AIMode>(
              icon: const Icon(Icons.tune),
              onSelected: (mode) => setState(() => _selectedMode = mode),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: AIMode.fetva,
                  child: _buildModeItem('Fetva Modu', Icons.menu_book, _selectedMode == AIMode.fetva),
                ),
                PopupMenuItem(
                  value: AIMode.teselli,
                  child: _buildModeItem('Manevi Destek', Icons.favorite, _selectedMode == AIMode.teselli),
                ),
                PopupMenuItem(
                  value: AIMode.ibadet,
                  child: _buildModeItem('İbadet Yardımı', Icons.mosque, _selectedMode == AIMode.ibadet),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            // Mode indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: theme.colorScheme.surfaceContainerHighest,
              child: Row(
                children: [
                  Icon(_getModeIcon(_selectedMode), size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    _getModeName(_selectedMode),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Chat messages
            Expanded(
              child: BlocConsumer<IslamAIBloc, IslamAIState>(
                listener: (context, state) {
                  if (state is IslamAILoaded) {
                    _scrollToBottom();
                  }
                },
                builder: (context, state) {
                  if (state is IslamAIInitial) {
                    return _buildWelcomeScreen(context);
                  }
                  
                  if (state is IslamAILoading) {
                    return _buildChatList(context, showTyping: true);
                  }
                  
                  if (state is IslamAILoaded) {
                    return _buildChatList(context, messages: state.messages);
                  }
                  
                  if (state is IslamAIError) {
                    return Center(child: Text(state.message));
                  }
                  
                  return const SizedBox.shrink();
                },
              ),
            ),
            
            // Input area
            _buildInputArea(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              'İslam-AI Asistan',
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Dini sorularınızı kaynaklı cevaplarla yanıtlayan akıllı asistanınız.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSuggestionChip(context, 'Abdest nasıl alınır?'),
                _buildSuggestionChip(context, 'Zekat kimlere verilir?'),
                _buildSuggestionChip(context, 'Oruç bozulur mu?'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(BuildContext context, String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        _controller.text = text;
        _sendMessage(context);
      },
    );
  }

  Widget _buildChatList(BuildContext context, {List<ChatMessage>? messages, bool showTyping = false}) {
    final bloc = context.read<IslamAIBloc>();
    final allMessages = messages ?? (bloc.state is IslamAILoaded ? (bloc.state as IslamAILoaded).messages : []);
    
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: allMessages.length + (showTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (showTyping && index == allMessages.length) {
          return _buildTypingIndicator();
        }
        return _buildMessageBubble(context, allMessages[index]);
      },
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage message) {
    final theme = Theme.of(context);
    final isUser = message.isUser;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isUser ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? Colors.white : theme.colorScheme.onSurface,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            _buildDot(1),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.3 + (value * 0.7)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildInputArea(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Sorunuzu yazın...',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(context),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () => _sendMessage(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeItem(String title, IconData icon, bool isSelected) {
    return Row(
      children: [
        Icon(icon, size: 20, color: isSelected ? AppTheme.primaryGreen : Colors.grey),
        const SizedBox(width: 12),
        Text(title),
        if (isSelected) ...[
          const Spacer(),
          Icon(Icons.check, size: 16, color: AppTheme.primaryGreen),
        ],
      ],
    );
  }

  void _sendMessage(BuildContext context) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    context.read<IslamAIBloc>().add(AskQuestion(question: text, mode: _selectedMode));
    _controller.clear();
  }

  IconData _getModeIcon(AIMode mode) {
    switch (mode) {
      case AIMode.fetva: return Icons.menu_book;
      case AIMode.teselli: return Icons.favorite;
      case AIMode.ibadet: return Icons.mosque;
    }
  }

  String _getModeName(AIMode mode) {
    switch (mode) {
      case AIMode.fetva: return 'Fetva Modu';
      case AIMode.teselli: return 'Manevi Destek';
      case AIMode.ibadet: return 'İbadet Yardımı';
    }
  }
}
