/// One message in a conversation.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/css.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/inset_shadow.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// How far the corner nearest the speaker is cut short.
///
/// This is the library's one piece of chat vocabulary, and it does the job a
/// drawn tail does elsewhere: it says which end of the row a message came from,
/// without hanging a triangle off a sheet of glass that was cut with a straight
/// edge.
///
/// A flat 4 rather than a step down the radius ladder, and that is the whole
/// point of writing it out: the ladder runs 8 to 16, so one step is a difference
/// nobody would ever read as meaning something. The cut has to be obvious at a
/// glance in a column of forty messages or it is not saying anything.
const double _tailRadius = 4;

/// How wide a bubble is allowed to get.
const double _maxWidth = 512;

/// A bubble's own padding track, tighter than a sheet's.
///
/// A sheet is a region of a page and a bubble is a sentence with a surface
/// behind it: twenty pixels of padding around eight words is a card, not a
/// message. Both axes, because unlike a control a bubble has no height to fight.
const Map<PlassDensity, Map<PlassSize, Offset>> _bubblePadding =
    <PlassDensity, Map<PlassSize, Offset>>{
      PlassDensity.standard: <PlassSize, Offset>{
        PlassSize.xs: Offset(8, 4),
        PlassSize.sm: Offset(10, 6),
        PlassSize.md: Offset(12, 8),
        PlassSize.lg: Offset(14, 10),
        PlassSize.xl: Offset(16, 12),
      },
      PlassDensity.compact: <PlassSize, Offset>{
        PlassSize.xs: Offset(6, 2),
        PlassSize.sm: Offset(8, 4),
        PlassSize.md: Offset(10, 6),
        PlassSize.lg: Offset(12, 6),
        PlassSize.xl: Offset(14, 8),
      },
    };

/// The gap between the avatar, the bubble and whatever sits beside it.
const double _rowGap = 8;

/// How large a status mark is drawn against the line it sits on.
const double _markScale = 1.15;

/// A typing dot, as a fraction of the line it sits on.
const double _dotScale = 0.45;

/// How long one dot takes to come up and go down again.
const Duration _dotCycle = Duration(milliseconds: 1200);

/// Whose message this is.
///
/// `start` and `end` rather than `them`/`me` or `left`/`right`: a thread runs
/// the way the language does, and the same two words already mean this
/// everywhere else in the library.
enum PlChatBubbleSide {
  /// From someone else — the default, because a message from someone else is the
  /// one you have no other way of knowing about.
  start,

  /// From the reader.
  end,
}

/// How far a message has got.
///
/// The four steps are a ladder and the fifth is not on it: [failed] is the
/// message that did not go, which is why it is the only one drawn in another
/// colour family.
enum PlChatBubbleStatus {
  /// On its way.
  sending,

  /// It left.
  sent,

  /// It arrived.
  delivered,

  /// It was read.
  read,

  /// It did not go.
  failed,
}

/// What a link inside a message unfurls to.
@immutable
class PlChatBubbleLinkPreview {
  /// Creates a card.
  const PlChatBubbleLinkPreview({
    this.onPressed,
    this.title,
    this.description,
    this.image,
    this.site,
  });

  /// Called when the card is pressed.
  ///
  /// There is no `url`: Flutter has no navigation of its own, so where a link
  /// goes is the app's and this is where it is decided — the same trade a
  /// [PlTextLink] makes.
  final VoidCallback? onPressed;

  /// The page's title.
  final Widget? title;

  /// Its summary, clamped to two lines.
  final Widget? description;

  /// The share image, drawn across the top of the card.
  final ImageProvider<Object>? image;

  /// Who published it — a domain, a site name.
  final Widget? site;
}

