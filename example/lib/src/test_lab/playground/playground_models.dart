import 'package:elastic_sheet/elastic_sheet.dart';

enum PlaygroundPlacement { top, center, bottom }

const List<List<ElasticSheetAnchor>> playgroundAnchorGrid = [
  [
    ElasticSheetAnchor.topLeft,
    ElasticSheetAnchor.topCenter,
    ElasticSheetAnchor.topRight,
  ],
  [
    ElasticSheetAnchor.centerLeft,
    ElasticSheetAnchor.center,
    ElasticSheetAnchor.centerRight,
  ],
  [
    ElasticSheetAnchor.bottomLeft,
    ElasticSheetAnchor.bottomCenter,
    ElasticSheetAnchor.bottomRight,
  ],
];

enum PlaygroundChangedProp {
  stiffness,
  damping,
  mass,
  overshootClamp,
  expandDuration,
  collapseDuration,
  reboundProfile,
  anchor,
}

const String playgroundCollapsedLabelText = 'Order Details';
const String playgroundExpandedHeadingText = 'Account Information';
const String playgroundConfirmPaymentText = 'Confirm Payment';
const String playgroundOvershootDescriptionText =
    'Defines the overshoot clamp amplitude during the spring transition. Raising it yields extra stretch.';
const String playgroundExpandedWidthDescriptionText =
    'Defines the expanded width of the sheet.';
const String playgroundExpandedHeightDescriptionText =
    'Defines the expanded height of the sheet.';
const String playgroundExpandDescriptionText =
    'Duration of the expansion animation in milliseconds.';
const String playgroundCollapseDescriptionText =
    'Duration of the collapse animation in milliseconds.';
const String playgroundButtonWidthDescriptionText =
    'Controls the collapsed width (button width) in the preview.';
const String playgroundButtonHeightDescriptionText =
    'Controls the collapsed height (button height) in the preview.';
const String playgroundPlacementDescriptionText =
    'Defines the layout placement of the sheet within the screen.';
const String playgroundCloseDialogText = 'Close';
const String playgroundReboundDescriptionText =
    'Choose how the late rebound travels across the surface. Sequential cross-axis transfers tension vertically first on open, then horizontally, and reverses the order on collapse.';
const String playgroundAnchorDescriptionText =
    'Choose the edge or corner that stays pinned while the surface grows. In dynamicHeight, the horizontal part collapses back to the center column.';
const String playgroundAnchorFootnoteText =
    'Combined corner anchors matter in fixed sizing. Dynamic height keeps only the vertical row.';

String playgroundAnchorLabel(ElasticSheetAnchor anchor) {
  switch (anchor) {
    case ElasticSheetAnchor.topLeft:
      return 'TL';
    case ElasticSheetAnchor.topCenter:
      return 'T';
    case ElasticSheetAnchor.topRight:
      return 'TR';
    case ElasticSheetAnchor.centerLeft:
      return 'L';
    case ElasticSheetAnchor.center:
      return 'C';
    case ElasticSheetAnchor.centerRight:
      return 'R';
    case ElasticSheetAnchor.bottomLeft:
      return 'BL';
    case ElasticSheetAnchor.bottomCenter:
      return 'B';
    case ElasticSheetAnchor.bottomRight:
      return 'BR';
  }
}
