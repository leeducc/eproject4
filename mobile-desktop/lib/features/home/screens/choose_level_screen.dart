import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/ielts_level_provider.dart';
import '../../../core/localization/app_localizations.dart';

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
    debugPrint('[ChooseLevelScreen] initState');
    final provider = context.read<IeltsLevelProvider>();
    _selectedIndex =
        kIeltsLevels.indexWhere((l) => l.range == provider.selectedLevel.range);
    if (_selectedIndex < 0) _selectedIndex = 0;

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
      curve: Curves.easeInOut,
    );
    _fadeController.forward();

    debugPrint('[ChooseLevelScreen] initial selected index: $_selectedIndex');
  }

  @override
  void dispose() {
    debugPrint('[ChooseLevelScreen] dispose');
    _barController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onLevelTap(int index) {
    debugPrint('[ChooseLevelScreen] Level index selected: $index');
    setState(() => _selectedIndex = index);
    _fadeController.reset();
    _fadeController.forward();
  }

  void _onConfirm() {
    final chosen = kIeltsLevels[_selectedIndex];
    debugPrint('[ChooseLevelScreen] Confirming level: ${chosen.label}');
    context.read<IeltsLevelProvider>().setLevel(chosen);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final level = kIeltsLevels[_selectedIndex];
    const maxBarHeight = 130.0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, 
                     color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.translate('choose_your_level'),
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),

              
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [
                        level.accentColor,
                        level.primaryColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: level.accentColor.withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
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
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
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
                          const Icon(Icons.psychology_rounded,
                              color: Colors.white, size: 32),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        level.description,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.95), 
                            fontSize: 15, 
                            height: 1.5,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 20),
                      _buildSkillChips(context),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),

              
              Text(
                l10n.translate('select_level_below'), 
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 24),

              
              Row(
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
                              
                              AnimatedOpacity(
                                opacity: isSelected ? 1 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: lvl.primaryColor,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: lvl.primaryColor.withOpacity(0.5),
                                        blurRadius: 4,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                height: isSelected ? targetHeight : animatedHeight,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12)),
                                  color: isSelected
                                      ? lvl.primaryColor
                                      : theme.colorScheme.surface.withOpacity(0.5),
                                  border: isSelected 
                                      ? null 
                                      : Border.all(color: theme.dividerColor.withOpacity(0.1)),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: lvl.primaryColor.withOpacity(0.4),
                                            blurRadius: 16,
                                            offset: const Offset(0, 4),
                                          )
                                        ]
                                      : [],
                                ),
                              ),
                              const SizedBox(height: 12),
                              
                              Text(
                                lvl.range,
                                style: TextStyle(
                                  color: isSelected
                                      ? lvl.primaryColor
                                      : theme.colorScheme.onSurface.withOpacity(0.4),
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
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

              const SizedBox(height: 64),

              
              ElevatedButton(
                onPressed: _onConfirm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  backgroundColor: level.primaryColor,
                  shadowColor: level.primaryColor.withOpacity(0.4),
                  elevation: 8,
                ),
                child: Text(
                  l10n.translate('start_practising'),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillChips(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final skills = [
      l10n.translate('reading'), 
      l10n.translate('listening'), 
      l10n.translate('writing'), 
      l10n.translate('vocabulary_section')
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: skills.map((s) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Text(s,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
        );
      }).toList(),
    );
  }
}