/// A stack of sections, one of which is open.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// A section sits one step down the radius ladder from the sheet it is inside,
/// so a hovered header's corner is visibly inside the pane's own corner rather
/// than fighting it.
const Map<PlassSize, PlassSize> _itemRadiusScale = <PlassSize, PlassSize>{
  PlassSize.xs: PlassSize.xs,
  PlassSize.sm: PlassSize.xs,
  PlassSize.md: PlassSize.sm,
  PlassSize.lg: PlassSize.sm,
  PlassSize.xl: PlassSize.md,
};

/// The space between a header and the body it opened.
///
/// The header's own padding does **not** pay for it. An open header is a tinted
/// band with its own bottom edge; the body begins at that edge, and the first
/// line of text lands against it with only half a leading in between — the title
/// and the paragraph explaining it read as one run of text broken by a colour
/// change. What the header's padding buys is room around the *title*, and the
/// body has to buy its own.
///
/// It is a little under the padding below, because a paragraph's first line has
/// the leading above it and its last has nothing under, so equal numbers on the
/// two sides look bottom-heavy.
const Map<PlassDensity, Map<PlassSize, double>> _panelPaddingTop =
    <PlassDensity, Map<PlassSize, double>>{
      PlassDensity.standard: <PlassSize, double>{
        PlassSize.xs: 6,
        PlassSize.sm: 8,
        PlassSize.md: 12,
        PlassSize.lg: 14,
        PlassSize.xl: 16,
      },
      PlassDensity.compact: <PlassSize, double>{
        PlassSize.xs: 4,
        PlassSize.sm: 6,
        PlassSize.md: 8,
        PlassSize.lg: 10,
        PlassSize.xl: 12,
      },
    };

