# Changelog

## 0.2.0

### Performance
* **ElasticSheetActions** no longer extends `InheritedNotifier`; descendants
  that call `ElasticSheetActions.of(context)` are no longer rebuilt every
  animation frame.
* Invisible collapsed/expanded children are now skipped entirely during
  rendering instead of being drawn at zero opacity.
* Scoped child widgets are cached and reused across animation frames.

### Bug Fixes
* Fixed potential crash when disposing `ElasticSheetController` during an
  active `pulse()` animation.
* `_RenderSizeReporter` now captures the callback reference before scheduling
  a post-frame callback, preventing stale-reference issues.
* Removed redundant `BoxDecoration.lerp` call with a constant factor of `1.0`
  in the pending-state decoration builder.

### API Improvements
* `expand()`, `collapse()`, and `toggle()` now return `TickerFuture` instead
  of `Future<void>`, enabling `.orCancel` support.
* Added `toString()` to `ElasticSheetConfig` for better debugging output.
* Documented all empirical timing constants in `ElasticSheetMotion` with
  named constants and explanatory comments.

## 0.1.2

* Updated `example/lib/main.dart` with comprehensive documentation and showcase details.

## 0.1.1

* Initial public release.

## 0.1.0

- Initial public package structure for `elastic_sheet`
- Added runnable `example/` app that consumes the package through `package:elastic_sheet/elastic_sheet.dart`
- Added realistic showcase scenarios and playground examples under `example/`
- Added package tests for fixed and dynamic expansion behavior
