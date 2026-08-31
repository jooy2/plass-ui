/// The path to where the reader is.
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

/// What is drawn between two steps of the trail.
///
/// Four named marks rather than a free-for-all, because a separator is read
/// hundreds of times a day and the difference between them is meaning, not
/// decoration: a chevron and an arrow say "and then", a slash says "path", a dot
/// says "these are peers of one thing". Anything else can still be passed as a
/// widget.
enum PlBreadcrumbSeparator {
  /// A wedge turned a quarter, and the default.
  chevron,

  /// The arrow, which says "and then" out loud.
  arrow,

  /// `/`, which says "path".
  slash,

  /// `·`, which says "peers of one thing".
  dot,
}

/// Between the steps, and the only thing density touches.
const Map<PlassDensity, Map<PlassSize, double>> _trailGap = <PlassDensity, Map<PlassSize, double>>{
  PlassDensity.standard: <PlassSize, double>{
    PlassSize.xs: 4,
    PlassSize.sm: 6,
    PlassSize.md: 8,
    PlassSize.lg: 10,
    PlassSize.xl: 12,
  },
  PlassDensity.compact: <PlassSize, double>{
    PlassSize.xs: 2,
    PlassSize.sm: 4,
    PlassSize.md: 4,
    PlassSize.lg: 6,
    PlassSize.xl: 8,
  },
};

/// A step's corner, read two steps down the radius ladder.
///
/// `md` is 12, which on a line of text 20px tall is most of the way to a pill —
/// and a breadcrumb step is not a chip. What the hover tint needs is a rectangle
/// with the corners taken off, which is what the ladder says everywhere else; it
/// just has to be read further down for something this short.
const Map<PlassSize, PlassSize> _stepRadiusScale = <PlassSize, PlassSize>{
  PlassSize.xs: PlassSize.xs,
  PlassSize.sm: PlassSize.xs,
  PlassSize.md: PlassSize.xs,
  PlassSize.lg: PlassSize.sm,
  PlassSize.xl: PlassSize.sm,
};

/// One step of the trail.
///
/// A description rather than a widget, which is the one place this component
/// departs from the React build's shape — and it is Flutter's own idiom, the
/// same one `DataColumn` and `BottomNavigationBarItem` use. The reason is that
/// the trail has to *reason* about its steps: which one is the current page, how
/// many there are, and which ones a fold takes out. A `Widget` is opaque and
/// none of those questions can be asked of one.
@immutable
class PlBreadcrumbItem {
  /// Creates a step.
  const PlBreadcrumbItem({
    required this.label,
    this.onPressed,
    this.startIcon,
    this.endIcon,
    this.current,
    this.disabled = false,
  });

  /// What the step says.
  final Widget label;

  /// Called when the step is followed. Leaving it out makes the step plain text,
  /// which is what the step you are already on should be.
  final VoidCallback? onPressed;

  /// Content before the label — a home glyph, a repository avatar.
  final Widget? startIcon;

  /// Content after the label.
  final Widget? endIcon;

  /// Marks this step as the page the reader is on, which stops it answering.
  ///
  /// The last step is the current one on its own, so this is only needed for a
  /// trail that ends somewhere the reader is not — and setting it anywhere takes
  /// the mark off the last step, because only one step in a trail can be it.
  final bool? current;

  /// Unavailable. Stops answering, keeps its place in the trail.
  final bool disabled;
}

/// The path to where the reader is.
///
/// ```dart
/// PlBreadcrumb(
///   items: <PlBreadcrumbItem>[
///     PlBreadcrumbItem(label: const Text('Home'), onPressed: goHome),
///     PlBreadcrumbItem(label: const Text('Settings'), onPressed: goSettings),
///     const PlBreadcrumbItem(label: Text('Billing')),
///   ],
/// )
/// ```
///
/// The last step is the page the reader is on, so it is plain text rather than
/// something to press — the page you are already on is not somewhere to go.
class PlBreadcrumb extends StatefulWidget {
  /// Creates a trail.
  const PlBreadcrumb({
    required this.items,
    this.size,
    this.color,
    this.density,
    this.separator = PlBreadcrumbSeparator.chevron,
    this.separatorWidget,
    this.maxItems,
    this.itemsBeforeCollapse = 1,
    this.itemsAfterCollapse = 1,
    this.expandable = true,
    this.label = 'Breadcrumb',
    this.expandLabel = 'Show the hidden steps',
    super.key,
  });

