/// A box files are chosen into.
library;

import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/dismiss.dart';
import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/inset_shadow.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/internal/surface.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// The box's inner padding.
///
/// Its own ladder rather than the sheet's, because a dropzone is sized by the
/// gesture it has to catch rather than by what is written in it: a target the
/// height of one line of text is a target you miss.
const Map<PlassDensity, Map<PlassSize, double>> _zonePadding =
    <PlassDensity, Map<PlassSize, double>>{
      PlassDensity.standard: <PlassSize, double>{
        PlassSize.xs: 16,
        PlassSize.sm: 20,
        PlassSize.md: 24,
        PlassSize.lg: 32,
        PlassSize.xl: 40,
      },
      PlassDensity.compact: <PlassSize, double>{
        PlassSize.xs: 8,
        PlassSize.sm: 12,
        PlassSize.md: 16,
        PlassSize.lg: 20,
        PlassSize.xl: 24,
      },
    };

/// How thick the dashed edge is.
const double _edgeWidth = 2;

/// How long one dash is, and the gap after it.
const double _dash = 6;

/// The gap.
const double _gap = 4;

/// How large the glyph above the title is drawn, against the title.
const double _glyphScale = 1.8;

/// A row in the list.
const double _rowPaddingX = 8;

/// And its height, as padding.
const double _rowPaddingY = 6;

/// How large a row's × is drawn against the line it sits on.
const double _removeScale = 1.3;

/// Why a file was turned away. One reason per file, in the order they are
/// checked.
enum PlFileRejectionReason {
  /// It is not one of the kinds [PlFilePicker.accept] names.
  type,

  /// It is larger than [PlFilePicker.maxSize].
  size,

  /// There is no room left under [PlFilePicker.maxFiles].
  count,
}

/// One file that was turned away, and why.
@immutable
class PlFileRejection {
  /// Creates a rejection.
  const PlFileRejection({required this.file, required this.reason});

  /// The file.
  final PlFile file;

  /// Why it was not kept.
  final PlFileRejectionReason reason;
}

/// A file, as the picker needs to know it.
///
/// Deliberately **not** a `dart:io` `File` and not an abstraction over one: this
/// package has no dependencies and no business opening anything. What the picker
/// draws is a name and a size, and what its rules read is a name, a size and a
/// kind — so that is what it asks for. [source] is whatever the app's own picker
/// handed over, carried through untouched so the caller gets its own object back
/// on the other side.
@immutable
class PlFile {
  /// Creates a file.
  const PlFile({required this.name, required this.size, this.mimeType, this.source});

  /// What it is called, extension and all.
  final String name;

  /// How many bytes it is.
  final int size;

  /// Its kind — `image/png`. Left out, only the extension is checked against
  /// [PlFilePicker.accept].
  final String? mimeType;

  /// Whatever the app's own picker handed over. The picker never looks at it.
  final Object? source;

  /// `1.4 MB`, in the units a person reading a file list expects.
  ///
  /// Base 1000 rather than 1024, and `MB` rather than `MiB`: it is the number
  /// every operating system's file browser shows, and a picker that disagrees
  /// with the Finder about how big the file is has picked a fight it cannot win.
  String get readableSize {
    if (size < 1000) {
      return '$size B';
    }

    const List<String> units = <String>['kB', 'MB', 'GB', 'TB'];
    var value = size / 1000;
    var unit = 0;

    while (value >= 1000 && unit < units.length - 1) {
      value /= 1000;
      unit += 1;
    }

    return '${value < 10 ? value.toStringAsFixed(1) : value.round()} ${units[unit]}';
  }

  /// Whether this file matches an `accept` string.
  ///
  /// The same three forms the HTML attribute takes — `.ext`, `type/subtype`,
  /// `type/*` — because that is the grammar every picker plugin already speaks.
  bool matches(String accept) {
    final lowerName = name.toLowerCase();
    final lowerType = (mimeType ?? '').toLowerCase();

    return accept
        .split(',')
        .map((String entry) => entry.trim().toLowerCase())
        .where((String entry) => entry.isNotEmpty)
        .any((String entry) {
          if (entry.startsWith('.')) {
            return lowerName.endsWith(entry);
          }

          if (entry.endsWith('/*')) {
            return lowerType.startsWith(entry.substring(0, entry.length - 1));
          }

          return lowerType == entry;
        });
  }
}

