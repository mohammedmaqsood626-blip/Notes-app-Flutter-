import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';

class NotesProvider extends ChangeNotifier {
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isLoading = false;
  bool _showFavorites = false;
  String _viewMode = 'grid';

  List<Note> get notes => _filteredNotes;
  List<Note> get allNotes => _notes;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  bool get showFavorites => _showFavorites;
  String get viewMode => _viewMode;

  final _uuid = const Uuid();

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _notes = [];

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
    String? fileName,
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
      fileName: fileName,
    );

    _notes.add(note);

    _applyFilters();
    notifyListeners();
  }

  Future<void> updateNote(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);

    if (index != -1) {
      _notes[index] = note.copyWith(updatedAt: DateTime.now());
    }

    _applyFilters();
    notifyListeners();
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);

    _applyFilters();
    notifyListeners();
  }

  Future<void> togglePin(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);

    if (index != -1) {
      _notes[index] = note.copyWith(
        isPinned: !note.isPinned,
        updatedAt: DateTime.now(),
      );
    }

    _applyFilters();
    notifyListeners();
  }

  Future<void> toggleFavorite(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);

    if (index != -1) {
      _notes[index] = note.copyWith(
        isFavorite: !note.isFavorite,
        updatedAt: DateTime.now(),
      );
    }

    _applyFilters();
    notifyListeners();
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

  int get pinnedCount =>
      _notes.where((n) => n.isPinned).length;

  int get favoritesCount =>
      _notes.where((n) => n.isFavorite).length;
}
