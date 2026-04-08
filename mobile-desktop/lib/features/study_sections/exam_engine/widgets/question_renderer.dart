import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/models/quiz_bank_models.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';

class QuestionRenderer extends StatelessWidget {
  final Question question;
  final int indexPrefix;

  const QuestionRenderer({super.key, required this.question, required this.indexPrefix});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF42A5F5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Q$indexPrefix',
                  style: const TextStyle(color: Color(0xFF42A5F5), fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question.instruction,
                  style: TextStyle(color: theme.textTheme.titleMedium?.color, fontSize: 16, fontWeight: FontWeight.bold, height: 1.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInputBody(context),
        ],
      ),
    );
  }

  Widget _buildInputBody(BuildContext context) {
    final provider = Provider.of<ExamProvider>(context);

    switch (question.type) {
      case QuestionType.multipleChoice:
        return _MockMultipleChoiceWidget(question: question, provider: provider);
      case QuestionType.fillBlank:
        return _MockFillBlankWidget(question: question, provider: provider);
      case QuestionType.matching:
        return _MockMatchingWidget(question: question, provider: provider);
      default:
        return Text(
          'Unsupported question type: ${question.type.name}',
          style: const TextStyle(color: Colors.redAccent),
        );
    }
  }
}

class _MockMultipleChoiceWidget extends StatelessWidget {
  final Question question;
  final ExamProvider provider;

  const _MockMultipleChoiceWidget({required this.question, required this.provider});

