import 'package:flutter/material.dart';
import '../../../../core/models/quiz_bank_models.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';

class QuestionRenderer extends StatelessWidget {
  final Question question;
  final int indexPrefix;

  const QuestionRenderer({Key? key, required this.question, required this.indexPrefix}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2330),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
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
                  color: Colors.blueAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Q$indexPrefix',
                  style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question.instruction,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, height: 1.4),
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
    final currentAnswer = provider.state?.userAnswers[question.id];

    switch (question.type) {
      case QuestionType.MULTIPLE_CHOICE:
        // SQL mock data uses 'multiple_select' boolean and 'label' for option text
        final bool isMultiSelect = question.data['multiple_select'] == true
            || question.data['selection_type'] == 'MULTI';
        final options = List<dynamic>.from(question.data['options'] ?? []);

        print('[QuestionRenderer] MULTIPLE_CHOICE id=${question.id} options=${options.length} isMultiSelect=$isMultiSelect');

        if (options.isEmpty) {
          return const Text('No options defined.', style: TextStyle(color: Colors.white54));
        }

        return Column(
          children: options.map<Widget>((opt) {
            // SQL uses 'label', fallback to 'text' for flexibility
            final optionId = (opt['id'] ?? '').toString();
            final optionText = (opt['label'] ?? opt['text'] ?? optionId).toString();

            bool isSelected = false;
            if (isMultiSelect && currentAnswer is List) {
              isSelected = currentAnswer.contains(optionId);
            } else if (!isMultiSelect && currentAnswer is String) {
              isSelected = currentAnswer == optionId;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: isMultiSelect
                  ? CheckboxListTile(
                      value: isSelected,
                      onChanged: (val) {
                        List<String> lst = currentAnswer is List ? List<String>.from(currentAnswer) : [];
                        if (val == true) lst.add(optionId);
                        else lst.remove(optionId);
                        provider.recordAnswer(question.id, lst);
                      },
                      title: Text(optionText, style: const TextStyle(color: Colors.white70)),
                      tileColor: isSelected ? Colors.blueAccent.withOpacity(0.1) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: isSelected ? Colors.blueAccent : Colors.white12),
                      ),
                    )
                  : RadioListTile<String>(
                      value: optionId,
                      groupValue: currentAnswer as String?,
                      onChanged: (val) {
                        provider.recordAnswer(question.id, val);
                      },
                      title: Text(optionText, style: const TextStyle(color: Colors.white70)),
                      tileColor: isSelected ? Colors.blueAccent.withOpacity(0.1) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: isSelected ? Colors.blueAccent : Colors.white12),
                      ),
                    ),
            );
          }).toList(),
        );

      case QuestionType.FILL_BLANK:
        final blanksMap = question.data['blanks'] as Map<String, dynamic>? ?? {};
        final userInputs = currentAnswer is Map
            ? Map<String, dynamic>.from(currentAnswer)
            : <String, dynamic>{};

        print('[QuestionRenderer] FILL_BLANK id=${question.id} blanks=${blanksMap.keys.toList()}');

        if (blanksMap.isEmpty) {
          return const Text('No blanks defined.', style: TextStyle(color: Colors.white54));
        }

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: blanksMap.keys.map<Widget>((blankKey) {
            return SizedBox(
              width: 150,
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: blankKey,
                  labelStyle: const TextStyle(color: Colors.blueAccent),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                ),
                onChanged: (val) {
                  userInputs[blankKey] = val;
                  provider.recordAnswer(question.id, userInputs);
                },
                controller: TextEditingController.fromValue(TextEditingValue(
                  text: userInputs[blankKey]?.toString() ?? '',
                  selection: TextSelection.collapsed(
                      offset: (userInputs[blankKey]?.toString() ?? '').length),
                )),
              ),
            );
          }).toList(),
        );

      case QuestionType.MATCHING:
        // SQL format: left_items=[{id,text}], right_items=[{id,text}], solution={leftId: rightId}
        // Fallback: slots/options (older format)
        final leftItems = List<dynamic>.from(
            question.data['left_items'] ?? question.data['slots'] ?? []);
        final rightItems = List<dynamic>.from(
            question.data['right_items'] ?? question.data['options'] ?? []);
        final userInputs = currentAnswer is Map
            ? Map<String, dynamic>.from(currentAnswer)
            : <String, dynamic>{};

        print('[QuestionRenderer] MATCHING id=${question.id} left=${leftItems.length} right=${rightItems.length}');

        if (leftItems.isEmpty) {
          return const Text('No matching items defined.', style: TextStyle(color: Colors.white54));
        }

        return Column(
          children: leftItems.map<Widget>((leftItem) {
            final leftId = (leftItem['id'] ?? '').toString();
            final leftText = (leftItem['text'] ?? leftId).toString();

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(leftText, style: const TextStyle(color: Colors.white70)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: userInputs[leftId]?.toString(),
                      dropdownColor: const Color(0xFF1E2330),
                      style: const TextStyle(color: Colors.white),
                      hint: const Text('Select...', style: TextStyle(color: Colors.white38, fontSize: 13)),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white24)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white24)),
                      ),
                      items: rightItems.map((opt) {
                        final optId = (opt['id'] ?? '').toString();
                        final optText = (opt['text'] ?? optId).toString();
                        return DropdownMenuItem<String>(
                          value: optId,
                          child: Text(optText, style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        userInputs[leftId] = val;
                        provider.recordAnswer(question.id, userInputs);
                      },
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );

      default:
        return Text(
          'Unsupported question type: ${question.type.name}',
          style: const TextStyle(color: Colors.redAccent),
        );
    }
  }
}
