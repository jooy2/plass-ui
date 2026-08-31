/// A stack of avatars, overlapping, with the ones that did not fit as a count.
library;

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/components/avatar/pl_avatar.dart';
import 'package:plass_ui/src/internal/avatar_group.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// How far one avatar sits under the last, per step.
///
/// Roughly a third of the box at every size: enough that the stack reads as a
/// stack, and not so much that a face is hidden behind the next one.
const Map<PlassSize, double> _overlap = <PlassSize, double>{
  PlassSize.xs: 8,
  PlassSize.sm: 10,
  PlassSize.md: 14,
  PlassSize.lg: 16,
  PlassSize.xl: 20,
};

/// The width of the gap drawn between two overlapping faces.
const double _ring = 2;

/// A stack of avatars, overlapping, with the ones that did not fit as a count.
///
/// ```dart
/// PlAvatarGroup(
///   max: 4,
///   total: 11,
///   avatars: <PlAvatar>[
///     PlAvatar(name: 'Ada Lovelace'),
///     PlAvatar(name: 'Grace Hopper'),
///   ],
/// )
/// ```
///
/// [size], [shape], [variant], [color] and [elevation] are set once here rather
/// than on every avatar — a stack whose fourth face is a size out is not a stack
/// — and an avatar's own value still wins, which is what lets one of them be
/// marked out from the rest.
///
/// Each face carries a ring in the page's own sheet colour, and it is not
/// decoration: two circles of similar tone laid over each other have no boundary
/// between them at all and the stack reads as one smeared shape. Drawn in
/// `PlassTokens.surface` it reads as the *hole* the near face is cut out of
/// rather than as a line around anything.
class PlAvatarGroup extends StatelessWidget {
  /// Creates a stack of avatars.
  const PlAvatarGroup({
    required this.avatars,
    this.max,
    this.total,
    this.overlap,
    this.shape = PlAvatarShape.circle,
    this.variant = PlassVariant.ghost,
    this.size,
    this.color,
    this.elevation = 0,
    this.semanticLabel,
    super.key,
  }) : assert(max == null || max >= 0, 'max cannot be negative'),
       assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// The faces, in the order the stack shows them.
  ///
  /// Typed as [PlAvatar] rather than as widgets because the stack has to know
  /// how wide a face is to lay the next one over it, and because each of them
  /// is given the group's axes to fill in whatever it did not say itself.
  final List<PlAvatar> avatars;

  /// How many faces are drawn before the rest become a count. Left out, every
  /// one of them is drawn.
  final int? max;

  /// How many there are altogether, when the group was handed only the first
  /// few. Without it the count is worked out from [avatars], which is right only
  /// when all of them were passed.
  final int? total;

  /// How far each avatar sits under the one before it, in logical pixels. Left
  /// out it is a fraction of [size], which keeps the overlap looking the same at
  /// every step.
  final double? overlap;

  /// Passed to every avatar in the group.
  final PlAvatarShape shape;

  /// See [shape].
  final PlassVariant variant;

  /// See [shape].
  final PlassSize? size;

  /// See [shape].
  final PlassColor? color;

  /// See [shape].
  final PlassElevation elevation;

  /// What the stack is a stack *of*, for a screen reader.
  ///
  /// A row of faces is a picture of a set, and what it is a set of is the
  /// sentence beside it — name the group when nothing else is saying so.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
    final color = this.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;

    final PlassTokens tokens = PlassTheme.of(context);

    final List<PlAvatar> shown = max == null
        ? avatars
        : avatars.sublist(0, max!.clamp(0, avatars.length));
    final int counted = total ?? avatars.length;
    final int hidden = counted - shown.length;

    final List<PlAvatar> faces = <PlAvatar>[
      ...shown,
      if (hidden > 0) PlAvatar(initials: '+$hidden'),
    ];

    // The plate behind a face is the ring, so the box a face occupies is its own
    // box plus one on each side — and the step has to be measured against that
    // rather than against the avatar.
    final double box = controlHeight[size]! + _ring * 2;
    final double step = (box - (overlap ?? _overlap[size]!)).clamp(0, box);

    final BorderRadius radius = shape == PlAvatarShape.circle
        ? BorderRadius.circular(box)
        : BorderRadius.circular(PlassTokens.radius[size]! + _ring);

    // Flutter has no negative margin — `EdgeInsets` asserts it is non-negative —
    // so the overlap is a `Stack` of faces each pushed one step further along.
    // The stack takes the size of its widest child, which is the last one, so
    // the row still measures exactly as wide as it draws. Later faces paint over
    // earlier ones, which is the order the stylesheet produces too.
    final Widget stack = Stack(
      alignment: AlignmentDirectional.topStart,
      children: <Widget>[
        for (int index = 0; index < faces.length; index += 1)
          Padding(
            padding: EdgeInsetsDirectional.only(start: index * step),
            child: Container(
              padding: const EdgeInsets.all(_ring),
              decoration: BoxDecoration(color: tokens.surface, borderRadius: radius),
              child: faces[index],
            ),
          ),
      ],
    );

    return Semantics(
      label: semanticLabel,
      container: semanticLabel != null,
      // The faces keep their own nodes, so a named stack is read as its name and
      // then as the people in it rather than as one run-on sentence.
      explicitChildNodes: semanticLabel != null,
      child: PlassAvatarGroupScope(
        shape: shape,
        variant: variant,
        size: size,
        color: color,
        elevation: elevation,
        child: stack,
      ),
    );
  }
}
