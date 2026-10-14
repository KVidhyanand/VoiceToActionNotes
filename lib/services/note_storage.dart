import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/voice_note.dart';

class NoteStorage {
  static const _storageKey = 'voice_notes';

  static Future<List<VoiceNote>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final rawNotes = prefs.getStringList(_storageKey) ?? [];
    return rawNotes
        .map(
          (item) =>
              VoiceNote.fromJson(jsonDecode(item) as Map<String, dynamic>),
        )
        .toList();
  }

  static Future<void> saveNotes(List<VoiceNote> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = notes.map((note) => jsonEncode(note.toJson())).toList();
    await prefs.setStringList(_storageKey, encoded);
  }
}
