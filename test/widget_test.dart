
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathmaster/main.dart';
import 'package:mathmaster/screens/calculator_screen.dart';
import 'package:mathmaster/screens/converter_screen.dart';
import 'package:mathmaster/screens/quiz_screen.dart';
import 'package:mathmaster/models/quiz_question.dart';

void main() {
  testWidgets('MathMaster App - Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MathMasterApp());
    expect(find.text('MathMaster'), findsOneWidget);
  });

  group('HomeScreen Tests', () {
    testWidgets('HomeScreen displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      
      expect(find.text('MathMaster'), findsOneWidget);
      expect(find.text('Kalkulator'), findsOneWidget);
      expect(find.text('Konverter'), findsOneWidget);
      expect(find.text('Kuis Matematika'), findsOneWidget);
      expect(find.byIcon(Icons.calculate), findsOneWidget);
    });

    testWidgets('HomeScreen tab switching works', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      
      // Initially on calculator
      expect(find.byType(CalculatorScreen), findsOneWidget);
      
      // Tap converter tab
      await tester.tap(find.text('Konverter'));
      await tester.pumpAndSettle();
      
      expect(find.byType(ConverterScreen), findsOneWidget);
      
      // Tap quiz tab
      await tester.tap(find.text('Kuis Matematika'));
      await tester.pumpAndSettle();
      
      expect(find.byType(QuizScreen), findsOneWidget);
    });
  });
}