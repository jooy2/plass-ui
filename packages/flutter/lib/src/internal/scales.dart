/// The measurements every Plass component is built out of.
///
/// This is `src/internal/styles.ts` from the React package, in Dart, and it is
/// here for the same reason it is there: a `size` of `md` has to be 40px on a
/// button, a text field, a select and a chip, and a table copied into eleven
/// files is a table that will disagree with itself by the twelfth.
///
/// CSS `rem` values become logical pixels one for one, because the React
/// package's scales are all written against a 16px root and Flutter's logical
/// pixel is the same unit at the same density. `h-10` is `2.5rem` is `40`.
///
/// None of this is exported from `plass_ui.dart` — it is the library talking to
/// itself.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/types.dart';

/// The height of a control, and the one number the whole library lines up on.
///
/// The ladder is 8px per step, and it starts higher than a dense desktop
/// toolkit would: `md` is 40, not 32. A moulded surface needs room to be one —
/// a gradient, a specular highlight and a hairline inside 32px is three effects
/// fighting over eleven pixels of fill. `xs` exists for a table row.
///
/// `lg` at 48 and `xl` at 56 both clear the 44px mobile touch target. Density
/// never touches these.
const Map<PlassSize, double> controlHeight = <PlassSize, double>{
  PlassSize.xs: 24,
  PlassSize.sm: 32,
  PlassSize.md: 40,
  PlassSize.lg: 48,
  PlassSize.xl: 56,
};

/// A control's label. One line, so the leading is 1.0.
const Map<PlassSize, double> controlText = <PlassSize, double>{
  PlassSize.xs: 11,
  PlassSize.sm: 13,
  PlassSize.md: 14,
  PlassSize.lg: 16,
  PlassSize.xl: 18,
};

/// Horizontal padding, and the only thing density is allowed to touch.
///
/// The two tracks are roughly 2:1 so the difference is legible at a glance
/// rather than a two-pixel nudge.
const Map<PlassDensity, Map<PlassSize, double>> paddingX = <PlassDensity, Map<PlassSize, double>>{
  PlassDensity.standard: <PlassSize, double>{
    PlassSize.xs: 10,
    PlassSize.sm: 12,
    PlassSize.md: 16,
    PlassSize.lg: 24,
    PlassSize.xl: 28,
  },
  PlassDensity.compact: <PlassSize, double>{
    PlassSize.xs: 6,
    PlassSize.sm: 8,
    PlassSize.md: 10,
    PlassSize.lg: 14,
    PlassSize.xl: 16,
  },
};

/// A table cell's vertical padding, and therefore a row's height.
///
/// The horizontal track is [paddingX] — a cell is padded the same way a control
/// is, so a table and the buttons beside it agree about how far text sits from
/// an edge. This is the other axis, which no other component needs: everything
/// else states a height and lets the padding fall out of it, and a table cannot,
/// because a cell that wraps has to grow.
const Map<PlassDensity, Map<PlassSize, double>> cellPaddingY =
    <PlassDensity, Map<PlassSize, double>>{
      PlassDensity.standard: <PlassSize, double>{
        PlassSize.xs: 6,
        PlassSize.sm: 8,
        PlassSize.md: 12,
        PlassSize.lg: 14,
        PlassSize.xl: 16,
      },
      PlassDensity.compact: <PlassSize, double>{
        PlassSize.xs: 2,
        PlassSize.sm: 4,
        PlassSize.md: 7,
        PlassSize.lg: 9,
        PlassSize.xl: 11,
      },
    };

/// Between a control's own parts — an icon and its label.
const Map<PlassSize, double> gap = <PlassSize, double>{
  PlassSize.xs: 4,
  PlassSize.sm: 6,
  PlassSize.md: 8,
  PlassSize.lg: 10,
  PlassSize.xl: 12,
};

/// How large a glyph *inside* a control is drawn, as a multiple of the label.
///
/// A ratio rather than a ladder: an icon in a button belongs to the word next
/// to it, so it tracks the label rather than carrying a size of its own. The
/// React package writes this as `1.2em` and means the same thing.
const double iconScale = 1.2;

