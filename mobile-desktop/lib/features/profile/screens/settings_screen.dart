import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/font_size_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../faq/screens/faq_list_screen.dart';
import '../../auth/screens/login_screen.dart';
import '../../../data/services/auth_api.dart';
import 'about_us_screen.dart';
import 'delete_account_screen.dart';
import 'wallet_screen.dart';
import '../../feedback/screens/feedback_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    debugPrint('[SettingsScreen] build – currentLocale: ${Localizations.localeOf(context)}');
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    
    String currentLanguageCode = localeProvider.locale?.languageCode ?? Localizations.localeOf(context).languageCode;
    String currentLanguageName = _getLanguageName(currentLanguageCode, l10n);

    String currentFontSizeName = _getFontSizeName(fontSizeProvider.level, l10n);
    String currentThemeName = _getThemeModeName(themeProvider.themeMode, l10n);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.translate('settings'), style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        children: [
          // Basic Functionality
          _buildSection([
            _buildSettingsItem(
              l10n.translate('language_settings'), 
              trailingText: currentLanguageName,
              onTap: () => _showLanguageDialog(context),
            ),
            _buildDivider(indent: 16),
            _buildSettingsItem(l10n.translate('learning_reminders')),
            _buildDivider(indent: 16),
            _buildSettingsSwitch(l10n.translate('night_mode'), themeProvider.themeMode == ThemeMode.dark, (value) {
              debugPrint('[SettingsScreen] Night Mode toggled: $value');
              themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
            }),
            _buildDivider(indent: 16),
            _buildSettingsItem(
              l10n.translate('font_size'),
              trailingText: currentFontSizeName,
              onTap: () => _showFontSizeDialog(context),
            ),
          ]),
          
          const SizedBox(height: 24), // Spacing between sections

          // Account & Support
          _buildSection([
            _buildSettingsItem(
              l10n.translate('faq'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FAQListScreen()),
              ),
            ),
            _buildDivider(indent: 16),
            _buildSettingsItem(
              'Ví xu của tôi',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WalletScreen()),
              ),
            ),
            _buildDivider(indent: 16),
            _buildSettingsItem(l10n.translate('clear_cache')),
            _buildDivider(indent: 16),
            _buildSettingsItem(
              l10n.translate('about_us'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutUsScreen()),
              ),
            ),
            _buildDivider(indent: 16),
            _buildSettingsItem(
              l10n.translate('feedback'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FeedbackScreen()),
              ),
            ),
          ]),
          
          const SizedBox(height: 24), // Spacing between sections

          // Danger Zone
          _buildSection([
            _buildSettingsItem(
              l10n.translate('delete_account'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DeleteAccountScreen()),
              ),
            ),
          ]),
          
          const SizedBox(height: 32),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton(
              onPressed: () async {
                debugPrint('[SettingsScreen] Logging out...');
                await AuthApi.logout();
                if (!mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: Text(l10n.translate('logout'), style: const TextStyle(color: Colors.redAccent, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  String _getLanguageName(String code, AppLocalizations l10n) {
    if (code == 'en') return 'English';
    if (code == 'zh') return 'Tiếng Trung (汉语)';
    return 'Tiếng Việt';
  }

  String _getFontSizeName(FontSizeLevel level, AppLocalizations l10n) {
    switch (level) {
      case FontSizeLevel.small:
        return l10n.translate('font_size_small');
      case FontSizeLevel.medium:
        return l10n.translate('font_size_medium');
      case FontSizeLevel.large:
        return l10n.translate('font_size_large');
      case FontSizeLevel.extraLarge:
        return l10n.translate('font_size_xlarge');
    }
  }

  Widget _buildSettingsItem(String title, {String? trailingText, VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(title, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 15)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(trailingText, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 14)),
          if (trailingText != null) const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withOpacity(0.5), size: 20),
        ],
      ),
      onTap: onTap ?? () {},
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
    );
  }

  Widget _buildSettingsSwitch(String title, bool value, ValueChanged<bool> onChanged) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(title, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 15)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white,
        activeTrackColor: theme.colorScheme.primary,
        inactiveThumbColor: Colors.grey,
        inactiveTrackColor: Colors.grey.withOpacity(0.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
    );
  }

  Widget _buildSection(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDivider({double indent = 0}) {
    return Divider(color: Theme.of(context).dividerTheme.color?.withOpacity(0.5) ?? Colors.grey.withOpacity(0.2), height: 1, thickness: 1, indent: indent);
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.translate('select_language'),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildLanguageOption(context, 'Tiếng Việt', 'vi', localeProvider),
              _buildLanguageOption(context, 'English', 'en', localeProvider),
              _buildLanguageOption(context, 'Tiếng Trung (汉语)', 'zh', localeProvider),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.translate('cancel'), style: const TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context, String name, String code, LocaleProvider provider) {
    bool isSelected = provider.locale?.languageCode == code || (provider.locale == null && code == 'vi');
    final theme = Theme.of(context);
    
    return ListTile(
      title: Text(name, style: TextStyle(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface)),
      trailing: isSelected ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
      onTap: () {
        provider.setLocale(Locale(code));
        Navigator.pop(context);
        debugPrint('[SettingsScreen] Language changed to $code');
      },
    );
  }

  void _showFontSizeDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fontSizeProvider = Provider.of<FontSizeProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.translate('font_size'),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildFontSizeOption(context, l10n.translate('font_size_small'), FontSizeLevel.small, fontSizeProvider),
              _buildFontSizeOption(context, l10n.translate('font_size_medium'), FontSizeLevel.medium, fontSizeProvider),
              _buildFontSizeOption(context, l10n.translate('font_size_large'), FontSizeLevel.large, fontSizeProvider),
              _buildFontSizeOption(context, l10n.translate('font_size_xlarge'), FontSizeLevel.extraLarge, fontSizeProvider),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.translate('cancel'), style: const TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFontSizeOption(BuildContext context, String name, FontSizeLevel level, FontSizeProvider provider) {
    bool isSelected = provider.level == level;
    final theme = Theme.of(context);
    
    return ListTile(
      title: Text(name, style: TextStyle(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface)),
      trailing: isSelected ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
      onTap: () {
        provider.setFontSizeLevel(level);
        Navigator.pop(context);
        debugPrint('[SettingsScreen] Font size changed to $level');
      },
    );
  }

  String _getThemeModeName(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.translate('theme_light');
      case ThemeMode.dark:
        return l10n.translate('theme_dark');
      case ThemeMode.system:
        return l10n.translate('theme_system');
    }
  }
}