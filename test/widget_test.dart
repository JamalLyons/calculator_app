import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calculator_app/main.dart';

void main() {
  testWidgets('Calculator UI renders and computes 2 + 3 × 4 = 20 in L→R mode',
      (WidgetTester tester) async {
    // Provide a standard phone screen size
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CalculatorApp());
    await tester.pumpAndSettle();

    // Verify initial display is 0
    expect(find.text('0'), findsAtLeast(1));

    // Tap '2'
    await tester.tap(find.widgetWithText(InkWell, '2'));
    await tester.pumpAndSettle();

    // Tap '+'
    await tester.tap(find.widgetWithText(InkWell, '+'));
    await tester.pumpAndSettle();

    // Tap '3'
    await tester.tap(find.widgetWithText(InkWell, '3'));
    await tester.pumpAndSettle();

    // Tap '×' -> commits 2 + 3 = 5 as running accumulator
    await tester.tap(find.widgetWithText(InkWell, '×'));
    await tester.pumpAndSettle();
    expect(find.text('5'), findsAtLeast(1));

    // Tap '4'
    await tester.tap(find.widgetWithText(InkWell, '4'));
    await tester.pumpAndSettle();

    // Tap '=' -> 5 × 4 = 20!
    await tester.tap(find.widgetWithText(InkWell, '='));
    await tester.pumpAndSettle();
    expect(find.text('20'), findsAtLeast(1));
  });

  testWidgets('Theme toggle switches between light and dark themes smoothly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CalculatorApp());
    await tester.pumpAndSettle();

    // Initial theme is dark mode (icon is light_mode to toggle to light)
    expect(find.byIcon(Icons.light_mode), findsOneWidget);

    // Tap theme toggle
    await tester.tap(find.byIcon(Icons.light_mode));
    await tester.pumpAndSettle();

    // Now in light mode (icon is dark_mode)
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
  });

  testWidgets('Mode toggle switches between L→R and PEMDAS mode',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CalculatorApp());
    await tester.pumpAndSettle();

    // Initially in L→R mode
    expect(find.text('L→R Mode'), findsOneWidget);

    // Tap mode toggle in AppBar
    await tester.tap(find.byTooltip('Switch between L→R and PEMDAS mode'));
    await tester.pumpAndSettle();

    // Should now be in PEMDAS mode
    expect(find.text('PEMDAS Mode'), findsOneWidget);
  });

  testWidgets('History button opens sheet and shows past calculations',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CalculatorApp());
    await tester.pumpAndSettle();

    // Compute 7 + 8 = 15
    await tester.tap(find.widgetWithText(InkWell, '7'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(InkWell, '+'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(InkWell, '8'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(InkWell, '='));
    await tester.pumpAndSettle();
    expect(find.text('15'), findsAtLeast(1));

    // Open History
    await tester.tap(find.byTooltip('Calculation History'));
    await tester.pumpAndSettle();

    expect(find.text('Calculation History'), findsOneWidget);
    expect(find.text('= 15'), findsOneWidget);
  });

  testWidgets('Buttons meet minimum accessibility touch target size of 48dp',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CalculatorApp());
    await tester.pumpAndSettle();

    // Check size of digit 5 button
    final buttonFinder = find.widgetWithText(InkWell, '5');
    final buttonSize = tester.getSize(buttonFinder);
    expect(buttonSize.width, greaterThanOrEqualTo(48.0));
    expect(buttonSize.height, greaterThanOrEqualTo(48.0));
  });
}
