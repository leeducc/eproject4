import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/models/quiz_bank_models.dart';
import '../providers/exam_provider.dart';
import 'question_renderer.dart';
import 'question_map_sheet.dart';
import 'exam_section_widgets.dart';

class ListeningSectionView extends StatefulWidget {
  const ListeningSectionView({Key? key}) : super(key: key);

  @override
  State<ListeningSectionView> createState() => _ListeningSectionViewState();
}

class _ListeningSectionViewState extends State<ListeningSectionView> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  int? _currentGroupId;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _audioPlayer.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => _isPlaying = s == PlayerState.playing);
    });
    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      if (_currentGroupId != null) {
        // Mark audio as played — cannot play again
        final provider = Provider.of<ExamProvider>(context, listen: false);
        provider.markAudioPlayed(_currentGroupId!);
        print('[ListeningSectionView] Audio complete for group $_currentGroupId — locked');
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String path, int groupId) async {
    final provider = Provider.of<ExamProvider>(context, listen: false);
    if (provider.isAudioPlayed(groupId)) {
      print('[ListeningSectionView] Audio already played for group $groupId — blocked');
      return;
    }
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8123/api';
    final fullUrl = path.startsWith('http') ? path : '$baseUrl/v1/media$path';
    _currentGroupId = groupId;
    print('[ListeningSectionView] Playing audio: $fullUrl (group=$groupId)');
    await _audioPlayer.play(UrlSource(fullUrl));
  }

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExamProvider>(
      builder: (context, provider, _) {
        final state = provider.state;
        if (state == null) return const SizedBox.shrink();

        // Flatten ALL listening questions in order (preserving group membership)
        final List<_QuestionWithGroup> flatQuestions = [];
        for (var group in (state.exam.groups ?? []).where((g) => g.skill == SkillType.LISTENING)) {
          for (var q in group.questions) {
            flatQuestions.add(_QuestionWithGroup(q, group));
          }
        }
        for (var q in (state.exam.questions ?? []).where((q) => q.skill == SkillType.LISTENING)) {
          flatQuestions.add(_QuestionWithGroup(q, null));
        }

        if (flatQuestions.isEmpty) {
          return const Center(child: Text('No listening questions.', style: TextStyle(color: Colors.white70)));
        }

        // Sync PageController to provider index
        final targetIndex = state.currentQuestionIndex.clamp(0, flatQuestions.length - 1);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients && _pageController.page?.round() != targetIndex) {
            _pageController.animateToPage(targetIndex,
                duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
          }
        });

        final current = flatQuestions[targetIndex];
        final group = current.group;
        final isAudioLocked = group != null && provider.isAudioPlayed(group.id);
        final isFlagged = provider.isFlagged(current.question.id);

        return Column(
          children: [
            // ─── Persistent Audio Player ────────────────────────────────────
            if (group != null && group.mediaUrl != null)
              _AudioPlayerBar(
                group: group,
                isPlaying: _isPlaying && _currentGroupId == group.id,
                isLocked: isAudioLocked,
                position: _currentGroupId == group.id ? _position : Duration.zero,
                duration: _currentGroupId == group.id ? _duration : Duration.zero,
                onPlay: () => _playAudio(group.mediaUrl!, group.id),
                onSeek: (v) => _audioPlayer.seek(Duration(seconds: v.toInt())),
                formatTime: _fmt,
              ),

            // ─── Header + Action Bar ────────────────────────────────────────
            ExamSectionHeader(
              title: group?.title ?? 'Listening',
              current: targetIndex,
              total: flatQuestions.length,
              isFlagged: isFlagged,
              onFlag: () => provider.toggleFlag(current.question.id),
              onMap: () => QuestionMapSheet.show(
                context,
                flatQuestions.map((e) => e.question).toList(),
                targetIndex,
              ),
            ),

            // ─── Swipeable Single-Question Page ────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: flatQuestions.length,
                onPageChanged: (index) {
                  print('[ListeningSectionView] Swiped to question index $index');
                  provider.jumpToQuestion(index);
                },
                itemBuilder: (context, index) {
                  final item = flatQuestions[index];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    child: QuestionRenderer(
                      question: item.question,
                      indexPrefix: index + 1,
                    ),
                  );
                },
              ),
            ),

            // ─── Prev / Next Navigation Controls ───────────────────────────
            ExamPageNavBar(
              currentIndex: targetIndex,
              total: flatQuestions.length,
              onPrev: () => provider.prevQuestion(),
              onNext: () => provider.nextQuestion(flatQuestions.length),
            ),
          ],
        );
      },
    );
  }
}

