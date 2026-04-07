import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/tutoring_provider.dart';
import '../../../../data/models/tutoring_models.dart';
import 'teacher_profile_screen.dart';

class SpeakingScreen extends StatefulWidget {
  const SpeakingScreen({Key? key}) : super(key: key);

  @override
  State<SpeakingScreen> createState() => _SpeakingScreenState();
}

class _SpeakingScreenState extends State<SpeakingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TutoringProvider>().fetchAvailableTeachers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TutoringProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Luyện Nói 1-1',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.onSurface.withOpacity(0.7)),
            onPressed: () => tp.fetchAvailableTeachers(),
          ),
        ],
      ),
      body: tp.isLoadingTeachers
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : tp.availableTeachers.isEmpty
              ? _buildEmptyState(theme)
              : RefreshIndicator(
                  onRefresh: () => tp.fetchAvailableTeachers(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tp.availableTeachers.length,
                    itemBuilder: (context, index) {
                      return _buildTeacherCard(context, tp.availableTeachers[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_rounded, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            'Hiện chưa có giáo viên nào sẵn sàng.',
            style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherCard(BuildContext context, TeacherSchedule teacher) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: theme.cardTheme.color ?? colorScheme.surface,
      elevation: theme.cardTheme.elevation ?? 0,
      shape: theme.cardTheme.shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeacherProfileScreen(teacher: teacher),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    child: teacher.avatar.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Image.network(teacher.avatar,
                                fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.person, color: colorScheme.primary)))
                        : Icon(Icons.person, color: colorScheme.primary, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          teacher.fullName,
                          style: TextStyle(color: colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              teacher.averageRating.toStringAsFixed(1),
                              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 4),
                            Text('•', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.2))),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'IELTS Specialist',
                                style: TextStyle(color: colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: colorScheme.onSurface.withOpacity(0.2), size: 16),
                ],
              ),
              if (teacher.bio.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  teacher.bio,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 14, height: 1.4),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

}