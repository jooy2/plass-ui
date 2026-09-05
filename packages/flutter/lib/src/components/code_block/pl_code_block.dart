/// A viewer for one line of code or a thousand.
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:plass_ui/src/internal/focus_ring.dart';
import 'package:plass_ui/src/internal/icons.dart';
import 'package:plass_ui/src/internal/interaction.dart';
import 'package:plass_ui/src/internal/scales.dart';
import 'package:plass_ui/src/theme/theme.dart';
import 'package:plass_ui/src/theme/tokens.dart';
import 'package:plass_ui/src/types.dart';

/// Which of a theme's twelve colours a run of text is drawn in.
///
/// The React build carries highlight.js's own class name on a token and lets
/// CSS map it onto a slot; there is no stylesheet here, so the mapping is the
/// caller's and this enum is what they map onto. The twelve are the slots a
/// theme declares, and they are the same twelve on both sides.
enum PlCodeTokenKind {
  /// A comment, or a doc comment.
  comment,

  /// A keyword, a literal, an operator.
  keyword,

  /// A string, a regular expression, a link.
  string,

  /// A number, a symbol, a bullet.
  number,

  /// A function or a section's name.
  function,

  /// A type, a built-in, a class.
  type,

  /// A variable, a parameter, a substitution.
  variable,

  /// A markup tag.
  tag,

  /// An attribute or a property.
  attribute,

  /// A pragma, an annotation, punctuation.
  meta,

  /// An added line in a diff.
  addition,

  /// A removed one.
  deletion,
}

/// One run of text with a single colour.
@immutable
class PlCodeToken {
  /// Creates a run. Leave [kind] out for text the theme draws in its own ink.
  const PlCodeToken(this.text, [this.kind]);

  /// The characters.
  final String text;

  /// Which slot colours them, or `null` for the foreground.
  final PlCodeTokenKind? kind;
}

/// One line of code, as the runs it is made of. An empty list is a blank line.
typedef PlCodeLine = List<PlCodeToken>;

/// The sixteen colours a code block is drawn out of.
///
/// Fourteen are declared and **five are derived** — the dim ink, the rule, the
/// hover wash and the two a marked line uses are all a fixed mix of the ground
/// and the ink, so a thirteenth theme is fourteen colours rather than nineteen.
@immutable
class PlCodeTheme {
  /// Creates a palette.
  const PlCodeTheme({
    required this.background,
    required this.foreground,
    required this.comment,
    required this.keyword,
    required this.string,
    required this.number,
    required this.function,
    required this.type,
    required this.variable,
    required this.tag,
    required this.attribute,
    required this.meta,
    required this.addition,
    required this.deletion,
    this.bold = false,
  });

  /// The sheet.
  final Color background;

  /// The ink everything not otherwise coloured is drawn in.
  final Color foreground;

  /// A comment, or a doc comment.
  final Color comment;

  /// A keyword, a literal, an operator.
  final Color keyword;

  /// A string, a regular expression, a link.
  final Color string;

  /// A number, a symbol, a bullet.
  final Color number;

  /// A function or a section's name.
  final Color function;

  /// A type, a built-in, a class.
  final Color type;

  /// A variable, a parameter, a substitution.
  final Color variable;

  /// A markup tag.
  final Color tag;

  /// An attribute or a property.
  final Color attribute;

  /// A pragma, an annotation, punctuation.
  final Color meta;

  /// An added line in a diff.
  final Color addition;

  /// A removed one.
  final Color deletion;

  /// Whether the structural slots are drawn heavier rather than in another hue.
  ///
  /// `mono`'s answer, and only `mono`'s: with no hue to separate a keyword from
  /// a string, the structure has to be carried by weight instead.
  final bool bold;

  /// The line numbers, the prompts and the bar's own text.
  Color get dim => Color.lerp(background, foreground, 0.58)!;

  /// The rule under the bar and around the block.
  Color get rule => foreground.withValues(alpha: 0.14);

  /// The wash under a hovered button on the bar.
  Color get hover => foreground.withValues(alpha: 0.09);

  /// A marked line's ground, and the rule down its leading edge.
  ///
  /// Neutral rather than dyed with the page's accent family: the block has
  /// deliberately refused the page's palette, and a primary-blue wash over
  /// Dracula would be the one colour on it nobody chose. Mixed from the theme's
  /// own ink, it is legible on all twelve.
  Color get mark => foreground.withValues(alpha: 0.10);

  /// The rule down that line's leading edge.
  Color get markEdge => foreground.withValues(alpha: 0.45);