/// One message in a conversation.
///
/// ```dart
/// PlChatBubble(
///   side: PlChatBubbleSide.end,
///   variant: PlassVariant.solid,
///   status: PlChatBubbleStatus.read,
///   child: const Text('On my way.'),
/// )
/// ```
///
/// Everything around the bubble is optional and nothing about it is fixed by
/// [side]: the avatar, the sender's name, the time, the delivery mark, the media
/// above the text and the link card below it are each drawn only when they are
/// given something. What [side] decides is which way the row runs and which
/// corner of the sheet is cut short.
///
/// [variant] is what tells your own messages from everyone else's, and it is
/// deliberately not tied to [side] — filling one column is a convention, not a
/// law, and a thread that fills neither is a perfectly good thread.
class PlChatBubble extends StatelessWidget {
  /// Creates a message.
  const PlChatBubble({
    this.side = PlChatBubbleSide.start,
    this.name,
    this.time,
    this.avatar,
    this.status,
    this.statusLabel,
    this.typing = false,
    this.typingLabel = 'Typing…',
    this.media,
    this.preview,
    this.actions,
    this.variant = PlassVariant.glass,
    this.size,
    this.color,
    this.density,
    this.elevation = 0,
    this.child,
    super.key,
  }) : assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// Whose message this is.
  final PlChatBubbleSide side;

  /// Who sent it, above the bubble.
  final Widget? name;

  /// When it was sent, beside the name.
  final Widget? time;

  /// The sender's picture — a [PlAvatar], at the size the thread uses. Left out,
  /// the bubble takes the whole row.
  final Widget? avatar;

  /// How far the message has got, drawn as a mark under the bubble.
  ///
  /// Left out, nothing is drawn: a received message has no delivery state worth
  /// showing.
  final PlChatBubbleStatus? status;

  /// What the mark is read out as. Never drawn.
  final String? statusLabel;

  /// Draws the three dots instead of the message.
  ///
  /// What [child] holds is left alone, so the same bubble can go back to it when
  /// the message arrives.
  final bool typing;

  /// What the dots are read out as. Never drawn.
  final String typingLabel;

  /// A picture, a video, a map — drawn edge to edge above the text, so the
  /// bubble's corners crop it.
  final Widget? media;

  /// A link in the message, unfurled into a card under the text.
  final PlChatBubbleLinkPreview? preview;

  /// The message's own actions — a menu trigger, most of the time.
  ///
  /// Sits beside the bubble. Unlike the React build it does not fade in on
  /// hover: a pointer is not the only way a thread is read here, and a handle
  /// that appears only under one is a handle a finger never finds.
  final Widget? actions;

  /// What the bubble's surface is made of.
  final PlassVariant variant;

  /// Type scale, radius and padding.
  final PlassSize? size;

  /// Semantic colour role.
  final PlassColor? color;

  /// Padding inside the bubble, and nothing else.
  final PlassDensity? density;

  /// Drop shadow depth, `0`–`3`.
  ///
  /// `0` is the default — a message lies in the thread rather than floating over
  /// it.
  final PlassElevation elevation;

  /// The message.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final color = this.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;
    final density = this.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

    final tokens = PlassTheme.of(context);
    final family = tokens.family(color);
    final end = side == PlChatBubbleSide.end;
    final meta = metaText[size]!;
    final body = sheetBody[size]!;
    final solid = variant == PlassVariant.solid;
    final ink = solid ? family.onSolid : tokens.fg;

    final radius = PlassTokens.radius[size]!;

    // The tightened corner is the one that faces the sender, and which side of
    // the screen that is depends on the writing direction as much as on `side`.
    // Resolved here rather than written as a `BorderRadiusDirectional` because
    // the same value reaches a `ClipRRect` and a `PlassSurface`, and one of
    // those takes a resolved [BorderRadius].
    final tailRight = end != (Directionality.of(context) == TextDirection.rtl);
    final corners = BorderRadius.only(
      topLeft: Radius.circular(tailRight ? radius : _tailRadius),
      topRight: Radius.circular(tailRight ? _tailRadius : radius),
      bottomLeft: Radius.circular(radius),
      bottomRight: Radius.circular(radius),
    );

    // A bubble *is* the thing being coloured — unlike a card, which holds other
    // people's content and so keeps its sheet undyed — so `solid` floods it and
    // the text switches with it. That is what makes a column of your own
    // messages read as yours at a glance rather than one line at a time.
    final surface = switch (variant) {
      PlassVariant.solid => PlassSurface(
        gradient: family.fill,
        ink: family.onSolid,
        shadows: <BoxShadow>[...tokens.elevation(elevation), tokens.lift(family)],
      ),
      PlassVariant.glass => PlassSurface(
        fill: tokens.glass,
        border: Border.all(color: tokens.glassLine, width: hairline),
        ink: tokens.fg,
        blur: true,
        insets: <PlassInsetShadow>[tokens.glossGlass],
        shadows: tokens.elevation(elevation),
      ),
      PlassVariant.ghost => PlassSurface(
        fill: family.soft,
        ink: tokens.fg,
        shadows: tokens.elevation(elevation),
      ),
    };

