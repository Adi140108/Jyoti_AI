import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:jyoti_ai/models/models.dart';
import 'package:jyoti_ai/providers/jyoti_provider.dart';
import 'package:jyoti_ai/theme/app_theme.dart';
import 'package:jyoti_ai/screens/onboarding_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JyotiTheme.background,
      body: Consumer<JyotiProvider>(
        builder: (context, provider, _) {
          final user = provider.user;
          final tierColor = Color(user.tier.color);
          final rashiColor = Color(user.rashi.color);

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
                  'Profile',
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
                      // Profile card
                      Container(
                        padding: const EdgeInsets.all(JyotiTheme.spacingLg),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            JyotiTheme.radiusLg,
                          ),
                          color: JyotiTheme.cardBg,
                          border: Border.all(color: JyotiTheme.border),
                        ),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: JyotiTheme.goldGradient,
                              ),
                              child: Center(
                                child: Text(
                                  user.name.isNotEmpty
                                      ? user.name[0].toUpperCase()
                                      : 'J',
                                  style: const TextStyle(
                                    color: Color(0xFF1A1A2E),
                                    fontSize: 26,
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
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      color: JyotiTheme.textPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      // Tier
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            JyotiTheme.radiusFull,
                                          ),
                                          color: tierColor.withValues(
                                            alpha: 0.15,
                                          ),
                                        ),
                                        child: Text(
                                          '${user.tier.emoji} ${user.tier.label}',
                                          style: TextStyle(
                                            color: tierColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      // Rashi
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            JyotiTheme.radiusFull,
                                          ),
                                          color: rashiColor.withValues(
                                            alpha: 0.15,
                                          ),
                                        ),
                                        child: Text(
                                          '${user.rashi.symbol} ${user.rashi.label}',
                                          style: TextStyle(
                                            color: rashiColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: JyotiTheme.spacingMd),

                      // Kundli Details
                      _sectionTitle('Kundli Details'),
                      const SizedBox(height: JyotiTheme.spacingSm),
                      _settingsGroup([
                        _SettingItem(
                          icon: Icons.calendar_month_outlined,
                          title: 'Date of Birth',
                          value:
                              '${user.dateOfBirth.day}/${user.dateOfBirth.month}/${user.dateOfBirth.year}',
                        ),
                        _SettingItem(
                          icon: Icons.access_time_rounded,
                          title: 'Time of Birth',
                          value: user.timeOfBirth,
                        ),
                        _SettingItem(
                          icon: Icons.location_on_outlined,
                          title: 'Place of Birth',
                          value: user.placeOfBirth,
                        ),
                        _SettingItem(
                          icon: Icons.auto_awesome_rounded,
                          title: 'Nakshatra',
                          value: user.nakshatra,
                        ),
                      ]),

                      const SizedBox(height: JyotiTheme.spacingLg),

                      // Change Rashi
                      _sectionTitle('Moon Sign'),
                      const SizedBox(height: JyotiTheme.spacingSm),
                      SizedBox(
                        height: 80,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: Rashi.values.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, index) {
                            final rashi = Rashi.values[index];
                            final isSelected = user.rashi == rashi;
                            final color = Color(rashi.color);

                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                provider.setRashi(rashi);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 66,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    JyotiTheme.radiusMd,
                                  ),
                                  color: isSelected
                                      ? color.withValues(alpha: 0.15)
                                      : JyotiTheme.cardBg,
                                  border: Border.all(
                                    color: isSelected
                                        ? color.withValues(alpha: 0.4)
                                        : JyotiTheme.border,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      rashi.symbol,
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: isSelected
                                            ? color
                                            : JyotiTheme.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      rashi.label,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: isSelected
                                            ? color
                                            : JyotiTheme.textSubtle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: JyotiTheme.spacingLg),

                      // Settings
                      _sectionTitle('Preferences'),
                      const SizedBox(height: JyotiTheme.spacingSm),
                      _settingsGroup([
                        _SettingItem(
                          icon: Icons.language_rounded,
                          title: 'Language',
                          value: user.language,
                          onTap: () => _showLanguagePicker(context, user.language, provider),
                        ),
                        _SettingItem(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          value: 'Enabled',
                        ),
                        _SettingItem(
                          icon: provider.isDarkMode
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                          title: 'Theme',
                          value: provider.isDarkMode ? 'Dark' : 'Light',
                          onTap: () => provider.toggleTheme(),
                        ),
                      ]),

                      const SizedBox(height: JyotiTheme.spacingLg),

                      _sectionTitle('About'),
                      const SizedBox(height: JyotiTheme.spacingSm),
                      _settingsGroup([
                        _SettingItem(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          value: '',
                        ),
                        _SettingItem(
                          icon: Icons.description_outlined,
                          title: 'Terms of Service',
                          value: '',
                        ),
                        _SettingItem(
                          icon: Icons.help_outline_rounded,
                          title: 'Help & FAQ',
                          value: '',
                        ),
                        _SettingItem(
                          icon: Icons.info_outline_rounded,
                          title: 'Version',
                          value: '1.0.0',
                        ),
                      ]),

                      const SizedBox(height: JyotiTheme.spacingXl),

                      // Sign out
                      Center(
                        child: TextButton(
                          onPressed: () => _showSignOutDialog(context, provider),
                          child: const Text(
                            'Sign Out',
                            style: TextStyle(
                              color: JyotiTheme.error,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: JyotiTheme.spacingSm),
                      const Center(
                        child: Text(
                          'Made with 🪷 in India',
                          style: TextStyle(
                            color: JyotiTheme.textSubtle,
                            fontSize: 12,
                          ),
                        ),
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

  void _showSignOutDialog(BuildContext context, JyotiProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: JyotiTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(JyotiTheme.radiusLg),
        ),
        title: const Text(
          'Sign Out',
          style: TextStyle(
            color: JyotiTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Are you sure you want to sign out? All your data including chat history, streak, and points will be cleared.',
          style: TextStyle(color: JyotiTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: JyotiTheme.textMuted),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog
              await provider.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, a, __) => const OnboardingScreen(),
                    transitionsBuilder: (_, a, __, child) =>
                        FadeTransition(opacity: a, child: child),
                    transitionDuration: const Duration(milliseconds: 500),
                  ),
                  (_) => false, // Remove all routes
                );
              }
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(
                color: JyotiTheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, String currentLanguage, JyotiProvider provider) {
    final List<String> languages = [
      'English',
      'Hinglish',
      'Hindi',
      'Telugu (Eng script)',
      'Kannada (Eng script)',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: JyotiTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(JyotiTheme.radiusXl)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: JyotiTheme.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Language',
                style: TextStyle(
                  color: JyotiTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: JyotiTheme.spacingLg),
              ...languages.map((lang) {
                final isSelected = currentLanguage == lang;
                return ListTile(
                  title: Text(
                    lang,
                    style: TextStyle(
                      color: isSelected ? JyotiTheme.gold : JyotiTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: JyotiTheme.gold)
                      : null,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    provider.setLanguage(lang);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: JyotiTheme.textSubtle,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }

  Widget _settingsGroup(List<_SettingItem> items) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(JyotiTheme.radiusLg),
        color: JyotiTheme.cardBg,
        border: Border.all(color: JyotiTheme.border),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          final isLast = idx == items.length - 1;

          return Column(
            children: [
              InkWell(
                onTap: item.onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: JyotiTheme.spacingMd,
                    vertical: JyotiTheme.spacingMd - 2,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            JyotiTheme.radiusSm,
                          ),
                          color: JyotiTheme.surfaceVariant,
                        ),
                        child: Icon(
                          item.icon,
                          color: JyotiTheme.textSecondary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: JyotiTheme.spacingMd),
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            color: JyotiTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (item.value.isNotEmpty)
                        Text(
                          item.value,
                          style: const TextStyle(
                            color: JyotiTheme.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: JyotiTheme.textSubtle,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.only(left: 68),
                  child: Divider(height: 1, color: JyotiTheme.border),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _SettingItem({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });
}