  /// The steps, in order.
  final List<PlBreadcrumbItem> items;

  /// Type scale.
  final PlassSize? size;

  /// The colour family a step picks up when it is hovered.
  final PlassColor? color;

  /// How tightly the steps pack. Spacing only.
  final PlassDensity? density;

  /// The mark between two steps.
  final PlBreadcrumbSeparator separator;

  /// A mark of your own, which wins over [separator].
  final Widget? separatorWidget;

  /// How many steps to show before the middle is folded away behind a `…`. Left
  /// out, the whole trail is shown however long it gets.
  final int? maxItems;

  /// How many steps stay at the front of a folded trail.
  final int itemsBeforeCollapse;

  /// How many stay at the end.
  final int itemsAfterCollapse;

  /// Whether pressing the `…` unfolds the trail in place. Turn it off to leave
  /// the fold as a plain mark.
  final bool expandable;

  /// The name the trail is announced by. Never drawn.
  final String label;

  /// What the `…` is announced as. Never drawn.
  final String expandLabel;

  @override
  State<PlBreadcrumb> createState() => _PlBreadcrumbState();
}

class _PlBreadcrumbState extends State<PlBreadcrumb> {
  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassColor get _color => widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;
  PlassDensity get _density =>
      widget.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

  bool _unfolded = false;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final family = tokens.family(_color);
    final total = widget.items.length;

    // The last step is the page you are on — unless a step says it is. Exactly
    // one step in a trail may be the current page, so a caller who marks an
    // earlier one takes the mark off the last.
    final claimed = widget.items.any((PlBreadcrumbItem step) => step.current == true);

    final folding =
        !_unfolded &&
        widget.maxItems != null &&
        total > (widget.maxItems! < 1 ? 1 : widget.maxItems!) &&
        // A fold has to actually remove something. With one before and one after
        // on a three-step trail the `…` would stand in for exactly one step,
        // which is longer than the step it replaced.
        total - widget.itemsBeforeCollapse - widget.itemsAfterCollapse > 1;

    final before = widget.itemsBeforeCollapse < 0 ? 0 : widget.itemsBeforeCollapse;
    final after = widget.itemsAfterCollapse < 0 ? 0 : widget.itemsAfterCollapse;

    final shown = folding
        ? <PlBreadcrumbItem?>[
            ...widget.items.take(before),
            null,
            ...widget.items.skip(total - after),
          ]
        : <PlBreadcrumbItem?>[...widget.items];

    final mark = widget.separatorWidget ?? _mark(tokens, family);
    final trail = <Widget>[];

    for (var index = 0; index < shown.length; index += 1) {
      if (index > 0) {
        trail.add(ExcludeSemantics(child: mark));
      }

      final step = shown[index];

      trail.add(
        step == null
            ? _Fold(
                expandable: widget.expandable,
                label: widget.expandLabel,
                size: _size,
                family: family,
                muted: tokens.mutedFg,
                onPressed: () => setState(() => _unfolded = true),
              )
            : _Step(
                item: step,
                current: step.current ?? (!claimed && index == shown.length - 1),
                size: _size,
                family: family,
                tokens: tokens,
              ),
      );
    }

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.label,
      child: DefaultTextStyle.merge(
        style: TextStyle(fontSize: controlText[_size]!, height: 1.4),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: _trailGap[_density]![_size]!,
          runSpacing: _trailGap[_density]![_size]!,
          children: trail,
        ),
      ),
    );
  }

  /// The four marks.
  ///
  /// The two that point are the house glyph turned rather than redrawn, the same
  /// allowance the no-transform rule makes elsewhere: the wedge is drawn
  /// pointing down once, and a trail turns it a quarter. Both turn back under
  /// RTL, because a trail runs the way the language does.
  Widget _mark(PlassTokens tokens, PlassColorFamily family) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final glyph = controlText[_size]! * iconScale;

    switch (widget.separator) {
      case PlBreadcrumbSeparator.chevron:
        return PlassGlyph(
          PlassGlyphShape.chevron,
          size: glyph,
          color: tokens.mutedFg,
          quarterTurns: rtl ? 1 : -1,
        );
      case PlBreadcrumbSeparator.arrow:
        return PlassGlyph(
          PlassGlyphShape.arrowRight,
          size: glyph,
          color: tokens.mutedFg,
          quarterTurns: rtl ? 2 : 0,
        );
      case PlBreadcrumbSeparator.slash:
        return Text('/', style: TextStyle(color: tokens.mutedFg.withValues(alpha: 0.7)));
      case PlBreadcrumbSeparator.dot:
        return Text('·', style: TextStyle(color: tokens.mutedFg.withValues(alpha: 0.7)));
    }
  }
}