  /// The colour a token of [kind] is drawn in.
  Color inkFor(PlCodeTokenKind? kind) {
    switch (kind) {
      case null:
        return foreground;
      case PlCodeTokenKind.comment:
        return comment;
      case PlCodeTokenKind.keyword:
        return keyword;
      case PlCodeTokenKind.string:
        return string;
      case PlCodeTokenKind.number:
        return number;
      case PlCodeTokenKind.function:
        return function;
      case PlCodeTokenKind.type:
        return type;
      case PlCodeTokenKind.variable:
        return variable;
      case PlCodeTokenKind.tag:
        return tag;
      case PlCodeTokenKind.attribute:
        return attribute;
      case PlCodeTokenKind.meta:
        return meta;
      case PlCodeTokenKind.addition:
        return addition;
      case PlCodeTokenKind.deletion:
        return deletion;
    }
  }

  /// Whether a run of [kind] is drawn heavier. Only ever true on `mono`.
  bool boldFor(PlCodeTokenKind? kind) {
    if (!bold) {
      return false;
    }

    return kind == PlCodeTokenKind.keyword ||
        kind == PlCodeTokenKind.function ||
        kind == PlCodeTokenKind.type ||
        kind == PlCodeTokenKind.tag;
  }
}

/// The house dark set, and what `auto` becomes on a dark screen.
const PlCodeTheme _dark = PlCodeTheme(
  background: Color(0xFF11151B),
  foreground: Color(0xFFDADEE6),
  comment: Color(0xFF78818F),
  keyword: Color(0xFFDA94E0),
  string: Color(0xFF80D58D),
  number: Color(0xFFF8AF6C),
  function: Color(0xFF87B9FF),
  type: Color(0xFF6DD6E8),
  variable: Color(0xFFF9AFA0),
  tag: Color(0xFFFC918E),
  attribute: Color(0xFFE7CC76),
  meta: Color(0xFF8E9FBE),
  addition: Color(0xFF71D790),
  deletion: Color(0xFFFF847D),
);

/// The house light set.
const PlCodeTheme _light = PlCodeTheme(
  background: Color(0xFFF9FAFC),
  foreground: Color(0xFF292E36),
  comment: Color(0xFF737B88),
  keyword: Color(0xFF8C289B),
  string: Color(0xFF18692E),
  number: Color(0xFFA04400),
  function: Color(0xFF2954BC),
  type: Color(0xFF006277),
  variable: Color(0xFF8C352D),
  tag: Color(0xFFAC172B),
  attribute: Color(0xFF7E5000),
  meta: Color(0xFF596986),
  addition: Color(0xFF006A29),
  deletion: Color(0xFFAC1922),
);

