import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:jyoti_ai/models/models.dart';
import 'package:jyoti_ai/providers/jyoti_provider.dart';
import 'package:jyoti_ai/theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<JyotiProvider>();
      if (provider.dailyReading == null) {
        provider.loadDailyData();
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JyotiTheme.background,
      body: Consumer<JyotiProvider>(
        builder: (context, provider, _) {
          final user = provider.user;
          final reading = provider.dailyReading;
          final panchang = provider.panchang;
          final rashiColor = Color(user.rashi.color);

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 80,
                floating: false,
                pinned: true,
                backgroundColor: JyotiTheme.background,
                surfaceTintColor: Colors.transparent,
                title: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: JyotiTheme.goldGradient,
                      ),
                      child: const Center(
                        child: Text('🕉️', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Jyoti AI',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: JyotiTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                actions: [
                  // Points badge
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        JyotiTheme.radiusFull,
                      ),
                      color: JyotiTheme.gold.withValues(alpha: 0.15),
                      border: Border.all(
                        color: JyotiTheme.gold.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('✨', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          '${user.points}',
                          style: const TextStyle(
                            color: JyotiTheme.goldLight,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: JyotiTheme.spacingMd,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting
                      _buildGreeting(user),
                      const SizedBox(height: JyotiTheme.spacingLg),

                      // Tier + Streak row
                      _buildTierStreak(user),
                      const SizedBox(height: JyotiTheme.spacingLg),

                      // Daily Reading Card
                      if (provider.isReadingLoading)
                        _buildLoadingSkeleton()
                      else if (reading != null)
                        _buildDailyReadingCard(context, reading, rashiColor),

                      const SizedBox(height: JyotiTheme.spacingMd),

                      // Panchang
                      if (panchang != null) _buildPanchangCard(panchang),

                      const SizedBox(height: JyotiTheme.spacingMd),

                      // Quick Actions
                      _buildQuickActions(context),

                      const SizedBox(height: JyotiTheme.spacingMd),

                      // Today's Muhurat
                      _buildMuhuratCard(),

                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGreeting(UserProfile user) {
    final hour = DateTime.now().hour;
    String greeting;
    String emoji;
    if (hour < 12) {
      greeting = 'Shubh Prabhat';
      emoji = '🌅';
    } else if (hour < 17) {
      greeting = 'Shubh Dopahar';
      emoji = '☀️';
    } else {
      greeting = 'Shubh Sandhya';
      emoji = '🌙';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$emoji $greeting, ${user.name}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: JyotiTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
          style: const TextStyle(color: JyotiTheme.textMuted, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildTierStreak(UserProfile user) {
    final tierColor = Color(user.tier.color);
    return Row(
      children: [
        // Tier badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(JyotiTheme.radiusFull),
            color: tierColor.withValues(alpha: 0.15),
            border: Border.all(color: tierColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(user.tier.emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                '${user.tier.label} Tier',
                style: TextStyle(
                  color: tierColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: JyotiTheme.spacingSm),
        // Streak
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(JyotiTheme.radiusFull),
            color: JyotiTheme.surfaceVariant,
            border: Border.all(color: JyotiTheme.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                '${user.loginStreak} day streak',
                style: const TextStyle(
                  color: JyotiTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailyReadingCard(BuildContext context, DailyReading reading, Color rashiColor) {
    final scoreStars =
        '★' * reading.overallScore.round() +
        '☆' * (5 - reading.overallScore.round());

    return Container(
      padding: const EdgeInsets.all(JyotiTheme.spacingMd),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(JyotiTheme.radiusLg),
        gradient: LinearGradient(
          colors: [rashiColor.withValues(alpha: 0.08), JyotiTheme.cardBg],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: rashiColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(JyotiTheme.radiusSm),
                  color: rashiColor.withValues(alpha: 0.15),
                ),
                child: Center(
                  child: Text(
                    reading.rashi.symbol,
                    style: TextStyle(fontSize: 22, color: rashiColor),
                  ),
                ),
              ),
              const SizedBox(width: JyotiTheme.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${reading.rashi.label} (${reading.rashi.english})',
                      style: TextStyle(
                        color: rashiColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Today\'s Reading',
                      style: TextStyle(
                        color: rashiColor.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Score
              Column(
                children: [
                  Text(
                    scoreStars,
                    style: TextStyle(
                      color: JyotiTheme.gold,
                      fontSize: 14,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    '${reading.overallScore}/5',
                    style: const TextStyle(
                      color: JyotiTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: JyotiTheme.spacingMd),
          const Divider(color: JyotiTheme.borderSubtle),
          const SizedBox(height: JyotiTheme.spacingSm),

          // Summary
          Text(
            reading.summary,
            style: const TextStyle(
              color: JyotiTheme.textSecondary,
              fontSize: 14,
              height: 1.7,
            ),
          ),

          const SizedBox(height: JyotiTheme.spacingMd),

          // Lucky row
          Row(
            children: [
              _miniTag('🎨 ${reading.luckyColor}', rashiColor),
              const SizedBox(width: 8),
              _miniTag('🔢 ${reading.luckyNumber}', rashiColor),
              const SizedBox(width: 8),
              _miniTag('⏰ ${reading.favorableTime}', rashiColor),
            ],
          ),

          const SizedBox(height: JyotiTheme.spacingMd),

          // Remedy
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(JyotiTheme.spacingSm + 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(JyotiTheme.radiusSm),
              color: JyotiTheme.gold.withValues(alpha: 0.08),
              border: Border.all(
                color: JyotiTheme.gold.withValues(alpha: 0.15),
              ),
            ),
            child: Text(
              reading.remedy,
              style: const TextStyle(
                color: JyotiTheme.goldLight,
                fontSize: 13,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: JyotiTheme.spacingMd),

          // Share button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showUnderWorking(context),
              icon: Icon(Icons.share_rounded, size: 18, color: rashiColor),
              label: Text(
                'Share Reading & Earn 50 pts',
                style: TextStyle(color: rashiColor),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: rashiColor.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(JyotiTheme.radiusMd),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniTag(String text, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(JyotiTheme.radiusSm),
          color: color.withValues(alpha: 0.08),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color.withValues(alpha: 0.8),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPanchangCard(PanchangData p) {
    return Container(
      padding: const EdgeInsets.all(JyotiTheme.spacingMd),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(JyotiTheme.radiusLg),
        color: JyotiTheme.cardBg,
        border: Border.all(color: JyotiTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📅', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              const Text(
                'Aaj Ka Panchang',
                style: TextStyle(
                  color: JyotiTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: JyotiTheme.spacingMd),
          _panchangRow('Tithi', p.tithi),
          _panchangRow('Nakshatra', p.nakshatra),
          _panchangRow('Yoga', p.yoga),
          _panchangRow('Karana', p.karana),
          const Divider(color: JyotiTheme.borderSubtle, height: 20),
          _panchangRow('🌅 Sunrise', p.sunrise),
          _panchangRow('🌇 Sunset', p.sunset),
          _panchangRow('⚠️ Rahu Kaal', p.rahuKaal),
        ],
      ),
    );
  }

  Widget _panchangRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: JyotiTheme.textMuted, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(
              color: JyotiTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: JyotiTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: JyotiTheme.spacingSm),
        Row(
          children: [
            _actionTile('💬', 'Ask Jyoti', '20 pts', JyotiTheme.gold, () => _showUnderWorking(context)),
            const SizedBox(width: 10),
            _actionTile('📜', 'Kundli', '30 pts', JyotiTheme.cosmic, () => _showUnderWorking(context)),
            const SizedBox(width: 10),
            _actionTile('💕', 'Match', '40 pts', const Color(0xFFEF4444), () => _showUnderWorking(context)),
          ],
        ),
      ],
    );
  }

  Widget _actionTile(String emoji, String label, String cost, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(JyotiTheme.spacingMd),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(JyotiTheme.radiusMd),
            color: color.withValues(alpha: 0.06),
            border: Border.all(color: color.withValues(alpha: 0.15)),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                cost,
                style: TextStyle(
                  color: color.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMuhuratCard() {
    return Container(
      padding: const EdgeInsets.all(JyotiTheme.spacingMd),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(JyotiTheme.radiusLg),
        color: JyotiTheme.cardBg,
        border: Border.all(color: JyotiTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🕐', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text(
                'Shubh Muhurat',
                style: TextStyle(
                  color: JyotiTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: JyotiTheme.spacingMd),
          _muhuratRow('Work / Business', '10:00 AM – 12:30 PM', '✅'),
          _muhuratRow('Travel', '2:00 PM – 4:00 PM', '✅'),
          _muhuratRow('Finance', '11:00 AM – 1:00 PM', '✅'),
          _muhuratRow('Avoid', '10:30 AM – 12:00 PM (Rahu Kaal)', '⚠️'),
        ],
      ),
    );
  }

  Widget _muhuratRow(String activity, String time, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(status, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              activity,
              style: const TextStyle(
                color: JyotiTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: JyotiTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Shimmer.fromColors(
      baseColor: JyotiTheme.surfaceVariant,
      highlightColor: JyotiTheme.border,
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: JyotiTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(JyotiTheme.radiusLg),
        ),
      ),
    );
  }
}
