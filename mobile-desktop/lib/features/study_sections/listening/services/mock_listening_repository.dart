import 'package:flutter/material.dart';
import 'listening_repository.dart';
import '../models/listening_exercise.dart';
import '../../../../core/providers/ielts_level_provider.dart';

const List<ListeningExercise> _kAllExercises = [
  // Band 0-4
  ListeningExercise(
    id: 'l1',
    title: 'Greetings and Introductions',
    audioUrl: 'https://example.com/audio1.mp3',
    band: IeltsBand.band0_4,
  ),
  ListeningExercise(
    id: 'l2',
    title: 'Ordering Food at a Restaurant',
    audioUrl: 'https://example.com/audio2.mp3',
    band: IeltsBand.band0_4,
  ),

  // Band 5-6
  ListeningExercise(
    id: 'l3',
    title: 'A Tour Guide Talk',
    audioUrl: 'https://example.com/audio3.mp3',
    band: IeltsBand.band5_6,
  ),
  ListeningExercise(
    id: 'l4',
    title: 'University Campus Orientation',
    audioUrl: 'https://example.com/audio4.mp3',
    band: IeltsBand.band5_6,
  ),

  // Band 7-8
  ListeningExercise(
    id: 'l5',
    title: 'Academic Lecture on Climate Change',
    audioUrl: 'https://example.com/audio5.mp3',
    band: IeltsBand.band7_8,
  ),
  ListeningExercise(
    id: 'l6',
    title: 'Discussion on Modern Architecture',
    audioUrl: 'https://example.com/audio6.mp3',
    band: IeltsBand.band7_8,
  ),

  // Band 9
  ListeningExercise(
    id: 'l7',
    title: 'Scientific Symposium Debate',
    audioUrl: 'https://example.com/audio7.mp3',
    band: IeltsBand.band9,
  ),
  ListeningExercise(
    id: 'l8',
    title: 'Philosophical Discourse Series',
    audioUrl: 'https://example.com/audio8.mp3',
    band: IeltsBand.band9,
  ),
];

class MockListeningRepository implements ListeningRepository {
  @override
  Future<List<ListeningExercise>> fetchExercises(IeltsBand band) async {
    debugPrint('[MockListeningRepository] fetchExercises → band=$band');
    await Future.delayed(const Duration(milliseconds: 400));
    final filtered = _kAllExercises.where((p) => p.band == band).toList();
    debugPrint('[MockListeningRepository] Returning ${filtered.length} exercises for $band');
    return filtered;
  }
}
