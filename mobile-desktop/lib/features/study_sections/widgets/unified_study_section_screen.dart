import 'package:flutter/material.dart';
import 'package:mobile_desktop/core/models/app_section_model.dart';
import 'package:mobile_desktop/core/providers/ielts_level_provider.dart';
import 'package:mobile_desktop/features/study_sections/services/app_config_api_service.dart';
import 'package:mobile_desktop/features/study_sections/smart_test/screens/smart_test_active_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_html/flutter_html.dart';
import '../reading/screens/reading_exam_screen.dart';
import '../listening/screens/listening_exam_screen.dart';
import '../../ranking/providers/ranking_provider.dart';

class UnifiedStudySectionScreen extends StatefulWidget {
  final String skill; 
  final String title;

  const UnifiedStudySectionScreen({
    super.key,
    required this.skill,
    required this.title,
  });

  @override
  State<UnifiedStudySectionScreen> createState() => _UnifiedStudySectionScreenState();
}

class _UnifiedStudySectionScreenState extends State<UnifiedStudySectionScreen> {
  int totalTime = 0;
  late Future<List<AppSectionModel>> _sectionsFuture;

  
  Color get _primaryColor => widget.skill == 'READING' ? const Color(0xFFFF9800) : const Color(0xFF5A9BD5);
  
  
  List<Color> get _headerGradient => widget.skill == 'READING' 
      ? [const Color(0xFFFDBB2D), const Color(0xFFE65100)] 
      : [const Color(0xFF5A9BD5), const Color(0xFF4A90E2)];

  late RankingProvider _rankingProvider;

