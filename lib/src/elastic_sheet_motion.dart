import 'dart:math' as math;

import 'package:flutter/animation.dart';

import 'elastic_sheet_config.dart';

/// Axis identifier for per-axis motion calculations.
enum ElasticSheetAxis { horizontal, vertical }

/// Pure-function motion math for [ElasticSheet].
///
/// Every constant below was tuned empirically to approximate the feel of a
/// critically-damped spring with a deliberate liquid-stretch overshoot.
/// The naming convention groups them by the motion phase they belong to.
class ElasticSheetMotion {
  const ElasticSheetMotion._();

  // ─── Axis-progress timing windows ──────────────────────────────
  // These [begin, end] pairs define *when* each axis starts and
  // finishes its base interpolation within the [0..1] animation.
  // Horizontal starts slightly later to create a staggered feel.

  static const double _hExpandStart = 0.10;
  static const double _hExpandEnd = 0.88;
  static const double _vExpandStart = 0.05;
  static const double _vExpandEnd = 0.74;

  static const double _hCollapseStart = 0.0;
  static const double _hCollapseEnd = 1.0;
  static const double _vCollapseStart = 0.1;
  static const double _vCollapseEnd = 0.93;

  // ─── Anticipation timing ───────────────────────────────────────
  // A brief backward motion before expansion, like a jump windup.

  static const double _hAnticipationEnd = 0.16;
  static const double _vAnticipationEnd = 0.18;

  // ─── Stretch-pulse timing ──────────────────────────────────────
  // The liquid stretch appears in the second half of the motion.

  static const double _stretchExpandStart = 0.52;
  static const double _stretchExpandEnd = 0.90;
  static const double _stretchCollapseStart = 0.10;
  static const double _stretchCollapseEnd = 0.52;

  // ─── Envelope exponents ────────────────────────────────────────
  // Control how quickly oscillation energy dissipates.
  // Higher exponent = faster decay.

  /// Main stretch envelope decay rate.
  static const double _stretchDecay = 1.35;

  /// Secondary recoil oscillation decay rate.
  static const double _recoilDecay = 2.1;

  /// Anticipation pulse envelope decay rate.
  static const double _anticipationDecay = 1.4;

  /// Damped pulse envelope decay rate (used for radius and edge).
  static const double _dampedPulseDecay = 1.6;

  // ─── Recoil mix ratio ──────────────────────────────────────────
  // How much the secondary recoil wave contributes relative to main.

  static const double _hRecoilMix = 0.21;
  static const double _vRecoilMix = 0.15;

  // ─── Overshoot settle ──────────────────────────────────────────
  // Secondary settle pass that pulls the overshoot back toward rest.

  static const double _settleStart = 0.58;
  static const double _settleRatio = 0.18;

  // ─── Sequential rebound timing ─────────────────────────────────
  // Phase windows for the cross-axis sequential rebound profile.

  static const double _reboundFirstStart = 0.56;
  static const double _reboundFirstEnd = 0.78;
  static const double _reboundSecondStart = 0.74;
  static const double _reboundSecondEnd = 0.98;

  // ─── Horizontal damping for simultaneous rebound ───────────────
  // The horizontal axis receives less rebound than vertical to
  // avoid the surface looking like it's "breathing" side-to-side.

  static const double _hSimultaneousReboundDamping = 0.45;

  // ─── Clamp bounds ──────────────────────────────────────────────
  // Prevent per-axis rebound from exceeding reasonable visual limits.

  static const double _reboundScaleMin = 0.88;
  static const double _reboundScaleMax = 1.12;

  /// Maximum anticipation dip before the expansion begins.
  static const double _maxAnticipation = -0.05;

  // ─── Overshoot amplitude mapping ───────────────────────────────

  static double overshootAmplitudeForClamp(double overshootClamp) {
    if (overshootClamp <= 1.0) {
      return 0.0;
    }
    return ((overshootClamp - 1.0) * 3.0).clamp(0.0, 0.18);
  }

  // ─── Main axis progress ────────────────────────────────────────

  static double axisProgress(
    double progress, {
    required bool isCollapsing,
    required ElasticSheetAxis axis,
    required ElasticSheetConfig config,
  }) {
    final isHorizontal = axis == ElasticSheetAxis.horizontal;

    final base = isCollapsing
        ? segment(
            progress,
            begin: isHorizontal ? _hCollapseStart : _vCollapseStart,
            end: isHorizontal ? _hCollapseEnd : _vCollapseEnd,
            curve: Curves.easeInOutCubic,
          )
        : segment(
            progress,
            begin: isHorizontal ? _hExpandStart : _vExpandStart,
            end: isHorizontal ? _hExpandEnd : _vExpandEnd,
            curve: Curves.easeOutCubic,
          );

    final anticipation = isCollapsing
        ? 0.0
        : _anticipationPulse(
            segment(
              progress,
              begin: 0.0,
              end: isHorizontal ? _hAnticipationEnd : _vAnticipationEnd,
              curve: Curves.easeOutCubic,
            ),
            amplitude: _anticipationAmplitude(axis: axis, config: config),
          );

    final stretchProgress = isCollapsing
        ? segment(
            1 - progress,
            begin: _stretchCollapseStart,
            end: _stretchCollapseEnd,
            curve: Curves.easeOutCubic,
          )
        : segment(
            progress,
            begin: _stretchExpandStart,
            end: _stretchExpandEnd,
            curve: Curves.easeOutCubic,
          );

    final stretch = _liquidStretchPulse(
      stretchProgress,
      isHorizontal: isHorizontal,
      isCollapsing: isCollapsing,
      config: config,
    );

    return (base + anticipation + stretch).clamp(
      isCollapsing ? 0.0 : _maxAnticipation,
      config.overshootClamp,
    );
  }