/// How far the focus ring sits outside the control, matching CSS's
/// `outline-offset: 0`.
///
/// Flush, and flush on every control in both packages. A ring held a couple of
/// pixels off something that already draws an edge of its own — a field, a
/// tick, a switch — reads as three rectangles round one object, and the object
/// looks as though it has come loose from the ring. At zero the ring sits
/// directly against the outside of the edge and the edge simply thickens.
const double focusRingOffset = 0;

/// How thick that ring is, matching CSS's `outline: 2px solid`.
const double focusRingWidth = 2;

/// The radius of the bloom that follows the pointer, in logical pixels.
///
/// `6rem` in the stylesheet, which is 96.
const double glowRadius = 96;

/// The radius of the brighter flash on press. `5rem`, which is 80.
const double flashRadius = 80;

/// How much saturation a read-only surface keeps.
///
/// Read-only keeps the shape, the colour and the edge but goes flat, loses its
/// lift and drains most of the saturation — a label that happens to be
/// control-shaped. It is not dimmed: the value is still there to be read, which
/// is the whole difference from disabled.
const double readOnlySaturation = 0.55;

/// How much saturation a disabled surface keeps, and how much opacity.
///
/// Disabled is **the light going out.** The key keeps its shape, its colour and
/// its place in the layout, and stops catching any light: no gloss, no tinted
/// lift, no shadow, most of the saturation gone and half the opacity with it.
///
/// Opacity is doing real work here rather than standing in for a decision. On a
/// page made of translucent sheets, a surface that has gone part-transparent is
/// a surface the page is showing *through* — it has stopped being an object.
const double disabledSaturation = 0.35;

/// See [disabledSaturation].
const double disabledOpacity = 0.5;

/// The brightness a filled surface takes under the pointer.
///
/// Hover turns the light up and press turns it down, and both are a brightness
/// change rather than a second set of colours — because the fill is a gradient
/// and a gradient cannot be transitioned, but light falling on one can.
const double hoverBrightness = 1.05;

/// The brightness a filled surface takes while it is held down.
const double pressBrightness = 0.95;

/// A type size paired with the line box it sits in.
///
/// Flutter's [TextStyle.height] is a multiple of the font size and CSS's
/// `font-size/line-height` shorthand is two lengths, so the table is written the
/// way the stylesheet writes it and the division happens here. Which matters
/// beyond convenience: the React scales pick line boxes that are **whole
/// pixels with the same parity as the thing sitting in them** — a 20px line for
/// an 18px tick — and a ratio would land those on fractions at four steps out
/// of five.
@immutable
class PlassTextScale {
  /// Creates a type step. [line] is the CSS `line-height`, in logical pixels.
  const PlassTextScale(this.size, this.line);

  /// The type size.
  final double size;

  /// The line box the type sits in.
  final double line;

  /// The same pair as Flutter states it.
  double get height => line / size;
}

/// The control type scale with an explicit leading, for the controls that hold
/// text which may wrap — a multiline field, an option in a list, a table cell.
///
/// The line boxes agree with [controlHeight] on purpose: a one-row control that
/// wraps has to keep lining up with a single-line one beside it.
const Map<PlassSize, PlassTextScale> controlTextLeading = <PlassSize, PlassTextScale>{
  PlassSize.xs: PlassTextScale(11, 16),
  PlassSize.sm: PlassTextScale(13, 18),
  PlassSize.md: PlassTextScale(14, 20),
  PlassSize.lg: PlassTextScale(16, 24),
  PlassSize.xl: PlassTextScale(18, 28),
};

/// Labels, descriptions and error messages: one step below the control's text.
const Map<PlassSize, double> metaText = <PlassSize, double>{
  PlassSize.xs: 10,
  PlassSize.sm: 11,
  PlassSize.md: 12,
  PlassSize.lg: 13,
  PlassSize.xl: 14,
};