/// The eight ports, kept at the hex they were published in.
///
/// A code block is the one component whose colours a reader already has an
/// opinion about: someone who writes in One Dark all day reads a Dracula block
/// as a different product's documentation. A Dracula re-solved against this
/// library's own ground would be a theme nobody recognises and nobody asked
/// for, so none of them is corrected.
const Map<String, PlCodeTheme> _ports = <String, PlCodeTheme>{
  'one-dark': PlCodeTheme(
    background: Color(0xFF282C34),
    foreground: Color(0xFFABB2BF),
    comment: Color(0xFF5C6370),
    keyword: Color(0xFFC678DD),
    string: Color(0xFF98C379),
    number: Color(0xFFD19A66),
    function: Color(0xFF61AFEF),
    type: Color(0xFFE5C07B),
    variable: Color(0xFFE06C75),
    tag: Color(0xFFE06C75),
    attribute: Color(0xFFD19A66),
    meta: Color(0xFF56B6C2),
    addition: Color(0xFF98C379),
    deletion: Color(0xFFE06C75),
  ),
  'dracula': PlCodeTheme(
    background: Color(0xFF282A36),
    foreground: Color(0xFFF8F8F2),
    comment: Color(0xFF6272A4),
    keyword: Color(0xFFFF79C6),
    string: Color(0xFFF1FA8C),
    number: Color(0xFFBD93F9),
    function: Color(0xFF50FA7B),
    type: Color(0xFF8BE9FD),
    variable: Color(0xFFF8F8F2),
    tag: Color(0xFFFF79C6),
    attribute: Color(0xFF50FA7B),
    meta: Color(0xFF6272A4),
    addition: Color(0xFF50FA7B),
    deletion: Color(0xFFFF5555),
  ),
  'monokai': PlCodeTheme(
    background: Color(0xFF272822),
    foreground: Color(0xFFF8F8F2),
    comment: Color(0xFF75715E),
    keyword: Color(0xFFF92672),
    string: Color(0xFFE6DB74),
    number: Color(0xFFAE81FF),
    function: Color(0xFFA6E22E),
    type: Color(0xFF66D9EF),
    variable: Color(0xFFF8F8F2),
    tag: Color(0xFFF92672),
    attribute: Color(0xFFA6E22E),
    meta: Color(0xFF75715E),
    addition: Color(0xFFA6E22E),
    deletion: Color(0xFFF92672),
  ),
  'nord': PlCodeTheme(
    background: Color(0xFF2E3440),
    foreground: Color(0xFFD8DEE9),
    comment: Color(0xFF616E88),
    keyword: Color(0xFF81A1C1),
    string: Color(0xFFA3BE8C),
    number: Color(0xFFB48EAD),
    function: Color(0xFF88C0D0),
    type: Color(0xFF8FBCBB),
    variable: Color(0xFFD8DEE9),
    tag: Color(0xFF81A1C1),
    attribute: Color(0xFF8FBCBB),
    meta: Color(0xFF5E81AC),
    addition: Color(0xFFA3BE8C),
    deletion: Color(0xFFBF616A),
  ),
  'night-owl': PlCodeTheme(
    background: Color(0xFF011627),
    foreground: Color(0xFFD6DEEB),
    comment: Color(0xFF637777),
    keyword: Color(0xFFC792EA),
    string: Color(0xFFECC48D),
    number: Color(0xFFF78C6C),
    function: Color(0xFF82AAFF),
    type: Color(0xFFFFCB8B),
    variable: Color(0xFFADDB67),
    tag: Color(0xFF7FDBCA),
    attribute: Color(0xFFADDB67),
    meta: Color(0xFF82AAFF),
    addition: Color(0xFFADDB67),
    deletion: Color(0xFFEF5350),
  ),
  'gruvbox': PlCodeTheme(
    background: Color(0xFF282828),
    foreground: Color(0xFFEBDBB2),
    comment: Color(0xFF928374),
    keyword: Color(0xFFFB4934),
    string: Color(0xFFB8BB26),
    number: Color(0xFFD3869B),
    function: Color(0xFFB8BB26),
    type: Color(0xFFFABD2F),
    variable: Color(0xFF83A598),
    tag: Color(0xFF8EC07C),
    attribute: Color(0xFFFABD2F),
    meta: Color(0xFF928374),
    addition: Color(0xFFB8BB26),
    deletion: Color(0xFFFB4934),
  ),
  'github': PlCodeTheme(
    background: Color(0xFFFFFFFF),
    foreground: Color(0xFF24292F),
    comment: Color(0xFF6E7781),
    keyword: Color(0xFFCF222E),
    string: Color(0xFF0A3069),
    number: Color(0xFF0550AE),
    function: Color(0xFF8250DF),
    type: Color(0xFF953800),
    variable: Color(0xFF953800),
    tag: Color(0xFF116329),
    attribute: Color(0xFF0550AE),
    meta: Color(0xFF6E7781),
    addition: Color(0xFF116329),
    deletion: Color(0xFF82071E),
  ),
  'solarized-light': PlCodeTheme(
    background: Color(0xFFFDF6E3),
    foreground: Color(0xFF657B83),
    comment: Color(0xFF93A1A1),
    keyword: Color(0xFF859900),
    string: Color(0xFF2AA198),
    number: Color(0xFFD33682),
    function: Color(0xFF268BD2),
    type: Color(0xFFB58900),
    variable: Color(0xFF268BD2),
    tag: Color(0xFF268BD2),
    attribute: Color(0xFFB58900),
    meta: Color(0xFFCB4B16),
    addition: Color(0xFF859900),
    deletion: Color(0xFFDC322F),
  ),
};

/// `mono`, which is the one theme that follows the page.
///
/// The only one with no hue in it at all: the structure is carried by weight
/// and by how far a run is muted. It is what a block printed on paper, or read
/// by someone who cannot separate the hues above, is left with — so it has to
/// stay legible on its own rather than being a degraded copy of a colour theme.
PlCodeTheme _mono(PlassTokens tokens) {
  final Color fg = tokens.fg;
  final Color muted = tokens.mutedFg;

  return PlCodeTheme(
    background: Color.lerp(tokens.surface, fg, 0.04)!,
    foreground: fg,
    comment: muted,
    keyword: fg,
    string: muted,
    number: muted,
    function: fg,
    type: fg,
    variable: fg,
    tag: fg,
    attribute: muted,
    meta: muted,
    addition: fg,
    deletion: muted,
    bold: true,
  );
}

