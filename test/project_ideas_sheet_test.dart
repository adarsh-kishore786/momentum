import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/models/idea.dart';
import 'package:momentum/models/project.dart';
import 'package:momentum/models/session.dart';
import 'package:momentum/notifiers/project_ideas_notifier.dart';
import 'package:momentum/notifiers/project_notifier.dart';
import 'package:momentum/notifiers/project_sessions_notifier.dart';
import 'package:momentum/screens/project_ideas_screen.dart';
import 'package:momentum/screens/project_screen.dart';

const _projectId = 1;
const _screen = Size(400, 800);

/// A system navigation bar inset, e.g. Android's 48dp three-button bar.
const _navBarInset = EdgeInsets.only(bottom: 48);

class _FakeProjectNotifier extends ProjectNotifier {
  _FakeProjectNotifier() : super(_projectId);

  @override
  FutureOr<Project> build() =>
      Project(id: _projectId, name: 'Test project', description: '');
}

class _FakeProjectIdeasNotifier extends ProjectIdeasNotifier {
  _FakeProjectIdeasNotifier() : super(_projectId);

  @override
  FutureOr<List<Idea>> build() => const [];
}

class _FakeProjectSessionsNotifier extends ProjectSessionsNotifier {
  _FakeProjectSessionsNotifier() : super(_projectId);

  @override
  FutureOr<List<Session>> build() => const [];
}

/// Pumps the real [ProjectScreen] on a fixed 400x800 surface and switches to
/// the Ideas tab, where the persistent input sheet lives.
Future<void> _pumpIdeasTab(
  WidgetTester tester, {
  EdgeInsets padding = _navBarInset,
  EdgeInsets viewInsets = EdgeInsets.zero,
}) async {
  tester.view.physicalSize = _screen;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        projectProvider(_projectId).overrideWith(_FakeProjectNotifier.new),
        projectIdeasNotifier(_projectId)
            .overrideWith(_FakeProjectIdeasNotifier.new),
        projectSessionsProvider(_projectId)
            .overrideWith(_FakeProjectSessionsNotifier.new),
      ],
      child: MaterialApp(
        home: MediaQuery(
          // Emulates what the engine reports: `padding` is viewPadding minus
          // viewInsets, so it collapses to 0 once the IME is up.
          data: MediaQueryData(
            size: _screen,
            padding: padding,
            viewPadding: _navBarInset,
            viewInsets: viewInsets,
          ),
          child: const ProjectScreen(projectId: _projectId),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
  await tester.tap(find.text('Ideas'));
  await tester.pumpAndSettle();
}

/// The text field inside the persistent AddIdeaField sheet.
Finder get _ideaField => find.descendant(
      of: find.byType(AddIdeaField),
      matching: find.byType(TextField),
    );

void main() {
  group('Ideas input sheet insets', () {
    testWidgets('clears the navigation bar when the keyboard is closed',
        (tester) async {
      await _pumpIdeasTab(tester);

      final fieldBottom = tester.getBottomLeft(_ideaField).dy;

      // 800 - 48 (nav bar) - 16 (AddIdeaField's own bottom padding).
      expect(fieldBottom, closeTo(_screen.height - 48 - 16, 0.5));
      expect(fieldBottom, lessThan(_screen.height - _navBarInset.bottom));
    });

    testWidgets('adds no extra inset on top of the keyboard', (tester) async {
      // With the IME up, Android reports padding.bottom == 0 and the Scaffold
      // lifts the sheet itself. Re-adding the nav-bar inset here would leave a
      // visible gap between the field and the keyboard.
      await _pumpIdeasTab(
        tester,
        padding: EdgeInsets.zero,
        viewInsets: const EdgeInsets.only(bottom: 300),
      );

      final fieldBottom = tester.getBottomLeft(_ideaField).dy;

      expect(fieldBottom, closeTo(_screen.height - 300 - 16, 0.5));
    });

    testWidgets('renders exactly one idea input on the Ideas tab',
        (tester) async {
      await _pumpIdeasTab(tester);

      expect(find.byType(AddIdeaField), findsOneWidget);
    });

    testWidgets('renders no idea input on the Sessions tab', (tester) async {
      await _pumpIdeasTab(tester);
      await tester.tap(find.text('Sessions'));
      await tester.pumpAndSettle();

      expect(find.byType(AddIdeaField), findsNothing);
    });
  });
}
