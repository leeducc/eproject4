import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/feedback_api.dart';
import '../models/feedback_model.dart';
import '../../../core/localization/app_localizations.dart';
import 'package:intl/intl.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _textContentController = TextEditingController();
  File? _imageFile;
  bool _isSubmitting = false;
  
  List<FeedbackModel> _userFeedbacks = [];
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });
    try {
      final feedbacks = await FeedbackApi.getUserFeedbacks();
      setState(() {
        _userFeedbacks = feedbacks;
      });
    } finally {
      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isSubmitting = true;
    });

    final success = await FeedbackApi.submitFeedback(
      title: _titleController.text.trim(),
      textContent: _textContentController.text.trim(),
      imageFile: _imageFile,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted successfully!')),
      );
      _titleController.clear();
      _textContentController.clear();
      setState(() {
        _imageFile = null;
      });
      _fetchHistory(); // Refresh history
      // Optionally switch to history tab or just stay
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit feedback. Please try again.')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textContentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.translate('feedback')),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'New Feedback'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildNewFeedbackForm(),
            _buildFeedbackHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildNewFeedbackForm() {
    return _isSubmitting
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _textContentController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your feedback here';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_imageFile != null)
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Image.file(
                          _imageFile!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _imageFile = null;
                            });
                          },
                        ),
                      ],
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Add an Image (Optional)'),
                    ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _submitFeedback,
                    child: const Text('Submit Feedback', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildFeedbackHistory() {
    if (_isLoadingHistory && _userFeedbacks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_userFeedbacks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('No feedback history found.', style: TextStyle(color: Colors.grey)),
            TextButton(onPressed: _fetchHistory, child: const Text('Refresh')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _userFeedbacks.length,
        itemBuilder: (context, index) {
          final feedback = _userFeedbacks[index];
          return _buildFeedbackCard(feedback);
        },
      ),
    );
  }

  Widget _buildFeedbackCard(FeedbackModel feedback) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final bool isResolved = feedback.status == 'RESOLVED';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(feedback.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Row(
          children: [
            Text(dateFormat.format(feedback.createdAt), style: const TextStyle(fontSize: 12)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isResolved ? Colors.green[100] : Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                feedback.status,
                style: TextStyle(
                  fontSize: 10,
                  color: isResolved ? Colors.green[800] : Colors.orange[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('My Feedback:', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(feedback.textContent),
                if (feedback.imageUrl != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'http://10.0.2.2:8123${feedback.imageUrl}',
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50),
                    ),
                  ),
                ],
                if (isResolved) ...[
                  const Divider(height: 32),
                  _buildAdminResponseSection(feedback.id),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminResponseSection(int feedbackId) {
    return FutureBuilder<FeedbackDetailModel?>(
      future: FeedbackApi.getFeedbackDetails(feedbackId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(strokeWidth: 2),
          ));
        }
        
        if (snapshot.hasError || snapshot.data == null) {
          return const Text('Failed to load response', style: TextStyle(color: Colors.red));
        }

        final adminMessages = snapshot.data!.messages.where((m) => m.isAdmin).toList();
        
        if (adminMessages.isEmpty) {
          return const Text('No admin response available.', style: TextStyle(fontStyle: FontStyle.italic));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.admin_panel_settings, size: 16, color: Colors.blue),
                SizedBox(width: 4),
                Text('Admin Response:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 8),
            ...adminMessages.map((msg) => Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(msg.textContent),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('yyyy-MM-dd HH:mm').format(msg.createdAt),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            )).toList(),
          ],
        );
      },
    );
  }
}
