import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';
import 'package:plass_ui_example/demos/glyphs.dart';

/// The width the content of a screen stops growing at.
const double contentWidth = 880;

/// The width at which the bottom bar gives way to a sidebar.
const double railBreakpoint = 720;

/// The route every screen is pushed with: the next page slides in from the end.
class ShowcaseRoute<T> extends PageRoute<T> {
  /// Creates the route.
  ShowcaseRoute({required this.builder, super.settings});

  /// Builds the page.
  final WidgetBuilder builder;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 260);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      textDirection: Directionality.of(context),
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    );
  }
}

/// The wash every screen sits on, so a glass surface has something to blur.
class Wash extends StatelessWidget {
  /// Creates the wash.
  const Wash({required this.child, super.key});

  /// What sits on it.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[tokens.bgFrom, tokens.bgTo],
        ),
      ),
      child: child,
    );
  }
}

/// A screen: a title, what it holds, and room for the system's bars.
class ScreenScroll extends StatelessWidget {
  /// Creates the screen.
  const ScreenScroll({
    required this.title,
    required this.children,
    this.subtitle,
    this.action,
    this.bottomInset = 0,
    this.controller,
    super.key,
  });

  /// The heading.
  final String title;

  /// The line under the heading.
  final String? subtitle;

  /// A control at the end of the heading.
  final Widget? action;

  /// What the screen holds, top to bottom.
  final List<Widget> children;

  /// Room held under the content, for a bar over it.
  final double bottomInset;

  /// Drives the scroll position.
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final safe = MediaQuery.paddingOf(context);

    return ListView(
      controller: controller,
      padding: EdgeInsets.fromLTRB(16, safe.top + 12, 16, safe.bottom + bottomInset + 24),
      children: <Widget>[
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: contentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: <Widget>[
                Row(
                  spacing: 12,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Semantics(
                            header: true,
                            child: Text(
                              title,
                              style: TextStyle(
                                color: tokens.fg,
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                          ),
                          if (subtitle != null)
                            Text(subtitle!, style: TextStyle(color: tokens.mutedFg, fontSize: 14)),
                        ],
                      ),
                    ),
                    ?action,
                  ],
                ),
                ...children,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A pushed screen: a back button over a [Wash].
class PushedScreen extends StatelessWidget {
  /// Creates the screen.
  const PushedScreen({required this.title, required this.child, super.key});

  /// The heading in the bar.
  final String title;

  /// What fills the rest of the screen.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final safe = MediaQuery.paddingOf(context);

    return Wash(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(8, safe.top + 4, 16, 4),
            child: Row(
              spacing: 4,
              children: <Widget>[
                PlIconButton(
                  label: 'Back',
                  variant: PlassVariant.ghost,
                  color: PlassColor.secondary,
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Directional(child: BackGlyph()),
                ),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: tokens.fg, fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: MediaQuery.removePadding(context: context, removeTop: true, child: child),
          ),
        ],
      ),
    );
  }
}

/// Mirrors [child] in a right-to-left screen.
class Directional extends StatelessWidget {
  /// Creates the mirror.
  const Directional({required this.child, super.key});

  /// The glyph.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;

    return rtl ? Transform.flip(flipX: true, child: child) : child;
  }
}

/// A chevron pointing back.
class BackGlyph extends StatelessWidget {
  /// Creates the chevron.
  const BackGlyph({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);

    return CustomPaint(
      size: Size.square(theme.size ?? 20),
      painter: _ChevronPainter(theme.color ?? const Color(0xFF000000)),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.shortestSide / 24;
    final path = Path()
      ..moveTo(15 * unit, 5 * unit)
      ..lineTo(8 * unit, 12 * unit)
      ..lineTo(15 * unit, 19 * unit);

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8 * unit
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_ChevronPainter oldDelegate) => oldDelegate.color != color;
}

/// The glyphs of the five destinations.
const Map<String, Widget> destinationGlyphs = <String, Widget>{
  'overview': HomeGlyph(),
  'inbox': BellGlyph(),
  'orders': BookmarkGlyph(),
  'request': PlusGlyph(),
  'more': MoreGlyph(),
};