/// And the space under it, on the same two tracks.
const Map<PlassDensity, Map<PlassSize, double>> _panelPaddingBottom =
    <PlassDensity, Map<PlassSize, double>>{
      PlassDensity.standard: <PlassSize, double>{
        PlassSize.xs: 10,
        PlassSize.sm: 12,
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

/// The hair of padding an unscored sheet keeps, so a hovered header does not run
/// into the edge.
const double _sheetInset = 4;

/// One section of a [PlAccordion].
///
/// A description rather than a widget: the accordion has to know which sections
/// are open, which one a press should close, and where the rules between them
/// go. None of that can be asked of an opaque `Widget`.
@immutable
class PlAccordionItem<T> {
  /// Creates a section.
  const PlAccordionItem({
    required this.value,
    this.title,
    this.subtitle,
    this.startIcon,
    this.action,
    this.disabled = false,
    this.child,
  });

  /// Identifies the section. What [PlAccordion.value] holds.
  final T value;

  /// The heading on the fold.
  final Widget? title;

  /// A second line under it, one step down the type scale and muted.
  final Widget? subtitle;

  /// Content before the title.
  final Widget? startIcon;

  /// A control pinned to the end of the header, before the chevron.
  ///
  /// Deliberately outside the part that folds: a header that both folds and
  /// holds a switch has two things to press, and one of them cannot be inside
  /// the other.
  final Widget? action;

  /// Unavailable. This section stops folding; the rest keep working.
  final bool disabled;

  /// The body.
  final Widget? child;
}

/// A stack of sections, one of which is open.
///
/// ```dart
/// PlAccordion<String>(
///   value: open,
///   onChanged: (Set<String> next) => setState(() => open = next),
///   items: const <PlAccordionItem<String>>[
///     PlAccordionItem<String>(value: 'billing', title: Text('Billing'), child: Text('…')),
///   ],
/// )
/// ```
///
/// The panel's height **is** animated, which looks like an exception to the rule
/// against moving things and is not: nothing is transformed, no text is
/// resampled, and the content does not shift relative to the panel it is in —
/// the panel is a window opening onto it. An accordion whose sections appear
/// instantly is a page that jumps, which is the failure the rule exists to
/// prevent.
class PlAccordion<T> extends StatelessWidget {
  /// Creates an accordion.
  const PlAccordion({
    required this.items,
    required this.value,
    this.onChanged,
    this.multiple = false,
    this.variant = PlassVariant.glass,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.density = PlassDensity.standard,
    this.elevation = 0,
    this.dividers = true,
    this.disabled = false,
    super.key,
  }) : assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// The sections, in order.
  final List<PlAccordionItem<T>> items;

  /// Which sections are open.
  final Set<T> value;

  /// Called with the set that should be open next.
  ///
  /// Leaving it `null` freezes the accordion at whatever is open.
  final ValueChanged<Set<T>>? onChanged;

  /// Whether more than one section may be open at once.
  ///
  /// `false` by default, which is the whole reason an accordion is not just a
  /// stack of collapsibles: closing the last one as the next opens is what keeps
  /// the page from growing under the reader.
  final bool multiple;

  /// What the sheet is made of.
  final PlassVariant variant;

  /// Type scale, radius and padding.
  final PlassSize size;

  /// Semantic colour role. It reaches an open header's wash and its title.
  final PlassColor color;

  /// How tightly the sections pack.
  final PlassDensity density;

  /// Drop shadow depth, `0`–`3`.
  ///
  /// `0` is the default — an accordion is part of the page it is set into, not a
  /// panel floating over it.
  final PlassElevation elevation;

  /// Scores the sheet between sections with a hairline instead of separating
  /// them with space.
  ///
  /// On by default: the rule is what says the folds are parts of one pane rather
  /// than a stack of unrelated tiles.
  final bool dividers;

  /// Unavailable. Every section stops answering.
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final family = tokens.family(color);
    final surface = sheetSurface(tokens, variant: variant, elevation: elevation);

    void toggle(T item) {
      final open = value.contains(item);

      if (!multiple) {
        // Closing the last one as the next opens is what keeps the page from
        // growing under the reader.
        onChanged?.call(<T>{if (!open) item});

        return;
      }

      final next = <T>{...value};

      if (open) {
        next.remove(item);
      } else {
        next.add(item);
      }

      onChanged?.call(next);
    }

    final sections = <Widget>[
      for (var index = 0; index < items.length; index += 1)
        _Section<T>(
          item: items[index],
          open: value.contains(items[index].value),
          size: size,
          density: density,
          family: family,
          tokens: tokens,
          dividers: dividers,
          ruled: dividers && index > 0,
          disabled: disabled || items[index].disabled || onChanged == null,
          onToggle: () => toggle(items[index].value),
        ),
    ];

    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: PlassSurfaceBox(
        surface: surface,
        borderRadius: BorderRadius.circular(PlassTokens.radius[size]!),
        child: Padding(
          // Scored, the rules have to reach both edges, so the sheet keeps no
          // padding of its own. Unscored, the sections are tiles and it keeps a
          // hair so a hovered header does not run into the edge.
          padding: EdgeInsets.all(dividers ? 0 : _sheetInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: sections,
          ),
        ),
      ),
    );
  }
}

/// One drawn section.
class _Section<T> extends StatelessWidget {
  const _Section({
    required this.item,
    required this.open,
    required this.size,
    required this.density,
    required this.family,
    required this.tokens,
    required this.dividers,
    required this.ruled,
    required this.disabled,
    required this.onToggle,
  });

  final PlAccordionItem<T> item;
  final bool open;
  final PlassSize size;
  final PlassDensity density;
  final PlassColorFamily family;
  final PlassTokens tokens;
  final bool dividers;
  final bool ruled;
  final bool disabled;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final padX = sheetPaddingX[density]![size]!;
    final padY = sheetPaddingY[density]![size]!;
    final title = sheetTitle[size]!;
    final body = sheetBody[size]!;
    final radius = BorderRadius.circular(
      dividers ? 0 : PlassTokens.radius[_itemRadiusScale[size]!]!,
    );

