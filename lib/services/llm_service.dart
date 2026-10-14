import 'dart:async';

import 'action_extraction_service.dart';

class LlmService {
  /// Placeholder for future LLM/SLM integration.
  ///
  /// Currently returns a structured action-point conversion using the local
  /// extraction service, but this method can later call a real API.
  static Future<String> generateActionPoints(String transcript) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return ActionExtractionService.convertTranscriptToActionPoints(transcript);
  }
}