    final padding = _bubblePadding[density]![size]!;
    final hasBody = typing || child != null || preview != null;

    final bubble = PlassSurfaceBox(
      surface: surface,
      borderRadius: corners,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Edge to edge: the bubble's own corners are what crop it, which is
          // why the padding lives on the sections rather than on the sheet.
          ?media,
          if (hasBody)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding.dx, vertical: padding.dy),
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  color: ink,
                  fontSize: body.size,
                  height: body.height,
                  leadingDistribution: TextLeadingDistribution.even,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: <Widget>[
                    if (typing)
                      _TypingDots(color: ink, line: body.line, label: typingLabel)
                    else
                      ?child,
                    if (preview != null) _Preview(preview: preview!, ink: ink, ring: family.ring),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    final column = Column(
      crossAxisAlignment: end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: sheetHeaderGap[size]!,
      children: <Widget>[
        if (name != null || time != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            spacing: _rowGap,
            children: <Widget>[
              if (name != null)
                DefaultTextStyle.merge(
                  style: TextStyle(color: tokens.fg, fontSize: meta, fontWeight: FontWeight.w600),
                  child: name!,
                ),
              if (time != null)
                DefaultTextStyle.merge(
                  style: TextStyle(color: tokens.mutedFg, fontSize: meta),
                  child: time!,
                ),
            ],
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: end ? _flip(context) : null,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 4,
          children: <Widget>[
            // As wide as its message and no wider. The sheet inside stretches
            // its sections — the media has to reach both edges — and a column
            // that stretches takes every pixel it is offered, so the shrinking
            // has to happen out here.
            Flexible(child: IntrinsicWidth(child: bubble)),
            ?actions,
          ],
        ),
        if (status != null) _mark(tokens, family, meta),
      ],
    );

    return Row(
      textDirection: end ? _flip(context) : null,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: _rowGap,
      children: <Widget>[
        ?avatar,
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            // Back the right way up: the row above it runs backwards to put the
            // avatar on the far side, and everything inside it would otherwise
            // be mirrored with it.
            child: Directionality(textDirection: Directionality.of(context), child: column),
          ),
        ),
      ],
    );
  }

  /// The direction a row runs when the message is the reader's own.
  ///
  /// Reversing the direction rather than reversing the list, so the row is
  /// mirrored for a thread in Arabic without being told twice.
  TextDirection _flip(BuildContext context) {
    return Directionality.of(context) == TextDirection.ltr ? TextDirection.rtl : TextDirection.ltr;
  }

  /// The delivery mark, and the word behind it.
  ///
  /// Only two of the five carry a colour: the one that arrived and the one that
  /// did not. The three in between are the ordinary course of events, and a
  /// thread where every message is marked in colour is a thread where the colour
  /// has stopped meaning anything.
  Widget _mark(PlassTokens tokens, PlassColorFamily family, double meta) {
    final shape = switch (status!) {
      PlChatBubbleStatus.sending => PlassGlyphShape.clock,
      PlChatBubbleStatus.sent => PlassGlyphShape.check,
      PlChatBubbleStatus.delivered || PlChatBubbleStatus.read => PlassGlyphShape.doubleCheck,
      PlChatBubbleStatus.failed => PlassGlyphShape.dangerMark,
    };
    final tone = switch (status!) {
      PlChatBubbleStatus.sending ||
      PlChatBubbleStatus.sent ||
      PlChatBubbleStatus.delivered => tokens.mutedFg,
      PlChatBubbleStatus.read => family.accent,
      PlChatBubbleStatus.failed => tokens.family(PlassColor.danger).accent,
    };
    final spoken = switch (status!) {
      PlChatBubbleStatus.sending => 'Sending',
      PlChatBubbleStatus.sent => 'Sent',
      PlChatBubbleStatus.delivered => 'Delivered',
      PlChatBubbleStatus.read => 'Read',
      PlChatBubbleStatus.failed => 'Not delivered',
    };

    // The mark is the whole of what is drawn; the word behind it is for the
    // readers the mark says nothing to.
    return Semantics(
      container: true,
      label: statusLabel ?? spoken,
      child: PlassGlyph(shape, size: meta * _markScale, color: tone),
    );
  }
}

