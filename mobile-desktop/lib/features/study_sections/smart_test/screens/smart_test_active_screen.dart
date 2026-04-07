import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/models/quiz_bank_models.dart';
import 'package:mobile_desktop/core_quiz/models/quiz_question.dart';
import 'package:mobile_desktop/core_quiz/widgets/dynamic_question_builder.dart';
import 'package:mobile_desktop/core_quiz/widgets/audio_player_widget.dart';
import '../services/smart_test_api_service.dart';
import 'package:mobile_desktop/features/study_sections/services/moderation_service.dart';
import '../models/smart_test_models.dart';
import 'smart_test_summary_screen.dart';
import 'package:mobile_desktop/core/models/wrong_answer.dart';
import 'package:mobile_desktop/core/providers/wrong_answer_provider.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';

class SmartTestActiveScreen extends StatefulWidget {
  final String skill;
  final String level;

  const SmartTestActiveScreen({super.key, required this.skill, required this.level});

  @override
  State<SmartTestActiveScreen> createState() => _SmartTestActiveScreenState();
}

class _SmartTestActiveScreenState extends State<SmartTestActiveScreen> {
  // Theme Constants matching the User's Image
  static const Color kAppBg = Color(0xFF121A21);
  static const Color kCardBg = Color(0xFF1D2733);
  static const Color kAccentBlue = Color(0xFF42A5F5);
  static const Color kTextWhite = Colors.white;
  static const Color kTextGray = Colors.white54;

  bool isLoading = true;
  List<Question> questions = [];
  Map<int, String> userAnswers = {};
  
