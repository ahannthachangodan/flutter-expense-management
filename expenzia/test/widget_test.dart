import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expenzia/main.dart';
import 'package:expenzia/presentation/providers/expense_provider.dart';

void main() {
  testWidgets('ExpenziaApp renders without crash', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenziaApp());
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  group('ExpenseProvider initial state', () {
    test('has correct defaults', () {
      final provider = ExpenseProvider();
      expect(provider.expenses, isEmpty);
      expect(provider.totalIncome, equals(0.0));
      expect(provider.totalExpenses, equals(0.0));
      expect(provider.totalBalance, equals(0.0));
      expect(provider.status, equals(ExpenseStatus.initial));
      expect(provider.isSaving, isFalse);
    });
  });
}