/// Three dots that light in sequence.
///
/// Colour only, like every other indeterminate indicator in the library — the
/// dots never move, so a bubble being typed into does not bounce in a thread
/// somebody is reading.
class _TypingDots extends StatefulWidget {
  const _TypingDots({required this.color, required this.line, required this.label});

  final Color color;
  final double line;
  final String label;

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _turn = AnimationController(vsync: this, duration: _dotCycle)
    ..repeat();

  @override
  void dispose() {
    _turn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final dot = widget.line * _dotScale;

    if (reduceMotion && _turn.isAnimating) {
      _turn.stop();
    } else if (!reduceMotion && !_turn.isAnimating) {
      _turn.repeat();
    }

    return Semantics(
      container: true,
      liveRegion: true,
      label: widget.label,
      child: SizedBox(
        height: widget.line,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: dot * 0.9,
          children: <Widget>[
            for (var index = 0; index < 3; index += 1)
              AnimatedBuilder(
                animation: _turn,
                builder: (BuildContext context, Widget? child) {
                  // A third of the cycle apart, so the three read as one wave
                  // rather than as three lights.
                  final phase = (_turn.value + index / 3) % 1;
                  final lit = 0.35 + 0.65 * (1 - (phase * 2 - 1).abs());

                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: widget.color.a * lit),
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox.square(dimension: dot),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// The unfurled link: an image, who published it, a title and two lines of
/// summary.
///
/// Its surface is mixed out of the ink rather than out of a token, because it is
/// the one part of a bubble that has to work on both a filled surface and a bare
/// one: on `solid` the text is white and the card is a white wash, on `glass`
/// the text is the page's ink and the card is a grey one. A fixed token would be
/// invisible against one of the two.
class _Preview extends StatelessWidget {
  const _Preview({required this.preview, required this.ink, required this.ring});

  final PlChatBubbleLinkPreview preview;
  final Color ink;
  final Color ring;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(PlassTokens.radius[PlassSize.sm]!);

    return PlassInteractive(
      onTap: preview.onPressed,
      interactive: preview.onPressed != null,
      cursor: preview.onPressed == null ? MouseCursor.defer : SystemMouseCursors.click,
      builder: (BuildContext context, PlassInteraction state) {
        Widget card = DecoratedBox(
          decoration: BoxDecoration(
            color: colorMix(ink, state.hovered ? 12 : 7),
            border: Border.all(color: colorMix(ink, 18), width: hairline),
            borderRadius: radius,
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (preview.image != null)
                  // Decorative: everything the picture is saying is written
                  // underneath it.
                  SizedBox(
                    height: 112,
                    child: Image(image: preview.image!, fit: BoxFit.cover),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 2,
                    children: <Widget>[
                      if (preview.site != null)
                        DefaultTextStyle.merge(
                          style: TextStyle(color: ink.withValues(alpha: ink.a * 0.7)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 4,
                            children: <Widget>[
                              PlassGlyph(
                                PlassGlyphShape.link,
                                size: 12,
                                color: ink.withValues(alpha: ink.a * 0.7),
                              ),
                              Flexible(child: preview.site!),
                            ],
                          ),
                        ),
                      if (preview.title != null)
                        DefaultTextStyle.merge(
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          child: preview.title!,
                        ),
                      if (preview.description != null)
                        DefaultTextStyle.merge(
                          style: TextStyle(color: ink.withValues(alpha: ink.a * 0.8)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          child: preview.description!,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

        if (state.focusVisible) {
          card = CustomPaint(
            foregroundPainter: PlassFocusRingPainter(color: ring, borderRadius: radius),
            child: card,
          );
        }

        return Semantics(
          container: true,
          link: preview.onPressed != null,
          onTap: preview.onPressed,
          child: card,
        );
      },
    );
  }
}