/// The palette a `theme` name means, resolved against the page it is on.
///
/// A name nothing here knows falls back to the house dark set rather than
/// throwing. The React build lets a consumer write a thirteenth theme as a
/// block of CSS custom properties; there is no stylesheet here, so a caller who
/// wants one hands the [PlCodeTheme] itself to [PlCodeBlock.customTheme].
PlCodeTheme resolveCodeTheme(String name, PlassTokens tokens) {
  switch (name) {
    case 'light':
      return _light;
    case 'mono':
      return _mono(tokens);
    case 'auto':
      return tokens.brightness == Brightness.dark ? _dark : _light;
    case 'dark':
      return _dark;
    default:
      return _ports[name] ?? _dark;
  }
}

/// The type scale, one step under the running text at every size.
///
/// A monospace face at the same nominal size as the prose around it reads a
/// size larger, because its x-height is taller and every glyph is as wide as an
/// `m`.
const Map<PlassSize, PlassTextScale> _codeText = <PlassSize, PlassTextScale>{
  PlassSize.xs: PlassTextScale(11, 17),
  PlassSize.sm: PlassTextScale(12, 19),
  PlassSize.md: PlassTextScale(13, 21),
  PlassSize.lg: PlassTextScale(14, 24),
  PlassSize.xl: PlassTextScale(16, 27),
};

/// The air around the code, split into the two axes because they go on two
/// different boxes: the vertical padding belongs to the box that scrolls, and
/// the horizontal padding belongs to each *line*, so a marked line's tint
/// reaches both edges of the block instead of stopping at a gutter.
const Map<PlassDensity, Map<PlassSize, double>> _bodyPadY = <PlassDensity, Map<PlassSize, double>>{
  PlassDensity.standard: <PlassSize, double>{
    PlassSize.xs: 8,
    PlassSize.sm: 12,
    PlassSize.md: 14,
    PlassSize.lg: 16,
    PlassSize.xl: 20,
  },
  PlassDensity.compact: <PlassSize, double>{
    PlassSize.xs: 6,
    PlassSize.sm: 8,
    PlassSize.md: 10,
    PlassSize.lg: 12,
    PlassSize.xl: 14,
  },
};

const Map<PlassDensity, Map<PlassSize, double>> _linePadX = <PlassDensity, Map<PlassSize, double>>{
  PlassDensity.standard: <PlassSize, double>{
    PlassSize.xs: 8,
    PlassSize.sm: 12,
    PlassSize.md: 14,
    PlassSize.lg: 16,
    PlassSize.xl: 20,
  },
  PlassDensity.compact: <PlassSize, double>{
    PlassSize.xs: 6,
    PlassSize.sm: 8,
    PlassSize.md: 10,
    PlassSize.lg: 12,
    PlassSize.xl: 14,
  },
};

/// How long the copy button says it worked.
const Duration _copiedFor = Duration(seconds: 2);

/// The rule down a marked line's leading edge.
const double _markEdge = 2;

/// `'4'`, `'4-9'` or `'1,4-9,12'`, as the set of numbers it names.
///
/// A set rather than a sorted list of ranges because the only question ever
/// asked of it is "is this line in it", once per line. Anything unparseable is
/// dropped rather than thrown: a marked line is an annotation, and a typo in one
/// should cost the annotation, not the code.
Set<int> parseLineSpec(String? spec) {
  final marked = <int>{};

  if (spec == null) {
    return marked;
  }

  final pattern = RegExp(r'^\s*(\d+)\s*(?:-\s*(\d+)\s*)?$');

  for (final String part in spec.split(',')) {
    final RegExpMatch? range = pattern.firstMatch(part);

    if (range == null) {
      continue;
    }

    final int from = int.parse(range.group(1)!);
    final int to = range.group(2) == null ? from : int.parse(range.group(2)!);

    // Written the wrong way round is still a range, and the reader who typed
    // `9-4` meant the same four lines.
    for (int line = from < to ? from : to; line <= (from > to ? from : to); line += 1) {
      marked.add(line);
    }
  }

  return marked;
}

/// `code` as plain lines, which is what a block with no [PlCodeBlock.lines] draws.
List<PlCodeLine> plainCodeLines(String code) {
  return code
      .split('\n')
      .map((String line) => line.isEmpty ? <PlCodeToken>[] : <PlCodeToken>[PlCodeToken(line)])
      .toList();
}