  @override
  void initState() {
    super.initState();
    debugPrint('[UnifiedStudySectionScreen] initState for ${widget.skill}');
    loadStats();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _rankingProvider = context.read<RankingProvider>();
        _rankingProvider.pushLearningScreen();
      }
    });
  }

  @override
  void dispose() {
    _rankingProvider.popLearningScreen();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final selectedLevel = context.watch<IeltsLevelProvider>().selectedLevel;
    final levelStr = selectedLevel.range;
    final skillName = widget.skill.toUpperCase();
    
    debugPrint('[UnifiedStudySectionScreen] fetching sections: skill=$skillName, levelStr=$levelStr');
    _sectionsFuture = AppConfigApiService().getSections(skillName, levelStr);
  }

  void loadStats() async {
    debugPrint('[UnifiedStudySectionScreen] loading stats from SharedPreferences');
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      totalTime = prefs.getInt("totalTime") ?? 0;
    });
  }

  String formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  IconData _getSectionIcon(String name) {
    String lowerName = name.toLowerCase();
    if (lowerName.contains('trac nghiem') || lowerName.contains('multiple choice')) {
      return Icons.task_alt_rounded;
    } else if (lowerName.contains('dien dap') || lowerName.contains('fill')) {
      return Icons.edit_note_rounded;
    } else if (lowerName.contains('noi') || lowerName.contains('speaking')) {
      return Icons.mic_none_rounded;
    }
    return Icons.menu_book_rounded;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[UnifiedStudySectionScreen] building UI');
    final theme = Theme.of(context);

    return FutureBuilder<List<AppSectionModel>>(
      future: _sectionsFuture,
      builder: (context, snapshot) {
        final sections = snapshot.data;
        int totalQuestions = sections?.fold(0, (sum, sec) => sum! + (sec.questionCount ?? 0)) ?? 0;
        int totalAppCorrect = sections?.fold(0, (sum, sec) => sum! + ((sec.mastery ?? 0) / 100 * (sec.questionCount ?? 0)).round()) ?? 0;
        double overallMastery = totalQuestions == 0 ? 0 : (totalAppCorrect / totalQuestions);
        
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Column(
            children: [
              _buildHeader(context, overallMastery, totalQuestions, totalAppCorrect),
              Expanded(
                child: _buildMainContent(snapshot, theme),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(context, sections, theme),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, double mastery, int totalQuestions, int totalCorrect) {
    debugPrint('[UnifiedStudySectionScreen] building smooth header');
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _headerGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 20, 
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 44),
            ],
          ),
          const SizedBox(height: 28),
          _statRow("Tổng số câu hỏi", "$totalQuestions"),
          _statRow("Đã trả lời đúng", "$totalCorrect"),
          _statRow("Thời gian học", formatTime(totalTime)),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                "Tiến độ tổng",
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 10,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: mastery,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "${(mastery * 100).toInt()}%",
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildMainContent(AsyncSnapshot<List<AppSectionModel>> snapshot, ThemeData theme) {
    debugPrint('[UnifiedStudySectionScreen] building content list');
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: theme.colorScheme.error)));
    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Center(child: Text('Chưa có bài tập nào.', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4))));
    }

    final sections = snapshot.data!;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        bool showPartHeader = index == 0 || sections[index - 1].displayOrder != section.displayOrder;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showPartHeader)
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 12, left: 4),
                child: Text(
                  "PHẦN ${section.displayOrder}",
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            _buildSectionCard(section, theme),
          ],
        );
      },
    );
  }

  Widget _buildSectionCard(AppSectionModel section, ThemeData theme) {
    debugPrint('[UnifiedStudySectionScreen] building card for ${section.sectionName}');
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => widget.skill == 'READING'
                ? ReadingExamScreen(title: section.sectionName, groupId: section.id, section: section)
                : ListeningExamScreen(title: section.sectionName, groupId: section.id, section: section),
          ),
        );
        loadStats();
        if (mounted) {
          final selectedLevel = context.read<IeltsLevelProvider>().selectedLevel;
          setState(() {
            _sectionsFuture = AppConfigApiService().getSections(widget.skill.toUpperCase(), selectedLevel.range);
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), 
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(_getSectionIcon(section.sectionName), color: _primaryColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.sectionName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Tổng cộng ${section.questionCount ?? 0} câu",
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                ),
                Text(
                  "${section.mastery?.toInt() ?? 0}%",
                  style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (section.mastery ?? 0) / 100,
                      backgroundColor: theme.dividerColor.withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(_primaryColor.withValues(alpha: 0.8)),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black12),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, List<AppSectionModel>? sections, ThemeData theme) {
    debugPrint('[UnifiedStudySectionScreen] building minimalist bottom bar');
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, -4))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: sections == null || sections.isEmpty
                  ? null
                  : () => _showAllGuides(context, sections),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: _primaryColor.withValues(alpha: 0.2)),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: Text("Bí kíp", style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                final level = context.read<IeltsLevelProvider>().selectedLevel.band.toString().split('.').last.replaceAll('_', '-').replaceAll('band', '');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SmartTestActiveScreen(skill: widget.skill, level: level)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 0, 
              ),
              child: const Text("Ra đề thông minh", 
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllGuides(BuildContext context, List<AppSectionModel> sections) {
    AppSectionModel? selectedSection;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: DraggableScrollableSheet(
                initialChildSize: 0.85,
                minChildSize: 0.5,
                maxChildSize: 0.95,
                expand: false,
                builder: (_, controller) {
                  if (selectedSection != null) {
                    return _buildGuideDetailView(selectedSection!, () {
                      setModalState(() => selectedSection = null);
                    });
                  }
                  return _buildGuideMenuView(sections, controller, (section) {
                    if (section.isPremium) {
                      _showPremiumAlert(context);
                    } else {
                      setModalState(() => selectedSection = section);
                    }
                  });
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGuideMenuView(List<AppSectionModel> sections, ScrollController controller, Function(AppSectionModel) onSelect) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _headerGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Center(
                child: Icon(
                  widget.skill == 'READING' ? Icons.auto_stories_rounded : Icons.headphones_rounded,
                  size: 100,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
            ),
            Positioned(
              left: 24,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.skill == 'READING' ? "TÀI LIỆU ĐỌC" : "TÀI LIỆU NGHE",
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("${widget.title} - Bí kíp",
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView.separated(
            controller: controller,
            padding: const EdgeInsets.symmetric(vertical: 20),
            itemCount: sections.length,
            separatorBuilder: (_, __) => Divider(color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
            itemBuilder: (context, index) {
              final section = sections[index];
              return ListTile(
                onTap: () => onSelect(section),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_getSectionIcon(section.sectionName), color: _primaryColor, size: 20),
                ),
                title: Text(
                  section.sectionName,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                subtitle: Text("Phần ${section.displayOrder}", style: TextStyle(fontSize: 13, color: Colors.grey)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (section.isPremium)
                      const Icon(Icons.stars_rounded, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black12, size: 16),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGuideDetailView(AppSectionModel section, VoidCallback onBack) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1))),
          ),
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: onBack),
              Expanded(
                child: Text(
                  section.sectionName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Html(
              data: section.guideContent ?? "<p>No guide provided yet.</p>",
              style: {
                "body": Style(fontSize: FontSize(16), lineHeight: const LineHeight(1.6)),
                "strong": Style(color: _primaryColor, fontWeight: FontWeight.bold),
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showPremiumAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Tiện ích PLUS"),
        content: const Text(
          "Bí kíp chuyên sâu chỉ dành cho thành viên PLUS. Hãy nâng cấp để mở khóa toàn bộ nội dung!",
          style: TextStyle(height: 1.5, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text("Nâng cấp ngay", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}