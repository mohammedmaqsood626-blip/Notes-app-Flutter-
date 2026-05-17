import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import 'database_service.dart';

class NotesProvider extends ChangeNotifier {
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isLoading = false;
  bool _showFavorites = false;
  String _viewMode = 'grid'; // 'grid' or 'list'

  List<Note> get notes => _filteredNotes;
  List<Note> get allNotes => _notes;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  bool get showFavorites => _showFavorites;
  String get viewMode => _viewMode;

  final _uuid = const Uuid();
  final _db = DatabaseService.instance;

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();
    _notes = await _db.getAllNotes();
    _applyFilters();
    _isLoading = false;
    notifyListeners();
  }

  void _applyFilters() {
    List<Note> filtered = List.from(_notes);

    if (_showFavorites) {
      filtered = filtered.where((n) => n.isFavorite).toList();
    }

    if (_selectedCategory != 'All') {
      filtered = filtered.where((n) => n.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((n) =>
          n.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          n.content.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Pinned notes first
    filtered.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    _filteredNotes = filtered;
  }

  Future<void> addNote({
    required String title,
    required String content,
    String category = 'General',
    Color color = const Color(0xFFFFF9C4),
    List<String> tags = const [],
  }) async {
    final now = DateTime.now();
    final note = Note(
      id: _uuid.v4(),
      title: title,
      content: content,
      category: category,
      color: color,
      createdAt: now,
      updatedAt: now,
      tags: tags,
    );
    await _db.createNote(note);
    await loadNotes();
  }

  Future<void> updateNote(Note note) async {
    final updated = note.copyWith(updatedAt: DateTime.now());
    await _db.updateNote(updated);
    await loadNotes();
  }

  Future<void> deleteNote(String id) async {
    await _db.deleteNote(id);
    _notes.removeWhere((n) => n.id == id);
    _applyFilters();
    notifyListeners();
  }

  Future<void> togglePin(Note note) async {
    final updated = note.copyWith(isPinned: !note.isPinned, updatedAt: DateTime.now());
    await _db.updateNote(updated);
    await loadNotes();
  }

  Future<void> toggleFavorite(Note note) async {
    final updated = note.copyWith(isFavorite: !note.isFavorite, updatedAt: DateTime.now());
    await _db.updateNote(updated);
    await loadNotes();
  }

  void setSearch(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void toggleFavoritesFilter() {
    _showFavorites = !_showFavorites;
    _applyFilters();
    notifyListeners();
  }

  void toggleViewMode() {
    _viewMode = _viewMode == 'grid' ? 'list' : 'grid';
    notifyListeners();
  }

  int get totalNotes => _notes.length;
  int get pinnedCount => _notes.where((n) => n.isPinned).length;
  int get favoritesCount => _notes.where((n) => n.isFavorite).length;
}
