import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/notes_provider.dart';
import '../models/note.dart';
import '../widgets/note_card.dart';
import '../widgets/category_chip.dart';
import 'note_editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late AnimationController _fabAnimController;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesProvider>().loadNotes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF1A1A2E),
          body: CustomScrollView(
            slivers: [
              _buildAppBar(provider),
              _buildSearchBar(provider),
              _buildStats(provider),
              _buildCategoryFilter(provider),
              if (provider.isLoading)
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))))
              else if (provider.notes.isEmpty)
                _buildEmptyState()
              else
                _buildNotesList(provider),
            ],
          ),
          floatingActionButton: _buildFAB(),
        );
      },
    );
  }

  Widget _buildAppBar(NotesProvider provider) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      pinned: true,
      backgroundColor: const Color(0xFF1A1A2E),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFF00BCD4)]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.note_alt_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text('NoteFlow',
              style: GoogleFonts.poppins(
                fontSize: 22, fontWeight: FontWeight.w700,
                foreground: Paint()..shader = const LinearGradient(
                  colors: [Color(0xFF7C4DFF), Color(0xFF00BCD4)],
                ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(provider.showFavorites ? Icons.favorite : Icons.favorite_border,
            color: provider.showFavorites ? Colors.pinkAccent : Colors.white70),
          onPressed: provider.toggleFavoritesFilter,
          tooltip: 'Favorites',
        ),
        IconButton(
          icon: Icon(provider.viewMode == 'grid' ? Icons.view_list_rounded : Icons.grid_view_rounded,
            color: Colors.white70),
          onPressed: provider.toggleViewMode,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar(NotesProvider provider) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: const Color(0xFF16213E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isSearching ? const Color(0xFF7C4DFF) : Colors.white12,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: _searchController,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
            onChanged: provider.setSearch,
            onTap: () => setState(() => _isSearching = true),
            onSubmitted: (_) => setState(() => _isSearching = false),
            decoration: InputDecoration(
              hintText: 'Search notes...',
              hintStyle: GoogleFonts.poppins(color: Colors.white38, fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.white38),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: Colors.white38, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        provider.setSearch('');
                        setState(() => _isSearching = false);
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStats(NotesProvider provider) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Row(
          children: [
            _statChip(Icons.note_rounded, '${provider.totalNotes}', 'Notes', const Color(0xFF7C4DFF)),
            const SizedBox(width: 10),
            _statChip(Icons.push_pin_rounded, '${provider.pinnedCount}', 'Pinned', const Color(0xFF00BCD4)),
            const SizedBox(width: 10),
            _statChip(Icons.favorite_rounded, '${provider.favoritesCount}', 'Faves', Colors.pinkAccent),
          ],
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String count, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text('$count $label',
              style: GoogleFonts.poppins(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(NotesProvider provider) {
    final cats = ['All', ...noteCategories];
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: cats.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => CategoryChip(
            label: cats[i],
            isSelected: provider.selectedCategory == cats[i],
            onTap: () => provider.setCategory(cats[i]),
          ),
        ),
      ),
    );
  }

  Widget _buildNotesList(NotesProvider provider) {
    if (provider.viewMode == 'list') {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, i) => Padding(
            padding: EdgeInsets.fromLTRB(16, i == 0 ? 16 : 6, 16, 6),
            child: NoteCard(note: provider.notes[i], isListView: true),
          ),
          childCount: provider.notes.length,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childCount: provider.notes.length,
        itemBuilder: (_, i) => NoteCard(note: provider.notes[i]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C4DFF), Color(0xFF00BCD4)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.note_add_rounded, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text('No notes yet', style: GoogleFonts.poppins(
              color: Colors.white70, fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Tap + to create your first note',
              style: GoogleFonts.poppins(color: Colors.white38, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.push(
        context, MaterialPageRoute(builder: (_) => const NoteEditorScreen())),
      backgroundColor: const Color(0xFF7C4DFF),
      elevation: 6,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: Text('New Note', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
    );
  }
}
