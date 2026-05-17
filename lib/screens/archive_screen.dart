import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notes_provider.dart';
import '../widgets/note_card.dart';
import 'note_editor_screen.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archive',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: Consumer<NotesProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final archived = provider.archivedNotes;
          if (archived.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.archive_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 16),
                  Text('No archived notes',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.outline)),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: archived.length,
            itemBuilder: (ctx, i) {
              final note = archived[i];
              return NoteCard(
                note: note,
                isGrid: false,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => NoteEditorScreen(note: note))),
                onDelete: () => provider.deleteNote(note.id),
                onPin: () => provider.togglePin(note),
                onArchive: () => provider.toggleArchive(note),
              );
            },
          );
        },
      ),
    );
  }
}
