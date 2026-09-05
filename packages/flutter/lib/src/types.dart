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

import 'dart:ui' show Color;

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

/// Where a band starts, and what a reading is made of from there up.
///
/// Here rather than on a component because two of them read it the same way: a
/// [PlMeter]'s bar and a `PlGaugeChart`'s arc are one idea in two shapes, and a
/// page that moves a reading from the bar to the dial must not have to rewrite
/// its bands to do it.
@immutable
class PlassThreshold {
  /// Creates a band.
  const PlassThreshold({required this.from, required this.color});

  /// The value the band begins at, in the reading's own units — not a
  /// percentage, unless the range happens to be one. A band whose [from] is
  /// outside `min`…`max` is simply never reached.
  final double from;

  /// The family the reading takes while it is in this band.
  final PlassColor color;

  @override
  bool operator ==(Object other) {
    return other is PlassThreshold && other.from == from && other.color == color;
  }

  @override
  int get hashCode => Object.hash(from, color);
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

/// How wide content is allowed to get, and the three widgets that ask.
///
/// A rung of the measure ladder or an exact width, and only one of them can be
/// true at a time — which is why it is two constructors rather than one
/// nullable pair. The React package spells it as a union, `maxWidth="lg"` or
/// `maxWidth="72ch"`, which TypeScript can carry and Dart cannot.
///
/// The exact width is the one worth having. The ladder is five numbers chosen
/// against the breakpoints, and the measure a paragraph actually wants is a
/// count of characters at whatever size it is set in. No ladder can spell that.
@immutable
class PlContainerWidth {
  /// A rung of the measure ladder.
  const PlContainerWidth.rung(PlassSize this.rung) : pixels = null;

  /// An exact width, in logical pixels.
  const PlContainerWidth.pixels(double this.pixels) : rung = null;

  /// The rung, when it was named as one.
  final PlassSize? rung;

  /// The width, when it was given as one.
  final double? pixels;

  @override
  bool operator ==(Object other) =>
      other is PlContainerWidth && other.rung == rung && other.pixels == pixels;

  @override
  int get hashCode => Object.hash(rung, pixels);
}

/// Every rung but [PlassBreakpoint.xs], which is the one with nothing below it.
///
/// The type of a question about a *floor* — "from here up", "until here". `xs`
/// has no floor to ask about: everything is at or above it, so `from: xs` would
/// mean "always" and `until: xs` would mean "never", and a prop with two values
/// that do nothing is a prop that invites them.
///
/// It carries the breakpoint rather than repeating its width, so there is still
/// one place a number is written down.
enum PlassBreakpointFloor {
  /// From 640 logical pixels up.
  sm(PlassBreakpoint.sm),

  /// From 768 up.
  md(PlassBreakpoint.md),

  /// From 1024 up.
  lg(PlassBreakpoint.lg),

  /// From 1280 up.
  xl(PlassBreakpoint.xl);

  const PlassBreakpointFloor(this.breakpoint);

  /// The rung this floor is the bottom of.
  final PlassBreakpoint breakpoint;

  /// The width, in logical pixels, at which it starts.
  double get width => breakpoint.width;
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

/// What makes a `PlAnimate*` widget run.
///
/// - [mount] — as soon as it is on screen. The default, and the only one that
///   needs nothing from the caller.
/// - [visible] — when it is scrolled into view inside the nearest scrollable.
///   Once, unless `once` is off. With no scrollable above it there is nothing to
///   watch, so it runs immediately rather than waiting forever.
/// - [hover] — while the pointer is on it, starting again on each entry. Focus
///   counts, or the effect would be unreachable without a mouse.
/// - [manual] — never on its own. `play` is what runs it.
enum PlassAnimateTrigger {
  /// As soon as it is on screen.
  mount,

  /// When it is scrolled into view.
  visible,

  /// While the pointer or focus is on it.
  hover,

