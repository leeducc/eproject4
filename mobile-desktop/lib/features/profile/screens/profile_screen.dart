import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/services/icoin_service.dart';
import '../../../data/services/profile_api.dart';
import 'settings_screen.dart';
import 'upgrade_pro_screen.dart';
import 'edit_profile_screen.dart';
import 'favorite_questions_screen.dart';
import '../../chat/screens/chat_with_admin_screen.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/ielts_level_provider.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final profile = await ProfileApi.getProfile();
    if (mounted) {
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    }
  }

  String _getAvatarUrl(String? url) {
    if (url == null || url.isEmpty) return 'https://i.imgur.com/BoN9kdC.png';
    if (url.startsWith('http')) return url;
    final baseUrl = dotenv.env['API_BASE_URL']?.replaceAll('/api', '') ?? 'http://10.0.2.2:8123';
    return '$baseUrl$url';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(context),
                _buildPlusBanner(context),
                _buildStatsSection(context),
                const SizedBox(height: 10),
                _buildDivider(context),
                _buildMenuSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final fullName = _profile?['fullName'] ?? 'User';
    final avatarUrl = _getAvatarUrl(_profile?['avatarUrl']);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(initialProfile: _profile),
                    ),
                  );
                  if (result == true) {
                    _loadProfile();
                  }
                },
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: ClipOval(
                    child: Image.network(
                      avatarUrl,
                      fit: BoxFit.cover,
                      width: 56,
                      height: 56,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 56,
                          height: 56,
                          color: Colors.blue.withOpacity(0.1),
                          child: const Icon(Icons.person, color: Colors.blue, size: 30),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(fullName,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      const Icon(Icons.workspace_premium, color: Colors.grey, size: 20),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber, width: 1),
                    ),
                    child: FutureBuilder<int?>(
                      future: ICoinService.getBalance(),
                      builder: (context, snapshot) {
                        final balance = snapshot.data ?? 0;
                        return Row(
                          children: [
                            const Icon(Icons.monetization_on, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text('$balance iCoins',
                                style: const TextStyle(
                                    color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.qr_code_scanner, color: Theme.of(context).colorScheme.onSurface),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.settings, color: Theme.of(context).colorScheme.onSurface),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlusBanner(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UpgradeProScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.workspace_premium, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.translate('offer_ends_in', params: {'time': '00:59:14'}),
                        style: const TextStyle(color: Colors.white, fontSize: 10)),
                    const SizedBox(height: 4),
                    Text(l10n.translate('upgrade_plus_unlimited'),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ],
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ieltsProvider = Provider.of<IeltsLevelProvider>(context);
    final currentRange = ieltsProvider.selectedLevel.range;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.translate('current_level'),
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15)),
              Row(
                children: [
                  Text('IELTS $currentRange',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), size: 18),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(context, '1', l10n.translate('questions')),
              _buildStatItem(context, '0', l10n.translate('vocabulary'),
                  icon: Icons.star, iconColor: Colors.orange),
              _buildStatItem(context, '00:29', l10n.translate('learning_time')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label,
      {IconData? icon, Color? iconColor}) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 4),
            ],
            Text(value,
                style: TextStyle(
                    color: theme.colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 13)),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isTeacher = _profile?['role'] == 'TEACHER';

    return Column(
      children: [
        _buildMenuItem(context, Icons.smart_toy, Colors.blueAccent, 'Max'),
        if (isTeacher)
          _buildMenuItem(
            context, 
            Icons.chat, 
            Colors.green, 
            'Chat with Admin',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatWithAdminScreen()),
              );
            },
          ),
        _buildMenuItem(context, Icons.bar_chart, Colors.orange, l10n.translate('english_proficiency_test'),
            trailingText: l10n.translate('not_tested')),
        _buildMenuItem(context, Icons.calculate, Colors.redAccent, l10n.translate('wrong_answer_collection')),
        _buildMenuItem(context, Icons.article, Colors.lightBlue, l10n.translate('my_essays')),

        _buildDivider(context),
        _buildMenuItem(context, Icons.favorite, Colors.redAccent, 'Favorite Questions', onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FavoriteQuestionsScreen()),
          );
        }),
        _buildMenuItem(context, Icons.edit, Colors.blue, l10n.translate('my_notes')),
        _buildDivider(context),
        _buildMenuItem(context, Icons.download, Colors.cyan, l10n.translate('offline_exams')),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, Color iconColor, String title,
      {String? trailingText, VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 15)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(trailingText,
                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 14)),
          if (trailingText != null) const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withOpacity(0.5), size: 20),
        ],
      ),
      onTap: onTap ?? () {},
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(color: Theme.of(context).dividerTheme.color, height: 16, thickness: 8);
  }
}