    Widget header = PlassInteractive(
      onTap: onToggle,
      interactive: !disabled,
      enabled: !disabled,
      cursor: disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      builder: (BuildContext context, PlassInteraction state) {
        final lit = open || state.hovered;
        final ink = disabled
            ? tokens.mutedFg
            : open
            ? family.accent
            : tokens.fg;

        Widget row = AnimatedContainer(
          duration: reduceMotion ? Duration.zero : PlassTokens.duration,
          curve: PlassTokens.ease,
          decoration: BoxDecoration(
            color: lit && !disabled ? family.soft : null,
            borderRadius: radius,
          ),
          padding: EdgeInsets.symmetric(horizontal: padX, vertical: padY),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: gap[size]!,
            children: <Widget>[
              if (item.startIcon != null)
                IconTheme.merge(
                  data: IconThemeData(color: tokens.mutedFg, size: title.size * iconScale),
                  child: item.startIcon!,
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: sheetHeaderGap[size]!,
                  children: <Widget>[
                    if (item.title != null)
                      DefaultTextStyle.merge(
                        style: TextStyle(
                          color: ink,
                          fontSize: title.size,
                          height: title.height,
                          fontWeight: FontWeight.w600,
                          leadingDistribution: TextLeadingDistribution.even,
                        ),
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        child: item.title!,
                      ),
                    if (item.subtitle != null)
                      DefaultTextStyle.merge(
                        style: TextStyle(color: tokens.mutedFg, fontSize: metaText[size]!),
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        child: item.subtitle!,
                      ),
                  ],
                ),
              ),
              // Turned, not moved. It is also the only thing on the header that
              // reports the open state by moving, which is why the header itself
              // only changes colour.
              AnimatedRotation(
                turns: open ? 0.5 : 0,
                duration: reduceMotion ? Duration.zero : PlassTokens.duration,
                curve: PlassTokens.ease,
                child: PlassGlyph(
                  PlassGlyphShape.chevron,
                  size: title.size * iconScale,
                  color: tokens.mutedFg,
                ),
              ),
            ],
          ),
        );

        row = plassStateFilter(child: row, disabled: disabled, lit: false);

        if (state.focusVisible) {
          row = CustomPaint(
            foregroundPainter: PlassFocusRingPainter(
              color: family.ring,
              borderRadius: radius,
              // A ring drawn outside a header on a clipped sheet is a ring with
              // its top or bottom sliced off at the first and last section.
              offset: dividers ? -focusRingWidth : focusRingOffset,
            ),
            child: row,
          );
        }

        return Semantics(
          container: true,
          button: true,
          expanded: open,
          enabled: !disabled,
          onTap: disabled ? null : onToggle,
          child: row,
        );
      },
    );

    if (item.action != null) {
      header = Row(
        children: <Widget>[
          Expanded(child: header),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padX),
            child: item.action!,
          ),
        ],
      );
    }

    // The body is clipped rather than squashed while the panel moves, which is
    // what makes it a window opening onto the content rather than the content
    // being scaled.
    final panel = AnimatedSize(
      duration: reduceMotion ? Duration.zero : PlassTokens.durationSlow,
      curve: PlassTokens.ease,
      alignment: Alignment.topCenter,
      child: open && item.child != null
          ? DefaultTextStyle.merge(
              style: TextStyle(
                color: tokens.mutedFg,
                fontSize: body.size,
                height: body.height,
                leadingDistribution: TextLeadingDistribution.even,
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: padX,
                  right: padX,
                  top: _panelPaddingTop[density]![size]!,
                  bottom: _panelPaddingBottom[density]![size]!,
                ),
                child: item.child!,
              ),
            )
          : const SizedBox(width: double.infinity),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: ruled
            ? Border(
                top: BorderSide(color: tokens.divider, width: hairline),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          header,
          ClipRect(child: panel),
        ],
      ),
    );
  }
}
