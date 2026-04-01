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

class UnifiedStudySectionScreen extends StatefulWidget {
  final String skill; // 'READING' or 'LISTENING'
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
  int totalAnswers = 0;
  int correctAnswers = 0;
  int totalTime = 0;
  late Future<List<AppSectionModel>> _sectionsFuture;

  @override
  void initState() {
    super.initState();
    debugPrint('[UnifiedStudySectionScreen] initState for ${widget.skill}');
    loadStats();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final selectedLevel = context.watch<IeltsLevelProvider>().selectedLevel;
    final levelStr = selectedLevel.range; // Uses "0-4.0", "5.0-6.0", etc.
    
    // Match database case (UPPERCASE) for Skill
    final skillName = widget.skill.toUpperCase();
    
    debugPrint('[UnifiedStudySectionScreen] fetching sections: skill=$skillName, levelStr=$levelStr');
    _sectionsFuture = AppConfigApiService().getSections(skillName, levelStr);
  }

  void loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalAnswers = prefs.getInt("totalAnswers") ?? 0;
      correctAnswers = prefs.getInt("correctAnswers") ?? 0;
      totalTime = prefs.getInt("totalTime") ?? 0;
    });
  }

  String formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  void _showAllGuides(BuildContext context, List<AppSectionModel> sections) {
    AppSectionModel? selectedSection;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E212A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
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
            );
          },
        );
      },
    );
  }

  Widget _buildGuideMenuView(List<AppSectionModel> sections, ScrollController controller, Function(AppSectionModel) onSelect) {
    return Column(
      children: [
        // Header Image Area (Matching Screenshot)
        Stack(
          children: [
            Container(
              height: 180,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF9A825), Color(0xFFE65100)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Center(
                child: Opacity(
                  opacity: 0.2,
                  child: Icon(
                    widget.skill == 'READING' ? Icons.menu_book : Icons.headset,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.skill == 'READING' ? "Đọc hiểu" : "Nghe hiểu",
                      style: const TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 5),
                  Text("${widget.title} - Bí kíp",
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
        
        // Menu List
        Expanded(
          child: Container(
            color: const Color(0xFF1E212A),
            child: ListView.builder(
              controller: controller,
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Part Header (e.g. Phần 1)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blueGrey.withOpacity(0.3),
                            Colors.blueGrey.withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: Text(
                        "Phần ${section.displayOrder}",
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                    
                    // Section Item
                    ListTile(
                      onTap: () => onSelect(section),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(
                        section.sectionName,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (section.isPremium)
                            const Icon(Icons.lock, color: Colors.amber, size: 20),
                          const SizedBox(width: 10),
                          const Icon(Icons.chevron_right, color: Colors.white24),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.white10, height: 1),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuideDetailView(AppSectionModel section, VoidCallback onBack) {
    return Column(
      children: [
        // Simple Detail Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white10)),
          ),
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: onBack),
              Expanded(
                child: Text(
                  section.sectionName,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        
        // Guide Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Html(
              data: section.guideContent ?? "<p>No guide provided yet.</p>",
              style: {
                "body": Style(color: Colors.white70, fontSize: FontSize(16)),
                "p": Style(lineHeight: const LineHeight(1.5)),
                "strong": Style(color: Colors.amber),
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
        backgroundColor: const Color(0xFF2C313D),
        title: const Text("Tiện ích Pro", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Bí kíp cho phần này chỉ dành cho người dùng Pro. Hãy nâng cấp để xem nội dung!",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Đóng", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigate to Pro Upgrade Screen
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: const Text("Nâng cấp ngay", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[UnifiedStudySectionScreen] Building UI for ${widget.skill}');
    double mastery = totalAnswers == 0 ? 0 : (correctAnswers / totalAnswers);

    return FutureBuilder<List<AppSectionModel>>(
      future: _sectionsFuture,
      builder: (context, snapshot) {
        final sections = snapshot.data;
        
        return Scaffold(
          backgroundColor: const Color(0xFF1E212A),
          body: Column(
            children: [
              _buildHeader(context, mastery),
              Expanded(
                child: _buildMainContent(snapshot),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(context, sections),
        );
      },
    );
  }

  Widget _buildMainContent(AsyncSnapshot<List<AppSectionModel>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      debugPrint('[UnifiedStudySectionScreen] Future Error: ${snapshot.error}');
      return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      debugPrint('[UnifiedStudySectionScreen] No data found for ${widget.skill}');
      return const Center(child: Text('No sections available.', style: TextStyle(color: Colors.white)));
    }

    final sections = snapshot.data!;
    debugPrint('[UnifiedStudySectionScreen] Loaded ${sections.length} sections');
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        bool showPartHeader = index == 0 || sections[index - 1].displayOrder != section.displayOrder;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showPartHeader)
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 8),
                child: Text(
                  "Phần ${section.displayOrder}",
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            _buildSectionCard(section),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, double mastery) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF9A825), Color(0xFFE65100)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
              Expanded(
                child: Center(
                  child: Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 20),
          _statRow("Tổng số câu trả lời", "$totalAnswers lần"),
          _statRow("Trả lời đúng", "$correctAnswers lần"),
          _statRow("Thời gian trả lời", formatTime(totalTime)),
          const SizedBox(height: 15),
          Row(
            children: [
              const Text("Nắm vững", style: TextStyle(color: Colors.white, fontSize: 13)),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: mastery,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionCard(AppSectionModel section) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => widget.skill == 'READING'
                ? ReadingExamScreen(title: section.sectionName, groupId: section.id, section: section)
                : ListeningExamScreen(title: section.sectionName, groupId: section.id, section: section),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2C313D),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(section.sectionName,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                Text("${section.mastery?.toInt() ?? 0}/${section.questionCount ?? 0}",
                    style: const TextStyle(color: Color(0xFF42A5F5), fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text("Nắm vững", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const Spacer(),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      value: (section.mastery ?? 0) / 100,
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF454B58)),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text("${section.mastery?.toInt() ?? 0}%", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, List<AppSectionModel>? sections) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1E212A),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: sections == null || sections.isEmpty
                  ? null
                  : () => _showAllGuides(context, sections),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Bí kíp làm bài", style: TextStyle(color: Color(0xFF42A5F5))),
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
                backgroundColor: const Color(0xFF42A5F5),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Ra đề thông minh", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
