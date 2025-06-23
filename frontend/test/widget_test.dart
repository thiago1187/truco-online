// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('Home page contains room field and action buttons',
      (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify presence of the room name field.
    expect(find.widgetWithText(TextField, 'Nome da sala'), findsOneWidget);

    // Verify presence of the create and join room buttons.
    expect(find.widgetWithText(ElevatedButton, 'Criar Sala'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Entrar na Sala'), findsOneWidget);
  });
}