  // ─── Overshoot pulse ───────────────────────────────────────────

  static double overshootPulse(
    double progress, {
    double pulseStart = 0.55,
    double amplitude = 0.09,
  }) {
    final t = segment(
      progress,
      begin: pulseStart,
      end: 1.0,
      curve: Curves.easeOutCubic,
    );
    if (t <= 0) {
      return 1.0;
    }
    final main = math.sin(t * math.pi) * amplitude;
    final settleT = segment(
      t,
      begin: _settleStart,
      end: 1.0,
      curve: Curves.easeOutCubic,
    );
    final settle = math.sin(settleT * math.pi) * amplitude * _settleRatio;
    return 1.0 + main - settle;
  }

  // ─── Axis rebound scale ────────────────────────────────────────

  static double axisReboundScale(
    double progress, {
    required ElasticSheetAxis axis,
    required bool isCollapsing,
    required ElasticSheetConfig config,
  }) {
    if (config.reboundProfile == ElasticSheetReboundProfile.simultaneous) {
      if (isCollapsing) {
        return 1.0;
      }

      final pulse = overshootPulse(
        progress,
        amplitude: overshootAmplitudeForClamp(config.overshootClamp),
      );

      if (axis == ElasticSheetAxis.horizontal) {
        return 1.0 + (pulse - 1.0) * _hSimultaneousReboundDamping;
      }

      return pulse;
    }

    // Sequential cross-axis rebound profile.
    final motionProgress = isCollapsing ? 1.0 - progress : progress;
    final primaryAxis = isCollapsing
        ? ElasticSheetAxis.horizontal
        : ElasticSheetAxis.vertical;
    final firstPhase = segment(
      motionProgress,
      begin: _reboundFirstStart,
      end: _reboundFirstEnd,
      curve: Curves.easeInOutCubic,
    );
    final secondPhase = segment(
      motionProgress,
      begin: _reboundSecondStart,
      end: _reboundSecondEnd,
      curve: Curves.easeInOutCubic,
    );
    final activeAxisScale = _phaseReboundMultiplier(
      axis == primaryAxis ? firstPhase : secondPhase,
      amplitude: _activeReboundAmplitude(axis: axis, config: config),
    );
    final counterAxisScale = _counterCompressionMultiplier(
      axis == primaryAxis ? secondPhase : firstPhase,
      amplitude: _counterCompressionAmplitude(axis: axis, config: config),
    );

    return (activeAxisScale * counterAxisScale).clamp(
      _reboundScaleMin,
      _reboundScaleMax,
    );
  }

  // ─── Bottom-edge progress ──────────────────────────────────────

  static double bottomEdgeProgress(
    double progress, {
    required bool isCollapsing,
  }) {
    final base = isCollapsing
        ? segment(progress, begin: 0.04, end: 1.0, curve: Curves.easeInOutCubic)
        : segment(
            progress,
            begin: 0.08,
            end: 0.90,
            curve: Curves.easeInOutCubic,
          );

    final pulseProgress = isCollapsing
        ? segment(
            1 - progress,
            begin: 0.08,
            end: 0.42,
            curve: Curves.easeOutCubic,
          )
        : segment(progress, begin: 0.68, end: 1.0, curve: Curves.easeOutCubic);

    return (base +
            _dampedPulse(
              pulseProgress,
              amplitude: isCollapsing ? 0.004 : 0.010,
            ))
        .clamp(0.0, 1.02);
  }

  // ─── Radius progress ──────────────────────────────────────────

  static double radiusProgress(double progress, {required bool isCollapsing}) {
    final base = segment(
      progress,
      begin: isCollapsing ? 0.18 : 0.24,
      end: isCollapsing ? 1.0 : 0.96,
      curve: Curves.easeInOutCubic,
    );

    final pulseProgress = isCollapsing
        ? segment(
            1 - progress,
            begin: 0.12,
            end: 0.42,
            curve: Curves.easeOutCubic,
          )
        : segment(progress, begin: 0.62, end: 0.94, curve: Curves.easeOutCubic);

    return (base +
            _dampedPulse(
              pulseProgress,
              amplitude: isCollapsing ? 0.006 : 0.018,
            ))
        .clamp(0.0, 1.03);
  }

