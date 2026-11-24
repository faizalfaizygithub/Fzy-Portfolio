import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fzy_portfolio/app.dart';
import 'package:fzy_portfolio/core/theme/app_typography.dart';
import 'package:fzy_portfolio/features/contact/domain/contact_message.dart';
import 'package:visibility_detector/visibility_detector.dart';

class _FailingRepo implements ContactRepository {
  int calls = 0;
  @override
  Future<ContactResult> send(ContactMessage message) async {
    calls++;
    return const ContactFailure('Delivery failed (test).');
  }
}

/// Scrolls [finder] into view, then nudges it below the floating nav bar.
Future<void> _reveal(WidgetTester tester, Finder finder) async {
  final scrollable = find.byType(Scrollable).first;
  await tester.scrollUntilVisible(finder, 400, scrollable: scrollable);
  await tester.drag(scrollable, const Offset(0, 250));
  await tester.pumpAndSettle();
}

Future<void> _pumpApp(
  WidgetTester tester, {
  required Size size,
  bool reduceMotion = true,
  ContactRepository? repo,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  if (reduceMotion) {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }
  await tester.pumpWidget(PortfolioApp(contactRepository: repo ?? _FailingRepo()));
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  setUpAll(() {
    AppTypography.useGoogleFonts = false;
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  for (final (label, size) in [
    ('desktop', const Size(1440, 900)),
    ('tablet', const Size(900, 1100)),
    ('mobile', const Size(390, 844)),
    ('small mobile', const Size(320, 640)),
  ]) {
    testWidgets('renders every section without overflow on $label', (tester) async {
      await _pumpApp(tester, size: size);

      expect(find.text('A Little About Me'), findsOneWidget);
      expect(find.text('Technologies I Work With'), findsOneWidget);
      expect(find.text('Beyond Writing Code'), findsOneWidget);
      expect(find.textContaining('Noviindus Technologies'), findsWidgets);
      expect(find.text('Ealzo'), findsOneWidget);

      // Scroll through the whole page so every section lays out at size.
      final scrollable = find.byType(Scrollable).first;
      for (var i = 0; i < 40; i++) {
        await tester.drag(scrollable, const Offset(0, -600));
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.textContaining('All Rights Reserved'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('full animations run without errors', (tester) async {
    await _pumpApp(tester, size: const Size(1440, 900), reduceMotion: false);
    await tester.pump(const Duration(seconds: 3));
    final scrollable = find.byType(Scrollable).first;
    for (var i = 0; i < 20; i++) {
      await tester.drag(scrollable, const Offset(0, -700));
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(tester.takeException(), isNull);
    // Leave the tree so repeating controllers are disposed.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('opening a project shows its detail page and back returns', (tester) async {
    await _pumpApp(tester, size: const Size(1440, 900));

    final card = find.text('Furnyshop');
    await _reveal(tester, card);
    await tester.tap(card);
    await tester.pumpAndSettle();

    expect(find.text('My contributions'), findsOneWidget);
    expect(find.text('Built checkout workflows.'), findsOneWidget);
    expect(find.text('NEXT PROJECT'), findsOneWidget);

    await tester.tap(find.text('All projects'));
    await tester.pumpAndSettle();
    expect(find.text('My contributions'), findsNothing);
  });

  testWidgets('project detail works on mobile with carousel gallery', (tester) async {
    await _pumpApp(tester, size: const Size(360, 780));
    final card = find.text('Mindiko');
    await _reveal(tester, card);
    await tester.tap(card);
    await tester.pumpAndSettle();

    expect(find.text('PROJECT GALLERY'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Next screen'));
    await tester.pumpAndSettle();

    final scrollable = find.byType(Scrollable).first;
    for (var i = 0; i < 15; i++) {
      await tester.drag(scrollable, const Offset(0, -500));
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Integrated Agora/WebRTC technologies.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('contact form validates and never fakes success', (tester) async {
    final repo = _FailingRepo();
    await _pumpApp(tester, size: const Size(1440, 900), repo: repo);

    final send = find.text('Send Message');
    await _reveal(tester, send);

    await tester.tap(send);
    await tester.pumpAndSettle();
    expect(find.text('Please enter your name.'), findsOneWidget);
    expect(find.text('Please enter a valid email address.'), findsNothing);
    expect(repo.calls, 0);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Jane');
    await tester.enterText(fields.at(1), 'jane@example.com');
    await tester.enterText(fields.at(2), 'Project');
    await tester.enterText(fields.at(3), 'Hello there, let us build an app.');
    await _reveal(tester, send);
    await tester.tap(send);
    await tester.pumpAndSettle();

    expect(repo.calls, 1);
    expect(find.text('Delivery failed (test).'), findsOneWidget);
    expect(find.text('Message sent!'), findsNothing);
    // What the user typed is kept after a failure.
    expect(find.text('jane@example.com'), findsOneWidget);
  });
}
