/// A glyph at a known size, in a known colour.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/types.dart';

/// A glyph at a known size, in a known colour.
///
/// The library draws no icons of its own beyond the handful its components
/// need — an icon set is a decision that belongs to the app, not to the
/// component library it installs. What this does is give whatever icon the app
/// chose the same two axes everything else here has.
///
/// ```dart
/// const PlIcon(icon: Icon(Icons.search), size: PlassSize.lg)
/// ```
///
/// The box is [iconSize] logical pixels square, and the glyph is told to fill
/// it three ways at once: through [IconTheme], through [DefaultTextStyle] and by
/// being laid into a box of exactly that size. So an [Icon], an [ImageIcon], a
/// drawing of your own and a bare character all come out the same size.
///
/// There is no `variant` and no `elevation`. An icon is not a surface: it is
/// ink, and the only thing the design language has to say about ink is which
/// family it is drawn in.
class PlIcon extends StatelessWidget {
  /// Creates an icon.
  const PlIcon({required this.icon, this.size = PlassSize.md, this.color, this.label, super.key});

  /// The glyph.
  ///
  /// It is a parameter rather than a `child` on purpose. An icon set hands you a
  /// widget you did not draw, and the two things you always want to change about
  /// it — how big it is and what colour it is — are the two you cannot reach once
  /// it is a child of something. As a parameter it is content the icon *sizes*,
  /// not content the icon merely wraps.
  final Widget icon;

  /// The box the glyph is drawn in: 14, 16, 20, 24 and 28px. Its own ladder
  /// rather than the control heights, because an icon is not a control — it is
  /// content, measured against the text beside it.
  final PlassSize size;

  /// Semantic colour role, or `null` — the default — to take the colour of
  /// whatever the icon is sitting in.
  ///
  /// Inheriting and not `primary`, which is the one place this parameter departs
  /// from every other component in the library. An icon is content, and the
  /// overwhelmingly common case is an icon inside something that has already
  /// decided what colour its content is: a button's label, a muted caption, an
  /// alert's own family. An icon that arrived pre-dyed would have to be turned
  /// off again at every one of those.
  final PlassColor? color;

  /// What the icon says, for a reader who cannot see it.
  ///
  /// Without it the icon is hidden from the accessibility tree entirely, which is
  /// the right default: the overwhelming majority of icons sit next to a word
  /// that already says the same thing, and reading both out loud is worse than
  /// reading one. Pass this only when the glyph carries meaning on its own.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final box = iconSize[size]!;
    final ink = color != null ? PlassTheme.of(context).family(color!).accent : null;

    Widget glyph = SizedBox.square(
      dimension: box,
      child: Center(
        child: IconTheme.merge(
          data: IconThemeData(size: box, color: ink),
          child: DefaultTextStyle.merge(
            // The box's own font size *is* the box, so a glyph authored in `em`
            // and one authored in pixels come out the same. Taking the
            // surrounding paragraph's size instead is the one thing that
            // certainly gets it wrong.
            style: TextStyle(fontSize: box, height: 1, color: ink),
            child: icon,
          ),
        ),
      ),
    );

    // An icon with something to say is an image with a name; one without is
    // furniture. There is no third case, and a name on a decorative glyph is the
    // most common way a screen reader ends up saying "graphic".
    glyph = label != null
        ? Semantics(
            label: label,
            image: true,
            container: true,
            child: ExcludeSemantics(child: glyph),
          )
        : ExcludeSemantics(child: glyph);

    return glyph;
  }
}
