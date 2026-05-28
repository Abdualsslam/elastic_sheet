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
const String playgroundStiffnessDescriptionText =
    'Controls how strong the spring is. Higher values make the sheet move faster and snap more firmly.';
const String playgroundDampingDescriptionText =
    'Controls how quickly the spring settles. Lower values feel bouncier; higher values feel calmer.';
const String playgroundMassDescriptionText =
    'Controls the perceived weight of the surface. Higher mass makes the motion feel heavier and slower.';
const String playgroundOvershootDescriptionText =
    'Limits how far the surface can stretch beyond its target. Small overshoot adds a liquid feel without breaking layout.';
const String playgroundExpandedWidthDescriptionText =
    'The target width used when the sheet opens.';
const String playgroundExpandedHeightDescriptionText =
    'The target height used when the sheet opens.';
const String playgroundExpandDescriptionText =
    'The maximum animation time used when the sheet expands. The spring still controls the feel of the movement.';
const String playgroundCollapseDescriptionText =
    'The maximum animation time used when the sheet collapses back to the compact state.';
const String playgroundButtonWidthDescriptionText =
    'The width of the collapsed ElasticSheet surface before expansion.';
const String playgroundButtonHeightDescriptionText =
    'The height of the collapsed ElasticSheet surface before expansion.';
const String playgroundPlacementDescriptionText =
    'Controls where the collapsed surface is placed inside the preview stage: top, center, or bottom.';
const String playgroundCloseDialogText = 'Close';
const String playgroundReboundDescriptionText =
    'Controls how the stretch returns after expansion or collapse. Simultaneous rebounds both axes together; sequential cross-axis feels more organic.';
const String playgroundAnchorDescriptionText =
    'Defines which edge or corner stays visually pinned while the sheet grows. This makes components expand naturally from their original position.';
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