  /// Only when `play` says so.
  manual,
}

/// Whether an effect brings its content in or takes it away.
///
/// [enter] and [exit] rather than the React package's `'in'` and `'out'`,
/// because `in` is a reserved word in Dart and cannot be an enum value.
enum PlassAnimateMode {
  /// The content arrives.
  enter,

  /// The same run backwards, held where it ends.
  exit,
}

/// Chords a control answers to, in the vocabulary [PlHotKeys] draws.
///
/// The key is a shortcut written the way a key cap is written — `'Enter'`,
/// `'Escape'`, `'Mod+Enter'`, `'Shift+Enter'` — and `Mod` resolves per platform,
/// so one entry is ⌘ on a Mac and Ctrl everywhere else. It is deliberately the
/// *same* string a [PlHotKeys] beside the field would print: a shortcut a widget
/// displays and a shortcut it binds have to be spelled one way, or the cap on
/// the screen is a claim nobody checked.
///
/// A chord that matches is **consumed** — the callback runs and the key goes no
/// further, so `Escape` bound on a field does not also pop the route above it
/// and `Enter` does not also fire the field's own `onSubmitted`. That is what
/// binding a key means, and it is why these are chords rather than letters:
/// `hotKeys: {'a': …}` is a field that cannot type an `a`.
typedef PlassHotKeys = Map<String, VoidCallback>;

/* ---------------------------------------------------------------------------
 * Charts
 *
 * The vocabulary the chart widgets share, and the reason it is here rather than
 * in one of them: a `series` handed to a [PlLineChart] has to be the same
 * `series` a [PlBarChart] takes, or switching a dashboard tile from one to the
 * other is a rewrite instead of a rename. The same argument [PlassSize] makes.
 *
 * Everything below describes *data*. How a chart draws it — the curve, the
 * stacking, the hole in a donut — belongs to the widget, because that is
 * exactly the part that differs.
 * ------------------------------------------------------------------------- */

/// Where a point sits along the category axis.
///
/// A closed union of the three things a category can be, which is what Dart
/// gives instead of React's `string | number | Date`. A `DateTime` is accepted
/// because a time series is the common case, and converting one to a string at
/// the call site is what makes two charts of the same data label their axes
/// differently.
class PlassChartCategory {
  /// A category that is a word.
  const PlassChartCategory.text(String this.text) : number = null, date = null;

  /// One that is a position on a number line.
  const PlassChartCategory.number(double this.number) : text = null, date = null;

  /// One that is a moment.
  const PlassChartCategory.date(DateTime this.date) : text = null, number = null;

  /// The word, when it is one.
  final String? text;

  /// The number, when it is one.
  final double? number;

  /// The moment, when it is one.
  final DateTime? date;

  @override
  String toString() {
    if (text != null) {
      return text!;
    }

    if (date != null) {
      return date!.toIso8601String();
    }

    final double value = number!;

    return value == value.roundToDouble() ? value.toInt().toString() : value.toString();
  }

  @override
  bool operator ==(Object other) {
    return other is PlassChartCategory &&
        other.text == text &&
        other.number == number &&
        other.date == date;
  }

  @override
  int get hashCode => Object.hash(text, number, date);
}

/// One value, with everything the chart might want to know about it.
///
/// `y` of `null` is a **gap** and not a zero — a sensor that was offline, a
/// month that has not closed yet. A line breaks across it, an area breaks with
/// it, and a bar is not drawn. This distinction is the whole reason a datum may
/// be null at all: a chart that renders missing data as zero is a chart that
/// reports an outage as a collapse.
class PlassChartPoint {
  /// Creates a point.
  const PlassChartPoint({this.y, this.x, this.z, this.color, this.label});

  /// The reading, or `null` for a gap.
  final double? y;

  /// Where it sits along the category axis, when the point carries its own.
  final PlassChartCategory? x;

  /// A third dimension — the area of a bubble, the weight of a cell.
  final double? z;

