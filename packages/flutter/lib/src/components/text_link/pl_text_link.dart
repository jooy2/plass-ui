/// A link, in a sentence or on its own.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/types.dart';

/// When the line under a link is drawn.
enum PlTextLinkUnderline {
  /// The default, and the reason is [PlTextLink.color]: a link takes no colour
  /// family unless one is asked for, so with the line off there would be
  /// nothing at all distinguishing it from the sentence it sits in.
  always,

  /// Only under the pointer.
  hover,

  /// Never — a real choice for a link in a nav bar or a footer, where position
  /// already says what it is. It has to be spelled out rather than fallen into,
  /// which is why this is an enum rather than a boolean.
  none,
}

/// How thick the line under a link is.
const double _underlineWidth = 1;

/// How strong the line is at rest, against the text it is under.
///
/// It goes to the full colour on hover, so it works the same on an inherited
/// colour as on an accent one.
const double _underlineRest = 0.45;

/// How large the mark after the label is, against that label.
///
/// Just under its cap height, rather than the 1.2em an icon inside a control
/// takes: this one sits in a sentence, and a glyph as tall as the line spaces
/// the words around it apart.
const double _markScale = 0.95;

/// A link, in a sentence or on its own.
///
/// ```dart
/// PlTextLink(onPressed: () => open(url), child: const Text('the changelog'))
/// ```
///
/// Everything about it is deliberately smaller than a button. It has no
/// surface, no height of its own and no colour unless asked — what it has is a
/// line under it, which is the one mark a reader already knows means "this goes
/// somewhere".
///
/// There is no `href`, and that is the one real difference from the React
/// build: Flutter has no navigation of its own, so where a link *goes* is the
/// app's to decide. [onPressed] is where it is decided.
class PlTextLink extends StatelessWidget {
  /// Creates a link.
  const PlTextLink({
    required this.child,
    this.onPressed,
    this.underline = PlTextLinkUnderline.always,
    this.color,
    this.size,
    this.external = false,
    this.icon,
    this.startIcon,
    this.showIcon,
    this.externalLabel = '(opens elsewhere)',
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  /// The label.
  final Widget child;

  /// Called when the link is followed, by pointer or by keyboard.
  ///
  /// Leaving it `null` makes the link inert, which is what a link to the page
  /// you are already on should be.
  final VoidCallback? onPressed;

  /// When the underline is drawn.
  final PlTextLinkUnderline underline;

  /// Semantic colour role.
  ///
  /// Unlike every control in the library this has **no default** — a link in a
  /// paragraph is usually the paragraph's own colour with a line under it, and a
  /// component that arrived pre-dyed is one a page has to undo.
  final PlassColor? color;

  /// The type scale.
  ///
  /// Also no default: a link inside a sentence is the size of the sentence. Set
  /// it for a link that stands on its own.
  final PlassSize? size;

  /// Whether the link leaves the app — a browser, another program, a different
  /// window.
  ///
  /// Something changing out from under the reader is the one thing about a link
  /// that cannot be seen before it happens, so this turns the mark on by default
  /// and adds a line for a screen reader.
  final bool external;

  /// The mark after the label. Left out, the house glyph is used: the arrow
  /// leaving its box when [external] is on, and the chain otherwise.
  ///
  /// It is [icon] rather than `endIcon`, and the difference from every other
  /// component's is the reason: this one is about the link's *destination* and
  /// it has an opinion — a link that leaves the app says so unless it is told
  /// not to. An `endIcon` elsewhere is a widget and nothing else.
  final Widget? icon;

  /// A mark before the label — a favicon, a file type, a lock.
  ///
  /// A plain widget with no opinion, unlike [icon] above: nothing is drawn here
  /// unless something is put here. It rides on the label at the same size and
  /// the same quarter-em away, so a link with one in front of it still sits
  /// inside a sentence.
  final Widget? startIcon;

  /// Whether a mark is drawn at all. Left out, it follows [external].
  ///
  /// Which is the whole reason it is not a plain `false` default: a link that
  /// takes the reader out of the app should say so, and a caller should have to
  /// ask for the silent version.
  final bool? showIcon;

  /// What a screen reader hears after the label on an [external] link. Never
  /// drawn.
  final String externalLabel;

  /// Drive focus from outside.
  final FocusNode? focusNode;

  /// Takes focus as it is inserted into the tree.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final inherited = DefaultTextStyle.of(context).style;
    final scale = size != null ? controlTextLeading[size!] : null;
    final ink = color != null ? tokens.family(color!).accent : inherited.color ?? tokens.fg;
    final ring = tokens.family(color ?? PlassTheme.colorOf(context) ?? PlassColor.primary).ring;
    final marked = showIcon ?? external;

    return PlassInteractive(
      onTap: onPressed,
      interactive: onPressed != null,
      focusNode: focusNode,
      autofocus: autofocus,
      // Not a button: a link goes somewhere, and a screen reader's list of
      // links is the thing that difference buys.
      shortcuts: PlassInteractive.enterOnly,
      builder: (BuildContext context, PlassInteraction state) {
        final lined =
            underline == PlTextLinkUnderline.always ||
            (underline == PlTextLinkUnderline.hover && state.hovered);

        Widget label = DefaultTextStyle.merge(
          style: TextStyle(
            color: ink,
            fontSize: scale?.size,
            height: scale?.height,
            decoration: lined ? TextDecoration.underline : TextDecoration.none,
            decorationThickness: _underlineWidth,
            // The line rests at 45% of whatever the text is and goes to the full
            // colour under the pointer.
            decorationColor: state.hovered ? ink : ink.withValues(alpha: ink.a * _underlineRest),
          ),
          child: child,
        );

        if (marked || startIcon != null) {
          final glyphSize = (scale?.size ?? inherited.fontSize ?? 14) * _markScale;

          label = Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              if (startIcon != null) ...<Widget>[
                IconTheme.merge(
                  data: IconThemeData(color: ink, size: glyphSize),
                  child: startIcon!,
                ),
                SizedBox(width: glyphSize * 0.25),
              ],
              Flexible(child: label),
              if (marked) ...<Widget>[
                SizedBox(width: glyphSize * 0.25),
                IconTheme.merge(
                  data: IconThemeData(color: ink, size: glyphSize),
                  child:
                      icon ??
                      PlassGlyph(
                        external ? PlassGlyphShape.externalLink : PlassGlyphShape.link,
                        size: glyphSize,
                        color: ink,
                      ),
                ),
              ],
            ],
          );
        }

        if (state.focusVisible) {
          label = CustomPaint(
            foregroundPainter: PlassFocusRingPainter(
              color: ring,
              borderRadius: BorderRadius.circular(4),
            ),
            child: label,
          );
        }

        return Semantics(
          container: true,
          link: true,
          enabled: onPressed != null,
          onTap: onPressed,
          // Drawn for nobody and read to everybody: the arrow says "leaves the
          // app" only to a reader who can see it.
          hint: external ? externalLabel : null,
          child: label,
        );
      },
    );
  }
}
