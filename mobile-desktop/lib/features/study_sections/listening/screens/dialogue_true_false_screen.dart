import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/dialogue_true_false_question.dart';

class DialogueTrueFalseScreen extends StatefulWidget {
  final List<DialogueTrueFalseQuestion> questions;
  const DialogueTrueFalseScreen({super.key, required this.questions});

  @override
  State<DialogueTrueFalseScreen> createState() => _DialogueTrueFalseScreenState();
}

class _DialogueTrueFalseScreenState extends State<DialogueTrueFalseScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentIndex = 0;
  bool? _selectedAnswer;
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

  Widget _buildResultList() {
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

  void _answer(bool choice) {
    if (_isAnswered) return;
    setState(() {
      _selectedAnswer = choice;
      _isAnswered = true;
      _userResults[_currentIndex] = (choice == widget.questions[_currentIndex].answer);
    });
  }

  void _nextQuestion() async {
    if (_currentIndex < widget.questions.length - 1) {
      await _audioPlayer.stop();
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
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
          content: _buildResultList(),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
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
          title: const Text("Dialogue True/False"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _confirmExit()) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    "Question ${_currentIndex + 1}/${widget.questions.length}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildProgressIndicator(),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                    const SizedBox(height: 32),
                    Text(
                      question.question,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (_isAnswered) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _userResults[_currentIndex] == true ? Icons.check_circle : Icons.cancel,
                            color: _userResults[_currentIndex] == true ? Colors.green : Colors.red,
                            size: 32,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _userResults[_currentIndex] == true ? "Correct" : "Incorrect",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _userResults[_currentIndex] == true ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _nextQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(_currentIndex < widget.questions.length - 1 ? "Next Question" : "Finish"),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: !_isAnswered ? () => _answer(true) : null,
                      child: Container(
                        height: 80,
                        color: Colors.green,
                        child: const Center(
                          child: Text(
                            "TRUE",
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: !_isAnswered ? () => _answer(false) : null,
                      child: Container(
                        height: 80,
                        color: Colors.red,
                        child: const Center(
                          child: Text(
                            "FALSE",
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
