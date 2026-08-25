/// Shared prop vocabulary for every Plass component.
///
/// These names and values are deliberately generic: a `size` of `md` or a
/// `color` of `primary` has to mean the same thing on a [PlButton], a text
/// field, a card or a dialog. Components pick the subset they need from here
/// and never invent a parallel spelling of the same idea.
///
/// It is also the same vocabulary the React package uses, value for value, so
/// that one documentation page can describe both. Exactly one name differs, and
/// it is marked where it happens.
library;

/// Scale of a component. [PlassSize.md] is the desktop default.
enum PlassSize {
  /// 24px tall. For a table row, and the one step where the gloss is faint.
  xs,

  /// 32px tall.
  sm,

  /// 40px tall. The desktop default.
  md,

  /// 48px tall. Clears the 44px mobile touch target.
  lg,

  /// 56px tall.
  xl,
}

/// Semantic colour role. Maps to a token family in [PlassTokens].
enum PlassColor {
  /// The action a screen is about. Indigo sweeping to azure.
  primary,

  /// The quiet neutral. A slate grey, and the one that is not a hue.
  secondary,

  /// Something completed. Green sweeping to teal.
  success,

  /// Something that needs attention but is not an error. Amber, with dark ink.
  warning,

  /// Something destructive or failed. Vermilion sweeping to rose.
  danger,

  /// Neutral information. Blue sweeping to cyan.
  info,
}

/// How tightly a component packs its content.
///
/// Only spacing changes — never the type scale, never the control's own height
/// — so a compact and a standard control of the same `size` still line up on a
/// shared baseline.
enum PlassDensity {
  /// The default track.
  ///
  /// **This value is spelled `'default'` in the React package.** `default` is a
  /// reserved word in Dart, so it is `standard` here. It is the only name in
  /// the shared vocabulary that differs between the two.
  standard,

  /// Roughly half the horizontal padding, for a dense toolbar or a table.
  compact,
}

/// Which way a component runs.
///
/// [PlassOrientation.horizontal] everywhere it is offered, because a vertical
/// control is the exception and an exception should have to be asked for.
enum PlassOrientation {
  /// Runs along the inline axis.
  horizontal,

  /// Runs down the block axis.
  vertical,
}

/// Which edge of an anchor something is placed against.
///
/// Physical rather than logical — `start`/`end` would be wrong here, because a
/// tooltip above a button is above it in every writing direction.
enum PlassSide {
  /// Above the anchor.
  top,

  /// To the right of the anchor.
  right,

  /// Below the anchor.
  bottom,

  /// To the left of the anchor.
  left,
}

/// Where something sits along the axis it is not placed on.
///
/// `start`/`end` rather than `left`/`right` because these flip under RTL, which
/// is the whole reason the library never says `left`.
enum PlassAlign {
  /// The leading edge in the current writing direction.
  start,

  /// The middle.
  center,

  /// The trailing edge in the current writing direction.
  end,
}

/// Which corner of a box something is pinned to.
///
/// Deliberately one word built out of the two the library already has —
/// `top`/`bottom` from [PlassSide], `start`/`end` from [PlassAlign] — rather
/// than a pair of properties. A corner is one decision, and splitting it into
/// two would let a caller spell `{ vertical: left }`.
enum PlassCorner {
  /// Top leading corner.
  topStart,

  /// Top trailing corner.
  topEnd,

  /// Bottom leading corner.
  bottomStart,

  /// Bottom trailing corner.
  bottomEnd,
}

/// What a surface is made of.
///
/// This is the library's own name, and the two materials in it are the whole
/// design language.
enum PlassVariant {
  /// **Tinted glass.** A gradient that sweeps between two ends of the colour
  /// family at one lightness, and a drop shadow tinted with that family. No
  /// highlight over the top of it: the sweep is the form. One per view, for the
  /// action the screen is about.
  solid,

  /// **Clear glass.** A translucent sheet over a blurred backdrop with a white
  /// hairline around it. Secondary actions, and the default for anything that
  /// *holds* content rather than being pressed.
  glass,

  /// Neither. No surface at all until the pointer is on it. Tertiary and inline
  /// actions.
  ghost,
}

/// The lowest and highest values [PlassElevation] accepts.
///
/// Elevation is an `int` rather than an enum so that it reads the same as the
/// React package's `0 | 1 | 2 | 3` and so that the arithmetic hover and press
/// do to it — one level up, one level down — stays arithmetic.
const int plassElevationMin = 0;

/// The top of the elevation ladder. See [plassElevationMin].
const int plassElevationMax = 3;

/// How far a surface sits off the page, as a drop shadow.
///
/// A control rests **on** the sheet rather than flush with it, so a button
/// defaults to `1` and not to `0`. Hovering adds a level and pressing removes
/// one, which is what puts it down against the sheet under the finger. The
/// ladder is neutral and faint; a control's shadow is mostly the tint below it.
///
/// `0` is flat, and it is the right default for anything a reader looks *into*
/// rather than presses — a field, a well, a panel behind other content.
typedef PlassElevation = int;
