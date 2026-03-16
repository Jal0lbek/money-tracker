import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import 'pin_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final theme = context.watch<ThemeProvider>();
    final bg = isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF0F4F8);
    final cardBg = isDark ? const Color(0xFF131929) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0A0E1A) : Colors.white,
        title: const Text('SOZLAMALAR'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('Ilova', isDark),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                _SettingsTile(
                  icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  iconColor: AppTheme.primaryGreen,
                  title: 'Qorong\'u rejim',
                  trailing: Switch(
                    value: isDark,
                    onChanged: (_) => theme.toggleTheme(),
                    activeColor: AppTheme.primaryGreen,
                  ),
                  isDark: isDark,
                ),
                Divider(height: 1, color: isDark ? const Color(0xFF1A2332) : const Color(0xFFF0F4F8)),
                _SettingsTile(
                  icon: Icons.lock_rounded,
                  iconColor: AppTheme.kartaColor,
                  title: 'PIN qulf',
                  subtitle: theme.pinEnabled ? 'Yoqilgan' : 'O\'chirilgan',
                  trailing: Switch(
                    value: theme.pinEnabled,
                    onChanged: (val) {
                      if (val) {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const PinScreen(isSetup: true),
                        ));
                      } else {
                        theme.disablePin();
                      }
                    },
                    activeColor: AppTheme.kartaColor,
                  ),
                  isDark: isDark,
                ),
                if (theme.pinEnabled) ...[
                  Divider(height: 1, color: isDark ? const Color(0xFF1A2332) : const Color(0xFFF0F4F8)),
                  _SettingsTile(
                    icon: Icons.edit_rounded,
                    iconColor: AppTheme.valyutaColor,
                    title: 'PINni o\'zgartirish',
                    isDark: isDark,
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const PinScreen(isSetup: true),
                    )),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),
          _sectionTitle('Ilova haqida', isDark),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.info_rounded,
                  iconColor: AppTheme.bankColor,
                  title: 'Versiya',
                  subtitle: '1.0.0',
                  isDark: isDark,
                ),
                Divider(height: 1, color: isDark ? const Color(0xFF1A2332) : const Color(0xFFF0F4F8)),
                _SettingsTile(
                  icon: Icons.code_rounded,
                  iconColor: AppTheme.primaryGreen,
                  title: 'Ishlab chiquvchi',
                  subtitle: 'Jalolbek Karimov',
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, bool isDark) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool isDark;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1A2332),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: TextStyle(color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF), fontSize: 12))
          : null,
      trailing: trailing ?? (onTap != null ? Icon(Icons.chevron_right_rounded, color: isDark ? const Color(0xFF4A5568) : const Color(0xFFD1D5DB)) : null),
    );
  }
}
