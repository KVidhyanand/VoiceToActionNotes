// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:voice_notes/main.dart';

void main() {
  testWidgets('Voice Notes Assistant loads', (WidgetTester tester) async {
    await tester.pumpWidget(const VoiceNotesApp());

    expect(find.text('Voice Notes Assistant'), findsOneWidget);
    expect(find.byIcon(Icons.mic), findsOneWidget);
    expect(find.text('Save Note'), findsOneWidget);
  });
}
