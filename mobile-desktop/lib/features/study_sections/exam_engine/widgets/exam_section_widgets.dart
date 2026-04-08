import 'package:flutter/material.dart';



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
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Question ${current + 1} of $total',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          
          GestureDetector(
            onTap: onFlag,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isFlagged
                    ? Colors.orangeAccent.withOpacity(0.2)
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: isFlagged ? Colors.orangeAccent : Theme.of(context).dividerColor.withOpacity(0.1)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(isFlagged ? Icons.flag : Icons.flag_outlined,
                    size: 14, color: isFlagged ? Colors.orangeAccent : Theme.of(context).colorScheme.onSurface.withOpacity(0.38)),
                const SizedBox(width: 4),
                Text(
                  isFlagged ? 'Flagged' : 'Flag',
                  style: TextStyle(
                      fontSize: 12,
                      color: isFlagged ? Colors.orangeAccent : Theme.of(context).colorScheme.onSurface.withOpacity(0.38)),
                ),
              ]),
            ),
          ),
          const SizedBox(width: 8),
          
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
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: hasPrev ? onPrev : null,
              icon: const Icon(Icons.arrow_back_ios_new, size: 14),
              label: const Text('Previous'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).dividerColor.withOpacity(0.1),
                disabledBackgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.04),
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                disabledForegroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.24),
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
                disabledBackgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.04),
                foregroundColor: Colors.white,
                disabledForegroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.24),
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