class _QuestionWithGroup {
  final Question question;
  final QuestionGroup? group;
  _QuestionWithGroup(this.question, this.group);
}

// ─── Widgets ────────────────────────────────────────────────────────────────

class _AudioPlayerBar extends StatelessWidget {
  final QuestionGroup group;
  final bool isPlaying;
  final bool isLocked;
  final Duration position;
  final Duration duration;
  final VoidCallback onPlay;
  final ValueChanged<double> onSeek;
  final String Function(Duration) formatTime;

  const _AudioPlayerBar({
    required this.group,
    required this.isPlaying,
    required this.isLocked,
    required this.position,
    required this.duration,
    required this.onPlay,
    required this.onSeek,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isLocked ? Colors.white.withOpacity(0.05) : Colors.purple.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isLocked ? Colors.white12 : Colors.purpleAccent.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.headphones, size: 14, color: isLocked ? Colors.white38 : Colors.purpleAccent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  group.title,
                  style: TextStyle(color: isLocked ? Colors.white38 : Colors.white70, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isLocked)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.lock, size: 12, color: Colors.white38),
                    SizedBox(width: 4),
                    Text('Played', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  ]),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              GestureDetector(
                onTap: isLocked ? null : onPlay,
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: isLocked ? Colors.white12 : Colors.purpleAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: isLocked ? Colors.white24 : Colors.white,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                        activeTrackColor: isLocked ? Colors.white24 : Colors.purpleAccent,
                        inactiveTrackColor: Colors.white12,
                        thumbColor: isLocked ? Colors.white24 : Colors.purpleAccent,
                        disabledThumbColor: Colors.white24,
                        disabledActiveTrackColor: Colors.white24,
                      ),
                      child: Slider(
                        min: 0,
                        max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 100,
                        value: position.inSeconds.toDouble().clamp(
                            0, duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 100),
                        onChanged: isLocked ? null : onSeek,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(formatTime(position), style: const TextStyle(color: Colors.white38, fontSize: 10)),
                        Text(formatTime(duration), style: const TextStyle(color: Colors.white38, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int current;
  final int total;
  final bool isFlagged;
  final VoidCallback onFlag;
  final VoidCallback onMap;

  const _SectionHeader({
    required this.title,
    required this.current,
    required this.total,
    required this.isFlagged,
    required this.onFlag,
    required this.onMap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12), overflow: TextOverflow.ellipsis),
                Text('Question ${current + 1} of $total',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // Flag button
          GestureDetector(
            onTap: onFlag,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isFlagged ? Colors.orangeAccent.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isFlagged ? Colors.orangeAccent : Colors.white12),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(isFlagged ? Icons.flag : Icons.flag_outlined,
                    size: 14, color: isFlagged ? Colors.orangeAccent : Colors.white38),
                const SizedBox(width: 4),
                Text(isFlagged ? 'Flagged' : 'Flag',
                    style: TextStyle(
                        fontSize: 12,
                        color: isFlagged ? Colors.orangeAccent : Colors.white38)),
              ]),
            ),
          ),
          const SizedBox(width: 8),
          // Question map button
          GestureDetector(
            onTap: onMap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.4)),
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.grid_view_rounded, size: 14, color: Colors.blueAccent),
                SizedBox(width: 4),
                Text('Map', style: TextStyle(fontSize: 12, color: Colors.blueAccent)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageNavBar extends StatelessWidget {
  final int currentIndex;
  final int total;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _PageNavBar({
    required this.currentIndex,
    required this.total,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E2330),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: currentIndex > 0 ? onPrev : null,
              icon: const Icon(Icons.arrow_back_ios_new, size: 14),
              label: const Text('Previous'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white12,
                disabledBackgroundColor: Colors.white.withOpacity(0.04),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white24,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: currentIndex < total - 1 ? onNext : null,
              icon: const Icon(Icons.arrow_forward_ios, size: 14),
              label: const Text('Next'),
              iconAlignment: IconAlignment.end,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                disabledBackgroundColor: Colors.white.withOpacity(0.04),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white24,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
