# Elastic Sheet

[![pub version](https://img.shields.io/pub/v/elastic_sheet.svg)](https://pub.dev/packages/elastic_sheet)
[![likes](https://img.shields.io/pub/likes/elastic_sheet)](https://pub.dev/packages/elastic_sheet)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A physics-driven Flutter surface that expands from its own anchor with liquid spring motion. Build compact buttons, floating action panels, composer bars, filters, checkout sections, and adaptive surfaces that grow in-place instead of opening as disconnected modals.

<p align="center">
  <a href="https://abdualsslam.github.io/elastic_sheet/"><strong>Open Live Demo</strong></a>
  ·
  <a href="https://github.com/Abdualsslam/elastic_sheet/tree/main/example">Example Source</a>
  ·
  <a href="https://pub.dev/packages/elastic_sheet">pub.dev</a>
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/Abdualsslam/elastic_sheet/main/doc/Care%20Desk%20showcase.gif" alt="Care Desk showcase" height="450" />
</p>

## Live Demo

Try the interactive Elastic Sheet Playground directly in your browser:

[Open Live Demo](https://abdualsslam.github.io/elastic_sheet/)

The demo is powered by the same Flutter example app under:

```text
example/lib/src/elastic_sheet_playground.dart
```

It lets you tune stiffness, damping, mass, overshoot, durations, rebound profile, anchors, placement, and collapsed/expanded sizes while seeing the result instantly.

## Showcase

| Feature | Description | Preview |
| :--- | :--- | :---: |
| **Spring Presets** | Switch between tuned motion profiles from gentle to snappy. | <img src="https://raw.githubusercontent.com/Abdualsslam/elastic_sheet/main/doc/presets.gif" width="220" alt="Presets" /> |
| **Anchor (Compact)** | Expand naturally from corners, edges, or center without disrupting the surrounding UI. | <img src="https://raw.githubusercontent.com/Abdualsslam/elastic_sheet/main/doc/anchor%20compact.gif" width="220" alt="Anchor Compact" /> |
| **Anchor (Grid)** | Keep complex layouts visually stable while surfaces grow from their original position. | <img src="https://raw.githubusercontent.com/Abdualsslam/elastic_sheet/main/doc/anchor%20grid.gif" width="220" alt="Anchor Grid" /> |

## Features

- Expand from any of 9 anchors: corners, edges, or center.
- Spring-based motion with configurable stiffness, damping, mass, and overshoot.
- Built-in motion presets: gentle, bouncy, natural, and snappy.
- Fixed or dynamic expanded sizing.
- Declarative `isExpanded` API.
- Controller-based API through `ElasticSheetController`.
- Partial child actions through `ElasticSheetActions`.
- Content states for ready, pending, and unavailable surfaces.
- Production-style example app and browser playground.

## Installation

```yaml
dependencies:
  elastic_sheet: ^0.2.0
```

## Usage

```dart
ElasticSheet(
  isExpanded: isExpanded,
  anchor: ElasticSheetAnchor.bottomCenter,
  config: const ElasticSheetConfig.natural(),
  collapsedSize: const Size(220, 52),
  expandedSize: const Size(320, 280),
  collapsedChild: const Center(child: Text('Open')),
  expandedChild: const Padding(
    padding: EdgeInsets.all(20),
    child: Text('Expanded content'),
  ),
)
```

## Controller API

Use `ElasticSheetController` when the surface should be opened, closed, toggled, or pulsed from outside the widget.

```dart
late final ElasticSheetController controller;

@override
void initState() {
  super.initState();
  controller = ElasticSheetController(
    vsync: this,
    config: const ElasticSheetConfig.snappy(),
  );
}

@override
void dispose() {
  controller.dispose();
  super.dispose();
}
```

Then render a controlled sheet:

```dart
ElasticSheet.controlled(
  controller: controller,
  anchor: ElasticSheetAnchor.centerRight,
  collapsedSize: const Size(220, 52),
  expandedSize: const Size(320, 320),
  collapsedChild: const Text('Compose'),
  expandedChild: const Text('Composer panel'),
)
```

## Anchors

Use `anchor` to keep a specific edge or corner fixed while the surface grows:

```dart
ElasticSheet(
  isExpanded: isOpen,
  anchor: ElasticSheetAnchor.topRight,
  collapsedSize: const Size(180, 48),
  expandedSize: const Size(320, 280),
  collapsedChild: const Text('Filters'),
  expandedChild: const Text('Expanded content'),
)
```

For `ElasticSheetExpandedSizing.dynamicHeight`, the horizontal part of the anchor is normalized to the center column, so `topLeft` and `topRight` behave like `topCenter`.

## Partial Triggers

`ElasticSheet.controlled` injects `ElasticSheetActions` around collapsed and expanded content. Any descendant can open, close, toggle, or pulse the surface without turning the whole child into one large button.

```dart
ElasticSheet.controlled(
  controller: controller,
  anchor: ElasticSheetAnchor.bottomCenter,
  collapsedSize: const Size(320, 56),
  expandedSize: const Size(320, 220),
  collapsedChild: Builder(
    builder: (context) => Row(
      children: [
        const Expanded(child: TextField()),
        IconButton(
          onPressed: () => ElasticSheetActions.of(context).expand(),
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    ),
  ),
  expandedChild: const Text('Composer actions'),
)
```

## Content States

Use `contentState` when a collapsed surface does not always have expanded data.

```dart
ElasticSheet(
  isExpanded: false,
  contentState: ElasticSheetContentState.pending,
  collapsedSize: const Size(180, 48),
  collapsedChild: const Text('Waiting for slot data'),
  onPendingTap: reloadSlots,
)
```

- `ready`: normal expand/collapse behavior. `expandedSize` and `expandedChild` are required.
- `pending`: no expanded content yet. The surface stays collapsed and plays a subtle pulse on tap.
- `unavailable`: visible but disabled. No pulse and no expansion.

## Example App

The runnable showcase lives in [`example/`](example). It imports `elastic_sheet` the same way a package consumer would and includes:

- Interactive playground with live spring controls.
- Responsive browser demo for GitHub Pages.
- Care Desk unified showcase.
- Checkout showcase.

Run it locally:

```bash
cd example
flutter run -d chrome
```

## Deploy Live Demo

The GitHub Pages workflow builds the example app with:

```bash
cd example
flutter build web --release --base-href "/elastic_sheet/"
```

In GitHub repository settings, configure Pages to use **GitHub Actions** as the source. The workflow publishes `example/build/web`.

## License

MIT. See [LICENSE](LICENSE).
