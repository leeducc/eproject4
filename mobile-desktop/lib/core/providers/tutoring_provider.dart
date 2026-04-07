import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/services/tutoring_service.dart';
import '../../data/models/tutoring_models.dart';

class TutoringProvider with ChangeNotifier {
  final TutoringService _tutoringService = TutoringService();
  
  int _queuePosition = 0;
  int _ewtMinutes = 0;
  bool _isQueueing = false;
  Map<String, dynamic>? _lastMatch;
  List<TeacherSchedule> _availableTeachers = [];
  bool _isLoadingTeachers = false;
  
  Stream<Map<String, dynamic>> get queueStream => _tutoringService.queueStream;
  Stream<Map<String, dynamic>> get rtcStream => _tutoringService.rtcStream;

  int get queuePosition => _queuePosition;
  int get ewtMinutes => _ewtMinutes;
  bool get isQueueing => _isQueueing;
  Map<String, dynamic>? get lastMatch => _lastMatch;
  List<TeacherSchedule> get availableTeachers => _availableTeachers;
  bool get isLoadingTeachers => _isLoadingTeachers;

  void joinQueue(int userId) {
    _isQueueing = true;
    _tutoringService.connect(userId).then((_) {
      _tutoringService.queueStream.listen((event) {
        _handleQueueEvent(event);
      });
      _tutoringService.joinQueue();
    });
    notifyListeners();
  }

  void _handleQueueEvent(Map<String, dynamic> event) {
    final type = event['type'];
    print('Tutoring Event: $type');

    if (type == 'JOIN_CONFIRMED') {
      _queuePosition = event['position'] ?? 0;
      _ewtMinutes = event['ewtMinutes'] ?? 0;
    } else if (type == 'MATCH_FOUND') {
      _lastMatch = event;
    } else if (type == 'MATCH_ACCEPTED') {
      _isQueueing = false;
      _lastMatch = null;
      _queuePosition = 0;
    } else if (type == 'MATCH_TIMEOUT') {
      _isQueueing = false;
      _lastMatch = null;
      _queuePosition = 0;
    }
    
    notifyListeners();
  }

  void acceptMatch(int teacherId) {
    _tutoringService.acceptMatch(teacherId);
  }

  void sendRtcSignal(Map<String, dynamic> signal) {
    _tutoringService.sendRtcSignal(signal);
  }

  void resetRtcStream() {
    // Optional: add stream reset logic if needed
  }

  void resetMatch() {
    _lastMatch = null;
    notifyListeners();
  }

  Future<void> fetchAvailableTeachers() async {
    _isLoadingTeachers = true;
    notifyListeners();
    try {
      _availableTeachers = await _tutoringService.getAvailableTeachers();
    } catch (e) {
      print('[TutoringProvider] Error fetching teachers: $e');
    } finally {
      _isLoadingTeachers = false;
      notifyListeners();
    }
  }

  Future<bool> bookSlot(int slotId) async {
    final success = await _tutoringService.bookSlot(slotId);
    if (success) {
      // Refresh the list to reflect booked status
      await fetchAvailableTeachers();
    }
    return success;
  }

  String formatVNTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  @override
  void dispose() {
    _tutoringService.disconnect();
    super.dispose();
  }
}