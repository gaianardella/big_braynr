import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../screens/course_model.dart';

// Provider per il corso selezionato
final selectedCourseProvider = StateProvider<String?>((ref) => null);

// Provider per i corsi
final coursesProvider = Provider<List<CourseModel>>((ref) {
  return [
    CourseModel(
      id: 'math',
      name: 'Matematica',
      color: const Color(0xFF4DA9FF),
      icon: Icons.calculate,
    ),
    CourseModel(
      id: 'physics',
      name: 'Fisica',
      color: const Color(0xFFFF9500),
      icon: Icons.science,
    ),
    CourseModel(
      id: 'history',
      name: 'Storia',
      color: const Color(0xFF5E72EB),
      icon: Icons.history_edu,
    ),
    CourseModel(
      id: 'cs',
      name: 'Informatica',
      color: const Color(0xFF64C2DB),
      icon: Icons.computer,
    ),
  ];
});