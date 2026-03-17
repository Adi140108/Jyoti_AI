import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:jyoti_ai/providers/jyoti_provider.dart';
import 'package:jyoti_ai/theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showUnderWorking(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'This feature is still under working.',
          style: TextStyle(color: JyotiTheme.textPrimary),
        ),
        backgroundColor: JyotiTheme.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(JyotiTheme.radiusSm),
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.mediumImpact();
    final provider = context.read<JyotiProvider>();
    provider.sendMessage(text);
    _controller.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 200,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JyotiTheme.background,
      appBar: AppBar(
        backgroundColor: JyotiTheme.surface,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: JyotiTheme.goldGradient,
              ),
              child: const Center(
                child: Text('🕉️', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Jyoti',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: JyotiTheme.textPrimary,
                  ),
                ),
                Consumer<JyotiProvider>(
                  builder: (_, p, __) => Text(
                    p.isChatLoading ? 'typing...' : 'AI Vedic Astrologer',
                    style: TextStyle(
                      fontSize: 12,
                      color: p.isChatLoading
                          ? JyotiTheme.goldLight
                          : JyotiTheme.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Points
          Consumer<JyotiProvider>(
            builder: (_, p, __) => Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(JyotiTheme.radiusFull),
                color: JyotiTheme.gold.withValues(alpha: 0.12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('✨', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    '${p.user.points}',
                    style: const TextStyle(
                      color: JyotiTheme.goldLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: Consumer<JyotiProvider>(
              builder: (context, provider, _) {
                if (provider.messages.isEmpty) {
                  return _buildEmptyChat();
                }

                return ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(JyotiTheme.spacingMd),
                  itemCount:
                      provider.messages.length +
                      (provider.isChatLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == provider.messages.length &&
                        provider.isChatLoading) {
                      return _buildTypingIndicator();
                    }
                    final msg = provider.messages[index];
                    return _buildMessageBubble(msg.text, msg.isUser);
                  },
                );
              },
            ),
          ),

          // Cost indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            color: JyotiTheme.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 12,
                  color: JyotiTheme.textSubtle,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Message cost depends on response length (~10-100 pts)',
                    style: TextStyle(color: JyotiTheme.textSubtle, fontSize: 11),
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
              ],
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.all(JyotiTheme.spacingMd),
            decoration: const BoxDecoration(
              color: JyotiTheme.surface,
              border: Border(top: BorderSide(color: JyotiTheme.border)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // Voice button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      _showUnderWorking(context);
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: JyotiTheme.surfaceVariant,
                        border: Border.all(color: JyotiTheme.border),
                      ),
                      child: const Icon(
                        Icons.mic_rounded,
                        color: JyotiTheme.textMuted,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: JyotiTheme.spacingSm),

                  // Text input
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      style: const TextStyle(
                        color: JyotiTheme.textPrimary,
                        fontSize: 15,
                      ),
                      maxLines: 3,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Apna sawaal poochein...',
                        hintStyle: const TextStyle(
                          color: JyotiTheme.textSubtle,
                        ),
                        filled: true,
                        fillColor: JyotiTheme.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            JyotiTheme.radius2xl,
                          ),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: JyotiTheme.spacingSm),

                  // Send button
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: JyotiTheme.goldGradient,
                        boxShadow: [
                          BoxShadow(
                            color: JyotiTheme.gold.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Color(0xFF1A1A2E),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(JyotiTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    JyotiTheme.gold.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
                border: Border.all(
                  color: JyotiTheme.gold.withValues(alpha: 0.2),
                ),
              ),
              child: const Center(
                child: Text('🔮', style: TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: JyotiTheme.spacingLg),
            const Text(
              'Jyoti Se Poochein',
              style: TextStyle(
                color: JyotiTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: JyotiTheme.spacingSm),
            const Text(
              'Aaj ke graho ke hisaab se apne sawalon ka jawaab paayein',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: JyotiTheme.textMuted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: JyotiTheme.spacingXl),

            // Suggested questions
            ...[
              'Aaj mera din kaisa rahega?',
              'Career mein kab progress hoga?',
              'Kya aaj travel karna theek hai?',
              'Love life ke baare mein batao',
            ].map(
              (q) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () {
                    _controller.text = q;
                    _sendMessage();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(JyotiTheme.radiusMd),
                      color: JyotiTheme.surfaceVariant,
                      border: Border.all(color: JyotiTheme.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: JyotiTheme.goldLight,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            q,
                            style: const TextStyle(
                              color: JyotiTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: JyotiTheme.textSubtle,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 12,
          left: isUser ? 60 : 0,
          right: isUser ? 0 : 60,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser
                ? const Radius.circular(16)
                : const Radius.circular(4),
            bottomRight: isUser
                ? const Radius.circular(4)
                : const Radius.circular(16),
          ),
          color: isUser
              ? JyotiTheme.gold.withValues(alpha: 0.15)
              : JyotiTheme.cardBg,
          border: Border.all(
            color: isUser
                ? JyotiTheme.gold.withValues(alpha: 0.25)
                : JyotiTheme.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🕉️', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      'Jyoti',
                      style: TextStyle(
                        color: JyotiTheme.goldLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              text,
              style: TextStyle(
                color: isUser ? JyotiTheme.goldLight : JyotiTheme.textSecondary,
                fontSize: 14.5,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, right: 60),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
          color: JyotiTheme.cardBg,
          border: Border.all(color: JyotiTheme.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🕉️', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 8),
            ...List.generate(3, (i) {
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.3, end: 1.0),
                duration: Duration(milliseconds: 600 + (i * 200)),
                curve: Curves.easeInOut,
                builder: (_, val, __) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: JyotiTheme.goldLight.withValues(alpha: val * 0.8),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
