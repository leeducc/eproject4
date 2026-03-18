import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/dialogue_question.dart';

class DialogueQuestionsScreen extends StatefulWidget {
  final String title;
  final List<DialogueQuestion> questions;
  const DialogueQuestionsScreen({super.key, required this.title, required this.questions});

  @override
  State<DialogueQuestionsScreen> createState() => _DialogueQuestionsScreenState();
}

class _DialogueQuestionsScreenState extends State<DialogueQuestionsScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentIndex = 0;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;
  List<bool?> _userResults = [];

  @override
  void initState() {
    super.initState();
    _userResults = List.generate(widget.questions.length, (_) => null);
    _loadAudio();
  }

  Future<void> _loadAudio() async {
    try {
      await _audioPlayer.setUrl(widget.questions[_currentIndex].audioUrl);
    } catch (e) {
      debugPrint("Error loading audio: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<bool> _confirmExit() async {
    return await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Are you sure?"),
            content: const Text("All progress will be lost."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Exit"),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget buildResultList() {
    return SizedBox(
      width: double.maxFinite,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.questions.length,
        itemBuilder: (_, i) {
          final result = _userResults[i];
          return ListTile(
            leading: Icon(
              result == true ? Icons.check_circle : Icons.cancel,
              color: result == true ? Colors.green : Colors.red,
            ),
            title: Text("Question ${i + 1}"),
            trailing: Icon(
              result == true ? Icons.check : Icons.close,
              color: result == true ? Colors.green : Colors.red,
            ),
          );
        },
      ),
    );
  }

  void _nextQuestion() async {
    if (_currentIndex < widget.questions.length - 1) {
      await _audioPlayer.stop();
      setState(() {
        _currentIndex++;
        _selectedAnswerIndex = null;
        _isAnswered = false;
      });
      _loadAudio();
    } else {
      await _audioPlayer.stop();
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Your Results 🎯"),
          content: buildResultList(),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to listening screen
              },
              child: const Text("CLOSE"),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.questions.length, (i) {
        final result = _userResults[i];
        final isCurrent = i == _currentIndex;

        Color color;
        if (result == true) {
          color = Colors.green;
        } else if (result == false) {
          color = Colors.red;
        } else if (isCurrent) {
          color = Colors.blueAccent;
        } else {
          color = Colors.grey.shade400;
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        );
      }),
    );
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
        appBar: AppBar(
          title: Text(widget.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _confirmExit()) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Question ${_currentIndex + 1}/${widget.questions.length}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              _buildProgressIndicator(),
              const SizedBox(height: 24),
              // Audio Player Section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      StreamBuilder<Duration?>(
                        stream: _audioPlayer.durationStream,
                        builder: (context, snapshot) {
                          final duration = snapshot.data ?? Duration.zero;
                          return StreamBuilder<Duration>(
                            stream: _audioPlayer.positionStream,
                            builder: (context, snapshot) {
                              var position = snapshot.data ?? Duration.zero;
                              if (position > duration) position = duration;
                              return Column(
                                children: [
                                  Slider(
                                    value: position.inMilliseconds.toDouble(),
                                    max: duration.inMilliseconds.toDouble() > 0 
                                        ? duration.inMilliseconds.toDouble() 
                                        : 1.0,
                                    onChanged: (value) {
                                      _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(_formatDuration(position)),
                                        Text(_formatDuration(duration)),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      StreamBuilder<PlayerState>(
                        stream: _audioPlayer.playerStateStream,
                        builder: (context, snapshot) {
                          final playerState = snapshot.data;
                          final playing = playerState?.playing ?? false;
                          final processingState = playerState?.processingState;
                          
                          return Column(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.volume_up,
                                  size: 60,
                                  color: playing ? Colors.green : Colors.white,
                                ),
                                onPressed: () {
                                  if (processingState == ProcessingState.completed) {
                                    _audioPlayer.seek(Duration.zero);
                                    _audioPlayer.play();
                                  } else if (playing) {
                                    _audioPlayer.pause();
                                  } else {
                                    _audioPlayer.play();
                                  }
                                },
                              ),
                              if (playing)
                                const Text(
                                  "Listening...",
                                  style: TextStyle(color: Colors.green),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                question.question,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: question.options.length,
                  itemBuilder: (context, index) {
                    final option = question.options[index];
                    
                    Color? backgroundColor;
                    Color textColor = Colors.white;
                    
                    if (_isAnswered) {
                      if (index == question.correctIndex) {
                        backgroundColor = Colors.green;
                      } else if (index == _selectedAnswerIndex) {
                        backgroundColor = Colors.red;
                      } else {
                        backgroundColor = Colors.grey.withOpacity(0.1);
                        textColor = Colors.white70;
                      }
                    }
    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: backgroundColor,
                          foregroundColor: textColor,
                          disabledBackgroundColor: backgroundColor ?? Colors.grey.withOpacity(0.12),
                          disabledForegroundColor: textColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          side: BorderSide(
                            color: _isAnswered && (index == question.correctIndex || index == _selectedAnswerIndex)
                                ? Colors.transparent
                                : Colors.grey.shade300,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isAnswered
                            ? null
                            : () {
                                setState(() {
                                  _selectedAnswerIndex = index;
                                  _isAnswered = true;
                                  _userResults[_currentIndex] = (index == question.correctIndex);
                                });
                              },
                        child: Text(
                          option, 
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_isAnswered)
                ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(_currentIndex < widget.questions.length - 1 ? "Next Question" : "Finish"),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
