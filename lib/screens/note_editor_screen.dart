import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../services/notes_provider.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;
  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagController;
  late Color _selectedColor;
  late String _selectedCategory;
  late List<String> _tags;
  bool _isPinned = false;
  bool _isFavorite = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final n = widget.note;
    _titleController = TextEditingController(text: n?.title ?? '');
    _contentController = TextEditingController(text: n?.content ?? '');
    _tagController = TextEditingController();
    _selectedColor = n?.color ?? noteColors[0];
    _selectedCategory = n?.category ?? 'General';
    _tags = List.from(n?.tags ?? []);
    _isPinned = n?.isPinned ?? false;
    _isFavorite = n?.isFavorite ?? false;

    _titleController.addListener(() => setState(() => _hasChanges = true));
    _contentController.addListener(() => setState(() => _hasChanges = true));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty && _contentController.text.trim().isEmpty) {
      Navigator.pop(context);
      return;
    }

    final provider = context.read<NotesProvider>();
    final title = _titleController.text.trim().isEmpty ? 'Untitled' : _titleController.text.trim();

    if (widget.note == null) {
      await provider.addNote(
        title: title,
        content: _contentController.text.trim(),
        category: _selectedCategory,
        color: _selectedColor,
        tags: _tags,
      );
    } else {
      final updated = widget.note!.copyWith(
        title: title,
        content: _contentController.text.trim(),
        category: _selectedCategory,
        color: _selectedColor,
        tags: _tags,
        isPinned: _isPinned,
        isFavorite: _isFavorite,
      );
      await provider.updateNote(updated);
    }
    if (mounted) Navigator.pop(context);
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
        _hasChanges = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _selectedColor,
      appBar: AppBar(
        backgroundColor: _selectedColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black54),
          onPressed: _saveNote,
        ),
        actions: [
          IconButton(
            icon: Icon(_isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              color: _isPinned ? const Color(0xFF7C4DFF) : Colors.black45),
            onPressed: () => setState(() { _isPinned = !_isPinned; _hasChanges = true; }),
          ),
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _isFavorite ? Colors.pinkAccent : Colors.black45),
            onPressed: () => setState(() { _isFavorite = !_isFavorite; _hasChanges = true; }),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.black45),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'delete', child: Row(children: [
                Icon(Icons.delete_outline_rounded, color: Colors.red),
                SizedBox(width: 8), Text('Delete'),
              ])),
            ],
            onSelected: (val) async {
              if (val == 'delete' && widget.note != null) {
                await context.read<NotesProvider>().deleteNote(widget.note!.id);
                if (mounted) Navigator.pop(context);
              }
            },
          ),
          TextButton(
            onPressed: _saveNote,
            child: Text('Save', style: GoogleFonts.poppins(
              color: const Color(0xFF7C4DFF), fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date & Category
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 14, color: Colors.black38),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy • hh:mm a').format(
                    widget.note?.updatedAt ?? DateTime.now()),
                  style: GoogleFonts.poppins(color: Colors.black45, fontSize: 12),
                ),
                const Spacer(),
                _buildCategoryDropdown(),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            TextField(
              controller: _titleController,
              style: GoogleFonts.poppins(
                fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Title',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black26),
                border: InputBorder.none,
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),

            // Content
            TextField(
              controller: _contentController,
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54, height: 1.6),
              decoration: InputDecoration(
                hintText: 'Start writing your note...',
                hintStyle: GoogleFonts.poppins(fontSize: 16, color: Colors.black26),
                border: InputBorder.none,
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              minLines: 8,
            ),

            const SizedBox(height: 20),

            // Tags
            _buildTagsSection(),

            const SizedBox(height: 24),

            // Color Picker
            _buildColorPicker(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isDense: true,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600),
          items: noteCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (val) => setState(() { _selectedCategory = val!; _hasChanges = true; }),
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tags', style: GoogleFonts.poppins(
          fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 6,
          children: [
            ..._tags.map((tag) => Chip(
              label: Text('#$tag', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF7C4DFF))),
              backgroundColor: const Color(0xFF7C4DFF).withOpacity(0.1),
              deleteIcon: const Icon(Icons.close_rounded, size: 14),
              onDeleted: () => setState(() { _tags.remove(tag); _hasChanges = true; }),
              side: BorderSide(color: const Color(0xFF7C4DFF).withOpacity(0.3)),
            )),
            SizedBox(
              width: 120,
              child: TextField(
                controller: _tagController,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: InputDecoration(
                  hintText: '+ Add tag',
                  hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.black38),
                  border: InputBorder.none,
                  isDense: true,
                ),
                onSubmitted: (_) => _addTag(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Note Color', style: GoogleFonts.poppins(
          fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: noteColors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => setState(() { _selectedColor = noteColors[i]; _hasChanges = true; }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: noteColors[i],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _selectedColor == noteColors[i]
                        ? const Color(0xFF7C4DFF) : Colors.black12,
                    width: _selectedColor == noteColors[i] ? 3 : 1.5,
                  ),
                  boxShadow: _selectedColor == noteColors[i]
                      ? [BoxShadow(color: const Color(0xFF7C4DFF).withOpacity(0.4), blurRadius: 8)]
                      : [],
                ),
                child: _selectedColor == noteColors[i]
                    ? const Icon(Icons.check_rounded, size: 16, color: Color(0xFF7C4DFF))
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
