import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/localization/app_localizations.dart';
import 'policy_detail_screen.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  String _version = '1.0.0';
  String _buildNumber = '1';

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = info.version;
      _buildNumber = info.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.translate('about_us'), style: TextStyle(color: colorScheme.onBackground, fontSize: 18)),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onBackground),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // App Logo
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        image: const DecorationImage(
                          image: AssetImage('assets/images/logo.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'EnglishHub',
                    style: TextStyle(
                      color: colorScheme.onBackground,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.translate('app_version', params: {'version': '$_version+$_buildNumber'}),
                    style: TextStyle(color: colorScheme.onBackground.withOpacity(0.6), fontSize: 14),
                  ),
                  const SizedBox(height: 40),
                  
                  // Latest Version Installed Row
                  _buildStatusRow(l10n.translate('latest_version_installed'), Icons.check_circle, Colors.greenAccent),
                  
                  const SizedBox(height: 24),
                  
                  // Policy Buttons
                  _buildPolicyItem(
                    context,
                    l10n.translate('terms_of_service'),
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PolicyDetailScreen(type: 'TERMS'),
                      ),
                    ),
                  ),
                  _buildDivider(),
                  _buildPolicyItem(
                    context,
                    l10n.translate('privacy_policy'),
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PolicyDetailScreen(type: 'PRIVACY'),
                      ),
                    ),
                  ),
                  _buildDivider(),
                ],
              ),
            ),
          ),
          
          // Company Footer
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0, top: 20.0),
            child: Column(
              children: [
                Text(
                  l10n.translate('company_footer'),
                  style: TextStyle(color: colorScheme.onBackground.withOpacity(0.3), fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'Copyright © 2024 EnglishHub. All rights reserved.',
                  style: TextStyle(color: colorScheme.onBackground.withOpacity(0.2), fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String text, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildPolicyItem(BuildContext context, String title, VoidCallback onTap) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(title, style: TextStyle(color: theme.colorScheme.onBackground, fontSize: 15)),
      trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onBackground.withOpacity(0.5), size: 20),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Divider(color: Theme.of(context).dividerTheme.color, height: 1),
    );
  }
}
