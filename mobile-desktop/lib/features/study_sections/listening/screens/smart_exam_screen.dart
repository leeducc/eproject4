import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../../../ranking/providers/ranking_provider.dart';
import '../../widgets/unified_result_screen.dart';

class SmartExamScreen extends StatefulWidget {
  final List<dynamic> questions;
  const SmartExamScreen({super.key, required this.questions});

  @override
  State<SmartExamScreen> createState() => _SmartExamScreenState();
}

class _SmartExamScreenState extends State<SmartExamScreen> {
  final AudioPlayer _mp3Player = AudioPlayer();
  final _ttsService = AudioService();
  
  int _currentIndex = 0;
  bool _isAnswered = false;
  int? _selectedDialogueIndex;
  bool? _selectedTrueFalse;
  List<bool?> _userResults = [];
  bool _isTtsSpeaking = false;
  late int _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now().millisecondsSinceEpoch;
    _userResults = List.generate(widget.questions.length, (_) => null);
    _ttsService.init();
    _ttsService.onStart = () {
      if (mounted) setState(() => _isTtsSpeaking = true);
    };
    _ttsService.onComplete = () {
      if (mounted) setState(() => _isTtsSpeaking = false);
    };
    _loadQuestionAudio();
  }

  void _loadQuestionAudio() async {
    final question = widget.questions[_currentIndex];
    await _mp3Player.stop();
    await _ttsService.stop();
    
    if (question is DialogueQuestion) {
      try {
        await _mp3Player.setUrl(question.audioUrl);
      } catch (e) {
        debugPrint("Error loading MP3: $e");
      }
    } else if (question is DialogueTrueFalseQuestion) {
      try {
        await _mp3Player.setUrl(question.audioUrl);
      } catch (e) {
        debugPrint("Error loading MP3: $e");
      }
    }
  }

  @override
  void dispose() {
    _mp3Player.dispose();
    _ttsService.stop();
    super.dispose();
  }

  void _answerDialogue(int index) {
    if (_isAnswered) return;
    final question = widget.questions[_currentIndex] as DialogueQuestion;
    setState(() {
      _selectedDialogueIndex = index;
      _isAnswered = true;
      _userResults[_currentIndex] = (index == question.correctIndex);
    });
  }

  void _answerTrueFalse(bool choice) {
    if (_isAnswered) return;
    final question = widget.questions[_currentIndex];
    bool correct = false;
    if (question is TrueFalseQuestion) {
      correct = (choice == question.answer);
    } else if (question is DialogueTrueFalseQuestion) {
      correct = (choice == question.answer);
    }
    
    setState(() {
      _selectedTrueFalse = choice;
      _isAnswered = true;
      _userResults[_currentIndex] = correct;
    });
  }

  void _nextQuestion() async {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _isAnswered = false;
        _selectedDialogueIndex = null;
        _selectedTrueFalse = null;
      });
      _loadQuestionAudio();
    } else {
      await _mp3Player.stop();
      _showResults();
    }
  }

  void _showResults() {
    final correctCount = _userResults.where((r) => r == true).length;
    final totalTime = (DateTime.now().millisecondsSinceEpoch - _startTime) ~/ 1000;
    
    debugPrint('[ListeningSmartExamScreen] session ended — correctCount=$correctCount');
    context.read<RankingProvider>().recordAnswers(correctCount);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => UnifiedResultScreen(
          score: correctCount,
          total: widget.questions.length,
          time: totalTime,
          skill: 'LISTENING',
        ),
      ),
    );
  }

  Future<bool> _confirmExit() async {
    return await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Thoát bài thi?"),
            content: const Text("Tiến trình của bạn sẽ bị mất."),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Thoát")),
            ],
          ),
        ) ?? false;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_currentIndex];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _confirmExit()) {
          if (mounted) Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Smart Exam")),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text("Question ${_currentIndex + 1}/${widget.questions.length}", 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.questions.length, (i) {
                      final res = _userResults[i];
                      Color color = i == _currentIndex ? Colors.blueAccent : Colors.grey.shade400;
                      if (res == true) color = Colors.green;
                      if (res == false) color = Colors.red;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 12, height: 12,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                      );
                    }),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildQuestionContent(question),
              ),
            ),
            if (question is TrueFalseQuestion || question is DialogueTrueFalseQuestion)
              SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _isAnswered ? null : () => _answerTrueFalse(true),
                        child: Container(
                          height: 70, 
                          color: _isAnswered && (question is TrueFalseQuestion ? question.answer : (question as DialogueTrueFalseQuestion).answer) == true 
                              ? Colors.green 
                              : (_isAnswered && _selectedTrueFalse == true ? Colors.red : Colors.green.withOpacity(_isAnswered ? 0.3 : 1.0)),
                          child: const Center(child: Text("TRUE", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: _isAnswered ? null : () => _answerTrueFalse(false),
                        child: Container(
                          height: 70, 
                          color: _isAnswered && (question is TrueFalseQuestion ? question.answer : (question as DialogueTrueFalseQuestion).answer) == false 
                              ? Colors.red 
                              : (_isAnswered && _selectedTrueFalse == false ? Colors.green : Colors.red.withOpacity(_isAnswered ? 0.3 : 1.0)),
                          child: const Center(child: Text("FALSE", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
               const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionContent(dynamic question) {
    if (question is TrueFalseQuestion) {
      return _buildTrueFalseUI(question);
    } else if (question is DialogueQuestion) {
      return _buildDialogueUI(question);
    } else if (question is DialogueTrueFalseQuestion) {
      return _buildDialogueTrueFalseUI(question);
    }
    return const Center(child: Text("Unknown question type"));
  }

  Widget _buildTrueFalseUI(TrueFalseQuestion q) {
    return Column(
      children: [
        Image.network(q.image, height: 200),
        const SizedBox(height: 30),
        IconButton(
          icon: Icon(Icons.volume_up, size: 60, color: _isTtsSpeaking ? Colors.green : Colors.white),
          onPressed: () => _ttsService.speak(q.word),
        ),
        if (_isTtsSpeaking) const Text("Listening...", style: TextStyle(color: Colors.green)),
        if (_isAnswered) ...[
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_userResults[_currentIndex] == true ? Icons.check_circle : Icons.cancel, color: _userResults[_currentIndex] == true ? Colors.green : Colors.red),
              const SizedBox(width: 8),
              Text(_userResults[_currentIndex] == true ? "Correct!" : "Incorrect!", 
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _userResults[_currentIndex] == true ? Colors.green : Colors.red)),
            ],
          ),
          const SizedBox(height: 10),
          Text(q.word, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
            onPressed: _nextQuestion, 
            child: Text(_currentIndex < widget.questions.length - 1 ? "NEXT QUESTION" : "FINISH")
          ),
        ]
      ],
    );
  }

  Widget _buildDialogueUI(DialogueQuestion q) {
    return Column(
      children: [
        _buildMp3Player(),
        const SizedBox(height: 20),
        Text(q.question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        ...List.generate(q.options.length, (index) {
          Color? bgColor;
          Color textColor = Colors.white;
          if (_isAnswered) {
            if (index == q.correctIndex) {
              bgColor = Colors.green;
            } else if (index == _selectedDialogueIndex) {
              bgColor = Colors.red;
            } else {
              bgColor = Colors.grey.withOpacity(0.1);
              textColor = Colors.white70;
            }
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: bgColor,
                disabledBackgroundColor: bgColor ?? Colors.grey.withOpacity(0.12),
                disabledForegroundColor: textColor,
                foregroundColor: textColor,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isAnswered ? null : () => _answerDialogue(index),
              child: Text(q.options[index], style: const TextStyle(fontSize: 16)),
            ),
          );
        }),
        if (_isAnswered)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
              onPressed: _nextQuestion, 
              child: Text(_currentIndex < widget.questions.length - 1 ? "NEXT QUESTION" : "FINISH")
            ),
          ),
      ],
    );
  }

  Widget _buildDialogueTrueFalseUI(DialogueTrueFalseQuestion q) {
    return Column(
      children: [
        _buildMp3Player(),
        const SizedBox(height: 30),
        Text(q.question, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        if (_isAnswered) ...[
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_userResults[_currentIndex] == true ? Icons.check_circle : Icons.cancel, color: _userResults[_currentIndex] == true ? Colors.green : Colors.red, size: 32),
              const SizedBox(width: 8),
              Text(_userResults[_currentIndex] == true ? "Correct" : "Incorrect", 
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _userResults[_currentIndex] == true ? Colors.green : Colors.red)),
            ],
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
            onPressed: _nextQuestion, 
            child: Text(_currentIndex < widget.questions.length - 1 ? "NEXT QUESTION" : "FINISH")
          ),
        ]
      ],
    );
  }

  Widget _buildMp3Player() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            StreamBuilder<Duration?>(
              stream: _mp3Player.durationStream,
              builder: (context, snapshot) {
                final duration = snapshot.data ?? Duration.zero;
                return StreamBuilder<Duration>(
                  stream: _mp3Player.positionStream,
                  builder: (context, snapshot) {
                    var position = snapshot.data ?? Duration.zero;
                    if (position > duration) position = duration;
                    return Column(
                      children: [
                        Slider(
                          value: position.inMilliseconds.toDouble(),
                          max: duration.inMilliseconds.toDouble() > 0 ? duration.inMilliseconds.toDouble() : 1.0,
                          onChanged: (v) => _mp3Player.seek(Duration(milliseconds: v.toInt())),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                            children: [Text(_formatDuration(position)), Text(_formatDuration(duration))]
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            StreamBuilder<PlayerState>(
              stream: _mp3Player.playerStateStream,
              builder: (context, snapshot) {
                final playing = snapshot.data?.playing ?? false;
                return Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.volume_up, size: 60, color: playing ? Colors.green : Colors.white),
                      onPressed: () => playing ? _mp3Player.pause() : _mp3Player.play(),
                    ),
                    if (playing) const Text("Listening...", style: TextStyle(color: Colors.green)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
