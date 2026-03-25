import 'package:flutter/material.dart';

/// Reusable header bar shown above each section's question list.
/// Shows group title, current question number, flag toggle, and question map button.
class ExamSectionHeader extends StatelessWidget {
  final String title;
  final int current;
  final int total;
  final bool isFlagged;
  final VoidCallback onFlag;
  final VoidCallback onMap;

  const ExamSectionHeader({
    Key? key,
    required this.title,
    required this.current,
    required this.total,
    required this.isFlagged,
    required this.onFlag,
    required this.onMap,
  }) : super(key: key);

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
                Text(
                  title,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Question ${current + 1} of $total',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
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
                color: isFlagged
                    ? Colors.orangeAccent.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: isFlagged ? Colors.orangeAccent : Colors.white12),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(isFlagged ? Icons.flag : Icons.flag_outlined,
                    size: 14, color: isFlagged ? Colors.orangeAccent : Colors.white38),
                const SizedBox(width: 4),
                Text(
                  isFlagged ? 'Flagged' : 'Flag',
                  style: TextStyle(
                      fontSize: 12,
                      color: isFlagged ? Colors.orangeAccent : Colors.white38),
                ),
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

/// Reusable Previous / Next navigation bar at the bottom of each section view.
class ExamPageNavBar extends StatelessWidget {
  final int currentIndex;
  final int total;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const ExamPageNavBar({
    Key? key,
    required this.currentIndex,
    required this.total,
    required this.onPrev,
    required this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool hasPrev = currentIndex > 0;
    final bool hasNext = currentIndex < total - 1;

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
              onPressed: hasPrev ? onPrev : null,
              icon: const Icon(Icons.arrow_back_ios_new, size: 14),
              label: const Text('Previous'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white12,
                disabledBackgroundColor: Colors.white.withOpacity(0.04),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white24,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: hasNext ? onNext : null,
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
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
