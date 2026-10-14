import 'package:flutter/material.dart';

import '../models/voice_note.dart';
import 'note_detail_screen.dart';

class NoteLibraryScreen extends StatelessWidget {
  final List<VoiceNote> notes;

  const NoteLibraryScreen({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.library_books, size: 72, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No saved notes yet. Record and save your first voice note.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 14.0),
          child: ListTile(
            title: Text(
              note.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('${note.category} • ${note.createdAtFormatted}'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NoteDetailScreen(note: note),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
