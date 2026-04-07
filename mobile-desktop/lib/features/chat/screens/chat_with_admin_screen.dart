import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/chat_message.dart';
import '../../../data/services/chat_service.dart';
import '../../../data/services/profile_api.dart';

class ChatWithAdminScreen extends StatefulWidget {
  const ChatWithAdminScreen({Key? key}) : super(key: key);

  @override
  _ChatWithAdminScreenState createState() => _ChatWithAdminScreenState();
}

class _ChatWithAdminScreenState extends State<ChatWithAdminScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  int? _myId;
  PlatformFile? _selectedFile;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final profile = await ProfileApi.getProfile();
    if (profile != null) {
      _myId = profile['id'] ?? 1; 
      await _chatService.connect(_myId!);
      _chatService.messageStream.listen((msg) {
        if (mounted) {
          setState(() {
            final index = _messages.indexWhere((m) => m.id == msg.id);
            if (index != -1) {
              _messages[index] = msg;
            } else {
              _messages.add(msg);
              _scrollToBottom();
            }
          });
        }
      });
      _loadHistory();
    }
  }

  Future<void> _loadHistory() async {
    final history = await ChatService.getChatHistory(1); 
    if (mounted) {
      setState(() {
        _messages = history;
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _chatService.disconnect();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      if (result.files.single.size > 10 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File size must be less than 10MB')),
        );
        return;
      }
      setState(() => _selectedFile = result.files.single);
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty && _selectedFile == null) return;

    final content = _controller.text.trim();
    final filePath = _selectedFile?.path;
    
    setState(() {
      _controller.clear();
      _selectedFile = null;
    });

    bool success = await ChatService.sendMessage(1, content, filePath: filePath);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send message')),
      );
    }
  }

  void _showHistoryModal(ChatMessage msg) async {
    final history = await ChatService.getEditHistory(msg.id);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Edit History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            if (history.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('No history found')),
              ),
            ...history.map((h) => ListTile(
              title: Text(h.oldContent),
              subtitle: Text(DateFormat('MMM d, HH:mm').format(h.editedAt)),
            )).toList(),
          ],
        ),
      ),
    );
  }

  void _editMessage(ChatMessage msg) {
    _controller.text = msg.content;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(controller: _controller, autofocus: true, maxLines: null),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newContent = _controller.text.trim();
              Navigator.pop(context);
              if (newContent.isNotEmpty && newContent != msg.content) {
                await ChatService.editMessage(msg.id, newContent);
              }
              _controller.clear();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Admin'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _buildMessageBubble(msg);
                    },
                  ),
          ),
          if (_selectedFile != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: theme.primaryColor.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.attach_file, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_selectedFile!.name, style: const TextStyle(fontSize: 12))),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => setState(() => _selectedFile = null),
                  ),
                ],
              ),
            ),
          _buildInputArea(theme),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isMe = msg.isMe;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msg.mediaUrl != null)
                GestureDetector(
                    onTap: () => launchUrl(Uri.parse('http://10.0.2.2:8123${msg.mediaUrl}')),
                    child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: msg.mediaType == 'IMAGE' 
                            ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network('http://10.0.2.2:8123${msg.mediaUrl}', errorBuilder: (c,e,s) => const Icon(Icons.error)))
                            : Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(8)),
                                child: const Row(children: [Icon(Icons.picture_as_pdf), SizedBox(width: 8), Text('Open PDF', style: TextStyle(fontSize: 12))]),
                            ),
                    ),
                ),
            Text(
              msg.content,
              style: TextStyle(color: isMe ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('HH:mm').format(msg.createdAt),
                  style: TextStyle(color: (isMe ? Colors.white70 : Colors.black54), fontSize: 10),
                ),
                if (msg.isEdited) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => _showHistoryModal(msg),
                    child: Text('Edited', style: TextStyle(color: (isMe ? Colors.white70 : Colors.black54), fontSize: 10, decoration: TextDecoration.underline)),
                  ),
                ],
                if (isMe) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _editMessage(msg),
                    child: const Icon(Icons.edit, size: 12, color: Colors.white70),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, -2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _pickFile,
            color: theme.primaryColor,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null,
              maxLength: 2000,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
                counterText: "",
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_controller.text.length > 2000) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message is too long (max 2000 characters)')),
                );
                return;
              }
              _sendMessage();
            },
            color: theme.primaryColor,
          ),
        ],
      ),
    );
  }
}