/// A viewer for one line of code or a thousand.
///
/// Everything it draws above the code is optional and off one parameter each,
/// because the same widget has to be a snippet inside a sentence — no bar, no
/// numbers, no chrome — and the full transcript at the top of a README, and
/// those are the same block with different things turned on rather than two
/// widgets.
///
/// **It is the one surface in the library that is not made of glass.** Every
/// other sheet here is translucent and takes the screen's colour family; this
/// one paints its own opaque ground and refuses the family entirely, because
/// the palette is the subject rather than the setting. A Dracula block tinted
/// `primary` would be a Dracula block nobody chose.
///
/// **It does not colour the code itself, and the React build does.** That side
/// reaches highlight.js through a dynamic import; this package has no
/// dependencies, and a hand-written grammar for thirty-five languages is a
/// promise it could not keep. So a caller who has a highlighter hands the
/// result in as [lines] — runs of text with a [PlCodeTokenKind] on them — and a
/// caller who does not gets the frame, the twelve palettes and the code drawn
/// in one ink.
///
/// ```dart
/// PlCodeBlock(
///   code: source,
///   language: 'dart',
///   lineNumbers: true,
/// )
/// ```
class PlCodeBlock extends StatefulWidget {
  /// Creates a code block.
  const PlCodeBlock({
    required this.code,
    this.lines,
    this.language,
    this.theme = 'dark',
    this.customTheme,
    this.size,
    this.color,
    this.density,
    this.elevation = 0,
    this.toolbar = true,
    this.title,
    this.showLanguage = true,
    this.copyable = true,
    this.rawToggle = false,
    this.highlightLines,
    this.lineNumbers = false,
    this.startLine = 1,
    this.prompt,
    this.wrap = false,
    this.maxHeight,
    this.fontFamily,
    this.fontSize,
    this.lineHeight,
    this.letterSpacing,
    this.copyLabel,
    this.copiedLabel,
    this.copyFailedLabel,
    this.rawLabel,
    this.codeLabel,
    this.onCopy,
    super.key,
  });

  /// The code. Trailing whitespace is trimmed off the end of the block — a
  /// raw string is almost always written with a newline before its closing
  /// quotes, and that newline is a blank line at the bottom of every block.
  final String code;

  /// The same code already coloured, one entry per line.
  ///
  /// What a caller's own highlighter produced. Left out, the block draws
  /// [code] in the theme's foreground — which is what a block with no
  /// highlighter available looks like, and is never a blank space where the
  /// code should be.
  final List<PlCodeLine>? lines;

  /// What it is written in. Drawn on the bar; nothing else reads it.
  final String? language;

  /// The palette. Independent of the screen's light and dark, except on `auto`.
  final String theme;

  /// A palette of the caller's own, which wins over [theme] when it is given.
  final PlCodeTheme? customTheme;

  /// The type scale and the air around the code.
  final PlassSize? size;

  /// Semantic colour role. It reaches the focus ring and nothing else — the
  /// block itself has refused the family on purpose.
  final PlassColor? color;

  /// The air around the code. Never the type scale.
  final PlassDensity? density;

  /// Drop shadow depth. `0` is flat, and is right for a block that is content.
  final PlassElevation elevation;

  /// The bar over the code, and the master switch for it.
  final bool toolbar;

  /// A name at the start of the bar — a file path, usually.
  final Widget? title;

  /// Names the language at the start of the bar.
  final bool showLanguage;

  /// The button that puts the code on the clipboard.
  final bool copyable;

  /// The toggle that drops the colouring and shows the characters as they are.
  ///
  /// Means nothing at all when there are no [lines] to drop.
  final bool rawToggle;

  /// Lines to mark: a tinted row with a rule down its leading edge.
  ///
  /// `'4'`, `'4-9'` or `'1,4-9,12'`. Counted the way the gutter counts, so a
  /// [startLine] of 286 means `'288'` marks the line the gutter calls 288.
  ///
  /// A string rather than React's number-or-string-or-list: one form covers
  /// every case there, and a Dart `Object?` that had to be type-tested at
  /// runtime is not an API.
  final String? highlightLines;

  /// Numbers down the side.
  final bool lineNumbers;

  /// What the first line is numbered.
  final int startLine;

  /// A shell prompt in front of every line that has something on it — `$`, `#`,
  /// `>>>`.
  ///
  /// It is drawn but never *copied*: the symbol is the widget's, not the code's,
  /// so a transcript stays a transcript and still pastes into a shell.
  final String? prompt;

