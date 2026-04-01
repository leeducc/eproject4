import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../models/ranking_models.dart';
import '../providers/ranking_provider.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    debugPrint('[RankingScreen] initState');
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentTab();
    });
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      debugPrint('[RankingScreen] tab changed to ${_tabController.index}');
      _loadCurrentTab();
    }
  }

  void _loadCurrentTab() {
    LeaderboardType type;
    switch (_tabController.index) {
      case 0:
        type = LeaderboardType.ANSWERS;
        break;
      case 1:
        type = LeaderboardType.VOCAB;
        break;
      case 2:
        type = LeaderboardType.TIME;
        break;
      default:
        type = LeaderboardType.ANSWERS;
    }
    context.read<RankingProvider>().loadLeaderboard(type);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final tabs = [
      _TabInfo(
        type: LeaderboardType.ANSWERS,
        label: l10n.translate('ranking_tab_answers'),
        unit: l10n.translate('ranking_unit_answers'),
      ),
      _TabInfo(
        type: LeaderboardType.VOCAB,
        label: l10n.translate('ranking_tab_vocab'),
        unit: l10n.translate('ranking_unit_vocab'),
      ),
      _TabInfo(
        type: LeaderboardType.TIME,
        label: l10n.translate('ranking_tab_time'),
        unit: l10n.translate('ranking_unit_time'),
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
            Container(
              color: colorScheme.surface,
              child: TabBar(
                controller: _tabController,
                labelColor: colorScheme.primary,
                unselectedLabelColor: colorScheme.onSurface.withOpacity(0.55),
                indicatorColor: colorScheme.primary,
                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(fontSize: 13),
                tabs: tabs.map((t) => Tab(text: t.label)).toList(),
              ),
            ),

            // ── Delay notice ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              color: colorScheme.surfaceVariant.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              child: Text(
                l10n.translate('ranking_update_delay'),
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withOpacity(0.55),
                ),
              ),
            ),

            // ── Body ──────────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: tabs.map((t) => _LeaderboardTab(tabInfo: t)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Per-tab leaderboard widget ───────────────────────────────────────────────

class _LeaderboardTab extends StatelessWidget {
  final _TabInfo tabInfo;
  const _LeaderboardTab({required this.tabInfo});

  @override
  Widget build(BuildContext context) {
    return Consumer<RankingProvider>(
      builder: (context, provider, child) {
        debugPrint('[_LeaderboardTab] build type=${tabInfo.type} loading=${provider.isLoading}');

        // Show skeleton while loading
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          final errL10n = AppLocalizations.of(context)!;
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48,
                    color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 12),
                Text(errL10n.translate('data_load_error'),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: () =>
                      context.read<RankingProvider>().loadLeaderboard(tabInfo.type),
                  child: Text(errL10n.translate('retry')),
                ),
              ],
            ),
          );
        }

        final entries = provider.entries;
        final myRank = provider.myRankInfo;

        return RefreshIndicator(
          onRefresh: () =>
              context.read<RankingProvider>().loadLeaderboard(tabInfo.type),
          child: Column(
            children: [
              Expanded(
                child: entries.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: Text(AppLocalizations.of(context)!.translate('no_data'),
                                style: const TextStyle(fontSize: 16)),
                          ),
                        ],
                      )
                    : ListView.builder(
                        itemCount: entries.length,
                        padding: const EdgeInsets.only(bottom: 4),
                        itemBuilder: (ctx, i) => _RankRow(
                          entry: entries[i],
                          unit: tabInfo.unit,
                          type: tabInfo.type,
                        ),
                      ),
              ),
              // ── Pinned "my rank" row at bottom ───────────────────────
              _MyRankRow(myRank: myRank, unit: tabInfo.unit),
            ],
          ),
        );
      },
    );
  }
}

// ── Leaderboard row ──────────────────────────────────────────────────────────

class _RankRow extends StatelessWidget {
  final LeaderboardEntry entry;
  final String unit;
  final LeaderboardType type;

  const _RankRow({required this.entry, required this.unit, required this.type});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final score = type == LeaderboardType.TIME
        ? '${(entry.score / 60).round()}$unit'
        : '${entry.score}$unit';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: _RankBadge(rank: entry.rank),
        title: Row(
          children: [
            _Avatar(displayName: entry.displayName, avatarUrl: entry.avatarUrl),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      entry.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (entry.isPro) ...[
                    const SizedBox(width: 6),
                    _ProBadge(),
                  ],
                ],
              ),
            ),
          ],
        ),
        trailing: Text(
          score,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

// ── My rank pinned bottom row ────────────────────────────────────────────────

class _MyRankRow extends StatelessWidget {
  final MyRankInfo? myRank;
  final String unit;

  const _MyRankRow({required this.myRank, required this.unit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final l10n = AppLocalizations.of(context)!;
    final ranked = myRank?.ranked ?? false;
    final rankText = ranked ? '#${myRank!.myRank}' : l10n.translate('ranking_not_ranked');
    final scoreText = ranked ? '${myRank!.myScore}$unit' : '';

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.85),
        border: Border(top: BorderSide(color: colorScheme.primary.withOpacity(0.3))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Text(
              rankText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            if (scoreText.isNotEmpty)
              Text(
                scoreText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                  fontSize: 15,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _RankBadge extends StatelessWidget {
  final int rank;
  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    if (rank == 1) return const Text('🥇', style: TextStyle(fontSize: 28));
    if (rank == 2) return const Text('🥈', style: TextStyle(fontSize: 28));
    if (rank == 3) return const Text('🥉', style: TextStyle(fontSize: 28));

    return SizedBox(
      width: 32,
      child: Center(
        child: Text(
          '$rank',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String displayName;
  final String? avatarUrl;
  const _Avatar({required this.displayName, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initials = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(avatarUrl!),
        onBackgroundImageError: (_, __) {},
      );
    }
    return CircleAvatar(
      radius: 20,
      backgroundColor: colorScheme.primaryContainer,
      child: Text(initials,
          style: TextStyle(
              color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
    );
  }
}

class _ProBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium, size: 12, color: Colors.white),
          SizedBox(width: 2),
          Text('PRO',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ],
      ),
    );
  }
}

// ── Tab metadata ─────────────────────────────────────────────────────────────

class _TabInfo {
  final LeaderboardType type;
  final String label;
  final String unit;
  const _TabInfo({required this.type, required this.label, required this.unit});
}
