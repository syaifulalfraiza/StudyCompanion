// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:studycompanion_app/main.dart';

void main() {
  // Simple smoke test: ensure the app builds without throwing and the
  // top-level widget is present. The previous counter test no longer
  // matches the app UI after the refactor, so we keep a lightweight
  // check here.
  testWidgets('App builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Ensure MyApp is present in the widget tree.
    expect(find.byType(MyApp), findsOneWidget);
  });
}