  @override
  Widget build(BuildContext context) {
    final currentAnswer = provider.state?.userAnswers[question.id];
    final bool isMultiSelect = question.data['multiple_select'] == true || question.data['selection_type'] == 'MULTI';
    final options = List<dynamic>.from(question.data['options'] ?? []);

    if (options.isEmpty) {
      return const Text('No options defined.', style: TextStyle(color: Colors.grey));
    }

    return Column(
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final opt = entry.value;
        final optionId = (opt['id'] ?? '').toString();
        final optionText = (opt['label'] ?? opt['text'] ?? optionId).toString();

        bool isSelected = false;
        if (isMultiSelect && currentAnswer is List) {
          isSelected = currentAnswer.contains(optionId);
        } else if (!isMultiSelect && currentAnswer is String) {
          isSelected = currentAnswer == optionId;
        }

        final prefix = String.fromCharCode(65 + index);
        final theme = Theme.of(context);

        Color backgroundColor;
        Color textColor;
        Color prefixColor;
        Color borderColor;

        if (isSelected) {
          backgroundColor = const Color(0xFF42A5F5).withOpacity(0.1);
          textColor = const Color(0xFF42A5F5);
          prefixColor = Colors.white;
          borderColor = const Color(0xFF42A5F5);
        } else {
          backgroundColor = theme.cardColor;
          textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
          prefixColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
          borderColor = theme.dividerColor.withOpacity(0.2);
        }

        return GestureDetector(
          onTap: () {
            if (isMultiSelect) {
              List<String> lst = currentAnswer is List ? List<String>.from(currentAnswer) : [];
              if (!isSelected) {
                lst.add(optionId);
              } else {
                lst.remove(optionId);
              }
              provider.recordAnswer(question.id, lst);
            } else {
              provider.recordAnswer(question.id, optionId);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF42A5F5) : theme.dividerColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      prefix,
                      style: TextStyle(
                        color: prefixColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    optionText,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MockFillBlankWidget extends StatelessWidget {
  final Question question;
  final ExamProvider provider;

  const _MockFillBlankWidget({required this.question, required this.provider});

  @override
  Widget build(BuildContext context) {
    final blanksMap = question.data['blanks'] as Map<String, dynamic>? ?? {};
    final currentAnswer = provider.state?.userAnswers[question.id];
    final userInputs = currentAnswer is Map ? Map<String, dynamic>.from(currentAnswer) : <String, dynamic>{};

    if (blanksMap.isEmpty) {
      return const Text('No blanks defined.', style: TextStyle(color: Colors.grey));
    }

    final theme = Theme.of(context);

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: blanksMap.keys.map<Widget>((blankKey) {
        return Container(
          width: 150,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
            border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
          ),
          child: TextField(
            style: TextStyle(color: theme.textTheme.bodyMedium?.color),
            decoration: InputDecoration(
              hintText: 'Answer $blankKey...',
              hintStyle: TextStyle(color: theme.hintColor),
              prefixIcon: Icon(Icons.edit_note_rounded, color: const Color(0xFF42A5F5).withOpacity(0.8), size: 18),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (val) {
              userInputs[blankKey] = val;
              provider.recordAnswer(question.id, userInputs);
            },
            controller: TextEditingController.fromValue(TextEditingValue(
              text: userInputs[blankKey]?.toString() ?? '',
              selection: TextSelection.collapsed(offset: (userInputs[blankKey]?.toString() ?? '').length),
            )),
          ),
        );
      }).toList(),
    );
  }
}

class _MockMatchingWidget extends StatefulWidget {
  final Question question;
  final ExamProvider provider;

  const _MockMatchingWidget({required this.question, required this.provider});

  @override
  State<_MockMatchingWidget> createState() => _MockMatchingWidgetState();
}

class _MockMatchingWidgetState extends State<_MockMatchingWidget> {
  String? _selectedLeftId;
  
  Map<String, dynamic> get _matches {
    final ans = widget.provider.state?.userAnswers[widget.question.id];
    return ans is Map ? Map<String, dynamic>.from(ans) : <String, dynamic>{};
  }

  void _onLeftTap(String id) {
    setState(() {
      _selectedLeftId = _selectedLeftId == id ? null : id;
    });
  }

  void _onRightTap(String id) {
    if (_selectedLeftId != null) {
      final inputs = _matches;
      inputs[_selectedLeftId!] = id;
      widget.provider.recordAnswer(widget.question.id, inputs);
      setState(() {
        _selectedLeftId = null;
      });
    }
  }
  
  void _clearMatch(String leftId) {
    final inputs = _matches;
    inputs.remove(leftId);
    widget.provider.recordAnswer(widget.question.id, inputs);
  }

  @override
  Widget build(BuildContext context) {
    final leftItems = List<dynamic>.from(widget.question.data['left_items'] ?? widget.question.data['slots'] ?? []);
    final rightItems = List<dynamic>.from(widget.question.data['right_items'] ?? widget.question.data['options'] ?? []);

    if (leftItems.isEmpty) return const Text('No matching items defined.', style: TextStyle(color: Colors.grey));

    final theme = Theme.of(context);
    final matchOrder = _matches.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: leftItems.map((left) {
                  final id = left['id'].toString();
                  final isSelected = _selectedLeftId == id;
                  final matchId = _matches[id];
                  final matchIndex = matchOrder.indexOf(id);

                  return _buildItem(
                    text: left['text']?.toString() ?? id,
                    isSelected: isSelected,
                    isMatched: matchId != null,
                    matchNumber: matchIndex != -1 ? matchIndex + 1 : null,
                    onTap: () => _onLeftTap(id),
                    theme: theme,
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
                  final matchIndex = pairedLeftId != null ? matchOrder.indexOf(pairedLeftId!) : -1;

                  return _buildItem(
                    text: right['text']?.toString() ?? id,
                    isSelected: false,
                    isMatched: pairedLeftId != null,
                    matchNumber: matchIndex != -1 ? matchIndex + 1 : null,
                    onTap: () {
                      if (pairedLeftId != null) {
                         _clearMatch(pairedLeftId!);
                      } else {
                         _onRightTap(id);
                      }
                    },
                    isRightSide: true,
                    theme: theme,
                    pairedLeftId: pairedLeftId,
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
    required ThemeData theme,
    String? pairedLeftId,
  }) {
    Color borderColor = theme.dividerColor.withOpacity(0.2);
    Color bgColor = theme.cardColor;
    Color textColor = theme.textTheme.bodyMedium?.color ?? Colors.grey;

    if (isSelected) {
      borderColor = const Color(0xFF42A5F5);
      bgColor = const Color(0xFF42A5F5).withOpacity(0.1);
      textColor = const Color(0xFF42A5F5);
    } else if (isMatched) {
      borderColor = const Color(0xFF4CAF50).withOpacity(0.5);
      bgColor = const Color(0xFF4CAF50).withOpacity(0.08);
      textColor = const Color(0xFF4CAF50);
    }

    Widget content = Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isSelected ? 2 : 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: isSelected || isMatched ? FontWeight.bold : FontWeight.w500,
              ),
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
          if (isRightSide && isMatched)
            Positioned(
              top: -22,
              left: -22,
              child: InkWell(
                onTap: () {
                    if(pairedLeftId != null) {
                        _clearMatch(pairedLeftId);
                    }
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
                    ],
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                ),
              ),
            ),
        ],
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: content,
    );
  }
}