/// A box files are chosen into.
///
/// ```dart
/// PlFilePicker(
///   value: files,
///   accept: 'image/*,.pdf',
///   maxSize: 5 * 1000 * 1000,
///   onBrowse: () async => myPickerPlugin.pick(),
///   onFilesChanged: (List<PlFile> next) => setState(() => files = next),
/// )
/// ```
///
/// **The picker does not pick.** This package has no dependencies, and reaching
/// the file system is a plugin's job in every Flutter app that does it — so
/// [onBrowse] is where the app's own picker runs. What this owns is everything
/// after that: the rules, the list, the removal, and the box itself.
///
/// The rules are worth having in one place. `accept` has to be checked against
/// what arrived rather than trusted to whatever offered it; `maxFiles` is
/// checked against what is **already held** rather than against one batch, which
/// is the difference between "you may add five files" and "you may end up with
/// five files", and only the second is what the number means.
class PlFilePicker extends StatefulWidget {
  /// Creates a picker.
  const PlFilePicker({
    required this.value,
    this.onFilesChanged,
    this.onBrowse,
    this.onRejected,
    this.accept,
    this.multiple = false,
    this.maxSize,
    this.maxFiles,
    this.dragging = false,
    this.label,
    this.description,
    this.error,
    this.invalid,
    this.title,
    this.hint,
    this.icon,
    this.showIcon = true,
    this.showList = true,
    this.removeLabel = _defaultRemoveLabel,
    this.variant = PlassVariant.glass,
    this.size = PlassSize.md,
    this.color = PlassColor.primary,
    this.density = PlassDensity.standard,
    this.elevation = 0,
    this.fullWidth = true,
    this.readOnly = false,
    this.disabled = false,
    super.key,
  }) : assert(
         elevation >= plassElevationMin && elevation <= plassElevationMax,
         'elevation must be between $plassElevationMin and $plassElevationMax',
       );

  /// The files that have been chosen.
  final List<PlFile> value;

  /// Called with the list that should be held next — a file added, or one
  /// removed from the list under the box.
  final ValueChanged<List<PlFile>>? onFilesChanged;

  /// Runs the app's own file picker and hands back what it found.
  ///
  /// Whatever it returns is checked against [accept], [maxSize] and [maxFiles],
  /// and what survives is reported through [onFilesChanged]. Leaving it out
  /// leaves the box inert — a picker with nothing to open.
  final Future<List<PlFile>> Function()? onBrowse;

  /// Called with everything that was turned away, and why.
  ///
  /// Without it a rejected file disappears silently, which is the single worst
  /// thing a dropzone does.
  final ValueChanged<List<PlFileRejection>>? onRejected;

  /// Which files are kept, in the `accept` grammar — `'image/*,.pdf'`.
  final String? accept;

  /// Whether more than one file may be held.
  final bool multiple;

  /// The largest a single file may be, in bytes.
  final int? maxSize;

  /// How many files may be held at once. Implies [multiple], and is checked
  /// against what is already held rather than against one batch.
  final int? maxFiles;

  /// Whether a file is currently over the box.
  ///
  /// There is no OS-level drag in Flutter without a plugin, so the picker cannot
  /// know this by itself. An app that has one tells it, and the box lights the
  /// way it should — the look of the state is the component's, the detection is
  /// the app's.
  final bool dragging;

  /// Label above the box.
  final Widget? label;

  /// Helper text below it.
  final Widget? description;

  /// Error message below it. Its presence also turns the picker invalid.
  final Widget? error;

  /// Forces the invalid state without a message.
  final bool? invalid;

  /// The line inside the box.
  final Widget? title;

  /// The line under it — what is accepted, how big, how many.
  final Widget? hint;

  /// The glyph above the title.
  final Widget? icon;

  /// Draws a glyph at all.
  final bool showIcon;

  /// Lists the chosen files under the box, each with a way to remove it.
  final bool showList;

  /// The name a screen reader gives a file's remove button.
  final String Function(String name) removeLabel;

  /// What the box is made of. Never dyed: what is dropped on it is other
  /// people's content.
  final PlassVariant variant;

  /// Type scale, radius and padding.
  final PlassSize size;

  /// Semantic colour role. It reaches the glyph, the edge under the pointer and
  /// the ring.
  final PlassColor color;

  /// How tightly the box packs.
  final PlassDensity density;

  /// Drop shadow depth, `0`–`3`.
  ///
  /// `0` is the default — a dropzone is cut into the page rather than floating
  /// over it.
  final PlassElevation elevation;

