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

import 'package:flutter/foundation.dart';

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

/// A width the layout answers to.
///
/// The same five names as [PlassSize], and deliberately so: a reader who has
/// learned the ladder once should not have to learn a second set of words for
/// where a screen changes shape. They are not the same ladder — a size is how
/// tall a control is and a breakpoint is how wide the window is — but they run
/// in the same direction and are used in the same sentence often enough that
/// two vocabularies would only ever get mixed up.
///
/// The widths are the React package's, which are Tailwind's: `sm` 640, `md`
/// 768, `lg` 1024, `xl` 1280, with [PlassBreakpoint.xs] meaning "from zero up".
enum PlassBreakpoint {
  /// From zero up.
  xs(0),

  /// From 640 logical pixels up.
  sm(640),

  /// From 768 up.
  md(768),

  /// From 1024 up.
  lg(1024),

  /// From 1280 up.
  xl(1280);

  const PlassBreakpoint(this.width);

  /// The width, in logical pixels, at which this breakpoint starts.
  final double width;

  /// Which breakpoint a window of [width] is in.
  static PlassBreakpoint of(double width) {
    PlassBreakpoint current = PlassBreakpoint.xs;

    for (final PlassBreakpoint candidate in PlassBreakpoint.values) {
      if (width >= candidate.width) {
        current = candidate;
      }
    }

    return current;
  }
}

/// A value that may change with the width of the window.
///
/// The base value applies from zero up and every override applies **from its
/// own breakpoint up**, so two of them usually describe a whole layout:
/// `PlassResponsive<int>(12, md: 6)` is a full width on a phone and a half from
/// 768.
///
/// The React package spells this as a bare value or a map — `span={6}` or
/// `span={{ xs: 12, md: 6 }}` — which a TypeScript union can carry and Dart
/// cannot. The base value being positional is what keeps the common case short:
/// `PlassResponsive(6)` is the whole of "six columns everywhere".
@immutable
class PlassResponsive<T> {
  /// Creates a responsive value. [base] applies from zero up; each named
  /// override applies from its own breakpoint up.
  const PlassResponsive(this.base, {this.sm, this.md, this.lg, this.xl});

  /// The value from zero up, and the one every override falls back to.
  final T base;

  /// From 640 up.
  final T? sm;

  /// From 768 up.
  final T? md;

  /// From 1024 up.
  final T? lg;

  /// From 1280 up.
  final T? xl;

  /// The value in force at [breakpoint], falling back through the ones below
  /// it — which is what makes one override a whole answer rather than the top
  /// of a ladder somebody has to finish.
  T resolve(PlassBreakpoint breakpoint) {
    switch (breakpoint) {
      case PlassBreakpoint.xl:
        return xl ?? lg ?? md ?? sm ?? base;
      case PlassBreakpoint.lg:
        return lg ?? md ?? sm ?? base;
      case PlassBreakpoint.md:
        return md ?? sm ?? base;
      case PlassBreakpoint.sm:
        return sm ?? base;
      case PlassBreakpoint.xs:
        return base;
    }
  }

  @override
  bool operator ==(Object other) {
    return other is PlassResponsive<T> &&
        other.base == base &&
        other.sm == sm &&
        other.md == md &&
        other.lg == lg &&
        other.xl == xl;
  }

  @override
  int get hashCode => Object.hash(base, sm, md, lg, xl);
}

/// How a row distributes the space its content did not use, along the axis the
/// content runs on.
///
/// The three positional values are the library's own `start`/`center`/`end`
/// rather than `left`/`right`, for the reason [PlassAlign] gives: they flip
/// under RTL.
enum PlassJustify {
  /// Packed against the leading edge.
  start,

  /// Packed in the middle.
  center,

  /// Packed against the trailing edge.
  end,

  /// The leftover space divided between the members, none at the ends.
  spaceBetween,

  /// Half a share at each end.
  spaceAround,

  /// An equal share at the ends and between.
  spaceEvenly,

  /// Behaves as [PlassJustify.start] for members that already have a width.
  stretch,
}

/// How content sits across the axis it does not run on.
enum PlassAlignItems {
  /// Against the top of the row.
  start,

  /// Centred in the row.
  center,

  /// Against the bottom of the row.
  end,

  /// Every member as tall as the row — which is what makes a row of cards the
  /// same height without anybody asking.
  stretch,

  /// Every member's first line of text on one line.
  baseline,
}

/// The same, for one member overriding the set it is in.
///
/// **There is no `baseline` here, where the React package has one.** CSS
/// resolves a baseline per item; a Flutter row is aligned on one baseline or on
/// none, so a single cell cannot opt into one the row is not using.
enum PlassAlignSelf {
  /// Take the row's own alignment.
  auto,

  /// Against the top of the row.
  start,

  /// Centred in the row.
  center,

  /// Against the bottom of the row.
  end,

  /// As tall as the row.
  stretch,
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

/// A day of the week, **Sunday first**.
///
/// The React package spells this as `0`–`6`, matching `Date.getDay()`; an enum
/// here for the reason every other axis is one, and in the same order — its
/// `index` is that number, so the two packages count the week identically.
///
/// Not `DateTime.weekday`, which counts Monday as 1 through Sunday as 7. The
/// calendar converts once, at the one place it reads a real date, rather than
/// carrying two numberings that somebody will eventually subtract from each
/// other.
enum PlassWeekday {
  /// `0`.
  sunday,

  /// `1`.
  monday,

  /// `2`.
  tuesday,

  /// `3`.
  wednesday,

  /// `4`.
  thursday,

  /// `5`.
  friday,

  /// `6`.
  saturday,
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
