'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import { useLabels } from '../../internal/labels.js';
import { CheckIcon, CodeIcon, CopyIcon } from '../../internal/icons.js';
import {
  canonicalLanguage,
  highlight as highlightCode,
  plainLines,
  type PlCodeLine
} from '../../internal/highlight.js';
import {
  cx,
  hasContent,
  metaTextClasses,
  radiusClasses,
  srOnlyClasses,
  surfaceSlots,
  toLength,
  transitionClasses
} from '../../internal/styles.js';
import type { PlassColor, PlassDensity, PlassElevation, PlassSize } from '../../types.js';

export { registerLanguage } from '../../internal/highlight.js';
export type { PlCodeLine, PlCodeToken } from '../../internal/highlight.js';

/**
 * Which palette the block wears.
 *
 * The four house themes come first. `dark` is the default and it is the one
 * that is not a preference: code has been read on a dark ground since
 * terminals, and a block that matched the page would be the one element on it
 * whose colours were chosen by something other than the code. `auto` is the
 * opt-out, and `mono` has no hue in it at all.
 *
 * The eight after them are ports, kept at their published values. They exist
 * because a code block is the one component whose colours a reader already has
 * an opinion about: someone who writes in One Dark all day reads a Dracula
 * block as a different product's documentation.
 *
 * The type is open on purpose. A theme is a set of `--p-code-*` custom
 * properties under a `[data-code-theme]` selector and nothing else, so a
 * consumer who writes one in their own stylesheet has a theme — with nothing to
 * register, nothing to import, and no cost to anybody who did not.
 */
export type PlCodeBlockTheme =
  | 'dark'
  | 'light'
  | 'auto'
  | 'mono'
  | 'one-dark'
  | 'dracula'
  | 'monokai'
  | 'nord'
  | 'night-owl'
  | 'gruvbox'
  | 'github'
  | 'solarized-light';

export interface PlCodeBlockProps extends Omit<
  React.ComponentPropsWithoutRef<'div'>,
  'color' | 'title' | 'prefix' | 'children' | 'onCopy'
