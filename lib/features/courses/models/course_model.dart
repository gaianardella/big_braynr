import 'package:flutter/material.dart';

/// Modello che rappresenta un corso di studio
class CourseModel {
  final String id;
  final String name;
  final Color color;
  final IconData icon;
  final String? description;
  final DateTime? lastAccessed;
  final int? totalFlashcards;
  final int? totalNotes;
  
  CourseModel({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    this.description,
    this.lastAccessed,
    this.totalFlashcards,
    this.totalNotes,
  });
  
  // Crea una copia dell'oggetto con i campi aggiornati
  CourseModel copyWith({
    String? id,
    String? name,
    Color? color,
    IconData? icon,
    String? description,
    DateTime? lastAccessed,
    int? totalFlashcards,
    int? totalNotes,
  }) {
    return CourseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      totalFlashcards: totalFlashcards ?? this.totalFlashcards,
      totalNotes: totalNotes ?? this.totalNotes,
    );
  }
  
  // Converti il modello in una mappa per la persistenza
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
      'icon': icon.codePoint,
      'description': description,
      'lastAccessed': lastAccessed?.toIso8601String(),
      'totalFlashcards': totalFlashcards,
      'totalNotes': totalNotes,
    };
  }
  
  // Crea un'istanza del modello a partire da una mappa
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      name: json['name'],
      color: Color(json['color']),
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      description: json['description'],
      lastAccessed: json['lastAccessed'] != null 
        ? DateTime.parse(json['lastAccessed']) 
        : null,
      totalFlashcards: json['totalFlashcards'],
      totalNotes: json['totalNotes'],
    );
  }
}