  /// Wraps long lines instead of scrolling them sideways.
  final bool wrap;

  /// How tall the block may get before the code scrolls inside it.
  final double? maxHeight;

  /// The typeface. Defaults to the platform's own monospace.
  final String? fontFamily;

  /// Overrides the size the [size] ladder chose.
  final double? fontSize;

  /// Overrides the leading, as a multiple of the font size.
  final double? lineHeight;

  /// Tracking, in logical pixels.
  final double? letterSpacing;

  /// The copy button's label.
  final String? copyLabel;

  /// And what it says once the clipboard has taken the code.
  final String? copiedLabel;

  /// And what it says when the clipboard refused.
  final String? copyFailedLabel;

  /// The raw toggle's label.
  final String? rawLabel;

  /// What the block is called when it has neither a title nor a language.
  final String? codeLabel;

  /// Fires with the copied text once the clipboard has taken it.
  final ValueChanged<String>? onCopy;

  @override
  State<PlCodeBlock> createState() => _PlCodeBlockState();
}

class _PlCodeBlockState extends State<PlCodeBlock> {
  bool _raw = false;
  bool? _copied;

  final ScrollController _across = ScrollController();

  PlassSize get _size => widget.size ?? PlassTheme.sizeOf(context) ?? PlassSize.md;
  PlassColor get _color => widget.color ?? PlassTheme.colorOf(context) ?? PlassColor.primary;
  PlassDensity get _density =>
      widget.density ?? PlassTheme.densityOf(context) ?? PlassDensity.standard;

  @override
  void dispose() {
    _across.dispose();
    super.dispose();
  }

  /// What the clipboard gets and what is drawn: line endings normalised,
  /// trailing blank lines gone, and nothing else touched. Indentation is
  /// meaningful in half of the languages here, so nothing is trimmed off the
  /// front.
  String get _source =>
      widget.code.replaceAll('\r\n', '\n').replaceAll('\r', '\n').replaceAll(RegExp(r'\s+$'), '');

  Future<void> _copy() async {
    bool done = true;

    try {
      await Clipboard.setData(ClipboardData(text: _source));
    } catch (_) {
      done = false;
    }

    if (!mounted) {
      return;
    }

    setState(() => _copied = done);

    if (done) {
      widget.onCopy?.call(_source);
    }

    await Future<void>.delayed(_copiedFor);

    if (mounted) {
      setState(() => _copied = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = PlassTheme.of(context);
    final labels = PlassTheme.labelsOf(context);
    final PlCodeTheme palette = widget.customTheme ?? resolveCodeTheme(widget.theme, tokens);

    final PlassSize size = _size;
    final PlassTextScale scale = _codeText[size]!;
    final double fontSize = widget.fontSize ?? scale.size;
    final double lineHeight = widget.lineHeight ?? scale.height;
    final BorderRadius radius = BorderRadius.circular(PlassTokens.radius[size]!);

    final bool coloured = widget.lines != null && !_raw;
    final List<PlCodeLine> lines = coloured ? widget.lines! : plainCodeLines(_source);

    final Set<int> marked = parseLineSpec(widget.highlightLines);
    final double padX = _linePadX[_density]![size]!;
    final double padY = _bodyPadY[_density]![size]!;

    final TextStyle codeStyle = TextStyle(
      fontFamily: widget.fontFamily ?? 'monospace',
      fontSize: fontSize,
      height: lineHeight,
      letterSpacing: widget.letterSpacing,
      color: palette.foreground,
    );

    /// Wide enough for the last number, so the gutter does not step as it scrolls.
    final int lastNumber = widget.startLine + (lines.isEmpty ? 0 : lines.length - 1);
    final double gutter = widget.lineNumbers ? fontSize * 0.62 * lastNumber.toString().length : 0;

    Widget rows = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int index = 0; index < lines.length; index += 1)
          _Line(
            tokens: lines[index],
            number: widget.lineNumbers ? widget.startLine + index : null,
            prompt: lines[index].isEmpty ? null : widget.prompt,
            marked: marked.contains(widget.startLine + index),
            palette: palette,
            style: codeStyle,
            gutter: gutter,
            padX: padX,
            wrap: widget.wrap,
          ),
      ],
    );