> {
  /**
   * The code. Trailing whitespace is trimmed off the end of the block — a
   * template literal is almost always written with a newline before its closing
   * backtick, and that newline is a blank line at the bottom of every block.
   */
  code: string;
  /**
   * What it is written in — `ts`, `dart`, `bash`, `yml`, `dockerfile`. The
   * common spellings and file extensions are understood, so a value copied off
   * a fenced code block works as-is.
   *
   * A language nothing here knows is drawn plain rather than refused; teach it
   * one with `registerLanguage`.
   */
  language?: string;
  /**
   * The palette. Independent of the page's light and dark, except on `auto`.
   *
   * Any other string works too, and is how a project brings its own: write
   * `[data-code-theme='ours'] { --p-code-bg: …; --p-code-keyword: … }` in your
   * own CSS and pass the name. Sixteen slots, five of which are derived from
   * the other two and need no declaration.
   * @default 'dark'
   */
  theme?: PlCodeBlockTheme | (string & {});
  /** The type scale and the air around the code. @default 'md' */
  size?: PlassSize;
  /** @default 'primary' */
  color?: PlassColor;
  /** @default 'default' */
  density?: PlassDensity;
  /** Drop shadow depth. `0` is flat, and is right for a block that is content. @default 0 */
  elevation?: PlassElevation;
  /**
   * Colours the code.
   *
   * Off, nothing is fetched at all: the grammar engine is behind a dynamic
   * import, so a block that does not highlight costs no more than the text in
   * it. On, the block draws plain on the first frame and colours itself when
   * the grammar lands — a few milliseconds, and never a blank space where the
   * code should be.
   * @default true
   */
  highlight?: boolean;
  /**
   * The bar over the code, and the master switch for it: with it off there is
   * no bar and none of `showLanguage`, `copyable` or `rawToggle` draws
   * anything, whatever they say.
   * @default true
   */
  toolbar?: boolean;
  /**
   * A name at the start of the bar — a file path, usually. Takes the place the
   * language would otherwise have; both can be shown at once.
   */
  title?: React.ReactNode;
  /** Names the language at the start of the bar. @default true */
  showLanguage?: boolean;
  /** The button that puts the code on the clipboard. @default true */
  copyable?: boolean;
  /**
   * The toggle that drops the colouring and shows the characters as they are.
   * Off by default: it is a second control on a bar that usually wants one, and
   * it means nothing at all when `highlight` is off.
   * @default false
   */
  rawToggle?: boolean;
  /**
   * Lines to mark: a tinted row with a rule down its leading edge.
   *
   * A number is one line, a string is a list of lines and ranges — `'4'`,
   * `'4-9'`, `'1,4-9,12'` — and an array is any mix of the two. They are
   * counted the way the gutter counts, so `startLine={286}` means
   * `highlightLines={288}` marks the line the gutter calls 288.
   *
   * The tint is mixed from the theme's own ink rather than from the page's
   * colour family, so it is legible on all twelve palettes and never the one
   * colour on a Dracula block that nobody chose.
   */
  highlightLines?: number | string | Array<number | string>;
  /** Numbers down the side. @default false */
  lineNumbers?: boolean;
  /** What the first line is numbered. @default 1 */
  startLine?: number;
  /**
   * A shell prompt in front of every line that has something on it — `$`, `#`,
   * `C:\>`, `>>>`.
   *
   * It is drawn but never *present*: the symbol is generated content, so it
   * cannot be selected, cannot be found by find-in-page and is not what the
   * copy button puts on the clipboard. A transcript stays a transcript and
   * still pastes into a shell.
   */
  prompt?: string;
  /** Wraps long lines instead of scrolling them sideways. @default false */
  wrap?: boolean;
  /**
   * How tall the block may get before the code scrolls inside it. A number is
   * pixels; any CSS length works. Left out, the block is as tall as the code.
   */
  maxHeight?: number | string;
  /** The typeface. Defaults to the page's own monospace stack. */
  fontFamily?: string;
  /** Overrides the size the `size` ladder chose. A number is pixels. */
  fontSize?: number | string;
  /** Overrides the leading. A bare number is a ratio, as in CSS. */
  lineHeight?: number | string;
  /** Tracking. A number is pixels; `-0.01em` and the like work too. */
  letterSpacing?: number | string;
  /** The copy button's label. @default 'Copy' */
  copyLabel?: string;
  /** And what it says once the code is on the clipboard. @default 'Copied' */
  copiedLabel?: string;
  /** And what it says when the clipboard refused. @default 'Copy failed' */
  copyFailedLabel?: string;
  /** The raw toggle's label. @default 'Raw' */
  rawLabel?: string;
  /** What the region is called when there is neither a title nor a language. @default 'Code' */
  codeLabel?: string;
  /** Fires with the copied text once the clipboard has taken it. */
  onCopy?: (code: string) => void;
}

/**
 * The type scale, one step under the running text at every size: a monospace
 * face at the same nominal size as the prose around it reads a size larger,
 * because its x-height is taller and every glyph is as wide as an `m`.
 */
const codeTextClasses: Record<PlassSize, string> = {
  xs: 'text-[0.6875rem]/[1.55]',
  sm: 'text-[0.75rem]/[1.6]',
  md: 'text-[0.8125rem]/[1.65]',
  lg: 'text-[0.875rem]/[1.7]',
  xl: 'text-[1rem]/[1.7]'
};

/**
 * The air around the code, split into the two axes because they go on two
 * different elements.
 *
 * The vertical padding belongs to the box that scrolls; the horizontal padding
 * belongs to each *line*, so a marked line's tint reaches both edges of the
 * block instead of stopping at a gutter. The lines sit in a `w-max min-w-full`
 * block, so they all reach the same edge whether the code is narrower than the
 * block or scrolled sideways inside it.
 */
