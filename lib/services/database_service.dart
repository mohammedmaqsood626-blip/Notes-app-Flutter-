import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();

  DatabaseService._init();

  final Box _box = Hive.box('notesBox');

  Future<Note> createNote(Note note) async {
    await _box.put(note.id, note.toMap());
    return note;
  }

  Future<List<Note>> getAllNotes() async {
    final notes = _box.values
        .map((e) => Note.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    notes.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return notes;
  }

  Future<int> updateNote(Note note) async {
    await _box.put(note.id, note.toMap());
    return 1;
  }

  Future<int> deleteNote(String id) async {
    await _box.delete(id);
    return 1;
  }

  Future<void> deleteAllNotes() async {
    await _box.clear();
  }

  Future close() async {}
}
