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

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: JyotiTheme.background,
      body: DashboardContent(),
    );
  }
}

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const DashboardAppBar(),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: JyotiTheme.spacingMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GreetingWidget(),
                const SizedBox(height: JyotiTheme.spacingLg),
                const TierStreakWidget(),
                const SizedBox(height: JyotiTheme.spacingLg),
                const DailyReadingSection(),
                const SizedBox(height: JyotiTheme.spacingMd),
                const PanchangSection(),
                const SizedBox(height: JyotiTheme.spacingMd),
                const QuickActionsSection(),
                const SizedBox(height: JyotiTheme.spacingMd),
                const MuhuratCard(),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DashboardAppBar extends StatelessWidget {
  const DashboardAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
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
        Selector<JyotiProvider, int>(
          selector: (_, p) => p.user.points,
          builder: (_, points, __) => Container(
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
                  '$points',
                  style: const TextStyle(
                    color: JyotiTheme.goldLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class GreetingWidget extends StatelessWidget {
  const GreetingWidget({super.key});

  @override
  Widget build(BuildContext context) {
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

    return Selector<JyotiProvider, String>(
      selector: (_, p) => p.user.name,
      builder: (context, name, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$emoji $greeting, $name',
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
      },
    );
  }
}

class TierStreakWidget extends StatelessWidget {
  const TierStreakWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<JyotiProvider, UserProfile>(
      selector: (_, p) => p.user,
      builder: (context, user, _) {
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
      },
    );
  }
}

class DailyReadingSection extends StatelessWidget {
  const DailyReadingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<JyotiProvider, (bool, DailyReading?, Color)>(
      selector: (_, p) => (
        p.isReadingLoading,
        p.dailyReading,
        Color(p.user.rashi.color)
      ),
      builder: (context, data, _) {
        final (isLoading, reading, rashiColor) = data;

        if (isLoading) {
          return const LoadingSkeleton();
        } else if (reading != null) {
          return DailyReadingCard(reading: reading, rashiColor: rashiColor);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class DailyReadingCard extends StatelessWidget {
  final DailyReading reading;
  final Color rashiColor;

  const DailyReadingCard({
    super.key,
    required this.reading,
    required this.rashiColor,
  });

  @override
  Widget build(BuildContext context) {
    final scoreStars = '★' * reading.overallScore.round() +
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
                    style: const TextStyle(
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
              MiniTag(text: '🎨 ${reading.luckyColor}', color: rashiColor),
              const SizedBox(width: 8),
              MiniTag(text: '🔢 ${reading.luckyNumber}', color: rashiColor),
              const SizedBox(width: 8),
              MiniTag(text: '⏰ ${reading.favorableTime}', color: rashiColor),
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
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share feature under development')),
                );
              },
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
}

class MiniTag extends StatelessWidget {
  final String text;
  final Color color;

  const MiniTag({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
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
}

class PanchangSection extends StatelessWidget {
  const PanchangSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<JyotiProvider, PanchangData?>(
      selector: (_, p) => p.panchang,
      builder: (context, panchang, _) {
        if (panchang == null) return const SizedBox.shrink();
        return PanchangCard(p: panchang);
      },
    );
  }
}

class PanchangCard extends StatelessWidget {
  final PanchangData p;

  const PanchangCard({super.key, required this.p});

  @override
  Widget build(BuildContext context) {
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
              Text('📅', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text(
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
          PanchangRow(label: 'Tithi', value: p.tithi),
          PanchangRow(label: 'Nakshatra', value: p.nakshatra),
          PanchangRow(label: 'Yoga', value: p.yoga),
          PanchangRow(label: 'Karana', value: p.karana),
          const Divider(color: JyotiTheme.borderSubtle, height: 20),
          PanchangRow(label: '🌅 Sunrise', value: p.sunrise),
          PanchangRow(label: '🌇 Sunset', value: p.sunset),
          PanchangRow(label: '⚠️ Rahu Kaal', value: p.rahuKaal),
        ],
      ),
    );
  }
}

class PanchangRow extends StatelessWidget {
  final String label;
  final String value;

  const PanchangRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: JyotiTheme.textMuted, fontSize: 13),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: JyotiTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
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
            ActionTile(
              emoji: '💬',
              label: 'Ask Jyoti',
              cost: '20 pts',
              color: JyotiTheme.gold,
              onTap: () {},
            ),
            const SizedBox(width: 10),
            ActionTile(
              emoji: '📜',
              label: 'Kundli',
              cost: '30 pts',
              color: JyotiTheme.cosmic,
              onTap: () {},
            ),
            const SizedBox(width: 10),
            ActionTile(
              emoji: '💕',
              label: 'Match',
              cost: '40 pts',
              color: const Color(0xFFEF4444),
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class ActionTile extends StatelessWidget {
  final String emoji;
  final String label;
  final String cost;
  final Color color;
  final VoidCallback onTap;

  const ActionTile({
    super.key,
    required this.emoji,
    required this.label,
    required this.cost,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
}

class MuhuratCard extends StatelessWidget {
  const MuhuratCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(JyotiTheme.spacingMd),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(JyotiTheme.radiusLg),
        color: JyotiTheme.cardBg,
        border: Border.all(color: JyotiTheme.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          SizedBox(height: JyotiTheme.spacingMd),
          MuhuratRow(
            activity: 'Work / Business',
            time: '10:00 AM – 12:30 PM',
            status: '✅',
          ),
          MuhuratRow(
            activity: 'Travel',
            time: '2:00 PM – 4:00 PM',
            status: '✅',
          ),
          MuhuratRow(
            activity: 'Finance',
            time: '11:00 AM – 1:00 PM',
            status: '✅',
          ),
          MuhuratRow(
            activity: 'Avoid',
            time: '10:30 AM – 12:00 PM (Rahu Kaal)',
            status: '⚠️',
          ),
        ],
      ),
    );
  }
}

class MuhuratRow extends StatelessWidget {
  final String activity;
  final String time;
  final String status;

  const MuhuratRow({
    super.key,
    required this.activity,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
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
}

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
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
