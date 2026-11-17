import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dossier/core/widgets/app_button.dart';
import 'package:dossier/core/widgets/empty_state.dart';
import 'package:dossier/core/widgets/status_chip.dart';
import 'package:dossier/core/widgets/progress_indicator_card.dart';
import 'package:dossier/core/widgets/confirmation_dialog.dart';
import 'package:dossier/core/utils/date_utils.dart';

void main() {
  group('Widget Tests', () {
    testWidgets('AppButton renders and handles tap callbacks', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Save Application',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Save Application'), findsOneWidget);
      await tester.tap(find.text('Save Application'));
      expect(tapped, isTrue);
    });

    testWidgets('EmptyState displays icon, title, and action button', (
      WidgetTester tester,
    ) async {
      bool buttonPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.assignment_outlined,
              title: 'Your scholarship planner starts here.',
              description: 'Add your first scholarship to keep organized.',
              buttonText: 'Add Scholarship',
              onButtonPressed: () => buttonPressed = true,
            ),
          ),
        ),
      );

      expect(
        find.text('Your scholarship planner starts here.'),
        findsOneWidget,
      );
      expect(find.text('Add Scholarship'), findsOneWidget);

      await tester.tap(find.text('Add Scholarship'));
      expect(buttonPressed, isTrue);
    });

    testWidgets('StatusChip renders deadline and status classifications', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StatusChip.fromDeadlineCategory(
                  DeadlineCategory.urgent,
                  customLabel: '5 days left',
                ),
                StatusChip.fromStatus('Submitted'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('5 days left'), findsOneWidget);
      expect(find.text('Submitted'), findsOneWidget);
    });

    testWidgets(
      'ProgressIndicatorCard renders percentages and fractions accurately',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ProgressIndicatorCard(completedCount: 3, totalCount: 6),
            ),
          ),
        );

        expect(find.text('50%'), findsOneWidget);
        expect(find.text('3 of 6 requirements completed'), findsOneWidget);
      },
    );

    testWidgets(
      'ConfirmationDialog shows warning content and returns user choice',
      (WidgetTester tester) async {
        bool? result;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () async {
                    result = await ConfirmationDialog.show(
                      context,
                      title: 'Delete Application?',
                      content: 'This will delete the scholarship.',
                      confirmText: 'Delete',
                      isDestructive: true,
                    );
                  },
                  child: const Text('Open Dialog'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('Delete Application?'), findsOneWidget);
        expect(find.text('This will delete the scholarship.'), findsOneWidget);

        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        expect(result, isTrue);
      },
    );
  });
}
