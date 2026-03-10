import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/ielts_level_provider.dart';

class ChooseLevelScreen extends StatefulWidget {
  const ChooseLevelScreen({Key? key}) : super(key: key);

  @override
  State<ChooseLevelScreen> createState() => _ChooseLevelScreenState();
}

class _ChooseLevelScreenState extends State<ChooseLevelScreen>
    with TickerProviderStateMixin {
  late int _selectedIndex;
  late AnimationController _barController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    final provider = context.read<IeltsLevelProvider>();
    _selectedIndex =
        kIeltsLevels.indexWhere((l) => l.range == provider.selectedLevel.range);
    if (_selectedIndex < 0) _selectedIndex = 1;

    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    debugPrint('[ChooseLevelScreen] initState – selected index: $_selectedIndex');
  }

  @override
  void dispose() {
    _barController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onLevelTap(int index) {
    debugPrint('[ChooseLevelScreen] Tapped level index: $index (${kIeltsLevels[index].label})');
    setState(() => _selectedIndex = index);
    _fadeController.reset();
    _fadeController.forward();
  }

  void _onConfirm() {
    final chosen = kIeltsLevels[_selectedIndex];
    debugPrint('[ChooseLevelScreen] Confirmed level: ${chosen.label}');
    context.read<IeltsLevelProvider>().setLevel(chosen);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final level = kIeltsLevels[_selectedIndex];
    final maxBarHeight = 120.0;

    return Scaffold(
      backgroundColor: const Color(0xFF161A23),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Choose Your IELTS Level',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // ── Description card ──────────────────────────────────────
            FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        level.accentColor.withOpacity(0.85),
                        level.primaryColor.withOpacity(0.55),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: level.accentColor.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              level.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.school_rounded,
                              color: Colors.white.withOpacity(0.9), size: 28),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        level.description,
                        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      _buildSkillChips(),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Bar chart selector ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(kIeltsLevels.length, (i) {
                  final lvl = kIeltsLevels[i];
                  final isSelected = i == _selectedIndex;
                  final targetHeight = (lvl.barHeight / 4) * maxBarHeight;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _onLevelTap(i),
                      child: AnimatedBuilder(
                        animation: _barController,
                        builder: (context, child) {
                          final animatedHeight =
                              targetHeight * _barController.value;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // selection indicator dot
                              AnimatedOpacity(
                                opacity: isSelected ? 1 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(bottom: 6),
                                  decoration: BoxDecoration(
                                    color: lvl.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              // bar
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                height: isSelected ? targetHeight : animatedHeight,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(10)),
                                  color: isSelected
                                      ? lvl.primaryColor
                                      : const Color(0xFF2A3040),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: lvl.primaryColor.withOpacity(0.5),
                                            blurRadius: 12,
                                            offset: const Offset(0, -4),
                                          )
                                        ]
                                      : [],
                                ),
                              ),
                              const SizedBox(height: 8),
                              // label below bar
                              Text(
                                lvl.range,
                                style: TextStyle(
                                  color: isSelected
                                      ? lvl.primaryColor
                                      : Colors.white38,
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                }),
              ),
            ),

            // ── Divider line ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      kIeltsLevels[_selectedIndex].primaryColor,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── "Not sure?" hint ──────────────────────────────────────
            GestureDetector(
              onTap: () {
                debugPrint('[ChooseLevelScreen] Tapped placement test hint');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Placement test coming soon!'),
                    backgroundColor: Color(0xFF2A3040),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Not sure about your level? Take a free placement test and let AI identify your current band.',
                        style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right, color: Colors.white38),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // ── Start / Confirm button ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: ElevatedButton(
                onPressed: _onConfirm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  backgroundColor: kIeltsLevels[_selectedIndex].primaryColor,
                  elevation: 6,
                  shadowColor: kIeltsLevels[_selectedIndex].primaryColor
                      .withOpacity(0.5),
                ),
                child: const Text(
                  'Start Practising',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillChips() {
    final skills = ['Reading', 'Listening', 'Writing', 'Vocabulary'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skills.map((s) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: Text(s,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        );
      }).toList(),
    );
  }
}