  Timer? _timer;
  int _secondsRemaining = 600;

  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final fetched = await SmartTestApiService().generateSmartTest(widget.skill, widget.level);
      if (!mounted) return;
      setState(() {
        questions = fetched;
        isLoading = false;
      });
      _startTimer();
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      } else {
        _timer?.cancel();
        _submitTest();
      }
    });
  }

  Future<void> _submitTest() async {
    _timer?.cancel();
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    
    try {
      final wrongAnswerProvider = context.read<WrongAnswerProvider>();
      final attempts = questions.map((q) {
        String ans = userAnswers[q.id] ?? "";
        bool isCorrect = _checkAnswerMock(q, ans);
        
        if (!isCorrect) {
          final quizQ = QuizQuestion.from(q);
          wrongAnswerProvider.addWrongAnswer(WrongAnswer(
            questionId: q.id,
            skill: widget.skill,
            questionTitle: q.instruction,
            instruction: 'Smart Test - ${widget.skill}',
            userAnswer: ans,
            correctAnswers: quizQ.correctIds,
            explanation: q.explanation,
            originalJson: quizQ.data,
            timestamp: DateTime.now(),
          ));
        }
        
        return QuestionAttemptDTO(questionId: q.id, userAnswer: ans, isCorrect: isCorrect);
      }).toList();
      
      final req = SmartTestSubmitRequest(skill: widget.skill, difficultyBand: widget.level, attempts: attempts);
      final res = await SmartTestApiService().submitSmartTest(req);
      
      if (!mounted) return;
      Navigator.pop(context); // pop loading dialog
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SmartTestSummaryScreen(response: res)));
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // pop loading dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submit Error: $e')));
      }
    }
  }
  
  bool _checkAnswerMock(Question q, String answer) {
      final quizQ = QuizQuestion.from(q);
      if (quizQ.correctIds.isNotEmpty) {
        return answer == quizQ.correctIds.first;
      }
      return answer.isNotEmpty; 
  }

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             ListTile(
               leading: const Icon(Icons.flag_outlined, color: kTextWhite),
               title: const Text('Báo cáo đề sai', style: TextStyle(color: kTextWhite)),
               onTap: () {
                 Navigator.pop(context);
                 _showReportDialog(questions[_currentPageIndex]);
               },
             ),
             const Divider(color: Colors.white10),
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceAround,
               children: [
                 _buildFontOption("Aa", 14),
                 _buildFontOption("Aa", 18),
                 _buildFontOption("Aa", 22),
               ],
             ),
             const SizedBox(height: 24),
             Row(
               children: [
                 Expanded(
                   child: _buildModeOption(Icons.wb_sunny_outlined, "Ban ngày", false),
                 ),
                 const SizedBox(width: 16),
                 Expanded(
                   child: _buildModeOption(Icons.nightlight_round, "Chế độ ban đêm", true),
                 ),
               ],
             )
          ],
        ),
      ),
    );
  }

  Widget _buildFontOption(String label, double size) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
         borderRadius: BorderRadius.circular(10),
         border: Border.all(color: Colors.white10),
      ),
      child: Text(label, style: TextStyle(color: kTextWhite, fontSize: size)),
    );
  }

  Widget _buildModeOption(IconData icon, String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isSelected ? kAccentBlue.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? kAccentBlue : Colors.white10),
      ),
      child: Column(
        children: [
          Icon(icon, color: isSelected ? kAccentBlue : kTextWhite),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: isSelected ? kAccentBlue : kTextWhite, fontSize: 12)),
        ],
      ),
    );
  }

  void _showReportDialog(Question q) {
      final TextEditingController reasonController = TextEditingController();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: kCardBg,
          title: const Text('Report Question', style: TextStyle(color: kTextWhite)),
          content: TextField(
            controller: reasonController,
            maxLines: 3,
            style: const TextStyle(color: kTextWhite),
            decoration: const InputDecoration(
              hintText: "Describe the issue...", 
              hintStyle: TextStyle(color: Colors.white30),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                String reason = reasonController.text.trim();
                if (reason.isEmpty) return;
                try {
                  await ModerationService().submitReport("QUESTION", q.id, reason);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report Submitted!')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
                }
              },
              child: const Text('Submit'),
            )
          ],
        ),
      );
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardBg,
        title: const Text('Are you sure?', style: TextStyle(color: kTextWhite)),
        content: const Text('Your test is running. Do you want to exit without saving?', style: TextStyle(color: kTextGray)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () {
            _timer?.cancel();
            Navigator.of(context).pop(true);
          }, child: const Text('Exit')),
        ],
      ),
    ) ?? false;
  }

  String get _formattedTime {
    int m = _secondsRemaining ~/ 60;
    int s = _secondsRemaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: kAppBg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: kTextWhite),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_formattedTime, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(width: 12),
              if (questions.isNotEmpty)
                Text("${_currentPageIndex + 1}/${questions.length}", style: const TextStyle(color: kTextGray, fontSize: 16)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_horiz, color: kTextWhite),
              onPressed: _showSettingsMenu,
            )
          ],
        ),
        body: isLoading 
            ? const Center(child: CircularProgressIndicator(color: kAccentBlue))
            : questions.isEmpty 
               ? const Center(child: Text("No questions generated.", style: TextStyle(color: kTextWhite)))
               : PageView.builder(
                   controller: _pageController,
                   onPageChanged: (idx) => setState(() => _currentPageIndex = idx),
                   itemCount: questions.length,
                   itemBuilder: (context, index) {
                      final q = questions[index];
                      return SmartQuestionCard(
                        question: q,
                        index: index,
                        total: questions.length,
                        selectedAnswerId: userAnswers[q.id],
                        onAnswer: (val) {
                          setState(() {
                            userAnswers[q.id] = val!;
                          });
                        },
                        isLast: index == questions.length - 1,
                        onSubmit: _submitTest,
                      );
                   },
                 ),
      ),
    );
  }
}

class SmartQuestionCard extends StatelessWidget {
  final Question question;
  final int index;
  final int total;
  final String? selectedAnswerId;
  final Function(String?) onAnswer;
  final bool isLast;
  final VoidCallback onSubmit;

