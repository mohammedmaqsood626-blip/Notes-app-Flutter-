import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../services/notes_provider.dart';
import '../screens/note_editor_screen.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final bool isListView;

  const NoteCard({super.key, required this.note, this.isListView = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context, MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note))),
      onLongPress: () => _showOptionsSheet(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: note.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8, offset: const Offset(0, 3)),
          ],
          border: note.isPinned
              ? Border.all(color: const Color(0xFF7C4DFF).withOpacity(0.5), width: 1.5)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: GoogleFonts.poppins(
                        fontSize: isListView ? 16 : 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (note.isPinned)
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.push_pin_rounded, size: 14, color: Color(0xFF7C4DFF)),
                    ),
                  if (note.isFavorite)
                    const Padding(
                      padding: EdgeInsets.only(left: 2),
                      child: Icon(Icons.favorite_rounded, size: 14, color: Colors.pinkAccent),
                    ),
                ],
              ),

              if (note.content.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  note.content,
                  style: GoogleFonts.poppins(
                    fontSize: 13, color: Colors.black54, height: 1.4),
                  maxLines: isListView ? 2 : 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              if (note.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4, runSpacing: 4,
                  children: note.tags.take(3).map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C4DFF).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('#$tag',
                      style: GoogleFonts.poppins(
                        fontSize: 10, color: const Color(0xFF7C4DFF), fontWeight: FontWeight.w600)),
                  )).toList(),
                ),
              ],

              const SizedBox(height: 10),

              // Bottom row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(note.category,
                      style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w600)),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('MMM dd').format(note.updatedAt),
                    style: GoogleFonts.poppins(fontSize: 10, color: Colors.black38),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsSheet(BuildContext context) {
    final provider = context.read<NotesProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(note.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                color: const Color(0xFF7C4DFF)),
              title: Text(note.isPinned ? 'Unpin' : 'Pin',
                style: GoogleFonts.poppins(color: Colors.white)),
              onTap: () { Navigator.pop(context); provider.togglePin(note); },
            ),
            ListTile(
              leading: Icon(note.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: Colors.pinkAccent),
              title: Text(note.isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                style: GoogleFonts.poppins(color: Colors.white)),
              onTap: () { Navigator.pop(context); provider.toggleFavorite(note); },
            ),
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: Color(0xFF00BCD4)),
              title: Text('Edit', style: GoogleFonts.poppins(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => NoteEditorScreen(note: note)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              title: Text('Delete', style: GoogleFonts.poppins(color: Colors.white)),
              onTap: () { Navigator.pop(context); provider.deleteNote(note.id); },
            ),
          ],
        ),
      ),
    );
  }
}
