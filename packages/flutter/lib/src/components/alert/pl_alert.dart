/// A message about something that happened, set into the page it is about.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/dismiss.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/inset_shadow.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// A message about something that happened, set into the page it is about.
///
/// ```dart
/// PlAlert(
///   color: PlassColor.danger,
///   title: const Text('Deploy failed'),
///   child: const Text('The build could not reach the registry.'),
/// )
/// ```
///
/// The three shapes people mean by "an alert" are one widget with different
/// slots filled rather than three widgets: a bare line (`showIcon: false`), a
/// line with a glyph (the default), and a glyph with a headline and the detail
/// under it ([title] plus [child]). Nothing about the surface changes between
/// them — only how much of it is used.
///
/// An alert **is** the thing being coloured — it is a notice about a severity,
/// not a container holding someone else's content — so unlike a card its sheet
/// takes the tint.
class PlAlert extends StatelessWidget {
  /// Creates an alert.
  const PlAlert({
    this.child,
    this.title,
    this.variant = PlassVariant.glass,
    this.size,
    // An alert with no severity named is an informational one. This is the one
    // place `primary` would be a lie: it is not the primary anything, it is a
    // note, and the palette already has the word for that.
    this.color,
    this.density,
    this.elevation = 0,
    this.icon,
    this.showIcon = true,
    this.action,
    this.onClose,
    this.closeLabel = 'Dismiss',
    super.key,
  }) : assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// The message.
  final Widget? child;

  /// The heading line.
  ///
  /// With it the alert is two-part — a headline and the detail under it; without
  /// it the whole thing is one line.
  final Widget? title;

  /// What the surface is made of. See [PlassVariant].
  ///
  /// [PlassVariant.ghost] is no sheet and no edge, only the tint — for an alert
  /// set among form fields, where a second bordered rectangle is one rectangle
  /// too many.
  final PlassVariant variant;

  /// Type scale, radius and padding.
  final PlassSize? size;

  /// Which severity this is. The glyph follows it unless [icon] says otherwise.
  final PlassColor? color;

  /// How tightly the alert packs its content.
  final PlassDensity? density;

  /// Drop shadow depth, `0`–`3`.
  ///
  /// `0` is the default — an alert belongs to the flow of the page it
  /// interrupts. The one that floats above it is a dialog.
  final PlassElevation elevation;

  /// The glyph at the start. Left out, the one that goes with [color] is used.
  final Widget? icon;

  /// Whether a glyph is drawn at all.
  ///
  /// The pair says what React says with one three-way prop; Dart has no value
  /// that is neither `null` nor a widget, so "take it away" gets its own name.
  final bool showIcon;

  /// Content pinned to the end of the row — a "Retry" button, a link.
  ///
  /// Kept out of [child] so it stays on the first line while the message wraps.
  final Widget? action;

  /// Called when the dismiss button is pressed. Passing it is what makes the
  /// button appear.
  final VoidCallback? onClose;

  /// The name a screen reader gives that button. Never drawn.
  final String closeLabel;

  /// Whether this severity is worth interrupting a screen reader for.
  ///
  /// "This failed" is, and "saved" is not — so the severity decides. Flutter has
  /// one live region rather than two politeness levels, so what the React build
  /// says with `role="alert"` against `role="status"` becomes whether the alert
  /// is a live region at all.
  /// Takes the **resolved** family rather than reading the field: an alert whose
  /// colour comes from the theme rather than from its own parameter is still a
  /// warning, and a getter reading the nullable field would have said otherwise.
  static bool _interrupts(PlassColor color) =>
      color == PlassColor.warning || color == PlassColor.danger;

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final color = this.color ?? PlassTheme.colorOf(context) ?? PlassColor.info;
    final density = this.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

    final tokens = PlassTheme.of(context);
    final family = tokens.family(color);
    final body = sheetBody[size]!;
    final titled = title != null;