/// A standalone glyph's box.
///
/// Its own ladder rather than a step off [controlHeight], because an icon is
/// not a control — it is content, and it is measured against the text it sits
/// beside rather than against the row it sits in. [iconScale] is the other half
/// of the same idea: that one sizes a glyph *inside* a control.
const Map<PlassSize, double> iconSize = <PlassSize, double>{
  PlassSize.xs: 14,
  PlassSize.sm: 16,
  PlassSize.md: 20,
  PlassSize.lg: 24,
  PlassSize.xl: 28,
};

/// A tick box: the square a checkbox draws and the circle a radio draws.
///
/// Sized against the text beside it rather than against the row it sits in — a
/// tick is an indicator next to a label, not a control you can put one inside.
const Map<PlassSize, double> tickSize = <PlassSize, double>{
  PlassSize.xs: 14,
  PlassSize.sm: 16,
  PlassSize.md: 18,
  PlassSize.lg: 20,
  PlassSize.xl: 24,
};

/// And its own radius, well below the control ladder's.
///
/// `md` on a control is 12, which on an 18px box is most of the way to a
/// circle — and a checkbox that is round is a radio button. The intent is the
/// same fillet, measured against a much smaller object.
const Map<PlassSize, double> tickRadius = <PlassSize, double>{
  PlassSize.xs: 4,
  PlassSize.sm: 5,
  PlassSize.md: 6,
  PlassSize.lg: 7,
  PlassSize.xl: 8,
};

/// The dot inside a checked radio.
///
/// Whole pixels at every step, and whole pixels *of margin* with them: what
/// decides the offset is `(box − border − border − dot) / 2`, so every dot here
/// has the same parity as the ring's content box. A 7px dot in an 18px ring
/// with a 1px edge sits 4.5px from each side, and a circle antialiased at half
/// coverage on all four sides reads as off-centre — up and to the left, because
/// that is the way the paint rounds.
const Map<PlassSize, double> tickDot = <PlassSize, double>{
  PlassSize.xs: 6,
  PlassSize.sm: 6,
  PlassSize.md: 8,
  PlassSize.lg: 8,
  PlassSize.xl: 10,
};

/// The line box a tick and its label share.
///
/// [controlTextLeading] rather than a ratio of its own, and that is the whole
/// point: a ratio produces a fractional line box at every step but one, and a
/// tick centred in 19.6px starts at 0.8px — which drags the ring, its edge and
/// the dot inside it off the pixel grid together.
const Map<PlassSize, PlassTextScale> tickRowText = controlTextLeading;

/// Between a label, the control under it and the text under that.
const Map<PlassSize, double> stackGap = <PlassSize, double>{
  PlassSize.xs: 4,
  PlassSize.sm: 6,
  PlassSize.md: 6,
  PlassSize.lg: 8,
  PlassSize.xl: 8,
};

/* ---------------------------------------------------------------------------
 * Sheets
 *
 * A control holds one line of text at a fixed height, which is what every
 * ladder above is about. A *sheet* — a card, an accordion section, an alert, a
 * modal — holds a heading, a paragraph and a footer, and all three of them
 * wrap. That is a different problem, and these tables are its answer.
 *
 * A sheet's subtitle deliberately has no table of its own: it is [metaText],
 * the same step below the body that a field's description sits on.
 * ------------------------------------------------------------------------ */

/// A sheet's own horizontal padding, which is not a control's.
///
/// [paddingX] is the room a label needs beside the edge of the key it is
/// printed on. This is the margin a sheet keeps around whatever it is holding,
/// and it is bigger, because the thing inside is a paragraph rather than a
/// word.
const Map<PlassDensity, Map<PlassSize, double>> sheetPaddingX =
    <PlassDensity, Map<PlassSize, double>>{
      PlassDensity.standard: <PlassSize, double>{
        PlassSize.xs: 10,
        PlassSize.sm: 14,
        PlassSize.md: 20,
        PlassSize.lg: 24,
        PlassSize.xl: 28,
      },
      PlassDensity.compact: <PlassSize, double>{
        PlassSize.xs: 8,
        PlassSize.sm: 10,
        PlassSize.md: 14,
        PlassSize.lg: 16,
        PlassSize.xl: 20,
      },
    };

