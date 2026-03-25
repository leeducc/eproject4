import 'package:flutter/material.dart';
import '../models/exam_result.dart';

class ExamResultScreen extends StatelessWidget {
  final ExamResult result;

  const ExamResultScreen({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1320),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Exam Complete!',
                            style: TextStyle(color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        Text(result.examTitle,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── Overall Band ──────────────────────────────────────────────
              if (!result.writingPending) ...[
                _OverallBandCard(band: result.overallBand),
                const SizedBox(height: 28),
              ],

              // ── Section Scores ────────────────────────────────────────────
              const Text('Section Scores',
                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
              const SizedBox(height: 14),

              _ScoreCard(
                icon: Icons.headphones,
                label: 'Listening',
                score: result.listeningScore,
                color: Colors.purpleAccent,
                description: 'Automatically graded',
              ),
              const SizedBox(height: 12),
              _ScoreCard(
                icon: Icons.menu_book,
                label: 'Reading',
                score: result.readingScore,
                color: Colors.blueAccent,
                description: 'Automatically graded',
              ),
              const SizedBox(height: 12),

              // Writing — conditional on grading type
              if (result.writingPending)
                _WritingPendingCard()
              else
                _ScoreCard(
                  icon: Icons.edit_document,
                  label: 'Writing',
                  score: result.writingScore ?? 0,
                  color: Colors.orangeAccent,
                  description: 'AI instant grading',
                ),

              const SizedBox(height: 40),

              // ── IELTS Band Guide ──────────────────────────────────────────
              _BandGuideSection(
                listeningScore: result.listeningScore,
                readingScore: result.readingScore,
              ),

              const SizedBox(height: 40),

              // ── Actions ───────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Pop back until we're off the exam stack entirely
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Back to Home', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Overall Band Card ──────────────────────────────────────────────────────

class _OverallBandCard extends StatelessWidget {
  final double band;
  const _OverallBandCard({required this.band});

  Color get _bandColor {
    if (band >= 7.5) return Colors.greenAccent;
    if (band >= 6.0) return Colors.blueAccent;
    if (band >= 5.0) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  String get _bandLabel {
    if (band >= 8.5) return 'Expert';
    if (band >= 7.5) return 'Very Good';
    if (band >= 6.5) return 'Competent';
    if (band >= 5.5) return 'Modest';
    if (band >= 4.5) return 'Limited';
    return 'Intermittent';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_bandColor.withOpacity(0.25), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _bandColor.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Overall Band Score',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                Text(_bandLabel,
                    style: TextStyle(
                        color: _bandColor, fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('(Average of graded sections)',
                    style: TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: _bandColor.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: _bandColor, width: 2.5),
            ),
            child: Center(
              child: Text(
                band.toStringAsFixed(1),
                style: TextStyle(
                  color: _bandColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Score Card ─────────────────────────────────────────────────────────────

class _ScoreCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final double score;
  final Color color;
  final String description;

  const _ScoreCard({
    required this.icon,
    required this.label,
    required this.score,
    required this.color,
    required this.description,
  });

  String get _levelLabel {
    if (score >= 8.5) return 'Expert';
    if (score >= 7.5) return 'Very Good';
    if (score >= 6.5) return 'Competent';
    if (score >= 5.5) return 'Modest';
    if (score >= 4.5) return 'Limited';
    return 'Intermittent';
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (score / 9.0).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1E2E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(label,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text(score.toStringAsFixed(1),
                        style: TextStyle(
                            color: color, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    const Text('/9', style: TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(description, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                    const Spacer(),
                    Text(_levelLabel,
                        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Writing Pending Card ────────────────────────────────────────────────────

class _WritingPendingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1E2E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.edit_document, color: Colors.orangeAccent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('Writing', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    Spacer(),
                    Icon(Icons.hourglass_top_rounded, color: Colors.orangeAccent, size: 18),
                    SizedBox(width: 4),
                    Text('Pending', style: TextStyle(color: Colors.orangeAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '✏️ Your essay has been submitted to a teacher for grading. '
                    'You will be notified when the result is ready.',
                    style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Band Guide Section ──────────────────────────────────────────────────────

class _BandGuideSection extends StatelessWidget {
  final double listeningScore;
  final double readingScore;

  const _BandGuideSection({required this.listeningScore, required this.readingScore});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('IELTS Band Guide',
            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1E2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            children: [
              _BandRow('9.0', 'Expert', Colors.greenAccent),
              _BandRow('8.0 – 8.5', 'Very Good', Colors.green),
              _BandRow('7.0 – 7.5', 'Good', Colors.lightGreen),
              _BandRow('6.0 – 6.5', 'Competent', Colors.blueAccent),
              _BandRow('5.0 – 5.5', 'Modest', Colors.orangeAccent),
              _BandRow('4.0 – 4.5', 'Limited', Colors.deepOrangeAccent),
              _BandRow('1.0 – 3.5', 'Intermittent/Non-user', Colors.redAccent),
            ],
          ),
        ),
      ],
    );
  }
}

class _BandRow extends StatelessWidget {
  final String band;
  final String label;
  final Color color;
  const _BandRow(this.band, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 75,
            child: Text(band, style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Courier')),
          ),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
