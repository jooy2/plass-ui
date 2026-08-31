/// A row of small glass plates that light up.
library;

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/progress.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// A row of small glass plates that light up.
///
/// ```dart
/// PlProgressBox(label: const Text('Step 3 of 5'), value: 3, max: 5, count: 5)
/// ```
///
/// The third shape, and the one that is about the material rather than about the
/// quantity. A bar and a ring both say *how much of it is done*; a row of plates
/// says *this is working* in the library's own vocabulary — the same groove, the
/// same corner, the same gradient — which is what makes it the right one for a
/// loading state inside a Plass surface, where a foreign grey spinner would look
/// borrowed.
///
/// It answers a value when it has one: the plates fill in order, the leading one
/// partially, so four plates read as a four-segment bar rather than as four
/// quarters. Without a value they cycle, each held back by its own index — and
/// what cycles is the fill's **opacity**, because the fill is a gradient and a
/// gradient has nothing to interpolate toward when it is absent.
class PlProgressBox extends StatefulWidget {
  /// Creates a row of plates. With no [value] it is indeterminate and cycles.
  const PlProgressBox({
    this.value,
    this.min = 0,
    this.max = 100,
    this.count = 4,
    this.label,
    this.showValue = false,
    this.formatValue,
    this.size,
    this.color,
    super.key,
  });

  /// How far along, between [min] and [max]. `null` — the default — is the
  /// indeterminate case, and a value outside the range is clamped.
  final double? value;

  /// The bottom of the range.
  final double min;

  /// The top of it.
  final double max;

  /// How many plates the row is made of.
  ///
  /// Four by default: enough that the wave reads as a wave, few enough that a
  /// determinate row can be counted at a glance rather than measured. Set it to
  /// the number of steps when the thing being waited on genuinely has steps.
  ///
  /// A row of no plates is not a loading indicator, so anything below one is
  /// one.
  final int count;

  /// A name for what is loading. Read out with the value by a screen reader.
  final Widget? label;

  /// Shows the value as text above the row.
  final bool showValue;

  /// How to write it. A function rather than an options object, for the reason
  /// `PlProgressLinear.formatValue` gives.
  final String Function(double value)? formatValue;

  /// Size of one plate.
  final PlassSize? size;

  /// Semantic colour role. It becomes the gradient a lit plate is filled with.
  final PlassColor? color;

  @override
  State<PlProgressBox> createState() => _PlProgressBoxState();
}

class _PlProgressBoxState extends State<PlProgressBox> with SingleTickerProviderStateMixin {
  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassColor get _color => widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;

  late final AnimationController _wave = AnimationController(vsync: this, duration: waveDuration);

  double? get _fraction => progressFraction(widget.value, widget.min, widget.max);

  int get _plates => widget.count < 1 ? 1 : widget.count;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncWave();
  }

  @override
  void didUpdateWidget(PlProgressBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncWave();
  }

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  void _syncWave() {
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final wanted = still ? slowWaveDuration : waveDuration;

    if (_wave.duration != wanted) {
      _wave.duration = wanted;

      if (_wave.isAnimating) {
        _wave
          ..stop()
          ..repeat();
      }
    }

    if (_fraction == null) {
      if (!_wave.isAnimating) {
        _wave.repeat();
      }
    } else if (_wave.isAnimating) {
      _wave.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final family = tokens.family(_color);
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final fraction = _fraction;
    final plates = _plates;
    final side = plateSize[_size]!;
    final radius = BorderRadius.circular(plateRadius[_size]!);
    final meta = metaText[_size]!;

    final text = fraction == null
        ? null
        : widget.formatValue != null && widget.value != null
        ? widget.formatValue!(widget.value!)
        : progressText(fraction);

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: plateGap[_size]!,
      children: <Widget>[
        for (var index = 0; index < plates; index += 1)
          _Plate(
            side: side,
            radius: radius,
            track: tokens.track,
            gradient: family.fill,
            // A plate is a groove of its own, so the leading one can be part
            // full. Without that, four plates could only ever show 0, 25, 50,
            // 75 or 100 and a value of 30% would round away to a quarter.
            filled: fraction == null ? null : ((fraction * plates) - index).clamp(0.0, 1.0),
            wave: fraction == null ? _wave : null,
            index: index,
            still: still,
          ),
      ],
    );

    final head = widget.label != null || (widget.showValue && text != null)
        ? Padding(
            padding: EdgeInsets.only(bottom: stackGap[_size]!),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (widget.label != null)
                  Flexible(
                    child: DefaultTextStyle.merge(
                      style: TextStyle(color: tokens.fg, fontSize: meta),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      child: widget.label!,
                    ),
                  ),
                if (widget.showValue && text != null) ...<Widget>[
                  if (widget.label != null) const SizedBox(width: 8),
                  // Drawn, not read: the same string is already this node's
                  // value.
                  ExcludeSemantics(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: tokens.mutedFg,
                        fontSize: meta,
                        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          )
        : null;

    return MergeSemantics(
      child: Semantics(
        role: fraction == null ? SemanticsRole.loadingSpinner : SemanticsRole.progressBar,
        value: progressSemanticValue(fraction, widget.formatValue, widget.value),
        container: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[?head, row],
        ),
      ),
    );
  }
}

/// One plate: a groove with a gradient over part of it.
///
/// [filled] is how much of it is covered, `0`…`1`, and `null` puts the plate on
/// [wave] instead — where the gradient is there the whole time at full strength
/// and its opacity is what cycles.
class _Plate extends StatelessWidget {
  const _Plate({
    required this.side,
    required this.radius,
    required this.track,
    required this.gradient,
    required this.filled,
    required this.wave,
    required this.index,
    required this.still,
  });

  final double side;
  final BorderRadius radius;
  final Color track;
  final Gradient gradient;
  final double? filled;
  final Animation<double>? wave;
  final int index;
  final bool still;

  @override
  Widget build(BuildContext context) {
    final fill = DecoratedBox(decoration: BoxDecoration(gradient: gradient));

    final Widget cover = wave != null
        ? AnimatedBuilder(
            animation: wave!,
            builder: (BuildContext context, Widget? child) => Opacity(
              // Each plate held back by its own index, which is what makes the
              // row a wave rather than a set of lamps blinking together.
              opacity: plateOpacity(wave!.value - index * plateStagger),
              child: child,
            ),
            child: fill,
          )
        : Align(
            alignment: AlignmentDirectional.centerStart,
            child: AnimatedFractionallySizedBox(
              duration: still ? Duration.zero : fillDuration,
              curve: PlassTokens.ease,
              alignment: AlignmentDirectional.centerStart,
              widthFactor: filled,
              heightFactor: 1,
              child: fill,
            ),
          );

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox.square(
        dimension: side,
        child: DecoratedBox(
          decoration: BoxDecoration(color: track),
          child: cover,
        ),
      ),
    );
  }
}