/// The other axis of [sheetPaddingX], offered separately: a sheet with
/// hairlines between its sections gives its vertical padding away to them.
const Map<PlassDensity, Map<PlassSize, double>> sheetPaddingY =
    <PlassDensity, Map<PlassSize, double>>{
      PlassDensity.standard: <PlassSize, double>{
        PlassSize.xs: 10,
        PlassSize.sm: 14,
        PlassSize.md: 20,
        PlassSize.lg: 24,
        PlassSize.xl: 28,
      },
      PlassDensity.compact: <PlassSize, double>{
        PlassSize.xs: 8,
        PlassSize.sm: 10,
        PlassSize.md: 14,
        PlassSize.lg: 16,
        PlassSize.xl: 20,
      },
    };

/// A sheet's heading: one step above the body, on the same ladder the controls
/// use, so a card's title lines up with the buttons that end up inside it.
const Map<PlassSize, PlassTextScale> sheetTitle = <PlassSize, PlassTextScale>{
  PlassSize.xs: PlassTextScale(12, 16),
  PlassSize.sm: PlassTextScale(13, 18),
  PlassSize.md: PlassTextScale(15, 20),
  PlassSize.lg: PlassTextScale(17, 24),
  PlassSize.xl: PlassTextScale(20, 28),
};

/// Body copy: the control type scale with the leading opened up, because a
/// label is one line and a body is a paragraph.
const Map<PlassSize, PlassTextScale> sheetBody = <PlassSize, PlassTextScale>{
  PlassSize.xs: PlassTextScale(11, 16),
  PlassSize.sm: PlassTextScale(12, 18),
  PlassSize.md: PlassTextScale(13, 22),
  PlassSize.lg: PlassTextScale(15, 24),
  PlassSize.xl: PlassTextScale(17, 28),
};

/// Between a sheet's sections, when there are no hairlines to separate them.
const Map<PlassSize, double> sheetSectionGap = <PlassSize, double>{
  PlassSize.xs: 6,
  PlassSize.sm: 8,
  PlassSize.md: 12,
  PlassSize.lg: 14,
  PlassSize.xl: 16,
};

/// Title to subtitle. Tight — they are one block of text, not two sections.
const Map<PlassSize, double> sheetHeaderGap = <PlassSize, double>{
  PlassSize.xs: 2,
  PlassSize.sm: 2,
  PlassSize.md: 4,
  PlassSize.lg: 4,
  PlassSize.xl: 6,
};

/// The hairline every Plass surface draws around itself, and the width of a
/// tick's edge. One value, because two of them is two toolkits.
const double hairline = 1;

/// The measure ladder, in logical pixels.
///
/// The same widths the breakpoints are from `sm` up, and written out rather
/// than read from [PlassBreakpoint]: a breakpoint is where the screen changes
/// shape and a measure is how wide text may get, and a project that moved one
/// because it wanted the other would have moved the wrong thing.
const Map<PlassSize, double> containerMeasure = <PlassSize, double>{
  PlassSize.xs: 480,
  PlassSize.sm: 640,
  PlassSize.md: 768,
  PlassSize.lg: 1024,
  PlassSize.xl: 1280,
};

/// A responsive value at the width the window is currently at.
///
/// The **window's** width rather than the widget's own box, which is what a CSS
/// media query measures and what makes two widgets side by side agree about
/// which rung they are on however wide each of them ended up.
///
/// It is called from `build` so the dependency is registered and the widget is
/// rebuilt when the window crosses a rung.
T resolveResponsive<T>(BuildContext context, PlassResponsive<T> value) {
  return value.resolve(PlassBreakpoint.of(MediaQuery.sizeOf(context).width));
}

/// The limit a responsive measure comes to at one width, or `null` for none.
///
/// The window's width, as every breakpoint in the package is: two containers
/// side by side are on the same rung however wide each of them ended up.
double? measureAt(PlassResponsive<PlContainerWidth?>? maxWidth, double width) {
  final PlContainerWidth? measure = maxWidth?.resolve(PlassBreakpoint.of(width));

  if (measure == null) {
    return null;
  }

  return measure.pixels ?? containerMeasure[measure.rung]!;
}
