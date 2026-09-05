import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_health/app/app.dart';

void main() {
  testWidgets('Web UI starts on Dashboard and navigates all 4 screens directly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // 1. Build the app (starts directly on Dashboard)
    await tester.pumpWidget(const SmartHealthApp());
    await tester.pumpAndSettle();

    // Verify top bar and Screen 1 (Dispense)
    expect(find.text('Project Resilience'), findsOneWidget);
    expect(find.text('PHC Rampur'), findsOneWidget);
    expect(find.text('Dispensing Ledger'), findsOneWidget);
    expect(find.text('Amoxicillin 500mg'), findsOneWidget);
    expect(find.text('Rabies Anti-Serum 1000IU'), findsOneWidget);

    // Test -1 button on first card
    final minusOneBtn = find.text('-1').first;
    await tester.tap(minusOneBtn);
    await tester.pumpAndSettle();
    expect(find.text('341'), findsOneWidget);

    // 2. Navigate to Tab 1: Command
    await tester.tap(find.text('Command'));
    await tester.pumpAndSettle();
    expect(find.text('Warangal District Command'), findsOneWidget);
    expect(find.text('Critical Shortages'), findsOneWidget);
    expect(find.text('PHC Gudur'), findsOneWidget);

    // 3. Navigate to Tab 2: Transfers
    await tester.tap(find.text('Transfers'));
    await tester.pumpAndSettle();
    expect(find.text('Stock Redistribution'), findsOneWidget);
    expect(find.text('Anti-Rabies Serum (1000 IU) • 45 Vials'), findsOneWidget);

    // 4. Navigate to Tab 3: Analytics
    await tester.tap(find.text('Analytics'));
    await tester.pumpAndSettle();
    expect(find.text('District Analytics & Forecast'), findsOneWidget);
    expect(find.text('BUFFER INTEGRITY'), findsOneWidget);
    expect(find.text('Parvathagiri PHC'), findsOneWidget);
  });
}
