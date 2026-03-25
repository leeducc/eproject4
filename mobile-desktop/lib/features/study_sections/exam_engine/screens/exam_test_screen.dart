import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/exam_model.dart';
import '../providers/exam_provider.dart';
import '../models/exam_session_state.dart';
import '../screens/exam_result_screen.dart';
import '../widgets/listening_section_view.dart';
import '../widgets/reading_section_view.dart';
import '../widgets/writing_section_view.dart';

class ExamTestScreen extends StatelessWidget {
  final ExamModel exam;
  final int listeningSecs;
  final int readingSecs;
  final int writingSecs;

  const ExamTestScreen({
    Key? key,
    required this.exam,
    required this.listeningSecs,
    required this.readingSecs,
    required this.writingSecs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('[ExamTestScreen] Creating ChangeNotifierProvider for ExamProvider');
    return ChangeNotifierProvider<ExamProvider>(
      create: (context) {
        final provider = ExamProvider();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          provider.startExam(
            exam: exam,
            listeningSecs: listeningSecs,
            readingSecs: readingSecs,
            writingSecs: writingSecs,
          );
        });
        return provider;
      },
      child: const _ExamTestBody(),
    );
  }
}

class _ExamTestBody extends StatefulWidget {
  const _ExamTestBody({Key? key}) : super(key: key);

  @override
  State<_ExamTestBody> createState() => _ExamTestBodyState();
}

class _ExamTestBodyState extends State<_ExamTestBody> {
  ExamProvider? _provider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-attach listener whenever the provider changes
    final newProvider = Provider.of<ExamProvider>(context, listen: false);
    if (_provider != newProvider) {
      _provider?.removeListener(_onProviderUpdate);
      _provider = newProvider;
      _provider!.addListener(_onProviderUpdate);
    }
  }

  void _onProviderUpdate() {
    final result = _provider?.submittedResult;
    if (result != null && mounted) {
      print('[ExamTestBody] submittedResult detected — navigating to ExamResultScreen');
      // Navigate from this stable context, not from WritingSectionView
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ExamResultScreen(result: result)),
      ).then((_) => _provider?.clearSession());
    }
  }

  @override
  void dispose() {
    _provider?.removeListener(_onProviderUpdate);
    super.dispose();
  }


  // ─── Confirm Give Up ────────────────────────────────────────────────────────

  void _confirmGiveUp() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E2330),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.exit_to_app, color: Colors.redAccent, size: 20),
          SizedBox(width: 8),
          Text('Give Up?', style: TextStyle(color: Colors.white, fontSize: 17)),
        ]),
        content: const Text(
          'Are you sure you want to exit?\nYour progress will NOT be saved.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Continue Exam', style: TextStyle(color: Colors.blueAccent)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Provider.of<ExamProvider>(context, listen: false).giveUp();
              Navigator.pop(context);
            },
            child: const Text('Exit', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  // ─── Confirm Move to Next Section ───────────────────────────────────────────

  void _confirmNextSection(ExamSection current) {
    final nextName = current == ExamSection.LISTENING ? 'Reading' : 'Writing';
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E2330),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Icon(Icons.arrow_forward_ios, color: Colors.greenAccent, size: 16),
          const SizedBox(width: 8),
          Text('Move to $nextName?', style: const TextStyle(color: Colors.white, fontSize: 17)),
        ]),
        content: Text(
          'You will move to the $nextName section and CANNOT return to this section.\n\nAny unanswered questions will stay empty.',
          style: const TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Stay Here', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Provider.of<ExamProvider>(context, listen: false).nextSection();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Go to $nextName'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    int h = totalSeconds ~/ 3600;
    int m = (totalSeconds % 3600) ~/ 60;
    int s = totalSeconds % 60;
    if (h > 0) {
      return '${h}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExamProvider>(
      builder: (context, provider, child) {
        final state = provider.state;

        if (state == null) {
          return const Scaffold(
            backgroundColor: Color(0xFF161A23),
            body: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
          );
        }

        // Auto-navigate to break screen when timer hits 0 mid-section
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // No break screen needed for now — section transitions are manual
        });

        final bool isLowTime = state.remainingSeconds < 300;
        final bool hasNextSection = state.currentSection != ExamSection.WRITING;

        return Scaffold(
          backgroundColor: const Color(0xFF161A23),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1A1E2E),
            elevation: 0,
            leadingWidth: 40,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white70, size: 22),
              onPressed: _confirmGiveUp,
              tooltip: 'Give Up',
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.exam.title,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: _sectionColor(state.currentSection).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        state.currentSection.name,
                        style: TextStyle(
                          color: _sectionColor(state.currentSection),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              // Timer
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: isLowTime ? Colors.redAccent.withOpacity(0.2) : Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isLowTime ? Colors.redAccent : Colors.green.withOpacity(0.4)),
                  ),
                  child: Text(
                    _formatTime(state.remainingSeconds),
                    style: TextStyle(
                      color: isLowTime ? Colors.redAccent : Colors.greenAccent,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Courier',
                    ),
                  ),
                ),
              ),
              // Next Section button
              if (hasNextSection)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton(
                    onPressed: () => _confirmNextSection(state.currentSection),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.greenAccent.withOpacity(0.1),
                      foregroundColor: Colors.greenAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(0, 32),
                    ),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('Next', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      SizedBox(width: 2),
                      Icon(Icons.arrow_forward_ios, size: 10),
                    ]),
                  ),
                ),
            ],
          ),
          body: provider.isSubmitting
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.blueAccent),
                      SizedBox(height: 16),
                      Text('Submitting Exam...', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                )
              : _buildSectionContent(state.currentSection),
        );
      },
    );
  }

  Color _sectionColor(ExamSection section) {
    switch (section) {
      case ExamSection.LISTENING: return Colors.purpleAccent;
      case ExamSection.READING: return Colors.blueAccent;
      case ExamSection.WRITING: return Colors.orangeAccent;
    }
  }

  Widget _buildSectionContent(ExamSection section) {
    switch (section) {
      case ExamSection.LISTENING: return const ListeningSectionView();
      case ExamSection.READING: return const ReadingSectionView();
      case ExamSection.WRITING: return const WritingSectionView();
    }
  }
}