    if (!widget.wrap) {
      // The rows are as wide as the longest line rather than as wide as the
      // window onto them, so every line's number starts at the same place
      // instead of at the scroll's — and a marked line's tint reaches the same
      // trailing edge as every other one.
      rows = ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: <PointerDeviceKind>{
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
            PointerDeviceKind.stylus,
          },
        ),
        child: SingleChildScrollView(
          controller: _across,
          scrollDirection: Axis.horizontal,
          child: IntrinsicWidth(child: rows),
        ),
      );
    }

    final String? languageName = widget.language?.trim().toLowerCase();
    final String regionName = widget.codeLabel ?? languageName ?? labels.code;

    // The name goes on the code rather than on the whole block, which is where
    // the React build puts its `role="region"` too. The bar above it is a set of
    // controls with names of their own, and a container around both would fold
    // theirs into the code's.
    Widget body = Semantics(
      container: true,
      label: regionName,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: padY),
        child: rows,
      ),
    );

    if (widget.maxHeight != null) {
      body = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: widget.maxHeight!),
        child: SingleChildScrollView(child: body),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: radius,
        border: Border.all(color: palette.rule, width: hairline),
        boxShadow: tokens.elevation(widget.elevation),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (widget.toolbar &&
                (widget.showLanguage ||
                    widget.copyable ||
                    widget.rawToggle ||
                    widget.title != null))
              _Bar(
                palette: palette,
                size: size,
                density: _density,
                family: tokens.family(_color),
                title: widget.title,
                language: widget.showLanguage ? languageName : null,
                copyable: widget.copyable,
                copied: _copied,
                copyLabel: widget.copyLabel ?? labels.copy,
                copiedLabel: widget.copiedLabel ?? labels.copied,
                copyFailedLabel: widget.copyFailedLabel ?? labels.copyFailed,
                onCopy: _copy,
                rawToggle: widget.rawToggle && widget.lines != null,
                raw: _raw,
                rawLabel: widget.rawLabel ?? labels.raw,
                onRaw: () => setState(() => _raw = !_raw),
              ),
            Flexible(child: body),
          ],
        ),
      ),
    );
  }
}

/// One line, and the two things in front of it that are not code.
///
/// The number and the prompt are the widget's own text rather than part of the
/// code, and that is the whole point: a `$` a reader copies and pastes into
/// their shell is a `$` their shell chokes on. Neither reaches the clipboard.
class _Line extends StatelessWidget {
  const _Line({
    required this.tokens,
    required this.number,
    required this.prompt,
    required this.marked,
    required this.palette,
    required this.style,
    required this.gutter,
    required this.padX,
    required this.wrap,
  });

  final PlCodeLine tokens;
  final int? number;
  final String? prompt;
  final bool marked;
  final PlCodeTheme palette;
  final TextStyle style;
  final double gutter;
  final double padX;
  final bool wrap;

  @override
  Widget build(BuildContext context) {
    final TextStyle dim = style.copyWith(color: palette.dim);

    return Container(
      decoration: BoxDecoration(
        color: marked ? palette.mark : null,
        border: BorderDirectional(
          start: BorderSide(
            color: marked ? palette.markEdge : const Color(0x00000000),
            width: _markEdge,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: padX),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (number != null)
            Padding(
              padding: EdgeInsetsDirectional.only(end: style.fontSize! * 0.9),
              child: SizedBox(
                width: gutter,
                child: Text('$number', style: dim, textAlign: TextAlign.end),
              ),
            ),
          if (prompt != null)
            Padding(
              padding: EdgeInsetsDirectional.only(end: style.fontSize! * 0.55),
              child: Text(prompt!, style: dim),
            ),
          // A blank line is still a line high: a row with nothing in it is zero
          // pixels tall, and a block that closed up its own paragraph breaks
          // would be reflowing the reader's file.
          Flexible(
            child: Text.rich(
              TextSpan(
                children: tokens.isEmpty
                    ? <InlineSpan>[const TextSpan(text: ' ')]
                    : <InlineSpan>[
                        for (final PlCodeToken run in tokens)
                          TextSpan(
                            text: run.text,
                            style: style.copyWith(
                              color: palette.inkFor(run.kind),
                              fontWeight: palette.boldFor(run.kind) ? FontWeight.w600 : null,
                            ),
                          ),
                      ],
              ),
              style: style,
              softWrap: wrap,
              overflow: TextOverflow.clip,
            ),
          ),
        ],
      ),
    );
  }
}

