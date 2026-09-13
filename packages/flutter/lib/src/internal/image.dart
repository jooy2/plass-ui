/// The arithmetic a [PlImage] turns its picture with.
///
/// It is here rather than in the widget for the reason `internal/gallery.dart`
/// is: **the React build needs the same answers.** Every function in this file
/// matches one in `internal/image.ts`, and a turn that rounded a stray `45` to a
/// different quarter on the two sides would be one picture lying two different
/// ways.
///
/// It is not exported from `plass_ui.dart`.
library;

/// A turn in degrees as a count of clockwise quarters, whatever number arrived.
///
/// `-90` is the `270` it means, `450` is `90`, anything between two quarters
/// goes to the nearer one, and a number that is not finite is no turn at all.
///
/// Halfway goes up in both directions, so `45` is one quarter and `-45` is none.
/// That is JavaScript's `Math.round`, written out, because Dart's own `round`
/// takes a half away from zero and would put `-45` on the other side.
int quartersOf(num degrees) {
  if (!degrees.isFinite) {
    return 0;
  }

  return (degrees / 90 + 0.5).floor() % 4;
}

/// Whether a turn puts the picture on its side, swapping its width and height.
bool isSideways(int quarters) => quarters.isOdd;