  const SmartQuestionCard({
    super.key,
    required this.question,
    required this.index,
    required this.total,
    this.selectedAnswerId,
    required this.onAnswer,
    required this.isLast,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final quizQ = QuizQuestion.from(question);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          if (quizQ.hasAudio)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: SmartAudioPlayer(audioUrl: quizQ.mediaUrl!),
            ),
          
          if (question.instruction.isNotEmpty)
             Padding(
               padding: const EdgeInsets.only(bottom: 30),
               child: Text(
                 question.instruction,
                 style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                 textAlign: TextAlign.center,
               ),
             ),

          ...quizQ.options.asMap().entries.map((entry) {
            final idx = entry.key;
            final option = entry.value;
            final isSelected = selectedAnswerId == option.id;
            final prefix = String.fromCharCode(65 + idx);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () => onAnswer(option.id),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  decoration: BoxDecoration(
                    color: _SmartTestActiveScreenState.kCardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? _SmartTestActiveScreenState.kAccentBlue : Colors.white10,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(prefix, style: TextStyle(
                        color: isSelected ? _SmartTestActiveScreenState.kAccentBlue : _SmartTestActiveScreenState.kTextGray,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(option.label, style: const TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),

          if (isLast)
            Padding(
               padding: const EdgeInsets.only(top: 40, bottom: 40),
               child: ElevatedButton(
                 style: ElevatedButton.styleFrom(
                   minimumSize: const Size(double.infinity, 55),
                   backgroundColor: _SmartTestActiveScreenState.kAccentBlue,
                   foregroundColor: Colors.white,
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                   elevation: 4,
                 ),
                 onPressed: onSubmit,
                 child: const Text("HOÀN THÀNH", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
               ),
            ),
        ],
      ),
    );
  }
}

class SmartAudioPlayer extends StatefulWidget {
  final String audioUrl;
  const SmartAudioPlayer({super.key, required this.audioUrl});

  @override
  State<SmartAudioPlayer> createState() => _SmartAudioPlayerState();
}

class _SmartAudioPlayerState extends State<SmartAudioPlayer> {
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _player.setUrl(widget.audioUrl);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _format(Duration d) {
    return "${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<Duration?>(
          stream: _player.durationStream,
          builder: (context, snapshot) {
            final duration = snapshot.data ?? Duration.zero;
            return StreamBuilder<Duration>(
              stream: _player.positionStream,
              builder: (context, snapshot) {
                var pos = snapshot.data ?? Duration.zero;
                if (pos > duration) pos = duration;
                return Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: _SmartTestActiveScreenState.kAccentBlue,
                        inactiveTrackColor: Colors.white10,
                        thumbColor: _SmartTestActiveScreenState.kAccentBlue,
                        trackHeight: 3.0,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      ),
                      child: Slider(
                        value: pos.inMilliseconds.toDouble(),
                        max: duration.inMilliseconds.toDouble() > 0 ? duration.inMilliseconds.toDouble() : 1.0,
                        onChanged: (v) => _player.seek(Duration(milliseconds: v.toInt())),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_format(pos), style: const TextStyle(color: _SmartTestActiveScreenState.kTextGray, fontSize: 12)),
                          Text(_format(duration), style: const TextStyle(color: _SmartTestActiveScreenState.kTextGray, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        const SizedBox(height: 10),
        StreamBuilder<PlayerState>(
          stream: _player.playerStateStream,
          builder: (context, snapshot) {
            final state = snapshot.data;
            final playing = state?.playing ?? false;
            return Center(
              child: GestureDetector(
                onTap: () {
                   if (playing) {
                     _player.pause();
                   } else {
                     if (state?.processingState == ProcessingState.completed) {
                       _player.seek(Duration.zero);
                     }
                     _player.play();
                   }
                },
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(color: _SmartTestActiveScreenState.kAccentBlue, shape: BoxShape.circle),
                  child: Icon(playing ? Icons.pause : Icons.volume_up, color: Colors.white, size: 35),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}