const bodyPaddingYClasses: Record<PlassDensity, Record<PlassSize, string>> = {
  default: { xs: 'py-2', sm: 'py-3', md: 'py-3.5', lg: 'py-4', xl: 'py-5' },
  compact: { xs: 'py-1.5', sm: 'py-2', md: 'py-2.5', lg: 'py-3', xl: 'py-3.5' }
};

const linePaddingXClasses: Record<PlassDensity, Record<PlassSize, string>> = {
  default: { xs: 'px-2', sm: 'px-3', md: 'px-3.5', lg: 'px-4', xl: 'px-5' },
  compact: { xs: 'px-1.5', sm: 'px-2', md: 'px-2.5', lg: 'px-3', xl: 'px-3.5' }
};

/**
 * The bar is shallower than the body: it holds controls, not a paragraph.
 *
 * Its horizontal padding is `linePaddingXClasses` plus the two pixels a line
 * spends on the rule a marked one draws, so the name at the start of the bar
 * begins exactly where the code under it does. Two ladders that were within
 * four pixels of each other would read as one ladder somebody got wrong.
 */
const barPaddingClasses: Record<PlassDensity, Record<PlassSize, string>> = {
  default: {
    xs: 'px-2.5 py-1',
    sm: 'px-3.5 py-1',
    md: 'px-4 py-1.5',
    lg: 'px-4.5 py-2',
    xl: 'px-5.5 py-2'
  },
  compact: {
    xs: 'px-2 py-0.5',
    sm: 'px-2.5 py-0.5',
    md: 'px-3 py-1',
    lg: 'px-3.5 py-1',
    xl: 'px-4 py-1.5'
  }
};

/** How long the copy button says it worked. */
const COPIED_FOR = 2000;

/**
 * `4`, `'4-9'`, `'1,4-9,12'` or any array of those, as the set of numbers they
 * name.
 *
 * A set rather than a sorted list of ranges because the only question ever
 * asked of it is "is this line in it", once per line. Anything unparseable is
 * dropped rather than thrown: a marked line is an annotation, and a typo in one
 * should cost the annotation, not the code.
 */
function markedLines(spec: number | string | Array<number | string> | undefined): Set<number> {
  const marked = new Set<number>();

  if (spec === undefined) {
    return marked;
  }

  for (const part of Array.isArray(spec) ? spec : [spec]) {
    if (typeof part === 'number') {
      if (Number.isFinite(part)) {
        marked.add(Math.trunc(part));
      }

      continue;
    }

    for (const token of part.split(',')) {
      const range = /^\s*(\d+)\s*(?:-\s*(\d+)\s*)?$/.exec(token);

      if (!range) {
        continue;
      }

      const from = Number(range[1]);
      const to = range[2] === undefined ? from : Number(range[2]);

      // Written the wrong way round is still a range, and the reader who typed
      // `9-4` meant the same four lines.
      for (let line = Math.min(from, to); line <= Math.max(from, to); line += 1) {
        marked.add(line);
      }
    }
  }

  return marked;
}

/**
 * Puts `text` on the clipboard, through whichever of the two ways the browser
 * allows.
 *
 * The async Clipboard API needs a secure context, and a component library is
 * used on `http://192.168.1.4:3000` more often than anyone admits. The fallback
 * is the old `execCommand` dance against an off-screen textarea, which works
 * everywhere and is deprecated everywhere.
 */
async function writeToClipboard(text: string): Promise<boolean> {
  try {
    if (navigator.clipboard?.writeText) {
      await navigator.clipboard.writeText(text);

      return true;
    }
  } catch {
    // Fall through: a rejected promise here is a permission or a context, and
    // the fallback below is subject to neither.
  }

  try {
    const carrier = document.createElement('textarea');

    carrier.value = text;
    carrier.setAttribute('readonly', '');
    carrier.style.cssText = 'position:fixed;top:0;left:0;opacity:0;pointer-events:none';
    document.body.append(carrier);
    carrier.select();

    const copied = document.execCommand('copy');

    carrier.remove();

    return copied;
  } catch {
    return false;
  }
}

