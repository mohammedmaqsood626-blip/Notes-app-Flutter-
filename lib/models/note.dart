import 'package:flutter/material.dart';

class Note {
  final String id;
  String title;
  String content;
  String category;
  Color color;
  bool isPinned;
  bool isFavorite;
  DateTime createdAt;
  DateTime updatedAt;
  List<String> tags;

  // NEW
  String? fileName;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.category = 'General',
    this.color = const Color(0xFFFFF9C4),
    this.isPinned = false,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],

    // NEW
    this.fileName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'color': color.value,
      'isPinned': isPinned ? 1 : 0,
      'isFavorite': isFavorite ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags.join(','),

      // NEW
      'fileName': fileName,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      category: map['category'] ?? 'General',
      color: Color(map['color'] ?? 0xFFFFF9C4),
      isPinned: map['isPinned'] == 1,
      isFavorite: map['isFavorite'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      tags: map['tags'] != null && map['tags'].toString().isNotEmpty
          ? map['tags'].toString().split(',')
          : [],

      // NEW
      fileName: map['fileName'],
    );
  }

  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    Color? color,
    bool? isPinned,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,

    // NEW
    String? fileName,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      color: color ?? this.color,
      isPinned: isPinned ?? this.isPinned,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,

      // NEW
      fileName: fileName ?? this.fileName,
    );
  }
}

// Predefined note colors
const List<Color> noteColors = [
  Color(0xFFFFF9C4), // Yellow
  Color(0xFFFFCDD2), // Pink
  Color(0xFFE8F5E9), // Green
  Color(0xFFE3F2FD), // Blue
  Color(0xFFF3E5F5), // Purple
  Color(0xFFFFF3E0), // Orange
  Color(0xFFE0F7FA), // Cyan
  Color(0xFFFCE4EC), // Rose
  Color(0xFFF1F8E9), // Light Green
  Color(0xFFE8EAF6), // Indigo
];

const List<String> noteCategories = [
  'General',
  'Work',
  'Personal',
  'Study',
  'Ideas',
  'To-Do',
  'Health',
  'Travel',
];