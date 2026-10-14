class ActionExtractionService {
  static String convertTranscriptToActionPoints(String transcript) {
    final cleanedTranscript = _sanitizeTranscript(transcript);
    final sentences = _splitIntoSentences(cleanedTranscript);

    if (sentences.isEmpty) {
      return 'No transcript available to convert into action points.';
    }

    // Group sentences into topics
    final topicGroups = _groupSentencesByTopic(sentences);

    // Build output with headings for each topic
    final output = <String>[];
    for (final group in topicGroups) {
      output.add('# ${group.heading}');
      for (final sentence in group.sentences) {
        output.add('• ${_capitalize(sentence)}');
      }
      output.add(''); // blank line between sections
    }

    // Add metadata bullets
    final categoryBullet = _categoryBullet(cleanedTranscript);
    if (categoryBullet != null) {
      output.add(categoryBullet);
    }

    final shareBullet = _shareBullet(cleanedTranscript);
    if (shareBullet != null) {
      output.add(shareBullet);
    }

    return output.join('\n').trim();
  }

  static String _generateDynamicHeading(List<String> sentences) {
    if (sentences.isEmpty) {
      return 'General Notes';
    }

    final text = sentences.join(' ').toLowerCase();

    final Map<String, List<String>> topics = {
      'Voice Recording & Transcription': [
        'voice',
        'record',
        'recording',
        'transcription',
        'speech',
        'microphone',
      ],

      'AI Processing': [
        'ai',
        'llm',
        'slm',
        'model',
        'processing',
        'analysis',
        'extract',
      ],

      'Notes Management': [
        'notes',
        'library',
        'storage',
        'save',
        'retrieve',
        'retrieval',
      ],

      'Sharing Capabilities': ['email', 'whatsapp', 'share', 'sharing', 'send'],

      'Project Requirements': ['requirement', 'must', 'need', 'specification'],

      'Development Tasks': [
        'implement',
        'develop',
        'feature',
        'integration',
        'coding',
      ],
    };

    String bestHeading = 'General Notes';
    int bestScore = 0;

    topics.forEach((heading, keywords) {
      int score = 0;

      for (final keyword in keywords) {
        if (text.contains(keyword)) {
          score++;
        }
      }

      if (score > bestScore) {
        bestScore = score;
        bestHeading = heading;
      }
    });

    return bestHeading;
  }

  static List<_TopicGroup> _groupSentencesByTopic(List<String> sentences) {
    final Map<String, List<String>> grouped = {};

    for (final sentence in sentences) {
      final heading = _generateDynamicHeading([sentence]);

      grouped.putIfAbsent(heading, () => []);
      grouped[heading]!.add(sentence);
    }

    return grouped.entries.map((e) => _TopicGroup(e.key, e.value)).toList();
  }

  static List<_TopicGroup> _groupSentencesByTopic1(List<String> sentences) {
    final groups = <_TopicGroup>[];
    var currentTopic = <String>[];
    var currentHeading = '';

    for (final sentence in sentences) {
      final heading = _extractTopicHeading(sentence);
      if (heading.isNotEmpty && heading != currentHeading) {
        // New topic detected
        if (currentTopic.isNotEmpty && currentHeading.isNotEmpty) {
          groups.add(_TopicGroup(currentHeading, currentTopic));
        }
        currentTopic = [sentence];
        currentHeading = heading;
      } else {
        // Same topic or no topic
        currentTopic.add(sentence);
        if (currentHeading.isEmpty) {
          currentHeading = heading.isNotEmpty ? heading : 'General Notes';
        }
      }
    }

    // Add remaining group
    if (currentTopic.isNotEmpty && currentHeading.isNotEmpty) {
      groups.add(_TopicGroup(currentHeading, currentTopic));
    } else if (currentTopic.isNotEmpty) {
      groups.add(_TopicGroup('General Notes', currentTopic));
    }

    return groups.isEmpty ? [_TopicGroup('General Notes', sentences)] : groups;
  }

  static String _extractTopicHeading(String sentence) {
    final lower = sentence.toLowerCase();

    // Meetings
    if (lower.contains('meeting') ||
        lower.contains('discussion') ||
        lower.contains('agenda') ||
        lower.contains('conference') ||
        lower.contains('call')) {
      return 'Meeting Notes';
    }

    // Projects & Tasks
    if (lower.contains('project') ||
        lower.contains('task') ||
        lower.contains('milestone') ||
        lower.contains('sprint') ||
        lower.contains('deliverable')) {
      return 'Project Tasks';
    }

    // Deadlines
    if (lower.contains('deadline') ||
        lower.contains('due') ||
        lower.contains('target date') ||
        lower.contains('timeline')) {
      return 'Important Deadlines';
    }

    // Issues & Bugs
    if (lower.contains('bug') ||
        lower.contains('issue') ||
        lower.contains('problem') ||
        lower.contains('error') ||
        lower.contains('failure') ||
        lower.contains('crash')) {
      return 'Issues & Fixes';
    }

    // Action Items
    if (lower.contains('action') ||
        lower.contains('follow up') ||
        lower.contains('todo') ||
        lower.contains('assign') ||
        lower.contains('complete')) {
      return 'Action Items';
    }

    // Ideas & Improvements
    if (lower.contains('idea') ||
        lower.contains('suggest') ||
        lower.contains('improve') ||
        lower.contains('enhancement') ||
        lower.contains('proposal')) {
      return 'Ideas & Suggestions';
    }

    // Decisions
    if (lower.contains('decision') ||
        lower.contains('decided') ||
        lower.contains('approved') ||
        lower.contains('agreed') ||
        lower.contains('confirmed')) {
      return 'Decisions';
    }

    // Learning
    if (lower.contains('learn') ||
        lower.contains('lesson') ||
        lower.contains('note') ||
        lower.contains('remember') ||
        lower.contains('knowledge')) {
      return 'Learning Notes';
    }

    // Requirements
    if (lower.contains('requirement') ||
        lower.contains('need') ||
        lower.contains('must') ||
        lower.contains('specification')) {
      return 'Requirements';
    }

    // Risks
    if (lower.contains('risk') ||
        lower.contains('concern') ||
        lower.contains('blocker') ||
        lower.contains('dependency')) {
      return 'Risks & Concerns';
    }

    // Budget & Finance
    if (lower.contains('budget') ||
        lower.contains('cost') ||
        lower.contains('expense') ||
        lower.contains('price') ||
        lower.contains('payment')) {
      return 'Budget & Finance';
    }

    // Customer Feedback
    if (lower.contains('customer') ||
        lower.contains('client') ||
        lower.contains('feedback') ||
        lower.contains('review')) {
      return 'Customer Feedback';
    }

    // Testing & QA
    if (lower.contains('test') ||
        lower.contains('testing') ||
        lower.contains('qa') ||
        lower.contains('validation')) {
      return 'Testing & QA';
    }

    // Development
    if (lower.contains('development') ||
        lower.contains('feature') ||
        lower.contains('implementation') ||
        lower.contains('coding')) {
      return 'Development Updates';
    }

    // Deployment
    if (lower.contains('deploy') ||
        lower.contains('release') ||
        lower.contains('production') ||
        lower.contains('launch')) {
      return 'Deployment & Release';
    }

    // Performance
    if (lower.contains('performance') ||
        lower.contains('optimization') ||
        lower.contains('speed') ||
        lower.contains('latency')) {
      return 'Performance Improvements';
    }

    // Security
    if (lower.contains('security') ||
        lower.contains('authentication') ||
        lower.contains('authorization') ||
        lower.contains('vulnerability')) {
      return 'Security Updates';
    }

    // Hiring & Team
    if (lower.contains('hiring') ||
        lower.contains('recruitment') ||
        lower.contains('team') ||
        lower.contains('resource')) {
      return 'Team & Resources';
    }

    // Training
    if (lower.contains('training') ||
        lower.contains('workshop') ||
        lower.contains('session') ||
        lower.contains('course')) {
      return 'Training & Development';
    }

    if (lower.contains('voice') ||
        lower.contains('recording') ||
        lower.contains('transcription')) {
      return 'Voice Recording & Transcription';
    }

    if (lower.contains('llm') ||
        lower.contains('slm') ||
        lower.contains('ai')) {
      return 'AI Processing';
    }

    if (lower.contains('library') ||
        lower.contains('notes') ||
        lower.contains('storage')) {
      return 'Notes Management';
    }

    if (lower.contains('email') ||
        lower.contains('whatsapp') ||
        lower.contains('sharing')) {
      return 'Sharing Capabilities';
    }

    return 'General Notes';

    //return '';
  }

  static String? _categoryBullet(String text) {
    final lower = text.toLowerCase();
    final categories = <String>{};

    if (lower.contains('public related') || lower.contains('public')) {
      categories.add('public');
    }
    if (lower.contains('work related') || lower.contains('work')) {
      categories.add('work');
    }
    if (lower.contains('personal notes') || lower.contains('personal')) {
      categories.add('personal');
    }

    if (categories.isEmpty) {
      return null;
    }

    final sortedCategories = categories.toList()..sort();
    return '• Store notes under ${sortedCategories.join(', ')} categories.';
  }

  static String? _shareBullet(String text) {
    final lower = text.toLowerCase();
    final points = <String>[];

    if (lower.contains('email')) {
      points.add('email');
    }
    if (lower.contains('whatsapp')) {
      points.add('whatsapp');
    }

    if (points.isEmpty) {
      return null;
    }

    return '• Allow notes to be shared via ${points.join(' and ')}.';
  }

  static String _sanitizeTranscript(String transcript) {
    var cleaned = transcript
        .replaceAll(RegExp(r'p\.p1\s*\{[^}]*\}'), '')
        .replaceAll(RegExp(r'\*\*'), '')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (cleaned.isNotEmpty &&
        cleaned.startsWith('The purpose of this application')) {
      cleaned = cleaned.replaceFirst(
        'The purpose of this application is primarily one, ',
        '',
      );
    }

    return cleaned;
  }

  static List<String> _splitIntoSentences(String text) {
    return text
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((sentence) => sentence.trim())
        .where((sentence) => sentence.isNotEmpty)
        .toList();
  }

  static String _capitalize(String sentence) {
    final cleaned = sentence.trim();
    return cleaned.isEmpty
        ? cleaned
        : '${cleaned[0].toUpperCase()}${cleaned.substring(1)}';
  }
}

class _TopicGroup {
  final String heading;
  final List<String> sentences;

  _TopicGroup(this.heading, this.sentences);
}