/**
 * A viewer for one line of code or a thousand.
 *
 * Everything it draws above the code is optional and off one prop each, because
 * the same component has to be a snippet inside a sentence — no bar, no
 * numbers, no chrome — and the full transcript at the top of a README, and
 * those are the same block with different things turned on rather than two
 * components.
 *
 * The colouring is highlight.js, and it is the one thing in the library reached
 * through a dynamic import: the grammars are forty kilobytes and there are
 * thirty-five of them, so they arrive as their own chunk, one language at a
 * time, and only for a block that asked to be coloured. See
 * `internal/highlight.ts` for why that is a `dependencies` entry rather than an
 * optional peer.
 *
 * The block is rendered as lines rather than as one run of text — even with no
 * numbers and no prompt — because a line is what carries a number, a prompt and
 * a place in the scroll, and a component that switched between two renderings
 * would have two sets of wrapping behaviour to keep in step.
 *
 * **It is the one surface in the library that is not made of glass.** Every
 * other sheet here is translucent and takes the page's colour family; this one
 * paints its own opaque ground and refuses the family entirely, because the
 * palette is the subject rather than the setting. A Dracula block tinted
 * `primary` would be a Dracula block nobody chose.
 */
export const PlCodeBlock = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlCodeBlockProps>(
  function PlCodeBlock(
    {
      code,
      language,
      theme = 'dark',
      size: sizeProp,
      color: colorProp,
      density: densityProp,
      elevation = 0,
      highlight = true,
      toolbar = true,
      title,
      showLanguage = true,
      copyable = true,
      rawToggle = false,
      highlightLines,
      lineNumbers = false,
      startLine = 1,
      prompt,
      wrap = false,
      maxHeight,
      fontFamily,
      fontSize,
      lineHeight,
      letterSpacing,
      copyLabel,
      copiedLabel,
      copyFailedLabel,
      rawLabel,
      codeLabel,
      onCopy,
      className,
      style,
      ...props
    },
    ref
  ) {
    const defaults = useDefaults();
    const size = sizeProp ?? defaults.size ?? 'md';
    const color = colorProp ?? defaults.color ?? 'primary';
    const density = densityProp ?? defaults.density ?? 'default';

    const labels = useLabels();
    const copyName = copyLabel ?? labels.copy;
    const copiedName = copiedLabel ?? labels.copied;
    const failedName = copyFailedLabel ?? labels.copyFailed;
    const rawName = rawLabel ?? labels.raw;

    /**
     * What the clipboard gets and what the highlighter is handed: line endings
     * normalised, trailing blank lines gone, and nothing else touched.
     * Indentation is meaningful in half of the languages here, so nothing is
     * trimmed off the front.
     *
     * The `\r` is not pedantry. A `code` prop very often arrives from a file,
     * and a file written on Windows ends every line with one — which lines are
     * split on `\n`, so each line keeps a carriage return the reader cannot
     * see, the highlighter treats as part of the last token, and the clipboard
     * hands straight to a shell.
     */
    const source = React.useMemo(() => code.replace(/\r\n?/g, '\n').replace(/\s+$/, ''), [code]);

    const name = canonicalLanguage(language);

    const [raw, setRaw] = React.useState(false);
    const [copied, setCopied] = React.useState<boolean | null>(null);
    const [coloured, setColoured] = React.useState<PlCodeLine[] | null>(null);

    const wanted = highlight && !raw && name !== null;

    /**
     * The colouring, once the grammar has arrived.
     *
     * `cancelled` rather than an `AbortController` because there is nothing to
     * abort: the import is already in flight and shared with every other block
     * in the same language, and all this has to guarantee is that a block
     * unmounted or re-pointed mid-fetch does not set state afterwards.
     */
    React.useEffect(() => {
      if (!wanted || !name) {
        setColoured(null);

        return;
      }

      let cancelled = false;

      highlightCode(source, name).then(
        (lines) => {
          if (!cancelled) {
            setColoured(lines);
          }
        },
        () => {
          if (!cancelled) {
            setColoured(null);
          }
        }
      );

      return () => {
        cancelled = true;
      };
    }, [source, name, wanted]);

    const lines = React.useMemo(
      () => (wanted && coloured ? coloured : plainLines(source)),
      [wanted, coloured, source]
    );

    /** Wide enough for the last number, so the gutter does not step as it scrolls. */
    const gutter = `${String(startLine + Math.max(lines.length - 1, 0)).length}ch`;

    const timer = React.useRef<ReturnType<typeof setTimeout> | undefined>(undefined);

    React.useEffect(() => () => clearTimeout(timer.current), []);

    const copy = async () => {
      const done = await writeToClipboard(source);

      clearTimeout(timer.current);
      setCopied(done);
      timer.current = setTimeout(() => setCopied(null), COPIED_FOR);

      if (done) {
        onCopy?.(source);
      }
    };

    const marked = React.useMemo(() => markedLines(highlightLines), [highlightLines]);

    /**
     * Select-all inside the block, rather than select-all of the page.
     *
     * The code is a focusable region, so a reader who tabbed to it and pressed
     * the shortcut every editor has meant *this* code — and the browser's own
     * answer, selecting the article around it too, is never what they were
     * after. It is unconditional rather than a prop because the alternative it
     * would turn back on is not a feature.
     *
     * The prompts and the line numbers are generated content, so they are
     * outside the range for the same reason they are outside the clipboard:
     * there is nothing there to select.
     */
    const codeRef = React.useRef<HTMLPreElement | null>(null);

    const selectEverything = (event: React.KeyboardEvent<HTMLDivElement>) => {
      if (event.key !== 'a' && event.key !== 'A') {
        return;
      }

      if (!(event.metaKey || event.ctrlKey) || event.altKey) {
        return;
      }

      const node = codeRef.current;
      const selection = typeof window === 'undefined' ? null : window.getSelection();

      if (!node || !selection) {
        return;
      }

      event.preventDefault();

      const range = document.createRange();

      range.selectNodeContents(node);
      selection.removeAllRanges();
      selection.addRange(range);
    };

    /**
     * The toolbar's buttons are plain elements against the block's own slots
     * rather than `PlIconButton`s, and that is not a shortcut.
     *
     * A Plass control reads `--plass-fg` and the glass ladder, which are the
     * *page's*. These sit on a sheet that has deliberately refused the page's
     * palette — a dark block on a white article is the ordinary case — so a
     * `PlIconButton` here would be a light control on a black bar. What they
     * keep is the house treatment: the radius ladder, the transition, the
     * focus ring.
     */
    const buttonClasses = cx(
      'inline-flex shrink-0 cursor-pointer items-center gap-1 border-0 bg-transparent',
      'px-1.5 py-1 text-(--p-code-dim) hover:text-(--p-code-fg) hover:bg-(--p-code-hover)',
      radiusClasses.xs,
      metaTextClasses[size],
      '[&_svg]:pointer-events-none [&_svg]:size-[1.15em] [&_svg]:shrink-0',
      transitionClasses,
      'focus-visible:[outline:2px_solid_var(--p-ring)] focus-visible:outline-offset-1'
    );

    const regionName = hasContent(title) ? undefined : (name ?? codeLabel ?? labels.code);

    return (
      <div
        ref={ref}
        className={cx(
          'plass-code flex min-w-0 flex-col overflow-hidden',
          radiusClasses[size],
          'border bg-(--p-code-bg) text-(--p-code-fg) [border-color:var(--p-code-rule)]',
          '[box-shadow:var(--p-elev)]',
          transitionClasses,
          className
        )}
        data-code-theme={theme}
        data-code-wrap={wrap ? 'true' : undefined}
        style={
          {
            ...surfaceSlots(color, elevation),
            '--p-code-gutter': gutter,
            ...(fontFamily ? { fontFamily } : null),
            ...(fontSize === undefined ? null : { fontSize: toLength(fontSize) }),
            ...(lineHeight === undefined ? null : { lineHeight }),
            ...(letterSpacing === undefined ? null : { letterSpacing: toLength(letterSpacing) }),
            ...style
          } as React.CSSProperties
        }
        {...props}
      >
        {toolbar && (showLanguage || copyable || rawToggle || hasContent(title)) ? (
          <div
            className={cx(
              'flex min-w-0 items-center gap-1 border-b [border-color:var(--p-code-rule)]',
              barPaddingClasses[density][size]
            )}
          >
            {hasContent(title) ? (
              <span className={cx('min-w-0 truncate font-mono', metaTextClasses[size])}>
                {title}
              </span>
            ) : null}

            {showLanguage && name ? (
              <span
                className={cx(
                  'min-w-0 truncate font-mono tracking-wide text-(--p-code-dim) uppercase select-none',
                  metaTextClasses[size]
                )}
              >
                {name}
              </span>
            ) : null}

            <span className="flex-1" />

            {rawToggle && highlight ? (
              <button
                type="button"
                aria-pressed={raw}
                aria-label={rawName}
                title={rawName}
                onClick={() => setRaw((previous) => !previous)}
                className={cx(buttonClasses, raw ? 'bg-(--p-code-hover) text-(--p-code-fg)' : '')}
              >
                <CodeIcon />
              </button>
            ) : null}

            {copyable ? (
              <button type="button" onClick={copy} className={buttonClasses}>
                {copied ? <CheckIcon /> : <CopyIcon />}
                <span>{copied === null ? copyName : copied ? copiedName : failedName}</span>
              </button>
            ) : null}
          </div>
        ) : null}

        <div className={cx('flex min-h-0 flex-col', codeTextClasses[size])}>
          <div
            // A scrollable region has to be reachable by a keyboard that has no
            // pointer to drag with, and a focusable region has to have a name.
            role="region"
            aria-label={typeof title === 'string' ? title : regionName}
            tabIndex={0}
            onKeyDown={selectEverything}
            className={cx(
              'min-h-0 overflow-auto',
              bodyPaddingYClasses[density][size],
              'focus-visible:[outline:2px_solid_var(--p-ring)] focus-visible:-outline-offset-2'
            )}
            style={maxHeight === undefined ? undefined : { maxHeight: toLength(maxHeight) }}
          >
            {/* `w-max min-w-full` is what keeps the gutter and the prompts
                aligned while the code is scrolled sideways: the rows are as wide
                as the longest line rather than as wide as the window onto them,
                so every line's number starts at the same place instead of at the
                scroll's. It is also what lets a marked line's tint reach the same
                trailing edge as every other one. */}
            <pre
              ref={codeRef}
              className={cx(
                'm-0 bg-transparent p-0 font-mono',
                wrap ? 'w-full' : 'w-max min-w-full'
              )}
            >
              {lines.map((tokens, index) => {
                const number = startLine + index;

                return (
                  <div
                    key={index}
                    className={cx('plass-code-line', linePaddingXClasses[density][size])}
                    data-line={lineNumbers ? number : undefined}
                    data-mark={marked.has(number) ? '' : undefined}
                    data-prompt={prompt && tokens.length > 0 ? prompt : undefined}
                  >
                    <code>
                      {tokens.map((run, position) =>
                        run.token ? (
                          <span key={position} className={run.token}>
                            {run.text}
                          </span>
                        ) : (
                          <React.Fragment key={position}>{run.text}</React.Fragment>
                        )
                      )}
                    </code>
                  </div>
                );
              })}
            </pre>
          </div>
        </div>

        {/* The copy button changes its own label, which a screen reader reading
            the page rather than the button would never hear. This is the
            announcement, and it is only ever one word long. */}
        <span aria-live="polite" className={srOnlyClasses}>
          {copied === null ? '' : copied ? copiedName : failedName}
        </span>
      </div>
    );
  }
);
