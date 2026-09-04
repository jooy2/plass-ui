/// The defaults an application sets once, and every widget reads.
///
/// **What is in here is decided by one rule: an axis belongs to the application
/// or it belongs to the widget.** [size] and [density] are the application's — a
/// product that is compact is compact everywhere, and repeating
/// `size: PlassSize.sm` at four hundred call sites is not a design decision, it
/// is transcription. [color] is the application's for the same reason, one step
/// weaker: a brand whose primary family is `secondary` says so once. The date
/// vocabulary is here because a Korean application names its words once rather
/// than on five pickers.
///
/// `variant` and `elevation` are **not** here, and their absence is the load
/// bearing part:
///
/// - `variant` names what a surface is *made of*, and the design language spends
///   its first paragraph on the fact that a pressed thing and a thing that holds
///   content are different materials. A button defaults to `solid` and a card to
///   `glass` because that is the arrangement, not because nobody got round to
///   configuring it. One value for both is not a default, it is a flattening.
/// - `elevation` is per-widget semantics for the same reason: a control rests
///   **on** the sheet and defaults to `1`, a field is cut **into** it and
///   defaults to `0`. A single number for the two says the opposite of what the
///   ladder means.
///
/// A caller who genuinely wants every button glass writes it on the buttons.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/date.dart';
import 'package:plass_ui/src/types.dart';

/// Everything a [PlassTheme] can decide for the subtree under it.
@immutable
class PlassDefaults {
  /// Creates a set of defaults. Every field is optional — nothing is decided
  /// until something decides it.
  const PlassDefaults({
    this.size,
    this.color,
    this.density,
    this.names,
    this.labels,
    this.weekStartsOn,
  });

  /// Nothing decided. The value every widget falls through to its own default
  /// from.
  static const PlassDefaults none = PlassDefaults();

  /// The rung of the size ladder every widget starts from.
  final PlassSize? size;

  /// The semantic family they start from.
  final PlassColor? color;

  /// How tightly they pack their content.
  final PlassDensity? density;

  /// The words the date widgets draw — the months, the weekdays.
  final PlDateNames? names;

  /// The words the widgets say about themselves — the steppers, the headings,
  /// the landmark every assistive technology reads a region by.
  final PlassLabels? labels;

  /// Which day their weeks start on.
  final PlassWeekday? weekStartsOn;

  /// This set with [other]'s answers filling in the ones it did not give.
  ///
  /// Merged by field rather than by replacing the object wholesale, so a nested
  /// theme that only says `density` does not silently take the application's
  /// `names` away from everything under it.
  PlassDefaults merge(PlassDefaults other) {
    return PlassDefaults(
      size: size ?? other.size,
      color: color ?? other.color,
      density: density ?? other.density,
      names: names ?? other.names,
      labels: labels ?? other.labels,
      weekStartsOn: weekStartsOn ?? other.weekStartsOn,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PlassDefaults &&
        other.size == size &&
        other.color == color &&
        other.density == density &&
        other.names == names &&
        other.labels == labels &&
        other.weekStartsOn == weekStartsOn;
  }

  @override
  int get hashCode => Object.hash(size, color, density, names, labels, weekStartsOn);
}
