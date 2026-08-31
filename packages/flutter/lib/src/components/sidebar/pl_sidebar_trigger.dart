/// The button that brings back a collapsed sidebar.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/icon_button/pl_icon_button.dart';
import 'package:plass_ui/src/internal/page_layout.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/types.dart';

/// Three lines.
///
/// Drawn here rather than in `internal/icons.dart` because this is the only
/// widget that needs it — the same place [PlAvatar] keeps its silhouette. It is
/// the one glyph in the package that is a picture of a *menu* rather than a
/// picture of what it does, and it is drawn anyway: thirty years of it have
/// made it the one shape a reader recognises without a word beside it, which is
/// the only argument that ever justifies a symbol.
class _MenuGlyph extends StatelessWidget {
  const _MenuGlyph();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _MenuPainter(DefaultTextStyle.of(context).style.color));
  }
}

class _MenuPainter extends CustomPainter {
  const _MenuPainter(this.color);

  final Color? color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color ?? const Color(0xFF000000)
      ..strokeWidth = size.shortestSide * (2 / 24)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final double at in <double>[7 / 24, 12 / 24, 17 / 24]) {
      canvas.drawLine(
        Offset(size.width * (4 / 24), size.height * at),
        Offset(size.width * (20 / 24), size.height * at),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_MenuPainter oldDelegate) => oldDelegate.color != color;
}

/// The button that brings back a [PlSidebar] the screen has become too narrow
/// to hold.
///
/// ```dart
/// PlHeader(brand: const <Widget>[PlSidebarTrigger(), Text('Acme')])
/// ```
///
/// It draws nothing while the sidebar is a column, and nothing at all outside a
/// [PlPageLayout] — there is no sidebar it could be talking about. Put it in a
/// [PlHeader]'s `brand` slot, ahead of the logo, which is where thirty years of
/// hamburgers have taught readers to look for it.
class PlSidebarTrigger extends StatelessWidget {
  /// Creates the button that opens a collapsed sidebar.
  const PlSidebarTrigger({
    this.side = PlassSidebarSide.start,
    this.icon,
    this.label,
    this.variant = PlassVariant.ghost,
    this.size,
    this.color,
    super.key,
  });

  /// Which of the layout's two sidebars it opens.
  final PlassSidebarSide side;

  /// The glyph. A hamburger, drawn here, unless something else is given.
  final Widget? icon;

  /// What it does, in words. `'Open sidebar'` or `'Close sidebar'`.
  final String? label;

  /// What the key is made of. `ghost` by default: it sits on a bar that is
  /// already a sheet.
  final PlassVariant variant;

  /// The key's size.
  final PlassSize? size;

  /// Semantic colour role.
  final PlassColor? color;

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final color = this.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;

    final PlassPageLayoutScope? layout = PlassPageLayoutScope.maybeOf(context);

    // Nothing to open, and — unlike the React build, which hides the button
    // with a media query so it is in the markup a server sends — nothing to
    // draw while the sidebar is a column either. There is no first paint to
    // hold together here.
    if (layout == null || !layout.collapsed) {
      return const SizedBox.shrink();
    }

    final bool open = layout.open[side] ?? false;

    return PlIconButton(
      onPressed: () => layout.setOpen(side, !open),
      variant: variant,
      size: size,
      color: color,
      label: label ?? (open ? 'Close sidebar' : 'Open sidebar'),
      icon: icon ?? const _MenuGlyph(),
    );
  }
}