  /// Stretches to the width of the container.
  final bool fullWidth;

  /// The files are shown but cannot be added to or removed.
  final bool readOnly;

  /// Unavailable.
  final bool disabled;

  static String _defaultRemoveLabel(String name) => 'Remove $name';

  @override
  State<PlFilePicker> createState() => _PlFilePickerState();
}

class _PlFilePickerState extends State<PlFilePicker> {
  bool get _inert => widget.disabled || widget.readOnly;

  bool get _usable => !_inert && widget.onBrowse != null && widget.onFilesChanged != null;

  Future<void> _browse() async {
    if (!_usable) {
      return;
    }

    final found = await widget.onBrowse!();

    if (!mounted || found.isEmpty) {
      return;
    }

    _add(found);
  }

  /// Sorts an incoming batch into kept and turned away, and reports both.
  void _add(List<PlFile> incoming) {
    final kept = <PlFile>[];
    final rejected = <PlFileRejection>[];
    final room = widget.multiple ? (widget.maxFiles ?? 1 << 30) : 1;
    final held = widget.multiple ? widget.value.length : 0;

    for (final file in incoming) {
      if (widget.accept != null && !file.matches(widget.accept!)) {
        rejected.add(PlFileRejection(file: file, reason: PlFileRejectionReason.type));
      } else if (widget.maxSize != null && file.size > widget.maxSize!) {
        rejected.add(PlFileRejection(file: file, reason: PlFileRejectionReason.size));
      } else if (held + kept.length >= room) {
        rejected.add(PlFileRejection(file: file, reason: PlFileRejectionReason.count));
      } else {
        kept.add(file);
      }
    }

    if (rejected.isNotEmpty) {
      widget.onRejected?.call(rejected);
    }

    if (kept.isNotEmpty) {
      widget.onFilesChanged?.call(widget.multiple ? <PlFile>[...widget.value, ...kept] : kept);
    }
  }