  // ─── Surface decoration progress ───────────────────────────────

  static double surfaceProgress(double progress, {required bool isCollapsing}) {
    return segment(
      progress,
      begin: isCollapsing ? 0.06 : 0.08,
      end: isCollapsing ? 0.92 : 0.78,
      curve: Curves.easeInOutCubic,
    );
  }

  // ─── Content opacity helpers ───────────────────────────────────

  static double ctaOpacity(double progress) {
    return 1.0 -
        segment(progress, begin: 0.05, end: 0.28, curve: Curves.easeOutCubic);
  }

  static double contentOpacity(double progress, {required bool isCollapsing}) {
    return isCollapsing
        ? segment(progress, begin: 0.68, end: 0.95, curve: Curves.easeOutCubic)
        : segment(progress, begin: 0.48, end: 0.84, curve: Curves.easeOutCubic);
  }

  // ─── Segment utility ──────────────────────────────────────────

  static double segment(
    double value, {
    required double begin,
    required double end,
    required Curve curve,
  }) {
    if (value <= begin) {
      return 0.0;
    }
    if (value >= end) {
      return 1.0;
    }
    return curve.transform((value - begin) / (end - begin));
  }

  // ─── Private helpers ──────────────────────────────────────────

  static double _liquidStretchPulse(
    double progress, {
    required bool isHorizontal,
    required bool isCollapsing,
    required ElasticSheetConfig config,
  }) {
    if (progress <= 0 || progress >= 1) {
      return 0.0;
    }

    final envelope = math.pow(1 - progress, _stretchDecay).toDouble();
    final main = math.sin(progress * math.pi) * envelope;
    final recoil =
        math.sin(progress * math.pi * 2.0) *
        math.pow(1 - progress, _recoilDecay).toDouble();
    final hAmp = config.horizontalStretchAmplitude;
    final vAmp = config.verticalStretchAmplitude;

    if (isCollapsing) {
      return isHorizontal
          ? (main * hAmp) + (recoil * hAmp * _hRecoilMix)
          : -(main * vAmp) - (recoil * vAmp * _vRecoilMix);
    }

    return isHorizontal
        ? -(main * hAmp) - (recoil * hAmp * _hRecoilMix)
        : (main * vAmp) + (recoil * vAmp * _vRecoilMix);
  }

  static double _anticipationAmplitude({
    required ElasticSheetAxis axis,
    required ElasticSheetConfig config,
  }) {
    if (axis == ElasticSheetAxis.horizontal) {
      return math.min(config.horizontalStretchAmplitude * 0.45, 0.016);
    }
    return math.min(config.verticalStretchAmplitude * 0.28, 0.02);
  }

  static double _anticipationPulse(
    double progress, {
    required double amplitude,
  }) {
    if (progress <= 0 || progress >= 1 || amplitude <= 0) {
      return 0.0;
    }
    final envelope = math.pow(1 - progress, _anticipationDecay).toDouble();
    return -math.sin(progress * math.pi) * envelope * amplitude;
  }

  static double _dampedPulse(double progress, {required double amplitude}) {
    if (progress <= 0 || progress >= 1) {
      return 0.0;
    }
    final envelope = math.pow(1 - progress, _dampedPulseDecay).toDouble();
    return math.sin(progress * math.pi) * envelope * amplitude;
  }

  static double _activeReboundAmplitude({
    required ElasticSheetAxis axis,
    required ElasticSheetConfig config,
  }) {
    final overshoot = overshootAmplitudeForClamp(config.overshootClamp);
    if (axis == ElasticSheetAxis.horizontal) {
      return math.min(overshoot * 0.34, 0.045);
    }
    return math.min(overshoot * 0.60, 0.072);
  }

  static double _counterCompressionAmplitude({
    required ElasticSheetAxis axis,
    required ElasticSheetConfig config,
  }) {
    final activeAmplitude = _activeReboundAmplitude(axis: axis, config: config);
    if (axis == ElasticSheetAxis.horizontal) {
      return math.min(activeAmplitude * 0.30, 0.014);
    }
    return math.min(activeAmplitude * 0.26, 0.018);
  }

  static double _phaseReboundMultiplier(
    double progress, {
    required double amplitude,
  }) {
    if (progress <= 0 || progress >= 1 || amplitude <= 0) {
      return 1.0;
    }
    final envelope = math.pow(1.0 - (progress * 0.35), 1.1).toDouble();
    return 1.0 + (math.sin(progress * math.pi) * amplitude * envelope);
  }

  static double _counterCompressionMultiplier(
    double progress, {
    required double amplitude,
  }) {
    if (progress <= 0 || progress >= 1 || amplitude <= 0) {
      return 1.0;
    }
    final envelope = math.pow(1.0 - (progress * 0.28), 1.2).toDouble();
    return 1.0 - (math.sin(progress * math.pi) * amplitude * envelope);
  }
}
