import 'package:flutter/material.dart';
import '../models/quiz_question.dart';

class MatchingWidget extends StatefulWidget {
  final QuizQuestion question;
  final bool isAnswered;
  final void Function(String? answerId) onAnswer;

  const MatchingWidget({
    super.key,
    required this.question,
    required this.isAnswered,
    required this.onAnswer,
  });

  @override
  State<MatchingWidget> createState() => _MatchingWidgetState();
}

class _MatchingWidgetState extends State<MatchingWidget> with SingleTickerProviderStateMixin {
  
  final Map<String, String?> _matches = {};
  
  final List<String> _matchOrder = [];
  String? _selectedLeftId;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    for (var item in widget.question.leftItems) {
      _matches[item['id'].toString()] = null;
    }
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onLeftTap(String leftId) {
    if (widget.isAnswered) return;
    setState(() {
      if (_matches[leftId] != null) {
        _clearMatch(leftId);
      } else {
        _selectedLeftId = (_selectedLeftId == leftId) ? null : leftId;
      }
    });
    _checkComplete();
  }

  void _onRightTap(String rightId) {
    if (widget.isAnswered) return;
    
    String? pairedLeftId;
    _matches.forEach((key, value) {
      if (value == rightId) pairedLeftId = key;
    });

    setState(() {
      if (pairedLeftId != null) {
        _clearMatch(pairedLeftId!);
      } else if (_selectedLeftId != null) {
        _matches[_selectedLeftId!] = rightId;
        _matchOrder.add(_selectedLeftId!);
        _selectedLeftId = null;
      }
    });
    
    _checkComplete();
  }

  void _clearMatch(String leftId) {
    _matches[leftId] = null;
    _matchOrder.remove(leftId);
    _selectedLeftId = null;
  }

  void _clearAll() {
    if (widget.isAnswered) return;
    setState(() {
      _matches.forEach((key, value) => _matches[key] = null);
      _matchOrder.clear();
      _selectedLeftId = null;
    });
    _checkComplete();
  }

  void _checkComplete() {
    bool allMatched = _matches.values.every((v) => v != null);
    if (allMatched) {
      bool isCorrect = true;
      final solution = widget.question.matchingSolution;
      
      _matches.forEach((leftId, rightId) {
        if (solution[leftId]?.toString() != rightId) {
          isCorrect = false;
        }
      });
      
      widget.onAnswer(isCorrect ? "__MATCHING_CORRECT__" : "__MATCHING_WRONG__");
    } else {
      widget.onAnswer(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final leftItems = widget.question.leftItems;
    final rightItems = widget.question.rightItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.question.instruction,
                style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            if (!widget.isAnswered && _matchOrder.isNotEmpty)
              TextButton.icon(
                onPressed: _clearAll,
                icon: Icon(Icons.refresh, size: 18, color: Theme.of(context).primaryColor.withOpacity(0.7)),
                label: Text("Xóa tất cả", style: TextStyle(color: Theme.of(context).primaryColor.withOpacity(0.7), fontSize: 13)),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Expanded(
              child: Column(
                children: leftItems.map((left) {
                  final id = left['id'].toString();
                  final isSelected = _selectedLeftId == id;
                  final matchId = _matches[id];
                  final matchIndex = _matchOrder.indexOf(id);
                  
                  return _buildItem(
                    text: left['text'],
                    isSelected: isSelected,
                    isMatched: matchId != null,
                    matchNumber: matchIndex != -1 ? matchIndex + 1 : null,
                    onTap: () => _onLeftTap(id),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(width: 20),
            
            Expanded(
              child: Column(
                children: rightItems.map((right) {
                  final id = right['id'].toString();
                  
                  
                  String? pairedLeftId;
                  _matches.forEach((k, v) { if (v == id) pairedLeftId = k; });
                  final matchIndex = pairedLeftId != null ? _matchOrder.indexOf(pairedLeftId!) : -1;
                  
                  return _buildItem(
                    text: right['text'],
                    isSelected: false,
                    isMatched: pairedLeftId != null,
                    matchNumber: matchIndex != -1 ? matchIndex + 1 : null,
                    onTap: () => _onRightTap(id),
                    isRightSide: true,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItem({
    required String text,
    required bool isSelected,
    required bool isMatched,
    int? matchNumber,
    required VoidCallback onTap,
    bool isRightSide = false,
  }) {
    Color borderColor = Theme.of(context).dividerColor;
    Color bgColor = Theme.of(context).cardColor;
    Color textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;
    
    if (isSelected) {
      borderColor = const Color(0xFF42A5F5);
      bgColor = const Color(0xFF42A5F5).withOpacity(0.15);
      textColor = const Color(0xFF42A5F5);
    } else if (isMatched) {
      borderColor = const Color(0xFF4CAF50).withOpacity(0.6);
      bgColor = const Color(0xFF4CAF50).withOpacity(0.1);
      textColor = const Color(0xFF4CAF50);
    }

    Widget content = Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: isSelected ? 2.5 : 1),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: isSelected || isMatched ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isMatched && matchNumber != null)
            Positioned(
              top: -22,
              right: -22,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  matchNumber.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          if (isMatched && !widget.isAnswered)
             Positioned(
              bottom: -22,
              right: -22,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white10),
                ),
                child: const Icon(Icons.close, size: 12, color: Colors.white70),
              ),
            ),
        ],
      ),
    );

    if (isSelected) {
      return ScaleTransition(
        scale: _pulseAnimation,
        child: GestureDetector(onTap: onTap, child: content),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: content,
    );
  }
}