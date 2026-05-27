# elastic_sheet

[![pub version](https://img.shields.io/pub/v/elastic_sheet.svg)](https://pub.dev/packages/elastic_sheet)
[![likes](https://img.shields.io/pub/likes/elastic_sheet)](https://pub.dev/packages/elastic_sheet)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

<p align="center">
  <img src="https://raw.githubusercontent.com/Abdualsslam/elastic_sheet/main/doc/Care%20Desk%20showcase.gif" alt="Care Desk showcase" height="450" />
</p>

`elastic_sheet` is a Flutter widget for building realistic expand/collapse surfaces with a liquid spring feel.

It is designed for inline actions, drawers, search affordances, composer bars, and other UI pieces that should feel like one surface stretching into another, not a modal abruptly appearing on top.

## Showcase

| Feature | Description | Preview |
| :--- | :--- | :---: |
| **Spring Presets** | Completely configurable spring physics, ranging from snappy drawer snaps to gentle floating surfaces. | <img src="https://raw.githubusercontent.com/Abdualsslam/elastic_sheet/main/doc/presets.gif" width="220" alt="Presets" /> |
| **Anchor (Compact)** | 9-point anchor system allows components to expand naturally from corners and edges without disrupting layout. | <img src="https://raw.githubusercontent.com/Abdualsslam/elastic_sheet/main/doc/anchor%20compact.gif" width="220" alt="Anchor Compact" /> |
| **Anchor (Grid)** | Maintains layout integrity for multi-directional expansions, ideal for grids, cards, and complex responsive blocks. | <img src="https://raw.githubusercontent.com/Abdualsslam/elastic_sheet/main/doc/anchor%20grid.gif" width="220" alt="Anchor Grid" /> |

## Features

- Declarative API with `isExpanded`
- Controller-based API with `ElasticSheetController`
- Configurable spring tuning via `ElasticSheetConfig`
- Optional rebound profiles, including a sequential cross-axis stretch
- 9-point anchors for fixed-size expansion, from `topLeft` to `bottomRight`
- Content states for `ready`, `pending`, and `unavailable`
- Legacy `top`, `center`, and `bottom` origins still supported
- Fixed and measured dynamic expanded sizing
- Runnable example app under [`example/`](example)

## Installation

```yaml
dependencies:
  elastic_sheet: ^0.2.0
```

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:elastic_sheet/elastic_sheet.dart';

class DemoCard extends StatefulWidget {
  const DemoCard({super.key});

  @override
  State<DemoCard> createState() => _DemoCardState();
}

class _DemoCardState extends State<DemoCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: ElasticSheet(
        isExpanded: _isExpanded,
        anchor: ElasticSheetAnchor.bottomCenter,
        config: const ElasticSheetConfig.gentle(),
        collapsedSize: const Size(220, 52),
        expandedSize: const Size(320, 320),
        expandedSizing: ElasticSheetExpandedSizing.dynamicHeight,
        collapsedChild: const Center(child: Text('Open')),
        expandedChild: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Expanded content'),
        ),
      ),
    );
  }
}
```

## Controller API

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

Then use:

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

You can also opt into a more natural late-stage rebound:

```dart
const config = ElasticSheetConfig.natural();
```

## Partial Triggers

`ElasticSheet.controlled` injects `ElasticSheetActions` around its collapsed
and expanded content. That lets any descendant open, close, toggle, or pulse
the surface without turning the whole `collapsedChild` into one large button.

```dart
ElasticSheet.controlled(
  controller: controller,
  anchor: ElasticSheetAnchor.bottomCenter,
  collapsedSize: const Size(320, 56),
  expandedSize: const Size(320, 220),
  collapsedChild: Builder(
    builder: (context) => Row(
      children: [
        Expanded(child: TextField(controller: draftController)),
        IconButton(
          onPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();
            ElasticSheetActions.of(context).expand();
          },
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    ),
  ),
  expandedChild: const Text('Composer actions'),
)
```

## Anchors

Use `anchor` to keep a specific edge or corner fixed while the surface grows:

```dart
ElasticSheet(
  isExpanded: _open,
  anchor: ElasticSheetAnchor.topRight,
  collapsedSize: const Size(180, 48),
  expandedSize: const Size(320, 280),
  collapsedChild: const Text('Filters'),
  expandedChild: const Text('Expanded content'),
)
```

For `ElasticSheetExpandedSizing.dynamicHeight`, the horizontal part of the
anchor is ignored so `topLeft` and `topRight` both behave like `topCenter`,
and the same applies to the `center` and `bottom` rows.

## Content States

Use `contentState` when a collapsed surface does not always have expanded data.

```dart
ElasticSheet(
  isExpanded: false,
  contentState: ElasticSheetContentState.pending,
  collapsedSize: const Size(180, 48),
  collapsedChild: const Text('Waiting for slot data'),
  onPendingTap: _reloadSlots,
)
```

- `ready`: normal expand/collapse behavior. `expandedSize` and `expandedChild` are required.
- `pending`: no expanded content yet. The surface stays collapsed and plays a subtle pulse on tap.
- `unavailable`: visible but disabled. No pulse and no expansion.

## Example app

The runnable showcase lives in [`example/`](example). It contains the playground plus several realistic scenarios that import the package exactly as an external consumer would.