/// The bar over the code.
///
/// Its buttons are plain surfaces against the block's own palette rather than
/// [PlIconButton]s, and that is not a shortcut. A Plass control reads the
/// *screen's* ink and glass ladder, and these sit on a sheet that has
/// deliberately refused them — a dark block on a white page is the ordinary
/// case — so a `PlIconButton` here would be a light control on a black bar.
class _Bar extends StatelessWidget {
  const _Bar({
    required this.palette,
    required this.size,
    required this.density,
    required this.family,
    required this.title,
    required this.language,
    required this.copyable,
    required this.copied,
    required this.copyLabel,
    required this.copiedLabel,
    required this.copyFailedLabel,
    required this.onCopy,
    required this.rawToggle,
    required this.raw,
    required this.rawLabel,
    required this.onRaw,
  });

  final PlCodeTheme palette;
  final PlassSize size;
  final PlassDensity density;
  final PlassColorFamily family;
  final Widget? title;
  final String? language;
  final bool copyable;
  final bool? copied;
  final String copyLabel;
  final String copiedLabel;
  final String copyFailedLabel;
  final VoidCallback onCopy;
  final bool rawToggle;
  final bool raw;
  final String rawLabel;
  final VoidCallback onRaw;

  @override
  Widget build(BuildContext context) {
    final double meta = metaText[size]!;
    final double padX = _linePadX[density]![size]! + _markEdge;
    final double padY = size == PlassSize.xs || size == PlassSize.sm ? 4 : 6;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padX, vertical: padY),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: palette.rule, width: hairline),
        ),
      ),
      child: Row(
        children: <Widget>[
          if (title != null)
            Flexible(
              child: DefaultTextStyle(
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: meta,
                  color: palette.foreground,
                ),
                overflow: TextOverflow.ellipsis,
                child: title!,
              ),
            ),
          if (title != null && language != null) const SizedBox(width: 6),
          if (language != null)
            Flexible(
              child: Text(
                language!.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: meta,
                  letterSpacing: 0.4,
                  color: palette.dim,
                ),
              ),
            ),
          const Spacer(),
          if (rawToggle)
            _BarButton(
              palette: palette,
              family: family,
              size: size,
              label: rawLabel,
              pressed: raw,
              showLabel: false,
              icon: PlassGlyph(PlassGlyphShape.code, size: meta * 1.15),
              onPressed: onRaw,
            ),
          if (copyable)
            _BarButton(
              palette: palette,
              family: family,
              size: size,
              label: copied == null
                  ? copyLabel
                  : copied!
                  ? copiedLabel
                  : copyFailedLabel,
              pressed: false,
              showLabel: true,
              icon: PlassGlyph(
                copied == true ? PlassGlyphShape.check : PlassGlyphShape.copy,
                size: meta * 1.15,
              ),
              onPressed: onCopy,
            ),
        ],
      ),
    );
  }
}

class _BarButton extends StatefulWidget {
  const _BarButton({
    required this.palette,
    required this.family,
    required this.size,
    required this.label,
    required this.pressed,
    required this.showLabel,
    required this.icon,
    required this.onPressed,
  });

  final PlCodeTheme palette;
  final PlassColorFamily family;
  final PlassSize size;
  final String label;
  final bool pressed;
  final bool showLabel;
  final Widget icon;
  final VoidCallback onPressed;

  @override
  State<_BarButton> createState() => _BarButtonState();
}

class _BarButtonState extends State<_BarButton> {
  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final double meta = metaText[widget.size]!;
    final BorderRadius radius = BorderRadius.circular(PlassTokens.radius[PlassSize.xs]!);

    return Semantics(
      button: true,
      label: widget.label,
      // The copy button draws its own word as well as carrying it, and a reader
      // told "Copy, Copy" has been told once too often. The label supersedes
      // what is inside it, which is also what makes the button findable by the
      // name it answers to rather than by the text that happens to be on it.
      excludeSemantics: true,
      child: PlassInteractive(
        onTap: widget.onPressed,
        builder: (BuildContext context, PlassInteraction state) {
          final bool lit = state.hovered || state.pressed || widget.pressed;
          final Color ink = lit ? palette.foreground : palette.dim;

          Widget button = Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(color: lit ? palette.hover : null, borderRadius: radius),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconTheme(
                  data: IconThemeData(color: ink),
                  child: widget.icon,
                ),
                if (widget.showLabel) ...<Widget>[
                  const SizedBox(width: 4),
                  Text(
                    widget.label,
                    style: TextStyle(fontSize: meta, color: ink),
                  ),
                ],
              ],
            ),
          );

          if (state.focusVisible) {
            button = CustomPaint(
              foregroundPainter: PlassFocusRingPainter(
                color: widget.family.ring,
                borderRadius: radius,
              ),
              child: button,
            );
          }

          return button;
        },
      ),
    );
  }
}
