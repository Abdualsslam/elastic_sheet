import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elastic_sheet/elastic_sheet.dart';

const Key _hostKey = Key('host');
const Size _collapsedSize = Size(100, 40);
const Size _expandedSize = Size(220, 260);
const Size _actionCollapsedSize = Size(220, 56);
const Size _actionExpandedSize = Size(220, 180);
const ElasticSheetConfig _fastConfig = ElasticSheetConfig(
  expandDuration: Duration(milliseconds: 40),
  collapseDuration: Duration(milliseconds: 40),
);
const ElasticSheetConfig _fastNaturalConfig = ElasticSheetConfig(
  expandDuration: Duration(milliseconds: 40),
  collapseDuration: Duration(milliseconds: 40),
  reboundProfile: ElasticSheetReboundProfile.sequentialCrossAxis,
);

void main() {
  test('overshootClamp increases the visible overshoot amplitude mapping', () {
    expect(ElasticSheetMotion.overshootAmplitudeForClamp(1.0), 0.0);
    expect(
      ElasticSheetMotion.overshootAmplitudeForClamp(1.12),
      greaterThan(ElasticSheetMotion.overshootAmplitudeForClamp(1.03)),
    );
  });

  test('axisProgress adds a subtle anticipation before expansion', () {
    const config = ElasticSheetConfig();

    expect(
      ElasticSheetMotion.axisProgress(
        0.05,
        isCollapsing: false,
        axis: ElasticSheetAxis.horizontal,
        config: config,
      ),
      lessThan(0.0),
    );
    expect(
      ElasticSheetMotion.axisProgress(
        0.05,
        isCollapsing: false,
        axis: ElasticSheetAxis.vertical,
        config: config,
      ),
      lessThan(0.0),
    );
    expect(
      ElasticSheetMotion.axisProgress(
        0.24,
        isCollapsing: false,
        axis: ElasticSheetAxis.vertical,
        config: config,
      ),
      greaterThan(0.0),
    );
  });

  test('overshootPulse settles back toward rest near the end', () {
    final mid = ElasticSheetMotion.overshootPulse(0.78);
    final late = ElasticSheetMotion.overshootPulse(0.95);

    expect(mid, greaterThan(1.0));
    expect(late, greaterThanOrEqualTo(1.0));
    expect(late, lessThan(mid));
    expect(ElasticSheetMotion.overshootPulse(1.0), 1.0);
  });

  test('natural preset enables sequential cross-axis rebound', () {
    const config = ElasticSheetConfig.natural();

    expect(
      config.reboundProfile,
      ElasticSheetReboundProfile.sequentialCrossAxis,
    );
  });

  test('sequentialCrossAxis rebounds vertical before horizontal on expand', () {
    const config = ElasticSheetConfig.natural();
    final earlyVertical = ElasticSheetMotion.axisReboundScale(
      0.67,
      axis: ElasticSheetAxis.vertical,
      isCollapsing: false,
      config: config,
    );
    final earlyHorizontal = ElasticSheetMotion.axisReboundScale(
      0.67,
      axis: ElasticSheetAxis.horizontal,
      isCollapsing: false,
      config: config,
    );
    final lateVertical = ElasticSheetMotion.axisReboundScale(
      0.86,
      axis: ElasticSheetAxis.vertical,
      isCollapsing: false,
      config: config,
    );
    final lateHorizontal = ElasticSheetMotion.axisReboundScale(
      0.86,
      axis: ElasticSheetAxis.horizontal,
      isCollapsing: false,
      config: config,
    );

    expect(earlyVertical, greaterThan(1.0));
    expect(earlyHorizontal, lessThan(1.0));
    expect(lateHorizontal, greaterThan(1.0));
    expect(lateVertical, lessThan(earlyVertical));
  });

  test('sequentialCrossAxis reverses the rebound order on collapse', () {
    const config = ElasticSheetConfig.natural();
    final earlyHorizontal = ElasticSheetMotion.axisReboundScale(
      0.33,
      axis: ElasticSheetAxis.horizontal,
      isCollapsing: true,
      config: config,
    );
    final earlyVertical = ElasticSheetMotion.axisReboundScale(
      0.33,
      axis: ElasticSheetAxis.vertical,
      isCollapsing: true,
      config: config,
    );
    final lateHorizontal = ElasticSheetMotion.axisReboundScale(
      0.14,
      axis: ElasticSheetAxis.horizontal,
      isCollapsing: true,
      config: config,
    );
    final lateVertical = ElasticSheetMotion.axisReboundScale(
      0.14,
      axis: ElasticSheetAxis.vertical,
      isCollapsing: true,
      config: config,
    );

    expect(earlyHorizontal, greaterThan(1.0));
    expect(earlyVertical, lessThan(1.0));
    expect(lateVertical, greaterThan(1.0));
    expect(lateHorizontal, lessThan(earlyHorizontal));
  });

  testWidgets('fixed sizing keeps the explicit expandedSize', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildHarness(
        ElasticSheet(
          isExpanded: true,
          collapsedSize: _collapsedSize,
          expandedSize: _expandedSize,
          collapsedChild: const Text('Open'),
          expandedChild: _buildShortExpandedChild(),
        ),
      ),
    );

    expect(_surfaceSize(tester).width, closeTo(_expandedSize.width, 0.01));
    expect(_surfaceSize(tester).height, closeTo(_expandedSize.height, 0.01));
    expect(find.byType(SingleChildScrollView), findsNothing);
  });

  testWidgets(
    'dynamicHeight uses fallback first then measured content height',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildHarness(
          ElasticSheet(
            isExpanded: true,
            collapsedSize: _collapsedSize,
            expandedSize: _expandedSize,
            expandedSizing: ElasticSheetExpandedSizing.dynamicHeight,
            collapsedChild: const Text('Open'),
            expandedChild: _buildShortExpandedChild(),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(_surfaceSize(tester).width, closeTo(_expandedSize.width, 0.01));
      expect(_surfaceSize(tester).height, closeTo(_expandedSize.height, 0.01));

      await tester.pump();

      expect(_surfaceSize(tester).width, closeTo(_expandedSize.width, 0.01));
      expect(_surfaceSize(tester).height, closeTo(120, 0.01));
      expect(find.byType(SingleChildScrollView), findsNothing);
    },
  );

  testWidgets('dynamicHeight caps height and enables scroll', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildHarness(
        ElasticSheet(
          isExpanded: true,
          collapsedSize: _collapsedSize,
          expandedSize: _expandedSize,
          expandedSizing: ElasticSheetExpandedSizing.dynamicHeight,
          maxExpandedHeight: 180,
          collapsedChild: const Text('Open'),
          expandedChild: _buildTallExpandedChild(),
        ),
      ),
    );

    await tester.pump();

    expect(_surfaceSize(tester).width, closeTo(_expandedSize.width, 0.01));
    expect(_surfaceSize(tester).height, closeTo(180, 0.01));
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('fixed sizing keeps the selected corner pinned while expanding', (
    WidgetTester tester,
  ) async {
    final anchors = <ElasticSheetAnchor>[
      ElasticSheetAnchor.topLeft,
      ElasticSheetAnchor.topRight,
      ElasticSheetAnchor.bottomLeft,
      ElasticSheetAnchor.bottomRight,
    ];

    for (final anchor in anchors) {
      await tester.pumpWidget(
        _buildHarness(
          _buildSurface(isExpanded: false, anchor: anchor, config: _fastConfig),
        ),
      );

      final hostRect = _hostRect(tester);
      _expectPinnedCorner(anchor, _surfaceRect(tester), hostRect);

      await tester.pumpWidget(
        _buildHarness(
          _buildSurface(isExpanded: true, anchor: anchor, config: _fastConfig),
        ),
      );
      await tester.pumpAndSettle();

      _expectPinnedCorner(anchor, _surfaceRect(tester), hostRect);
    }
  });

  testWidgets('natural rebound profile still respects fixed corner anchors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildHarness(
        _buildSurface(
          isExpanded: false,
          anchor: ElasticSheetAnchor.topLeft,
          config: _fastNaturalConfig,
        ),
      ),
    );

    final hostRect = _hostRect(tester);

    await tester.pumpWidget(
      _buildHarness(
        _buildSurface(
          isExpanded: true,
          anchor: ElasticSheetAnchor.topLeft,
          config: _fastNaturalConfig,
        ),
      ),
    );
    await tester.pumpAndSettle();

    _expectPinnedCorner(
      ElasticSheetAnchor.topLeft,
      _surfaceRect(tester),
      hostRect,
    );
  });

  testWidgets('legacy origin still controls dynamic vertical alignment', (
    WidgetTester tester,
  ) async {
    final cases = <ElasticSheetOrigin, double>{
      ElasticSheetOrigin.top: 0,
      ElasticSheetOrigin.center: 90,
      ElasticSheetOrigin.bottom: 180,
    };

    for (final entry in cases.entries) {
      await tester.pumpWidget(
        _buildHarness(
          ElasticSheet(
            isExpanded: true,
            collapsedSize: _collapsedSize,
            expandedSize: _expandedSize,
            expandedSizing: ElasticSheetExpandedSizing.dynamicHeight,
            origin: entry.key,
            collapsedChild: const Text('Open'),
            expandedChild: _buildShortExpandedChild(),
          ),
        ),
      );

      await tester.pump();

      expect(_surfaceTopOffset(tester), closeTo(entry.value, 0.01));
    }
  });

  testWidgets('anchor overrides origin when both are provided', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildHarness(
        ElasticSheet(
          isExpanded: true,
          anchor: ElasticSheetAnchor.topLeft,
          origin: ElasticSheetOrigin.bottom,
          collapsedSize: _collapsedSize,
          expandedSize: _expandedSize,
          collapsedChild: const Text('Open'),
          expandedChild: _buildShortExpandedChild(),
        ),
      ),
    );

    final hostRect = _hostRect(tester);
    final surfaceRect = _surfaceRect(tester);

    expect(surfaceRect.left, closeTo(hostRect.left, 0.01));
    expect(surfaceRect.top, closeTo(hostRect.top, 0.01));
  });

  testWidgets('dynamicHeight ignores the horizontal anchor component', (
    WidgetTester tester,
  ) async {
    final cases = <ElasticSheetAnchor, double>{
      ElasticSheetAnchor.topLeft: 0,
      ElasticSheetAnchor.topCenter: 0,
      ElasticSheetAnchor.topRight: 0,
      ElasticSheetAnchor.centerLeft: 90,
      ElasticSheetAnchor.center: 90,
      ElasticSheetAnchor.centerRight: 90,
      ElasticSheetAnchor.bottomLeft: 180,
      ElasticSheetAnchor.bottomCenter: 180,
      ElasticSheetAnchor.bottomRight: 180,
    };

    for (final entry in cases.entries) {
      await tester.pumpWidget(
        _buildHarness(
          ElasticSheet(
            isExpanded: true,
            anchor: entry.key,
            collapsedSize: _collapsedSize,
            expandedSize: _expandedSize,
            expandedSizing: ElasticSheetExpandedSizing.dynamicHeight,
            collapsedChild: const Text('Open'),
            expandedChild: _buildShortExpandedChild(),
          ),
        ),
      );

      await tester.pump();

      expect(_surfaceTopOffset(tester), closeTo(entry.value, 0.01));
      expect(_surfaceLeftOffset(tester), closeTo(40, 0.01));
    }
  });

  testWidgets('expand and collapse callbacks still fire once each', (
    WidgetTester tester,
  ) async {
    var expandedCount = 0;
    var collapsedCount = 0;

    Widget build(bool isExpanded) {
      return _buildHarness(
        ElasticSheet(
          isExpanded: isExpanded,
          config: _fastConfig,
          collapsedSize: _collapsedSize,
          expandedSize: _expandedSize,
          collapsedChild: const Text('Open'),
          expandedChild: _buildShortExpandedChild(),
          onExpanded: () => expandedCount += 1,
          onCollapsed: () => collapsedCount += 1,
        ),
      );
    }

    await tester.pumpWidget(build(false));
    await tester.pumpWidget(build(true));
    await tester.pumpAndSettle();

    expect(expandedCount, 1);
    expect(collapsedCount, 0);

    await tester.pumpWidget(build(false));
    await tester.pumpAndSettle();

    expect(expandedCount, 1);
    expect(collapsedCount, 1);
  });

  testWidgets('ElasticSheetActions.maybeOf returns null outside scope', (
    WidgetTester tester,
  ) async {
    ElasticSheetActions? actions;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              actions = ElasticSheetActions.maybeOf(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    expect(actions, isNull);
  });

  testWidgets('ElasticSheetActions.of throws a clear error outside scope', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              ElasticSheetActions.of(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    final exception = tester.takeException();
    expect(exception, isA<FlutterError>());
    expect(exception.toString(), contains('ElasticSheet.controlled'));
  });

  testWidgets('controlled descendants can expand, collapse, and toggle', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const _ControlledActionsHarness());

    expect(
      _surfaceSize(tester).height,
      closeTo(_actionCollapsedSize.height, 0.01),
    );

    await tester.tap(find.byKey(const Key('actions_expand')));
    await tester.pumpAndSettle();

    expect(
      _surfaceSize(tester).height,
      closeTo(_actionExpandedSize.height, 0.01),
    );
    expect(find.text('expanded'), findsOneWidget);

    await tester.tap(find.byKey(const Key('actions_collapse')));
    await tester.pumpAndSettle();

    expect(
      _surfaceSize(tester).height,
      closeTo(_actionCollapsedSize.height, 0.01),
    );

    await tester.tap(find.byKey(const Key('actions_expand')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('actions_toggle')));
    await tester.pumpAndSettle();

    expect(
      _surfaceSize(tester).height,
      closeTo(_actionCollapsedSize.height, 0.01),
    );
  });

  testWidgets(
    'ElasticSheetActions.of does not rebuild descendants every frame',
    (WidgetTester tester) async {
      await tester.pumpWidget(const _ActionsRebuildHarness());

      final state = tester.state<_ActionsRebuildHarnessState>(
        find.byType(_ActionsRebuildHarness),
      );
      final initialBuildCount = state.buildCount;

      state.controller.expand();
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 16));

      expect(state.buildCount, initialBuildCount);
    },
  );

  testWidgets('invisible expanded content is not built while collapsed', (
    WidgetTester tester,
  ) async {
    var expandedBuildCount = 0;

    await tester.pumpWidget(
      _buildHarness(
        ElasticSheet(
          isExpanded: false,
          collapsedSize: _actionCollapsedSize,
          expandedSize: _actionExpandedSize,
          collapsedChild: const Text('Collapsed'),
          expandedChild: _BuildCounter(
            onBuild: () => expandedBuildCount += 1,
            child: const SizedBox(height: 120),
          ),
        ),
        hostSize: const Size(320, 320),
      ),
    );

    expect(expandedBuildCount, 0);
  });

  testWidgets('invisible collapsed content is not built while expanded', (
    WidgetTester tester,
  ) async {
    late ElasticSheetController controller;
    var collapsedBuildCount = 0;

    await tester.pumpWidget(
      _ControlledVisibilityHarness(
        onControllerReady: (value) => controller = value,
        collapsedChild: _BuildCounter(
          onBuild: () => collapsedBuildCount += 1,
          child: const Text('Collapsed'),
        ),
        expandedChild: const SizedBox(height: 120),
      ),
    );

    collapsedBuildCount = 0;
    controller.jumpTo(1.0);
    await tester.pump();

    expect(collapsedBuildCount, 0);
  });

  testWidgets('supports swapping from one external controller to another', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const _ControllerSwapHarness());

    await tester.tap(find.byKey(const Key('expand-current-controller')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('swap-controller')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('expand-current-controller')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('controller swap preserves progress and updates actions scope', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const _ControllerSwapHarness());

    final state = tester.state<_ControllerSwapHarnessState>(
      find.byType(_ControllerSwapHarness),
    );

    state.first.jumpTo(0.42);
    await tester.pump();

    await tester.tap(find.byKey(const Key('swap-controller')));
    await tester.pump();

    expect(state.second.value, closeTo(0.42, 0.01));

    state.second.jumpTo(0.0);
    await tester.pump();

    expect(state.actionsController, same(state.second));
    expect(tester.takeException(), isNull);
  });

  testWidgets('supports switching from controlled to uncontrolled controller', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const _ControlledToUncontrolledHarness());

    await tester.tap(find.byKey(const Key('toggle-expanded')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('switch-to-uncontrolled')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('toggle-expanded')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('supports switching from uncontrolled to controlled controller', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const _UncontrolledToControlledHarness());

    await tester.tap(find.byKey(const Key('toggle-expanded')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('switch-to-controlled')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('toggle-expanded')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('toggle follows the target state while animation is in flight', (
    WidgetTester tester,
  ) async {
    late ElasticSheetController controller;

    await tester.pumpWidget(
      _ControlledPulseHarness(onControllerReady: (value) => controller = value),
    );

    controller.expand();
    controller.toggle();
    await tester.pumpAndSettle();

    expect(controller.isExpanded, isFalse);
    expect(controller.value, 0.0);
  });

  testWidgets('ready surfaces still require expanded content and size', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildHarness(
        ElasticSheet(
          isExpanded: false,
          contentState: ElasticSheetContentState.ready,
          collapsedSize: _collapsedSize,
          collapsedChild: const Text('Open'),
        ),
      ),
    );

    expect(tester.takeException(), isA<AssertionError>());
  });

  testWidgets('pending accepts missing expanded data and pulses on tap', (
    WidgetTester tester,
  ) async {
    var pendingTapCount = 0;

    await tester.pumpWidget(
      _buildHarness(
        ElasticSheet(
          isExpanded: false,
          contentState: ElasticSheetContentState.pending,
          config: _fastConfig,
          collapsedSize: _collapsedSize,
          collapsedChild: const Text('Pending'),
          onPendingTap: () => pendingTapCount += 1,
        ),
      ),
    );

    expect(_surfaceSize(tester).width, closeTo(_collapsedSize.width, 0.01));

    await tester.tap(find.text('Pending'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 45));

    expect(_surfaceSize(tester).width, greaterThan(_collapsedSize.width));

    await tester.pumpAndSettle();

    expect(pendingTapCount, 1);
    expect(_surfaceSize(tester).width, closeTo(_collapsedSize.width, 0.01));
    expect(find.byType(SingleChildScrollView), findsNothing);
  });

  testWidgets('unavailable stays collapsed and ignores taps', (
    WidgetTester tester,
  ) async {
    var pendingTapCount = 0;

    await tester.pumpWidget(
      _buildHarness(
        ElasticSheet(
          isExpanded: false,
          contentState: ElasticSheetContentState.unavailable,
          config: _fastConfig,
          collapsedSize: _collapsedSize,
          collapsedChild: const Text('Unavailable'),
          onPendingTap: () => pendingTapCount += 1,
        ),
      ),
    );

    await tester.tapAt(_surfaceRect(tester).center);
    await tester.pumpAndSettle();

    expect(pendingTapCount, 0);
    expect(_surfaceSize(tester).width, closeTo(_collapsedSize.width, 0.01));
  });

  testWidgets('controller pulse returns to a collapsed resting state', (
    WidgetTester tester,
  ) async {
    late ElasticSheetController controller;

    await tester.pumpWidget(
      _ControlledPulseHarness(onControllerReady: (value) => controller = value),
    );

    final pulse = controller.pulse();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 45));

    expect(_surfaceSize(tester).width, greaterThan(_collapsedSize.width));

    await tester.pumpAndSettle();
    await pulse;

    expect(controller.isExpanded, isFalse);
    expect(controller.isPulsing, isFalse);
    expect(_surfaceSize(tester).width, closeTo(_collapsedSize.width, 0.01));
  });

  testWidgets('controlled descendants can pulse without expanding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const _ControlledPulseActionsHarness());

    expect(
      _surfaceSize(tester).width,
      closeTo(_actionCollapsedSize.width, 0.01),
    );

    await tester.tap(find.byKey(const Key('actions_pulse')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 45));

    expect(_surfaceSize(tester).width, greaterThan(_actionCollapsedSize.width));

    await tester.pumpAndSettle();

    expect(
      _surfaceSize(tester).width,
      closeTo(_actionCollapsedSize.width, 0.01),
    );
    expect(find.byType(SingleChildScrollView), findsNothing);
  });

  testWidgets('controller dispose during pulse does not throw', (
    WidgetTester tester,
  ) async {
    late ElasticSheetController controller;

    await tester.pumpWidget(
      _ControlledPulseHarness(onControllerReady: (c) => controller = c),
    );

    // Start a pulse but immediately navigate away (disposing the controller).
    controller.pulse(); // ignore: unawaited_futures
    await tester.pump();

    // Dispose by removing the widget tree.
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));
    await tester.pumpAndSettle();

    // If we reach this point without a crash, the test passes.
    expect(true, isTrue);
  });

  testWidgets('controller jumpTo sets the animation value', (
    WidgetTester tester,
  ) async {
    late ElasticSheetController controller;

    await tester.pumpWidget(
      _ControlledPulseHarness(onControllerReady: (c) => controller = c),
    );

    controller.jumpTo(0.5);
    expect(controller.value, 0.5);

    controller.jumpTo(0.0);
    expect(controller.value, 0.0);
  });

  test('ElasticSheetConfig.toString returns readable output', () {
    const config = ElasticSheetConfig.gentle();
    final str = config.toString();

    expect(str, contains('ElasticSheetConfig'));
    expect(str, contains('stiffness'));
    expect(str, contains('damping'));
    expect(str, contains('rebound'));
  });

  test('ElasticSheetConfig.copyWith preserves unmodified fields', () {
    const original = ElasticSheetConfig.bouncy();
    final modified = original.copyWith(stiffness: 999);

    expect(modified.stiffness, 999);
    expect(modified.damping, original.damping);
    expect(modified.mass, original.mass);
    expect(modified.overshootClamp, original.overshootClamp);
    expect(modified.reboundProfile, original.reboundProfile);
  });

  testWidgets('config change during animation does not throw', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildHarness(
        ElasticSheet(
          isExpanded: false,
          config: _fastConfig,
          collapsedSize: _collapsedSize,
          expandedSize: _expandedSize,
          collapsedChild: const Text('Open'),
          expandedChild: _buildShortExpandedChild(),
        ),
      ),
    );

    // Start expanding.
    await tester.pumpWidget(
      _buildHarness(
        ElasticSheet(
          isExpanded: true,
          config: _fastConfig,
          collapsedSize: _collapsedSize,
          expandedSize: _expandedSize,
          collapsedChild: const Text('Open'),
          expandedChild: _buildShortExpandedChild(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 10));

    // Change config mid-animation.
    await tester.pumpWidget(
      _buildHarness(
        ElasticSheet(
          isExpanded: true,
          config: const ElasticSheetConfig.gentle(),
          collapsedSize: _collapsedSize,
          expandedSize: _expandedSize,
          collapsedChild: const Text('Open'),
          expandedChild: _buildShortExpandedChild(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}

class _ControlledPulseHarness extends StatefulWidget {
  const _ControlledPulseHarness({required this.onControllerReady});

  final ValueChanged<ElasticSheetController> onControllerReady;

  @override
  State<_ControlledPulseHarness> createState() =>
      _ControlledPulseHarnessState();
}

class _ControlledPulseHarnessState extends State<_ControlledPulseHarness>
    with SingleTickerProviderStateMixin {
  late final ElasticSheetController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ElasticSheetController(vsync: this, config: _fastConfig);
    widget.onControllerReady(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildHarness(
      ElasticSheet.controlled(
        controller: _controller,
        contentState: ElasticSheetContentState.pending,
        collapsedSize: _collapsedSize,
        collapsedChild: const Text('Pulse'),
      ),
    );
  }
}

class _ActionsRebuildHarness extends StatefulWidget {
  const _ActionsRebuildHarness();

  @override
  State<_ActionsRebuildHarness> createState() => _ActionsRebuildHarnessState();
}

class _ActionsRebuildHarnessState extends State<_ActionsRebuildHarness>
    with SingleTickerProviderStateMixin {
  late final ElasticSheetController controller;
  var buildCount = 0;

  @override
  void initState() {
    super.initState();
    controller = ElasticSheetController(vsync: this, config: _fastConfig);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildHarness(
      ElasticSheet.controlled(
        controller: controller,
        collapsedSize: _actionCollapsedSize,
        expandedSize: _actionExpandedSize,
        collapsedChild: _ActionsRebuildCounter(onBuild: () => buildCount += 1),
        expandedChild: const SizedBox(height: 120),
      ),
      hostSize: const Size(320, 320),
    );
  }
}

class _ActionsRebuildCounter extends StatelessWidget {
  const _ActionsRebuildCounter({required this.onBuild});

  final VoidCallback onBuild;

  @override
  Widget build(BuildContext context) {
    onBuild();
    final actions = ElasticSheetActions.of(context);

    return TextButton(
      key: const Key('actions-rebuild-counter-button'),
      onPressed: actions.toggle,
      child: const Text('Toggle'),
    );
  }
}

class _ControlledVisibilityHarness extends StatefulWidget {
  const _ControlledVisibilityHarness({
    required this.onControllerReady,
    required this.collapsedChild,
    required this.expandedChild,
  });

  final ValueChanged<ElasticSheetController> onControllerReady;
  final Widget collapsedChild;
  final Widget expandedChild;

  @override
  State<_ControlledVisibilityHarness> createState() =>
      _ControlledVisibilityHarnessState();
}

class _ControlledVisibilityHarnessState
    extends State<_ControlledVisibilityHarness>
    with SingleTickerProviderStateMixin {
  late final ElasticSheetController controller;

  @override
  void initState() {
    super.initState();
    controller = ElasticSheetController(vsync: this, config: _fastConfig);
    widget.onControllerReady(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildHarness(
      ElasticSheet.controlled(
        controller: controller,
        collapsedSize: _actionCollapsedSize,
        expandedSize: _actionExpandedSize,
        collapsedChild: widget.collapsedChild,
        expandedChild: widget.expandedChild,
      ),
      hostSize: const Size(320, 320),
    );
  }
}

class _BuildCounter extends StatelessWidget {
  const _BuildCounter({required this.onBuild, required this.child});

  final VoidCallback onBuild;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    onBuild();
    return child;
  }
}

class _ControllerSwapHarness extends StatefulWidget {
  const _ControllerSwapHarness();

  @override
  State<_ControllerSwapHarness> createState() => _ControllerSwapHarnessState();
}

class _ControllerSwapHarnessState extends State<_ControllerSwapHarness>
    with TickerProviderStateMixin {
  late final ElasticSheetController first;
  late final ElasticSheetController second;
  ElasticSheetController? actionsController;
  var useSecond = false;

  @override
  void initState() {
    super.initState();
    first = ElasticSheetController(vsync: this);
    second = ElasticSheetController(vsync: this);
  }

  @override
  void dispose() {
    first.dispose();
    second.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildHarness(
      Column(
        children: [
          TextButton(
            key: const Key('swap-controller'),
            onPressed: () => setState(() => useSecond = true),
            child: const Text('Swap'),
          ),
          TextButton(
            key: const Key('expand-current-controller'),
            onPressed: () => (useSecond ? second : first).expand(),
            child: const Text('Expand'),
          ),
          ElasticSheet.controlled(
            controller: useSecond ? second : first,
            collapsedSize: _actionCollapsedSize,
            expandedSize: _actionExpandedSize,
            collapsedChild: _ActionsControllerReporter(
              onBuild: (controller) => actionsController = controller,
            ),
            expandedChild: const SizedBox(height: 120),
          ),
        ],
      ),
      hostSize: const Size(320, 420),
    );
  }
}

class _ActionsControllerReporter extends StatelessWidget {
  const _ActionsControllerReporter({required this.onBuild});

  final ValueChanged<ElasticSheetController> onBuild;

  @override
  Widget build(BuildContext context) {
    final actions = ElasticSheetActions.of(context);
    onBuild(actions.controller);
    return const Text('Collapsed');
  }
}

class _ControlledToUncontrolledHarness extends StatefulWidget {
  const _ControlledToUncontrolledHarness();

  @override
  State<_ControlledToUncontrolledHarness> createState() =>
      _ControlledToUncontrolledHarnessState();
}

class _ControlledToUncontrolledHarnessState
    extends State<_ControlledToUncontrolledHarness>
    with TickerProviderStateMixin {
  late final ElasticSheetController controller;
  var useExternalController = true;
  var expanded = false;

  @override
  void initState() {
    super.initState();
    controller = ElasticSheetController(vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sheet = useExternalController
        ? ElasticSheet.controlled(
            controller: controller,
            collapsedSize: _actionCollapsedSize,
            expandedSize: _actionExpandedSize,
            collapsedChild: const Text('Collapsed'),
            expandedChild: const SizedBox(height: 120),
          )
        : ElasticSheet(
            isExpanded: expanded,
            config: _fastConfig,
            collapsedSize: _actionCollapsedSize,
            expandedSize: _actionExpandedSize,
            collapsedChild: const Text('Collapsed'),
            expandedChild: const SizedBox(height: 120),
          );

    return _buildHarness(
      Column(
        children: [
          TextButton(
            key: const Key('switch-to-uncontrolled'),
            onPressed: () => setState(() => useExternalController = false),
            child: const Text('Switch'),
          ),
          TextButton(
            key: const Key('toggle-expanded'),
            onPressed: () => setState(() => expanded = !expanded),
            child: const Text('Toggle expanded'),
          ),
          sheet,
        ],
      ),
      hostSize: const Size(320, 420),
    );
  }
}

class _UncontrolledToControlledHarness extends StatefulWidget {
  const _UncontrolledToControlledHarness();

  @override
  State<_UncontrolledToControlledHarness> createState() =>
      _UncontrolledToControlledHarnessState();
}

class _UncontrolledToControlledHarnessState
    extends State<_UncontrolledToControlledHarness>
    with TickerProviderStateMixin {
  late final ElasticSheetController controller;
  var useExternalController = false;
  var expanded = false;

  @override
  void initState() {
    super.initState();
    controller = ElasticSheetController(vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sheet = useExternalController
        ? ElasticSheet.controlled(
            controller: controller,
            collapsedSize: _actionCollapsedSize,
            expandedSize: _actionExpandedSize,
            collapsedChild: const Text('Collapsed'),
            expandedChild: const SizedBox(height: 120),
          )
        : ElasticSheet(
            isExpanded: expanded,
            config: _fastConfig,
            collapsedSize: _actionCollapsedSize,
            expandedSize: _actionExpandedSize,
            collapsedChild: const Text('Collapsed'),
            expandedChild: const SizedBox(height: 120),
          );

    return _buildHarness(
      Column(
        children: [
          TextButton(
            key: const Key('switch-to-controlled'),
            onPressed: () => setState(() => useExternalController = true),
            child: const Text('Switch'),
          ),
          TextButton(
            key: const Key('toggle-expanded'),
            onPressed: () => setState(() => expanded = !expanded),
            child: const Text('Toggle expanded'),
          ),
          sheet,
        ],
      ),
      hostSize: const Size(320, 420),
    );
  }
}

class _ControlledActionsHarness extends StatefulWidget {
  const _ControlledActionsHarness();

  @override
  State<_ControlledActionsHarness> createState() =>
      _ControlledActionsHarnessState();
}

class _ControlledActionsHarnessState extends State<_ControlledActionsHarness>
    with SingleTickerProviderStateMixin {
  late final ElasticSheetController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ElasticSheetController(vsync: this, config: _fastConfig);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildHarness(
      ElasticSheet.controlled(
        controller: _controller,
        collapsedSize: _actionCollapsedSize,
        expandedSize: _actionExpandedSize,
        collapsedChild: Builder(
          builder: (context) {
            return Center(
              child: TextButton(
                key: const Key('actions_expand'),
                onPressed: () => ElasticSheetActions.of(context).expand(),
                child: const Text('Expand'),
              ),
            );
          },
        ),
        expandedChild: Builder(
          builder: (context) {
            final actions = ElasticSheetActions.of(context);

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(actions.isExpanded ? 'expanded' : 'collapsed'),
                  const SizedBox(height: 8),
                  TextButton(
                    key: const Key('actions_collapse'),
                    onPressed: () => actions.collapse(),
                    child: const Text('Collapse'),
                  ),
                  TextButton(
                    key: const Key('actions_toggle'),
                    onPressed: () => actions.toggle(),
                    child: const Text('Toggle'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      hostSize: const Size(320, 320),
    );
  }
}

class _ControlledPulseActionsHarness extends StatefulWidget {
  const _ControlledPulseActionsHarness();

  @override
  State<_ControlledPulseActionsHarness> createState() =>
      _ControlledPulseActionsHarnessState();
}

class _ControlledPulseActionsHarnessState
    extends State<_ControlledPulseActionsHarness>
    with SingleTickerProviderStateMixin {
  late final ElasticSheetController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ElasticSheetController(vsync: this, config: _fastConfig);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildHarness(
      ElasticSheet.controlled(
        controller: _controller,
        contentState: ElasticSheetContentState.pending,
        collapsedSize: _actionCollapsedSize,
        collapsedChild: Builder(
          builder: (context) {
            return Center(
              child: TextButton(
                key: const Key('actions_pulse'),
                onPressed: () => ElasticSheetActions.of(context).pulse(),
                child: const Text('Pulse'),
              ),
            );
          },
        ),
      ),
      hostSize: const Size(320, 320),
    );
  }
}

Widget _buildHarness(Widget child, {Size hostSize = const Size(300, 300)}) {
  return MaterialApp(
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          key: _hostKey,
          width: hostSize.width,
          height: hostSize.height,
          child: child,
        ),
      ),
    ),
  );
}

ElasticSheet _buildSurface({
  required bool isExpanded,
  ElasticSheetAnchor? anchor,
  ElasticSheetOrigin origin = ElasticSheetOrigin.bottom,
  ElasticSheetConfig config = const ElasticSheetConfig(),
}) {
  return ElasticSheet(
    isExpanded: isExpanded,
    anchor: anchor,
    origin: origin,
    config: config,
    collapsedSize: _collapsedSize,
    expandedSize: _expandedSize,
    collapsedChild: const Text('Open'),
    expandedChild: _buildShortExpandedChild(),
  );
}

Widget _buildShortExpandedChild() {
  return const SizedBox(
    height: 120,
    width: double.infinity,
    child: ColoredBox(color: Colors.orange),
  );
}

Widget _buildTallExpandedChild() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(
      4,
      (_) => const SizedBox(
        height: 100,
        width: double.infinity,
        child: ColoredBox(color: Colors.blue),
      ),
    ),
  );
}

void _expectPinnedCorner(
  ElasticSheetAnchor anchor,
  Rect surfaceRect,
  Rect hostRect,
) {
  switch (anchor) {
    case ElasticSheetAnchor.topLeft:
      expect(surfaceRect.left, closeTo(hostRect.left, 0.01));
      expect(surfaceRect.top, closeTo(hostRect.top, 0.01));
      return;
    case ElasticSheetAnchor.topRight:
      expect(surfaceRect.right, closeTo(hostRect.right, 0.01));
      expect(surfaceRect.top, closeTo(hostRect.top, 0.01));
      return;
    case ElasticSheetAnchor.bottomLeft:
      expect(surfaceRect.left, closeTo(hostRect.left, 0.01));
      expect(surfaceRect.bottom, closeTo(hostRect.bottom, 0.01));
      return;
    case ElasticSheetAnchor.bottomRight:
      expect(surfaceRect.right, closeTo(hostRect.right, 0.01));
      expect(surfaceRect.bottom, closeTo(hostRect.bottom, 0.01));
      return;
    case ElasticSheetAnchor.topCenter:
    case ElasticSheetAnchor.centerLeft:
    case ElasticSheetAnchor.center:
    case ElasticSheetAnchor.centerRight:
    case ElasticSheetAnchor.bottomCenter:
      throw ArgumentError.value(anchor, 'anchor', 'Expected a corner anchor.');
  }
}

Rect _hostRect(WidgetTester tester) {
  return tester.getRect(find.byKey(_hostKey));
}

Rect _surfaceRect(WidgetTester tester) {
  return tester.getRect(find.byType(ClipRRect));
}

Size _surfaceSize(WidgetTester tester) {
  return tester.getSize(find.byType(ClipRRect));
}

double _surfaceTopOffset(WidgetTester tester) {
  final hostTopLeft = tester.getTopLeft(find.byKey(_hostKey));
  final surfaceTopLeft = tester.getTopLeft(find.byType(ClipRRect));
  return surfaceTopLeft.dy - hostTopLeft.dy;
}

double _surfaceLeftOffset(WidgetTester tester) {
  final hostTopLeft = tester.getTopLeft(find.byKey(_hostKey));
  final surfaceTopLeft = tester.getTopLeft(find.byType(ClipRRect));
  return surfaceTopLeft.dx - hostTopLeft.dx;
}
