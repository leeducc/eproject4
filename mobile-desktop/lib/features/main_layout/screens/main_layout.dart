import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../home/screens/home_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../ranking/screens/ranking_screen.dart';
import '../../ranking/providers/ranking_provider.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with WidgetsBindingObserver {
  int _currentIndex = 0;

  // ── 120-second heartbeat for time tracking ────────────────────────────────
  static const int _heartbeatSeconds = 120;
  Timer? _heartbeatTimer;

  @override
  void initState() {
    super.initState();
    debugPrint('[MainLayout] initState — registering WidgetsBindingObserver');
    WidgetsBinding.instance.addObserver(this);
    _startHeartbeat(); // Start immediately when user enters MainLayout
  }

  @override
  void dispose() {
    debugPrint('[MainLayout] dispose — removing observer');
    WidgetsBinding.instance.removeObserver(this);
    _heartbeatTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('[MainLayout] lifecycle: $state');
    if (state == AppLifecycleState.resumed) {
      _startHeartbeat();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _stopHeartbeat();
    }
  }

  void _startHeartbeat() {
    debugPrint('[MainLayout] starting 120s heartbeat');
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: _heartbeatSeconds),
      (_) {
        debugPrint('[MainLayout] heartbeat — recording ${_heartbeatSeconds}s');
        context.read<RankingProvider>().recordTime(_heartbeatSeconds);
      },
    );
  }

  void _stopHeartbeat() {
    debugPrint('[MainLayout] stopping heartbeat');
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final List<Widget> _screens = [
      const HomeScreen(),
      const RankingScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.5),
        currentIndex: _currentIndex,
        onTap: (index) {
          debugPrint('[MainLayout] tab tapped: $index');
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.book), label: l10n.translate('ielts_tab')),
          BottomNavigationBarItem(icon: const Icon(Icons.leaderboard), label: l10n.translate('rankings')),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: l10n.translate('me')),
        ],
      ),
    );
  }
}