/// One drawn step.
class _Step extends StatelessWidget {
  const _Step({
    required this.item,
    required this.current,
    required this.size,
    required this.family,
    required this.tokens,
  });

  final PlBreadcrumbItem item;
  final bool current;
  final PlassSize size;
  final PlassColorFamily family;
  final PlassTokens tokens;

  @override
  Widget build(BuildContext context) {
    final interactive = item.onPressed != null && !current && !item.disabled;
    final radius = BorderRadius.circular(PlassTokens.radius[_stepRadiusScale[size]!]!);
    final line = controlText[size]! * 1.4;

    Widget slot(Widget content) {
      return SizedBox(
        height: line,
        child: Center(child: content),
      );
    }

    Widget body(PlassInteraction state) {
      final ink = item.disabled
          ? tokens.mutedFg
          : current
          ? tokens.fg
          : interactive && state.hovered
          ? family.accent
          : tokens.mutedFg;

      Widget content = DefaultTextStyle.merge(
        style: TextStyle(color: ink, fontWeight: current ? FontWeight.w500 : null),
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        child: IconTheme.merge(
          data: IconThemeData(color: ink, size: controlText[size]! * iconScale),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: gap[size]!,
            children: <Widget>[
              if (item.startIcon != null) slot(item.startIcon!),
              Flexible(child: item.label),
              if (item.endIcon != null) slot(item.endIcon!),
            ],
          ),
        ),
      );

      content = AnimatedContainer(
        duration: PlassTokens.duration,
        curve: PlassTokens.ease,
        decoration: BoxDecoration(
          color: interactive && state.hovered ? family.soft : null,
          borderRadius: radius,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: content,
      );

      content = plassStateFilter(child: content, disabled: item.disabled, lit: false);

      if (state.focusVisible) {
        content = CustomPaint(
          foregroundPainter: PlassFocusRingPainter(color: family.ring, borderRadius: radius),
          child: content,
        );
      }

      return content;
    }

    if (!interactive) {
      return Semantics(
        container: true,
        enabled: !item.disabled,
        // The step the reader is on is a *page*, not the chosen one of a set of
        // options — which is why it is a header rather than a selection.
        header: current,
        child: body(const PlassInteraction()),
      );
    }

    return PlassInteractive(
      onTap: item.onPressed,
      shortcuts: PlassInteractive.enterOnly,
      builder: (BuildContext context, PlassInteraction state) {
        return Semantics(container: true, link: true, onTap: item.onPressed, child: body(state));
      },
    );
  }
}

/// The `…` that stands in for the middle of a folded trail.
class _Fold extends StatelessWidget {
  const _Fold({
    required this.expandable,
    required this.label,
    required this.size,
    required this.family,
    required this.muted,
    required this.onPressed,
  });

  final bool expandable;
  final String label;
  final PlassSize size;
  final PlassColorFamily family;
  final Color muted;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final glyph = controlText[size]! * iconScale;
    final radius = BorderRadius.circular(PlassTokens.radius[PlassSize.xs]!);

    if (!expandable) {
      return ExcludeSemantics(
        child: PlassGlyph(PlassGlyphShape.ellipsis, size: glyph, color: muted),
      );
    }

    return PlassInteractive(
      onTap: onPressed,
      builder: (BuildContext context, PlassInteraction state) {
        Widget mark = AnimatedContainer(
          duration: PlassTokens.duration,
          curve: PlassTokens.ease,
          decoration: BoxDecoration(
            color: state.hovered ? family.soft : null,
            borderRadius: radius,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: PlassGlyph(
            PlassGlyphShape.ellipsis,
            size: glyph,
            color: state.hovered ? family.accent : muted,
          ),
        );

        if (state.focusVisible) {
          mark = CustomPaint(
            foregroundPainter: PlassFocusRingPainter(color: family.ring, borderRadius: radius),
            child: mark,
          );
        }

        return Semantics(
          container: true,
          button: true,
          label: label,
          onTap: onPressed,
          child: mark,
        );
      },
    );
  }
}