  /// A colour for this one point, overriding the series'.
  ///
  /// The exception to the palette, for the bar that is the reader's own and the
  /// slice that is "Other". Use it sparingly: a chart where every point picks
  /// its own colour has no palette at all.
  final Color? color;

  /// What the tooltip and the table call this point.
  final String? label;
}

/// One datum: either a bare reading or a point that says more about itself.
class PlassChartDatum {
  /// A bare reading, or `null` for a gap.
  const PlassChartDatum(this.value) : point = null;

  /// A gap.
  const PlassChartDatum.gap() : value = null, point = null;

  /// A reading with a category, a weight, a colour or a name on it.
  const PlassChartDatum.point(PlassChartPoint this.point) : value = null;

  /// The bare reading, when it is one.
  final double? value;

  /// The point, when it is one.
  final PlassChartPoint? point;
}

/// One line, one band or one run of bars, and everything about it.
class PlassChartSeries {
  /// Creates a series.
  const PlassChartSeries({
    required this.data,
    this.id,
    this.name,
    this.color,
    this.dashed = false,
    this.hidden = false,
  });

  /// The readings, in category order.
  final List<PlassChartDatum> data;

  /// What identifies it. Defaults to its place in the list.
  final String? id;

  /// What the legend, the tooltip and the table call it.
  final String? name;

  /// Its colour, overriding the palette slot its index would have given it.
  final Color? color;

  /// Draws the line dashed — a forecast, a target, a last year.
  final bool dashed;

  /// Starts the series switched off in the legend.
  final bool hidden;
}

/// How much of a tooltip a pointer summons.
enum PlassChartTooltipMode {
  /// The whole column: every series at the category under the pointer. The
  /// default, because a chart is nearly always read across.
  ///
  /// Spelled `column` and not `index`, which is what the React build calls it:
  /// every Dart enum already has an `index`, and a value of that name cannot be
  /// declared. The word is better anyway — what it summons *is* the column.
  column,

  /// Only the mark actually under the pointer.
  item,

  /// None at all.
  none,
}

/// One stretch of time on a row of a `PlTimelineChart`.
@immutable
class PlassTimelinePoint {
  /// Creates a span.
  const PlassTimelinePoint({required this.start, required this.end, this.label, this.color});

  /// When it begins.
  final PlassChartCategory start;

  /// And when it is done. A span that ends before it starts is drawn either way
  /// round.
  final PlassChartCategory end;

  /// What the span is called, in the readout and in the reading.
  final String? label;

  /// Overrides its row's colour for this one span.
  final PlassColor? color;

  @override
  bool operator ==(Object other) {
    return other is PlassTimelinePoint &&
        other.start == start &&
        other.end == end &&
        other.label == label &&
        other.color == color;
  }

  @override
  int get hashCode => Object.hash(start, end, label, color);
}

/// One row of a `PlTimelineChart`, and everything on it.
///
/// A row is a series — one entity, one name, one colour — but its data are
/// spans rather than values, so it cannot be a [PlassChartSeries]. There is no
/// `hidden` here and no legend to pair it with: the rows *are* the category
/// axis, already named down the side, and a twenty-entry legend restating them
/// is not a filter anyone wants.
@immutable
class PlassTimelineSeries {
  /// Creates a row.
  const PlassTimelineSeries({required this.data, this.name, this.color});

  /// The spans on this row. Overlapping ones are moved onto lanes of their own.
  final List<PlassTimelinePoint> data;

  /// Its name on the axis, in the readout and in the reading.
  final String? name;

  /// Overrides the palette slot this row would otherwise take.
  final PlassColor? color;
}

/// Which values are written onto the marks.
enum PlassChartValueLabels {
  /// None. The default: a chart with a number on every point is a table drawn
  /// badly.
  none,

  /// The last point of each series — where it ended up, which is the question a
  /// line chart is usually being asked.
  last,

  /// The highest and the lowest.
  extremes,

  /// Every one of them.
  all,
}
