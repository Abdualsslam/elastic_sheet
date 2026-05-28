import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elastic_sheet_example/main.dart';

void main() {
  testWidgets('Desktop playground presents a live demo layout', (
    WidgetTester tester,
  ) async {
    _setTestViewport(tester, const Size(1440, 900));

    await tester.pumpWidget(const MyApp());

    expect(
      find.byKey(const Key('playground_desktop_demo_layout')),
      findsOneWidget,
    );
    expect(find.text('Elastic Sheet Playground'), findsOneWidget);
    expect(find.text('Live Demo'), findsOneWidget);
    expect(find.text('Live Surface'), findsOneWidget);
    expect(find.text('Motion / Spring'), findsOneWidget);
    expect(find.text('Size / Dimensions'), findsOneWidget);
    expect(find.text('Timing'), findsOneWidget);
    expect(find.text('Anchor / Placement'), findsOneWidget);
    expect(find.text('Presets'), findsOneWidget);
    expect(find.byKey(const Key('playground_surface_toggle')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Desktop playground keeps core controls in a short viewport', (
    WidgetTester tester,
  ) async {
    _setTestViewport(tester, const Size(1440, 760));

    await tester.pumpWidget(const MyApp());

    expect(
      find.byKey(const Key('playground_desktop_demo_layout')),
      findsOneWidget,
    );
    _expectFinderInsideViewport(tester, find.text('Live Surface'));
    _expectFinderInsideViewport(tester, find.text('Motion / Spring'));
    _expectFinderInsideViewport(tester, find.text('Timing'));
    _expectFinderInsideViewport(tester, find.text('Anchor / Placement'));
    _expectFinderInsideViewport(tester, find.text('Size / Dimensions'));
    _expectFinderInsideViewport(tester, find.text('Presets'));
    _expectFinderInsideViewport(
      tester,
      find.byKey(const Key('playground_surface_toggle')),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Desktop playground surface toggles within surrounded controls', (
    WidgetTester tester,
  ) async {
    _setTestViewport(tester, const Size(1440, 760));

    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byKey(const Key('playground_surface_toggle')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('playground_expanded_heading')),
      findsOneWidget,
    );
    _expectFinderInsideViewport(tester, find.text('Motion / Spring'));
    _expectFinderInsideViewport(tester, find.text('Anchor / Placement'));
    _expectFinderInsideViewport(
      tester,
      find.byKey(const Key('playground_surface_toggle')),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tablet playground uses preview-first two-column controls', (
    WidgetTester tester,
  ) async {
    _setTestViewport(tester, const Size(900, 900));

    await tester.pumpWidget(const MyApp());

    expect(
      find.byKey(const Key('playground_tablet_demo_layout')),
      findsOneWidget,
    );
    expect(find.text('Live Surface'), findsOneWidget);
    expect(find.text('Motion / Spring'), findsOneWidget);
    expect(find.text('Anchor / Placement'), findsOneWidget);
    expect(find.byKey(const Key('playground_surface_toggle')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Playground info buttons use info icons and tooltips', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.ensureVisible(
      find.byKey(const Key('playground_info_overshoot')),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.info_outline_rounded), findsWidgets);
    expect(find.byTooltip('What is overshoot?'), findsOneWidget);

    await tester.tap(find.byKey(const Key('playground_info_overshoot')));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('stretch beyond its target'), findsOneWidget);

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('App shows the elastic sheet playground', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Elastic Sheet'), findsOneWidget);
    expect(find.byType(Slider), findsWidgets);
  });

  testWidgets('Playground surface toggles directly without a toggle button', (
    WidgetTester tester,
  ) async {
    _setTestViewport(tester, const Size(390, 840));

    await tester.pumpWidget(const MyApp());

    expect(find.text('toggle  ↕'), findsNothing);
    expect(find.byKey(const Key('playground_collapsed_label')), findsOneWidget);
    expect(find.byKey(const Key('playground_surface_toggle')), findsOneWidget);

    await tester.tap(find.byKey(const Key('playground_collapsed_label')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('playground_expanded_heading')),
      findsOneWidget,
    );

    final expandedSurfaceRect = tester.getRect(find.byType(ClipRRect).first);
    await tester.tapAt(expandedSurfaceRect.bottomCenter - const Offset(0, 12));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('playground_collapsed_label')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Playground size sliders update the expanded surface size', (
    WidgetTester tester,
  ) async {
    _setTestViewport(tester, const Size(390, 840));

    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byKey(const Key('playground_collapsed_label')));
    await tester.pumpAndSettle();

    final widthValueFinder = find.byKey(
      const Key('playground_expanded_width_value'),
    );
    final heightValueFinder = find.byKey(
      const Key('playground_expanded_height_value'),
    );
    final initialWidthValue = tester.widget<Text>(widthValueFinder).data;
    final initialHeightValue = tester.widget<Text>(heightValueFinder).data;

    await tester.ensureVisible(
      find.byKey(const Key('playground_expanded_width_slider')),
    );
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const Key('playground_expanded_width_slider')),
      const Offset(120, 0),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const Key('playground_expanded_height_slider')),
    );
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const Key('playground_expanded_height_slider')),
      const Offset(120, 0),
    );
    await tester.pumpAndSettle();

    final updatedWidthValue = tester.widget<Text>(widthValueFinder).data;
    final updatedHeightValue = tester.widget<Text>(heightValueFinder).data;

    expect(updatedWidthValue, isNot(initialWidthValue));
    expect(updatedHeightValue, isNot(initialHeightValue));
    expect(
      find.byKey(const Key('playground_expanded_heading')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Playground info icon shows the control description', (
    WidgetTester tester,
  ) async {
    _setTestViewport(tester, const Size(390, 840));

    await tester.pumpWidget(const MyApp());

    await tester.ensureVisible(
      find.byKey(const Key('playground_info_overshoot')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('playground_info_overshoot')));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Playground exposes and switches rebound profiles', (
    WidgetTester tester,
  ) async {
    _setTestViewport(tester, const Size(390, 840));

    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byKey(const Key('playground_toggle_toast')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const Key('playground_rebound_sequential')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('playground_rebound_sequential')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const Key('playground_rebound_simultaneous')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('playground_rebound_simultaneous')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('playground_preset_natural')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Playground placement chips move the surface vertically', (
    WidgetTester tester,
  ) async {
    _setTestViewport(tester, const Size(390, 840));

    await tester.pumpWidget(const MyApp());

    final hostFinder = find.byKey(const Key('playground_surface_host'));

    await tester.ensureVisible(
      find.byKey(const Key('playground_placement_top')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('playground_placement_top')));
    await tester.pumpAndSettle();
    final topY = tester.getTopLeft(hostFinder).dy;

    await tester.tap(find.byKey(const Key('playground_placement_center')));
    await tester.pumpAndSettle();
    final centerY = tester.getTopLeft(hostFinder).dy;

    await tester.tap(find.byKey(const Key('playground_placement_bottom')));
    await tester.pumpAndSettle();
    final bottomY = tester.getTopLeft(hostFinder).dy;

    expect(topY, lessThan(centerY));
    expect(centerY, lessThan(bottomY));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Playground anchor changes direction without moving the button', (
    WidgetTester tester,
  ) async {
    _setTestViewport(tester, const Size(390, 840));

    await tester.pumpWidget(const MyApp());

    final surfaceFinder = find
        .descendant(
          of: find.byKey(const Key('playground_surface_toggle')),
          matching: find.byType(ClipRRect),
        )
        .first;

    await tester.ensureVisible(
      find.byKey(const Key('playground_placement_bottom')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('playground_placement_bottom')));
    await tester.pumpAndSettle();

    final bottomAnchorY = tester.getTopLeft(surfaceFinder).dy;

    await tester.ensureVisible(
      find.byKey(const Key('playground_anchor_center')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('playground_anchor_center')));
    await tester.pumpAndSettle();
    final centerAnchorY = tester.getTopLeft(surfaceFinder).dy;

    await tester.ensureVisible(
      find.byKey(const Key('playground_anchor_topCenter')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('playground_anchor_topCenter')));
    await tester.pumpAndSettle();
    final topAnchorY = tester.getTopLeft(surfaceFinder).dy;

    expect(centerAnchorY, closeTo(bottomAnchorY, 0.01));
    expect(topAnchorY, closeTo(bottomAnchorY, 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Playground exposes the unified and checkout showcase entries', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byKey(const Key('playground_open_test_lab')), findsNothing);
    expect(
      find.byKey(const Key('playground_open_unified_showcase')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('playground_open_checkout_showcase')),
      findsOneWidget,
    );
  });

  testWidgets('Playground opens the checkout showcase route', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(
      find.byKey(const Key('playground_open_checkout_showcase')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('checkout_showcase_page')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Playground opens the unified showcase route', (
    WidgetTester tester,
  ) async {
    await _openUnifiedShowcase(tester);

    expect(find.byKey(const Key('unified_showcase_page')), findsOneWidget);
    expect(find.text('Top Zone'), findsNothing);
    expect(find.byKey(const Key('unified_showcase_top_zone')), findsNothing);
    expect(find.byKey(const Key('unified_showcase_middle_zone')), findsNothing);
    expect(find.byKey(const Key('unified_showcase_bottom_zone')), findsNothing);
    expect(
      find.byKey(const Key('unified_showcase_top_search_toggle')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('unified_showcase_middle_day_toggle')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('unified_showcase_bottom_composer_input_field')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('unified_showcase_middle_availability_toggle')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('unified_showcase_middle_queue_surface')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Unified showcase top search surface opens and closes', (
    WidgetTester tester,
  ) async {
    await _openUnifiedShowcase(tester);

    final toggle = find.byKey(const Key('unified_showcase_top_search_toggle'));
    await tester.tap(toggle);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();

    final backdrop = find.byKey(
      const Key('unified_showcase_top_search_backdrop'),
    );
    expect(backdrop, findsOneWidget);
    expect(
      find.byKey(const Key('unified_showcase_top_search_query_field')),
      findsOneWidget,
    );

    await _tapBackdropAtSafeSpot(tester, backdrop);

    expect(backdrop, findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Unified showcase locale switch changes copy and direction', (
    WidgetTester tester,
  ) async {
    await _openUnifiedShowcase(tester);

    await tester.tap(
      find.byKey(const Key('unified_showcase_locale_toggle')).hitTestable(),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('unified_showcase_locale_backdrop')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const Key('unified_showcase_locale_option_ar')).hitTestable(),
    );
    await tester.pumpAndSettle();

    expect(find.text('مكتب الرعاية'), findsOneWidget);
    expect(find.text('ابحث عن مريض أو نتيجة أو رسالة'), findsOneWidget);

    final directionality = tester.widget<Directionality>(
      find.byKey(const Key('unified_showcase_directionality')),
    );
    expect(directionality.textDirection, TextDirection.rtl);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Unified showcase keeps filter collapsed when search closes', (
    WidgetTester tester,
  ) async {
    await _openUnifiedShowcase(tester);

    final searchToggle = find.byKey(
      const Key('unified_showcase_top_search_toggle'),
    );
    await tester.tap(searchToggle);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();

    final searchBackdrop = find.byKey(
      const Key('unified_showcase_top_search_backdrop'),
    );
    final filterBackdrop = find.byKey(
      const Key('unified_showcase_top_filter_backdrop'),
    );
    expect(searchBackdrop, findsOneWidget);
    expect(filterBackdrop, findsNothing);

    await _tapBackdropAtSafeSpot(tester, searchBackdrop);

    expect(searchBackdrop, findsNothing);
    expect(filterBackdrop, findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Unified showcase filter surface does not animate when search closes',
    (WidgetTester tester) async {
      await _openUnifiedShowcase(tester);

      final filterSurface = find.byKey(
        const ValueKey('unified_showcase_top_filter_surface'),
      );
      final searchToggle = find.byKey(
        const Key('unified_showcase_top_search_toggle'),
      );

      final initialRect = tester.getRect(filterSurface);

      await tester.tap(searchToggle);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      _expectRectsClose(tester.getRect(filterSurface), initialRect);

      final searchBackdrop = find.byKey(
        const Key('unified_showcase_top_search_backdrop'),
      );
      await _tapBackdropAtSafeSpot(tester, searchBackdrop);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));

      _expectRectsClose(tester.getRect(filterSurface), initialRect);

      await tester.pumpAndSettle();
      _expectRectsClose(tester.getRect(filterSurface), initialRect);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Unified showcase top filter updates the working preset', (
    WidgetTester tester,
  ) async {
    await _openUnifiedShowcase(tester);

    final toggle = find.byKey(const Key('unified_showcase_top_filter_toggle'));
    await tester.tap(toggle.hitTestable());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();

    final backdrop = find.byKey(
      const Key('unified_showcase_top_filter_backdrop'),
    );
    expect(backdrop, findsOneWidget);

    await tester.tap(
      find
          .byKey(const Key('unified_showcase_top_filter_preset_lab_results'))
          .hitTestable(),
    );
    await tester.pumpAndSettle();

    await _tapBackdropAtSafeSpot(tester, backdrop);

    expect(backdrop, findsNothing);

    final labelFinder = find.byKey(
      const Key('unified_showcase_top_filter_label'),
    );
    expect(tester.widget<Text>(labelFinder).data, 'Lab results');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Unified showcase middle day surface expands from the schedule', (
    WidgetTester tester,
  ) async {
    await _openUnifiedShowcase(tester);

    final toggle = find.byKey(const Key('unified_showcase_middle_day_toggle'));
    await _bringUnifiedFinderIntoComfortableView(tester, toggle);
    await tester.tap(toggle.hitTestable());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();

    final backdrop = find.byKey(
      const Key('unified_showcase_middle_day_backdrop'),
    );
    expect(backdrop, findsOneWidget);
    expect(find.text('Thursday details'), findsOneWidget);

    await _tapBackdropAtSafeSpot(tester, backdrop);

    expect(backdrop, findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Unified showcase bottom composer edits and opens from plus', (
    WidgetTester tester,
  ) async {
    await _openUnifiedShowcase(tester);

    final inputField = find.byKey(
      const Key('unified_showcase_bottom_composer_input_field'),
    );
    final expandButton = find.byKey(
      const Key('unified_showcase_bottom_composer_expand_button'),
    );
    const updatedDraft = 'Send the final review file tonight';

    expect(inputField, findsOneWidget);
    await tester.ensureVisible(inputField);
    await tester.pumpAndSettle();

    await tester.tap(inputField);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('unified_showcase_bottom_composer_backdrop')),
      findsNothing,
    );

    await tester.enterText(inputField, updatedDraft);
    await tester.pumpAndSettle();
    expect(_textFieldValue(tester, inputField), updatedDraft);

    await tester.tap(expandButton.hitTestable());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();

    final backdrop = find.byKey(
      const Key('unified_showcase_bottom_composer_backdrop'),
    );
    final draftPreview = find.byKey(
      const Key('unified_showcase_bottom_composer_draft_preview'),
    );
    expect(backdrop, findsOneWidget);
    expect(
      find.descendant(of: draftPreview, matching: find.text(updatedDraft)),
      findsOneWidget,
    );

    await _tapFilterBackdropAtSafeSpot(tester, backdrop);

    expect(_textFieldValue(tester, inputField), updatedDraft);
    expect(backdrop, findsNothing);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _openUnifiedShowcase(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());

  await tester.tap(find.byKey(const Key('playground_open_unified_showcase')));
  await tester.pumpAndSettle();
}

Future<void> _tapBackdropAtSafeSpot(
  WidgetTester tester,
  Finder backdropFinder,
) async {
  final backdropRect = tester.getRect(backdropFinder);
  final target = backdropRect.bottomLeft + const Offset(12, -12);

  await tester.tapAt(target);
  await tester.pumpAndSettle();
}

Future<void> _tapFilterBackdropAtSafeSpot(
  WidgetTester tester,
  Finder backdropFinder,
) async {
  final backdropRect = tester.getRect(backdropFinder);
  final target = backdropRect.topLeft + const Offset(12, 12);

  await tester.tapAt(target);
  await tester.pumpAndSettle();
}

Future<void> _bringUnifiedFinderIntoComfortableView(
  WidgetTester tester,
  Finder finder,
) async {
  final page = _unifiedShowcasePageScrollable();

  var attempts = 0;
  while (finder.evaluate().isEmpty && attempts < 20) {
    await tester.drag(page, const Offset(0, -260));
    await tester.pumpAndSettle();
    attempts += 1;
  }

  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();

  final center = tester.getCenter(finder);
  const targetY = 320.0;
  final delta = center.dy - targetY;

  if (delta.abs() > 40) {
    await tester.drag(page, Offset(0, -delta));
    await tester.pumpAndSettle();
  }
}

Finder _unifiedShowcasePageScrollable() {
  return find
      .descendant(
        of: find.byKey(const Key('unified_showcase_page')),
        matching: find.byType(Scrollable),
      )
      .first;
}

String _textFieldValue(WidgetTester tester, Finder finder) {
  final field = tester.widget<TextField>(finder);
  return field.controller?.text ?? '';
}

void _setTestViewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void _expectFinderInsideViewport(WidgetTester tester, Finder finder) {
  expect(finder, findsOneWidget);
  final rect = tester.getRect(finder);
  final viewport = tester.view.physicalSize / tester.view.devicePixelRatio;

  expect(rect.top, greaterThanOrEqualTo(0));
  expect(rect.left, greaterThanOrEqualTo(0));
  expect(rect.bottom, lessThanOrEqualTo(viewport.height));
  expect(rect.right, lessThanOrEqualTo(viewport.width));
}

void _expectRectsClose(Rect actual, Rect expected) {
  expect(actual.left, closeTo(expected.left, 0.01));
  expect(actual.top, closeTo(expected.top, 0.01));
  expect(actual.width, closeTo(expected.width, 0.01));
  expect(actual.height, closeTo(expected.height, 0.01));
}