  void _remove(int index) {
    widget.onFilesChanged?.call(<PlFile>[
      for (var at = 0; at < widget.value.length; at += 1)
        if (at != index) widget.value[at],
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final hasError = widget.error != null;
    final isInvalid = widget.invalid ?? hasError;
    // Invalid re-points the whole family at `danger`, so the edge, the ring and
    // the message all turn over together — the same wiring a text field uses.
    final family = tokens.family(isInvalid ? PlassColor.danger : widget.color);

    final size = widget.size;
    final meta = metaText[size]!;
    final radius = BorderRadius.circular(PlassTokens.radius[size]!);

    Widget zone = PlassInteractive(
      onTap: _usable ? _browse : null,
      enabled: !widget.disabled,
      interactive: _usable,
      cursor: widget.disabled
          ? SystemMouseCursors.forbidden
          : _usable
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      builder: (BuildContext context, PlassInteraction state) {
        final lit = widget.dragging && !_inert;
        final warm = (state.hovered || state.pressed) && !_inert;

        // The sheet is never dyed. What is dropped on it is other people's
        // content — the family reaches the glyph, the edge and the ring.
        final fill = switch (widget.variant) {
          PlassVariant.solid =>
            lit
                ? family.softHover
                : warm
                ? tokens.glassHover
                : tokens.glassPress,
          PlassVariant.glass =>
            lit
                ? family.softHover
                : warm
                ? tokens.glassHover
                : tokens.glass,
          PlassVariant.ghost =>
            lit
                ? family.softHover
                : warm
                ? family.soft
                : null,
        };

        Widget box = PlassSurfaceBox(
          surface: PlassSurface(
            fill: fill,
            ink: tokens.fg,
            blur: widget.variant != PlassVariant.ghost,
            insets: widget.variant == PlassVariant.ghost
                ? const <PlassInsetShadow>[]
                : <PlassInsetShadow>[tokens.glossGlass],
            shadows: tokens.elevation(widget.elevation),
          ),
          borderRadius: radius,
          child: Padding(
            padding: EdgeInsets.all(_zonePadding[widget.density]![size]!),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: gap[size]!,
              children: <Widget>[
                if (widget.showIcon)
                  widget.icon ??
                      PlassGlyph(
                        PlassGlyphShape.upload,
                        size: sheetTitle[size]!.size * _glyphScale,
                        color: family.accent,
                      ),
                DefaultTextStyle.merge(
                  style: TextStyle(
                    color: tokens.fg,
                    fontSize: sheetTitle[size]!.size,
                    height: sheetTitle[size]!.height,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  child: widget.title ?? const Text('Choose files'),
                ),
                if (widget.hint != null)
                  DefaultTextStyle.merge(
                    style: TextStyle(color: tokens.mutedFg, fontSize: meta),
                    textAlign: TextAlign.center,
                    child: widget.hint!,
                  ),
              ],
            ),
          ),
        );

        // The dashed edge is the one place the library draws a line that is not
        // solid, and it is not decoration: a dashed rectangle is the established
        // sign for "this area takes a drop", and a dropzone that looks like a
        // card is a card nobody tries to drop on.
        box = CustomPaint(
          foregroundPainter: _DashedEdge(
            color: lit
                ? family.ring
                : warm
                ? family.lineHover
                : tokens.border,
            radius: radius,
          ),
          child: box,
        );

        box = plassStateFilter(
          child: box,
          disabled: widget.disabled,
          readOnly: widget.readOnly,
          lit: false,
        );

        if (state.focusVisible) {
          box = CustomPaint(
            foregroundPainter: PlassFocusRingPainter(color: family.ring, borderRadius: radius),
            child: box,
          );
        }

        return Semantics(
          container: true,
          button: true,
          enabled: !widget.disabled,
          readOnly: widget.readOnly,
          onTap: _usable ? _browse : null,
          child: box,
        );
      },
    );

    if (widget.fullWidth) {
      zone = SizedBox(width: double.infinity, child: zone);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: stackGap[size]!,
      children: <Widget>[
        if (widget.label != null)
          DefaultTextStyle.merge(
            style: TextStyle(
              color: widget.disabled ? tokens.mutedFg : tokens.fg,
              fontSize: meta,
              fontWeight: FontWeight.w600,
            ),
            child: widget.label!,
          ),
        zone,
        if (widget.showList && widget.value.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            spacing: stackGap[size]!,
            children: <Widget>[
              for (var index = 0; index < widget.value.length; index += 1)
                _row(tokens, family, index: index, meta: meta),
            ],
          ),
        if (widget.description != null && !hasError)
          DefaultTextStyle.merge(
            style: TextStyle(color: tokens.mutedFg, fontSize: meta),
            child: widget.description!,
          ),
        if (hasError)
          DefaultTextStyle.merge(
            style: TextStyle(color: family.accent, fontSize: meta),
            child: widget.error!,
          ),
      ],
    );
  }

  Widget _row(
    PlassTokens tokens,
    PlassColorFamily family, {
    required int index,
    required double meta,
  }) {
    final file = widget.value[index];
    final scale = controlTextLeading[widget.size]!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: family.soft,
        borderRadius: BorderRadius.circular(PlassTokens.radius[PlassSize.xs]!),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _rowPaddingX, vertical: _rowPaddingY),
        child: Row(
          spacing: 8,
          children: <Widget>[
            Expanded(
              child: Text(
                file.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: tokens.fg,
                  fontSize: scale.size,
                  height: scale.height,
                  leadingDistribution: TextLeadingDistribution.even,
                ),
              ),
            ),
            Text(
              file.readableSize,
              style: TextStyle(
                color: tokens.mutedFg,
                fontSize: meta,
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
            ),
            if (!_inert && widget.onFilesChanged != null)
              PlassDismissButton(
                label: widget.removeLabel(file.name),
                onPressed: () => _remove(index),
                size: scale.size * _removeScale,
                color: tokens.mutedFg,
                ring: family.ring,
              ),
          ],
        ),
      ),
    );
  }
}

/// The dashed edge round the box.
///
/// Flutter has no dashed border, so the rounded rectangle is walked with
/// [Path.computeMetrics] and cut into pieces. Which is the honest way round:
/// a dash pattern is a fact about the *outline*, and the outline is the thing
/// that knows how long it is.
class _DashedEdge extends CustomPainter {
  const _DashedEdge({required this.color, required this.radius});

  final Color color;
  final BorderRadius radius;

  @override
  void paint(Canvas canvas, Size size) {
    final outline = Path()..addRRect(radius.toRRect(Offset.zero & size).deflate(_edgeWidth / 2));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = _edgeWidth
      ..color = color;

    for (final metric in outline.computeMetrics()) {
      var at = 0.0;

      while (at < metric.length) {
        canvas.drawPath(metric.extractPath(at, at + _dash), paint);
        at += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedEdge oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
