/// Controls how the late-stage rebound is distributed across axes.
enum ElasticSheetReboundProfile {
  /// Keep the existing simultaneous rebound behavior.
  simultaneous,

  /// Rebound one axis first, then transfer tension to the cross-axis.
  sequentialCrossAxis,
}

/// All parameters that control the liquid spring animation.
///
/// Use the named constructors for sensible presets, or fine-tune
/// every value yourself.
class ElasticSheetConfig {
  /// Controls how fast the spring pulls toward the target.
  /// Higher = snappier.  Range: 50-500.  Default: 220.
  final double stiffness;

  /// Controls how quickly oscillation dies out.
  /// Lower = more bouncy.  Range: 5-40.  Default: 18.
  final double damping;

  /// Virtual mass on the spring.
  /// Higher = heavier feel, slower peak velocity.  Default: 1.0.
  final double mass;

  /// Maximum allowed overshoot as a fraction of the target size.
  /// 1.03 = 3% past target.  Set to 1.0 to disable overshoot.
  final double overshootClamp;

  /// Amplitude of the liquid stretch pulse on the horizontal axis.
  /// Default: 0.028.
  final double horizontalStretchAmplitude;

  /// Amplitude of the liquid stretch pulse on the vertical axis.
  /// Default: 0.065.
  final double verticalStretchAmplitude;

  /// Duration of the expand animation.
  final Duration expandDuration;

  /// Duration of the collapse animation.
  final Duration collapseDuration;

  /// Shapes how the late rebound is distributed across the two axes.
  final ElasticSheetReboundProfile reboundProfile;

  const ElasticSheetConfig({
    this.stiffness = 220,
    this.damping = 18,
    this.mass = 1.0,
    this.overshootClamp = 1.03,
    this.horizontalStretchAmplitude = 0.028,
    this.verticalStretchAmplitude = 0.065,
    this.expandDuration = const Duration(milliseconds: 600),
    this.collapseDuration = const Duration(milliseconds: 600),
    this.reboundProfile = ElasticSheetReboundProfile.simultaneous,
  });

  /// Gentle - subtle overshoot, soft feel.
  const ElasticSheetConfig.gentle()
    : stiffness = 160,
      damping = 22,
      mass = 1.0,
      overshootClamp = 1.02,
      horizontalStretchAmplitude = 0.018,
      verticalStretchAmplitude = 0.040,
      expandDuration = const Duration(milliseconds: 700),
      collapseDuration = const Duration(milliseconds: 600),
      reboundProfile = ElasticSheetReboundProfile.simultaneous;

  /// Bouncy - exaggerated overshoot, playful feel.
  const ElasticSheetConfig.bouncy()
    : stiffness = 280,
      damping = 12,
      mass = 1.2,
      overshootClamp = 1.08,
      horizontalStretchAmplitude = 0.040,
      verticalStretchAmplitude = 0.090,
      expandDuration = const Duration(milliseconds: 550),
      collapseDuration = const Duration(milliseconds: 500),
      reboundProfile = ElasticSheetReboundProfile.simultaneous;

  /// Snappy - fast, minimal overshoot, utilitarian.
  const ElasticSheetConfig.snappy()
    : stiffness = 380,
      damping = 28,
      mass = 0.8,
      overshootClamp = 1.01,
      horizontalStretchAmplitude = 0.010,
      verticalStretchAmplitude = 0.025,
      expandDuration = const Duration(milliseconds: 400),
      collapseDuration = const Duration(milliseconds: 380),
      reboundProfile = ElasticSheetReboundProfile.simultaneous;

  /// Natural - a softer cross-axis transfer that feels more elastic.
  const ElasticSheetConfig.natural()
    : stiffness = 210,
      damping = 20,
      mass = 1.0,
      overshootClamp = 1.04,
      horizontalStretchAmplitude = 0.024,
      verticalStretchAmplitude = 0.055,
      expandDuration = const Duration(milliseconds: 640),
      collapseDuration = const Duration(milliseconds: 540),
      reboundProfile = ElasticSheetReboundProfile.sequentialCrossAxis;

  ElasticSheetConfig copyWith({
    double? stiffness,
    double? damping,
    double? mass,
    double? overshootClamp,
    double? horizontalStretchAmplitude,
    double? verticalStretchAmplitude,
    Duration? expandDuration,
    Duration? collapseDuration,
    ElasticSheetReboundProfile? reboundProfile,
  }) {
    return ElasticSheetConfig(
      stiffness: stiffness ?? this.stiffness,
      damping: damping ?? this.damping,
      mass: mass ?? this.mass,
      overshootClamp: overshootClamp ?? this.overshootClamp,
      horizontalStretchAmplitude:
          horizontalStretchAmplitude ?? this.horizontalStretchAmplitude,
      verticalStretchAmplitude:
          verticalStretchAmplitude ?? this.verticalStretchAmplitude,
      expandDuration: expandDuration ?? this.expandDuration,
      collapseDuration: collapseDuration ?? this.collapseDuration,
      reboundProfile: reboundProfile ?? this.reboundProfile,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ElasticSheetConfig &&
          stiffness == other.stiffness &&
          damping == other.damping &&
          mass == other.mass &&
          overshootClamp == other.overshootClamp &&
          horizontalStretchAmplitude == other.horizontalStretchAmplitude &&
          verticalStretchAmplitude == other.verticalStretchAmplitude &&
          expandDuration == other.expandDuration &&
          collapseDuration == other.collapseDuration &&
          reboundProfile == other.reboundProfile;

  @override
  int get hashCode => Object.hash(
    stiffness,
    damping,
    mass,
    overshootClamp,
    horizontalStretchAmplitude,
    verticalStretchAmplitude,
    expandDuration,
    collapseDuration,
    reboundProfile,
  );

  @override
  String toString() =>
      'ElasticSheetConfig('
      'stiffness: $stiffness, '
      'damping: $damping, '
      'mass: $mass, '
      'overshootClamp: $overshootClamp, '
      'hStretch: $horizontalStretchAmplitude, '
      'vStretch: $verticalStretchAmplitude, '
      'expand: ${expandDuration.inMilliseconds}ms, '
      'collapse: ${collapseDuration.inMilliseconds}ms, '
      'rebound: $reboundProfile)';
}
