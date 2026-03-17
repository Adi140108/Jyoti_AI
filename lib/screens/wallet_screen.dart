import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:jyoti_ai/models/models.dart';
import 'package:jyoti_ai/providers/jyoti_provider.dart';
import 'package:jyoti_ai/theme/app_theme.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

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
          final tierColor = Color(user.tier.color);
          final nextTier = _getNextTier(user.tier);
          final progress = _getTierProgress(user);

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 80,
                floating: false,
                pinned: true,
                backgroundColor: JyotiTheme.background,
                surfaceTintColor: Colors.transparent,
                title: const Text(
                  'Points & Wallet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: JyotiTheme.textPrimary,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: JyotiTheme.spacingMd,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Balance card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(JyotiTheme.spacingLg),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            JyotiTheme.radiusLg,
                          ),
                          gradient: LinearGradient(
                            colors: [
                              JyotiTheme.gold.withValues(alpha: 0.15),
                              JyotiTheme.cosmicDark.withValues(alpha: 0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: JyotiTheme.gold.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Available Points',
                              style: TextStyle(
                                color: JyotiTheme.textMuted,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('✨', style: TextStyle(fontSize: 28)),
                                const SizedBox(width: 8),
                                Text(
                                  '${user.points}',
                                  style: const TextStyle(
                                    color: JyotiTheme.goldLight,
                                    fontSize: 42,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '~${(user.points / 20).round()} min talk time',
                              style: const TextStyle(
                                color: JyotiTheme.textSubtle,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: JyotiTheme.spacingMd),

                            // Tier progress
                            Row(
                              children: [
                                Text(
                                  '${user.tier.emoji} ${user.tier.label}',
                                  style: TextStyle(
                                    color: tierColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                if (nextTier != null)
                                  Text(
                                    '${nextTier.emoji} ${nextTier.label}',
                                    style: TextStyle(
                                      color: Color(
                                        nextTier.color,
                                      ).withValues(alpha: 0.6),
                                      fontSize: 13,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                JyotiTheme.radiusFull,
                              ),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: JyotiTheme.surfaceVariant,
                                valueColor: AlwaysStoppedAnimation(tierColor),
                                minHeight: 6,
                              ),
                            ),
                            if (nextTier != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                '${nextTier.minPoints - user.lifetimePoints} pts to ${nextTier.label}',
                                style: const TextStyle(
                                  color: JyotiTheme.textSubtle,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: JyotiTheme.spacingLg),

                      // Buy Points header
                      const Text(
                        'Buy Points',
                        style: TextStyle(
                          color: JyotiTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: JyotiTheme.spacingSm),

                      // Points Packs
                      ...PointsPack.packs.map(
                        (pack) => _buildPackCard(context, pack, provider),
                      ),

                      const SizedBox(height: JyotiTheme.spacingLg),

                      // Earn Points section
                      const Text(
                        'Earn Free Points',
                        style: TextStyle(
                          color: JyotiTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: JyotiTheme.spacingSm),

                      _buildEarnTile(
                        context,
                        'Daily Login',
                        '+10 pts / day',
                        Icons.calendar_today_rounded,
                        JyotiTheme.gold,
                      ),
                      _buildEarnTile(
                        context,
                        'Share Reading',
                        '+50 pts / share',
                        Icons.share_rounded,
                        JyotiTheme.cosmic,
                      ),
                      _buildEarnTile(
                        context,
                        'Refer a Friend',
                        '+200 pts / signup',
                        Icons.group_add_rounded,
                        JyotiTheme.success,
                      ),
                      _buildEarnTile(
                        context,
                        '7-Day Streak',
                        '+200 pts bonus',
                        Icons.local_fire_department_rounded,
                        const Color(0xFFFF8C00),
                      ),
                      _buildEarnTile(
                        context,
                        'Rate a Reading',
                        '+15 pts (max 3/day)',
                        Icons.star_rounded,
                        JyotiTheme.goldLight,
                      ),
                      _buildEarnTile(
                        context,
                        'Complete Kundli',
                        '+100 pts (one-time)',
                        Icons.description_rounded,
                        JyotiTheme.info,
                      ),

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

  Widget _buildPackCard(
    BuildContext context,
    PointsPack pack,
    JyotiProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          // Simulate purchase
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: JyotiTheme.cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(JyotiTheme.radiusLg),
              ),
              title: Text(
                'Buy ${pack.name} Pack?',
                style: const TextStyle(color: JyotiTheme.textPrimary),
              ),
              content: Text(
                '₹${pack.priceRs} for ${pack.points} points (${pack.talkTime} talk time)',
                style: const TextStyle(color: JyotiTheme.textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    provider.addPoints(pack.points);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '✨ ${pack.points} points added!',
                          style: const TextStyle(color: JyotiTheme.textPrimary),
                        ),
                        backgroundColor: JyotiTheme.surface,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            JyotiTheme.radiusSm,
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Buy Now'),
                ),
              ],
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(JyotiTheme.spacingMd),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(JyotiTheme.radiusMd),
            color: JyotiTheme.cardBg,
            border: Border.all(
              color: pack.isBestValue
                  ? JyotiTheme.gold.withValues(alpha: 0.4)
                  : JyotiTheme.border,
              width: pack.isBestValue ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Points
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(JyotiTheme.radiusSm),
                  color: JyotiTheme.gold.withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Text(
                    '${pack.points}',
                    style: const TextStyle(
                      color: JyotiTheme.goldLight,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: JyotiTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          pack.name,
                          style: const TextStyle(
                            color: JyotiTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (pack.isBestValue) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                JyotiTheme.radiusFull,
                              ),
                              color: JyotiTheme.gold,
                            ),
                            child: const Text(
                              'BEST VALUE',
                              style: TextStyle(
                                color: Color(0xFF1A1A2E),
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${pack.talkTime} talk time',
                      style: const TextStyle(
                        color: JyotiTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Price
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(JyotiTheme.radiusMd),
                  gradient: pack.isBestValue ? JyotiTheme.goldGradient : null,
                  color: pack.isBestValue ? null : JyotiTheme.surfaceVariant,
                ),
                child: Text(
                  '₹${pack.priceRs}',
                  style: TextStyle(
                    color: pack.isBestValue
                        ? const Color(0xFF1A1A2E)
                        : JyotiTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEarnTile(
    BuildContext context,
    String title,
    String reward,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => _showUnderWorking(context),
        child: Container(
          padding: const EdgeInsets.all(JyotiTheme.spacingMd - 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(JyotiTheme.radiusMd),
            color: color.withValues(alpha: 0.05),
            border: Border.all(color: color.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(JyotiTheme.radiusSm),
                color: color.withValues(alpha: 0.12),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
              const SizedBox(width: JyotiTheme.spacingSm),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: JyotiTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                reward,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  UserTier? _getNextTier(UserTier current) {
    final tiers = UserTier.values;
    final idx = tiers.indexOf(current);
    if (idx < tiers.length - 1) return tiers[idx + 1];
    return null;
  }

  double _getTierProgress(UserProfile user) {
    final current = user.tier;
    final next = _getNextTier(current);
    if (next == null) return 1.0;

    final range = next.minPoints - current.minPoints;
    final progress = user.lifetimePoints - current.minPoints;
    return (progress / range).clamp(0.0, 1.0);
  }
}