    final surface = _surface(tokens, family);

    // On `solid` the surface already carries the family, so the glyph and the
    // title ride on it as one ink. On the other two the surface is only faintly
    // tinted: the message has to stay ordinary reading text, and the accent is
    // spent on the two things that say which kind of alert this is.
    final accent = variant == PlassVariant.solid ? surface.ink : family.accent;

    // The detail line under a title drops to the muted ink, the same step a
    // field's description takes. On a filled surface there is no muted ink to
    // drop to — the page's grey is invisible on a gradient — so the ink stays
    // and the title does the separating with its weight.
    final detail = variant == PlassVariant.solid ? surface.ink : tokens.mutedFg;

    // The glyph and the action centre on the *first line* of text whatever the
    // type scale turns out to be, so a one-line alert looks centred and a
    // three-line one still has its glyph at the top.
    Widget onFirstLine(Widget slot) {
      return SizedBox(
        height: body.line,
        child: Center(child: slot),
      );
    }

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: sheetSectionGap[size]!,
      children: <Widget>[
        if (showIcon)
          onFirstLine(
            IconTheme.merge(
              data: IconThemeData(color: accent, size: body.size * iconScale),
              child: icon ?? PlassGlyph(severityGlyph(color), color: accent),
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: sheetHeaderGap[size]!,
            children: <Widget>[
              if (titled)
                DefaultTextStyle.merge(
                  style: TextStyle(
                    color: accent,
                    fontSize: sheetTitle[size]!.size,
                    height: sheetTitle[size]!.height,
                    fontWeight: FontWeight.w600,
                    leadingDistribution: TextLeadingDistribution.even,
                  ),
                  child: title!,
                ),
              if (child != null)
                // Under a title the message is supporting detail and steps back
                // to the muted ink. On its own it *is* the alert, and stays
                // reading text.
                DefaultTextStyle.merge(
                  style: TextStyle(color: titled ? detail : surface.ink),
                  child: child!,
                ),
            ],
          ),
        ),
        if (action != null) onFirstLine(action!),
        if (onClose != null)
          onFirstLine(
            PlassDismissButton(
              label: closeLabel,
              onPressed: onClose,
              size: body.size * dismissScale,
              color: surface.ink,
              ring: family.ring,
            ),
          ),
      ],
    );

    return Semantics(
      container: true,
      liveRegion: _interrupts(color),
      child: PlassSurfaceBox(
        surface: surface,
        borderRadius: BorderRadius.circular(PlassTokens.radius[size]!),
        child: DefaultTextStyle.merge(
          style: TextStyle(
            color: surface.ink,
            fontSize: body.size,
            height: body.height,
            leadingDistribution: TextLeadingDistribution.even,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: sheetPaddingX[density]![size]!,
              vertical: sheetPaddingY[density]![size]!,
            ),
            child: content,
          ),
        ),
      ),
    );
  }

  /// The alert's own reading of the three materials.
  ///
  /// Not [controlSurface] and not [sheetSurface]: the sheet takes the tint the
  /// way a control's does, but the *ink* is the page's foreground the way a
  /// sheet's is, because what an alert holds is a sentence somebody has to read.
  PlassSurface _surface(PlassTokens tokens, PlassColorFamily family) {
    switch (variant) {
      case PlassVariant.solid:
        return PlassSurface(
          gradient: family.fill,
          ink: family.onSolid,
          shadows: <BoxShadow>[...tokens.elevation(elevation), tokens.lift(family)],
        );
      case PlassVariant.glass:
        return PlassSurface(
          fill: tokens.glass,
          border: Border.all(color: family.line, width: hairline),
          insets: <PlassInsetShadow>[tokens.glossGlass],
          ink: tokens.fg,
          blur: true,
          shadows: tokens.elevation(elevation),
        );
      case PlassVariant.ghost:
        return PlassSurface(fill: family.soft, ink: tokens.fg);
    }
  }
}
