import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'models/voice_note.dart';
import 'screens/note_library_screen.dart';
import 'services/llm_service.dart';
import 'services/note_storage.dart';

void main() {
  runApp(const VoiceNotesApp());
}

class VoiceNotesApp extends StatelessWidget {
  const VoiceNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Notes Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff6C63FF)),

        scaffoldBackgroundColor: const Color(0xffF1F5F9),

        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      home: const VoiceNotesHomePage(),
    );
  }
}

class VoiceNotesHomePage extends StatefulWidget {
  const VoiceNotesHomePage({super.key});

  @override
  State<VoiceNotesHomePage> createState() => _VoiceNotesHomePageState();
}

//class _VoiceNotesHomePageState extends State<VoiceNotesHomePage> {
class _VoiceNotesHomePageState extends State<VoiceNotesHomePage>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final TextEditingController _transcriptController = TextEditingController();
  final TextEditingController _noteTitleController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  bool _isListening = false;
  bool _isRecordingSession = false;
  bool _isGenerating = false;
  bool _speechEnabled = false;
  bool _recordingStopped = false;
  int _selectedIndex = 0;
  String _finalTranscript = '';
  String _interimTranscript = '';
  String _lastFinalRecognizedWords = '';
  List<VoiceNote> _notes = [];

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  //StringBuffer _fullTranscript = StringBuffer(); //Jun 9th, 2026 Vidya
  //final Set<String> _processedChunks = {}; //Jun 9th, 2026 Vidya

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _loadNotes();
    _categoryController.text = 'Personal';

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  /*
  Future<void> _initializeSpeech() async {
    _speechEnabled = await _speech.initialize(
      onStatus: (status) {
        debugPrint('STATUS: $status');

        if (status == stt.SpeechToText.notListeningStatus &&
            _isRecordingSession) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (_isRecordingSession) {
              _startListening();
            }
          });
        }

        setState(() {
          _isListening = status == stt.SpeechToText.listeningStatus;
        });
      },
      onError: (error) {
        debugPrint('Speech error: $error');
      },
    );
  }*/

  Future<void> _initializeSpeech() async {
    _speechEnabled = await _speech.initialize(
      onStatus: (status) {
        debugPrint('STATUS: $status');

        if ((status == stt.SpeechToText.doneStatus ||
                status == stt.SpeechToText.notListeningStatus) &&
            _isRecordingSession) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (_isRecordingSession) {
              _startListening();
            }
          });
        }

        setState(() {
          _isListening = status == stt.SpeechToText.listeningStatus;
        });
      },
      /*onStatus: (status) {
        debugPrint('STATUS: $status');

        if ((status == stt.SpeechToText.notListeningStatus ||
                status == stt.SpeechToText.doneStatus) &&
            _lastPartialResult.isNotEmpty) {
          if (_fullTranscript.isEmpty) {
            _fullTranscript = _lastPartialResult;
          } else {
            _fullTranscript += ' $_lastPartialResult';
          }

          _lastPartialResult = '';

          _transcriptController.text = _fullTranscript;
        }

        setState(() {
          _isListening = status == stt.SpeechToText.listeningStatus;
        });
      },*/
      onError: (error) => debugPrint('Speech recognition error: $error'),
    );
    setState(() {});
  }

  Future<void> _loadNotes() async {
    final notes = await NoteStorage.loadNotes();
    setState(() {
      _notes = notes;
    });
  }

  Future<void> _saveNotes() async {
    await NoteStorage.saveNotes(_notes);
  }

  String _fullTranscript = '';
  String _lastFinalResult = '';

  String _lastPartialResult = '';

  void _startListening() {
    if (!_speechEnabled) return;

    _recordingStopped = false;
    _isRecordingSession = true;

    _speech.listen(
      onResult: (result) {
        final recognized = result.recognizedWords.trim();

        if (recognized.isEmpty) return;

        if (result.finalResult) {
          _fullTranscript = _mergeTranscript(_fullTranscript, recognized);
        }

        setState(() {
          _transcriptController.text = result.finalResult
              ? _fullTranscript
              : _mergeTranscript(_fullTranscript, recognized);
        });

        debugPrint(
          'FINAL=${result.finalResult} '
          'WORDS="$recognized"',
        );
      },

      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        //pauseFor: const Duration(seconds: 30), //Jun 9th, 2026 Vidya - Commenting out to allow longer recordings without auto-pausing
        //listenFor: const Duration(minutes: 10), //Jun 9th, 2026 Vidya - Commenting out to allow longer recordings without auto-stopping
        autoPunctuation: true,
        enableHapticFeedback: true,
        cancelOnError: false,
      ),
    );

    setState(() {
      _isListening = true;
    });
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
      _isRecordingSession = false;
      _recordingStopped = true;
    });
    _showSnackBar('Recording stopped. Transcript preserved.');
  }

  void _toggleRecording() {
    if (_isRecordingSession) {
      _stopListening();
    } else {
      _transcriptController.text = '';
      _fullTranscript = '';
      _lastPartialResult = '';
      _transcriptController.clear();
      _startListening();
    }
  }

  Future<void> _generateActionPoints() async {
    //final transcript = _transcriptController.text.trim();
    final transcript = _transcriptController.text; //Vidya
    if (transcript.isEmpty) {
      _showSnackBar('Record a voice note first to generate action points.');
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    final extracted = await LlmService.generateActionPoints(transcript);

    setState(() {
      _transcriptController.text = extracted;
      _isGenerating = false;
    });

    _showSnackBar('Generated actionable points.');
  }

  void _saveNote() {
    final title = _noteTitleController.text.trim().isEmpty
        ? 'Untitled note'
        : _noteTitleController.text.trim();
    final body = _transcriptController.text.trim();
    final category = _categoryController.text.trim().isEmpty
        ? 'Personal'
        : _categoryController.text.trim();

    if (body.isEmpty) {
      _showSnackBar('Please record or enter note content before saving.');
      return;
    }

    final note = VoiceNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      category: category,
      createdAt: DateTime.now(),
    );

    setState(() {
      _notes.insert(0, note);
      _noteTitleController.clear();
      _transcriptController.clear();
      _finalTranscript = '';
      _interimTranscript = '';
    });
    _saveNotes();
    _showSnackBar('Saved to your notes library.');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String get _speechStateLabel {
    if (!_speechEnabled) return 'Speech unavailable';
    if (_isRecordingSession) {
      return _isListening ? 'Listening' : 'Recording paused';
    }
    return 'Ready to record';
  }

  String get _speechModeLabel {
    if (!_speechEnabled) return 'Permission needed';
    if (_isRecordingSession) {
      if (!_isListening) {
        return 'Recording paused due to silence. Tap Stop to finish or speak to resume.';
      }
      if (_interimTranscript.isNotEmpty) {
        return 'Interim speech detected. Finalizing transcript...';
      }
      return 'Capturing final recognized text.';
    }
    if (_recordingStopped && _transcriptController.text.trim().isNotEmpty) {
      return 'Recording stopped. Transcript preserved.';
    }
    return 'Tap the mic button to start recording.';
  }

  String _mergeTranscript(String existing, String recognized) {
    if (existing.isEmpty) return recognized;

    final existingNormalized = _normalizeText(existing);
    final recognizedNormalized = _normalizeText(recognized);
    if (recognizedNormalized.isEmpty) return existing;

    debugPrint('EXISTING: [$existing]');
    debugPrint('RECOGNIZED: [$recognized]');

    // Jun 22nd, 2026 Vidya - Added logic to avoid duplicate text in transcript when speech recognition overlaps

    if (existingNormalized == recognizedNormalized) {
      return existing;
    }

    /*
    if (existingNormalized.contains(recognizedNormalized)) {
      return existing;
    }*/

    final existingTokens = _tokenize(existingNormalized);
    final recognizedTokens = _tokenize(recognizedNormalized);

    final maxOverlap = existingTokens.length < recognizedTokens.length
        ? existingTokens.length
        : recognizedTokens.length;
    for (var overlap = maxOverlap; overlap > 0; overlap--) {
      final existingSuffix = existingTokens.sublist(
        existingTokens.length - overlap,
      );
      final recognizedPrefix = recognizedTokens.sublist(0, overlap);
      if (_tokensMatch(existingSuffix, recognizedPrefix)) {
        final newTokens = recognizedTokens.sublist(overlap);
        if (newTokens.isEmpty) return existing;
        return '${existing.trim()} ${newTokens.join(' ')}';
      }
    }

    return '${existing.trim()} ${recognized.trim()}';
  }

  String _normalizeText(String text) {
    return text
        .trim()
        .replaceAll(RegExp(r'[.,!?;:\\-]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .toLowerCase();
  }

  List<String> _tokenize(String text) {
    return text
        .trim()
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList();
  }

  bool _tokensMatch(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].toLowerCase() != b[i].toLowerCase()) {
        return false;
      }
    }
    return true;
  }

  Widget _buildRecordScreen() {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        //---------------------------------------------------------
        // HERO RECORDING CARD
        //---------------------------------------------------------
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              colors: _isListening
                  ? [const Color(0xff6C63FF), const Color(0xff8A7DFF)]
                  : [const Color(0xff1E293B), const Color(0xff334155)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (_, child) {
                  return Transform.scale(
                    scale: _isListening ? _pulseAnimation.value : 1,
                    child: child,
                  );
                },
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(.15),
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                _speechStateLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _speechModeLabel,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(.9)),
              ),

              const SizedBox(height: 24),

              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 56),
                ),
                onPressed: _speechEnabled ? _toggleRecording : null,
                icon: Icon(_isListening ? Icons.stop_circle : Icons.mic),
                label: Text(
                  _isListening ? "Stop Recording" : "Start Recording",
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        //---------------------------------------------------------
        // LIVE TRANSCRIPT
        //---------------------------------------------------------
        Text(
          "Transcript",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: TextField(
              controller: _transcriptController,
              minLines: 5,
              maxLines: 50,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Your voice transcript will appear here...",
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        //---------------------------------------------------------
        // AI CARD
        //---------------------------------------------------------
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: const Color(0xffF8FAFC),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.deepPurple,
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "AI Assistant",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text("Convert transcript into action items"),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                onPressed: _isGenerating ? null : _generateActionPoints,
                icon: _isGenerating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  _isGenerating ? "Generating..." : "Generate Action Points",
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        //---------------------------------------------------------
        // NOTE DETAILS
        //---------------------------------------------------------
        Text(
          "Note Details",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                TextField(
                  controller: _noteTitleController,
                  decoration: InputDecoration(
                    labelText: "Note Title",
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _categoryController.text.isEmpty
                      ? "Personal"
                      : _categoryController.text,
                  decoration: InputDecoration(
                    labelText: "Category",
                    prefixIcon: const Icon(Icons.folder),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: "Personal",
                      child: Text("Personal"),
                    ),
                    DropdownMenuItem(value: "Work", child: Text("Work")),
                    DropdownMenuItem(value: "Public", child: Text("Public")),
                  ],
                  onChanged: (value) {
                    _categoryController.text = value ?? "Personal";
                  },
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        //---------------------------------------------------------
        // ACTIONS
        //---------------------------------------------------------
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _transcriptController.clear();
                    _finalTranscript = '';
                    _interimTranscript = '';
                  });
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text("Clear"),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              flex: 2,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                onPressed: _saveNote,
                icon: const Icon(Icons.save),
                label: const Text("Save Note"),
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  List<Widget> get _pages => [
    _buildRecordScreen(),
    NoteLibraryScreen(notes: _notes),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Voice Notes', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Capture ideas instantly', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.mic), label: 'Record'),
          NavigationDestination(
            icon: Icon(Icons.library_books),
            label: 'Library',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _transcriptController.dispose();
    _noteTitleController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}
