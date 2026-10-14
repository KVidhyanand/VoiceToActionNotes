import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/voice_note.dart';

class NoteDetailScreen extends StatelessWidget {
  final VoiceNote note;

  const NoteDetailScreen({super.key, required this.note});

  Future<void> _shareByEmail(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final subject = Uri.encodeComponent(note.title);
    final body = Uri.encodeComponent('${note.category} note:\n\n${note.body}');
    final url = Uri.parse('mailto:?subject=$subject&body=$body');
    if (!await launchUrl(url)) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to open email client.')),
      );
    }
  }

  Future<void> _shareByWhatsApp(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final text = Uri.encodeComponent('${note.title}\n\n${note.body}');
    final url = Uri.parse('https://wa.me/?text=$text');
    if (!await launchUrl(url)) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to open WhatsApp.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Note details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      note.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Category: ${note.category}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Created: ${note.createdAtFormatted}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: SingleChildScrollView(
                    child: Text(
                      note.body,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            ElevatedButton.icon(
              icon: const Icon(Icons.email),
              label: const Text('Share by Email'),
              onPressed: () => _shareByEmail(context),
            ),
            const SizedBox(width: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.message),
              label: const Text('Share by WhatsApp'),
              onPressed: () => _shareByWhatsApp(context),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
