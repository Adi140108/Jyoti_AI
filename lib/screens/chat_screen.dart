import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:jyoti_ai/providers/jyoti_provider.dart';
import 'package:jyoti_ai/models/models.dart';
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
      drawer: const ChatHistoryDrawer(),
      appBar: AppBar(
        backgroundColor: JyotiTheme.surface,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: JyotiTheme.textPrimary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
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
                Selector<JyotiProvider, String>(
                  selector: (_, p) => p.currentSession?.title ?? 'Jyoti',
                  builder: (_, title, __) => Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: JyotiTheme.textPrimary,
                    ),
                  ),
                ),
                Selector<JyotiProvider, bool>(
                  selector: (_, p) => p.isChatLoading,
                  builder: (_, isLoading, __) => Text(
                    isLoading ? 'typing...' : 'AI Vedic Astrologer',
                    style: TextStyle(
                      fontSize: 12,
                      color: isLoading
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
          Selector<JyotiProvider, int>(
            selector: (_, p) => p.user.points,
            builder: (_, points, __) => Container(
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
                    '$points',
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
                final messages = provider.messages;
                final isLoading = provider.isChatLoading;

                if (messages.isEmpty && !isLoading) {
                  return const EmptyChatView();
                }

                return ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(JyotiTheme.spacingMd),
                  itemCount: messages.length + (isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length && isLoading) {
                      return const TypingIndicator();
                    }
                    final msg = messages[index];
                    return MessageBubble(text: msg.text, isUser: msg.isUser);
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
}

// Extracted Widget Components for Performance

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
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
                    const Text(
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
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Align(
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
      ),
    );
  }
}

class EmptyChatView extends StatelessWidget {
  const EmptyChatView({super.key});

  @override
  Widget build(BuildContext context) {
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
                    final provider = context.read<JyotiProvider>();
                    provider.sendMessage(q);
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
}

class ChatHistoryDrawer extends StatelessWidget {
  const ChatHistoryDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: JyotiTheme.background,
      child: SafeArea(
        child: Column(
          children: [
            // Header with New Chat button
            Padding(
              padding: const EdgeInsets.all(JyotiTheme.spacingMd),
              child: Column(
                children: [
                  const _DrawerHeader(),
                  const SizedBox(height: 20),
                  const PersonaSelectorhud(),
                  const SizedBox(height: 16),
                  const NewChatButton(),
                ],
              ),
            ),

            const Divider(color: JyotiTheme.border, height: 1),

            // Chat List
            const Expanded(
              child: ChatHistoryList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: JyotiTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: JyotiTheme.border),
          ),
          child: const Text('🔮', style: TextStyle(fontSize: 20)),
        ),
        const SizedBox(width: 12),
        const Text(
          'My Readings',
          style: TextStyle(
            color: JyotiTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class PersonaSelectorhud extends StatelessWidget {
  const PersonaSelectorhud({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: JyotiTheme.surface,
        borderRadius: BorderRadius.circular(JyotiTheme.radiusLg),
        border: Border.all(color: JyotiTheme.border),
      ),
      child: Row(
        children: Persona.values.map((p) {
          return Expanded(
            child: Selector<JyotiProvider, bool>(
              selector: (ctx, provider) => provider.persona == p,
              builder: (ctx, isSelected, _) {
                return GestureDetector(
                  onTap: () {
                    context.read<JyotiProvider>().setPersona(p);
                    HapticFeedback.lightImpact();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? JyotiTheme.background : Colors.transparent,
                      borderRadius: BorderRadius.circular(JyotiTheme.radiusMd),
                      border: Border.all(
                        color: isSelected
                            ? JyotiTheme.gold.withValues(alpha: 0.3)
                            : Colors.transparent,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: JyotiTheme.gold.withValues(alpha: 0.1),
                                blurRadius: 10,
                              )
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(p.emoji, style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 2),
                        Text(
                          p.name.split(' ').first,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? JyotiTheme.goldLight : JyotiTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class NewChatButton extends StatelessWidget {
  const NewChatButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<JyotiProvider>().startNewChat();
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: JyotiTheme.gold.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(JyotiTheme.radiusMd),
          border: Border.all(
            color: JyotiTheme.gold.withValues(alpha: 0.3),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: JyotiTheme.goldLight),
            SizedBox(width: 8),
            Text(
              'New Chat',
              style: TextStyle(
                color: JyotiTheme.goldLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatHistoryList extends StatelessWidget {
  const ChatHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<JyotiProvider, List<ChatSession>>(
      selector: (_, p) => p.sessions,
      builder: (context, sessions, _) {
        if (sessions.isEmpty) {
          return const Center(
            child: Text(
              'No chat history yet',
              style: TextStyle(color: JyotiTheme.textSubtle),
            ),
          );
        }
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            return ChatSessionTile(session: sessions[index]);
          },
        );
      },
    );
  }
}

class ChatSessionTile extends StatelessWidget {
  final ChatSession session;

  const ChatSessionTile({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Selector<JyotiProvider, String?>(
      selector: (_, p) => p.currentSessionId,
      builder: (context, currentId, _) {
        final isSelected = session.id == currentId;
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          child: InkWell(
            onTap: () {
              context.read<JyotiProvider>().switchSession(session.id);
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isSelected ? JyotiTheme.surface : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? JyotiTheme.gold.withValues(alpha: 0.2)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 18,
                    color: isSelected ? JyotiTheme.goldLight : JyotiTheme.textMuted,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      session.title,
                      style: TextStyle(
                        color: isSelected ? JyotiTheme.textPrimary : JyotiTheme.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.circle,
                      size: 8,
                      color: JyotiTheme.goldLight,
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      color: JyotiTheme.textSubtle,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        context.read<JyotiProvider>().deleteSession(session.id);
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
