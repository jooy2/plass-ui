import * as React from 'react';
import { ArrowRightIcon, ChevronIcon, EllipsisIcon } from '../../internal/icons.js';
import {
  controlTextClasses,
  cx,
  focusRingClasses,
  gapClasses,
  hasContent,
  iconClasses,
  radiusClasses,
  transitionClasses
} from '../../internal/styles.js';
import type { PlassColor, PlassDensity, PlassSize } from '../../types.js';

/**
 * What is drawn between two steps of the trail.
 *
 * Four named marks rather than a free-for-all, because a separator is read
 * hundreds of times a day and the difference between them is meaning, not
 * decoration: a `chevron` and an `arrow` say "and then", a `slash` says "path",
 * a `dot` says "these are peers of one thing". Anything else can still be passed
 * as a node.
 */
export type PlBreadcrumbSeparator = 'chevron' | 'arrow' | 'slash' | 'dot';

/** What a `PlBreadcrumbItem` inherits from the `PlBreadcrumb` around it. */
interface BreadcrumbContextValue {
  size: PlassSize;
  /** Whether this is the step the trail ends on. */
  last: boolean;
}

const BreadcrumbContext = /* @__PURE__ */ React.createContext<BreadcrumbContextValue>({
  size: 'md',
  last: false
});

export interface PlBreadcrumbProps extends Omit<React.ComponentPropsWithoutRef<'nav'>, 'color'> {
  /** @default 'md' */
  size?: PlassSize;
  /**
   * The colour family a link picks up when it is hovered.
   * @default 'primary'
   */
  color?: PlassColor;
  /**
   * How tightly the steps pack. Spacing only.
   * @default 'default'
   */
  density?: PlassDensity;
  /**
   * The mark between two steps. One of the four names, or any node.
   * @default 'chevron'
   */
  separator?: PlBreadcrumbSeparator | React.ReactNode;
  /**
   * How many steps to show before the middle is folded away behind a `…`. Left
   * out, the whole trail is shown however long it gets.
   */
  maxItems?: number;
  /**
   * How many steps stay at the front of a folded trail.
   * @default 1
   */
  itemsBeforeCollapse?: number;
  /**
   * How many stay at the end.
   * @default 1
   */
  itemsAfterCollapse?: number;
  /**
   * Whether pressing the `…` unfolds the trail in place. Turn it off to leave
   * the fold as a plain mark.
   * @default true
   */
  expandable?: boolean;
  /**
   * The name the trail is announced by. Never drawn.
   * @default 'Breadcrumb'
   */
  label?: string;
  /**
   * What the `…` is announced as. Never drawn.
   * @default 'Show the hidden steps'
   */
  expandLabel?: string;
  /**
   * Emits the trail a second time as a `BreadcrumbList`, in a
   * `<script type="application/ld+json">` beside the markup.
   *
   * Off by default, because a page can only have one of these and a great many
   * apps already emit theirs from an SEO layer of their own — two would be a
   * page describing itself twice. Turn it on where this component *is* the
   * trail: correct markup alone is not what puts a path under a search result,
   * and the structured data is.
   *
   * Every step goes in, including the ones a `maxItems` fold is hiding — what is
   * collapsed is a matter of how much room the row has, and the path is the path
   * either way.
   * @default false
   */
  structuredData?: boolean;
  /**
   * What relative `href`s are resolved against for `structuredData` — the site's
   * origin, as `https://example.com`.
   *
   * Search engines want an absolute URL there. Without this the `href`s are
   * emitted exactly as written, which is right when they are already absolute
   * and not much use when they are not.
   */
  baseUrl?: string;
  /** The `PlBreadcrumbItem`s. */
  children?: React.ReactNode;
}

export interface PlBreadcrumbItemProps extends Omit<
  React.ComponentPropsWithoutRef<'li'>,
  'color' | 'onClick'
> {
  /** Renders the step as a link. */
  href?: string;
  /** Fires when the step is pressed. Renders it as a button when there is no `href`. */
  onClick?: React.MouseEventHandler<HTMLElement>;
  /** Content before the label — a home glyph, a repository avatar. */
  startIcon?: React.ReactNode;
  /** Content after the label. */
  endIcon?: React.ReactNode;
  /**
   * Marks this step as the page you are on, which stops it being a link.
   *
   * The last step is the current one on its own, so this is only needed for a
   * trail that ends somewhere the reader is not — and setting it anywhere takes
   * the mark off the last step, because only one step in a trail can be it.
   */
  current?: boolean;
  /** Unavailable. Stops answering, keeps its place in the trail. */
  disabled?: boolean;
  /** The step's label. */
  children?: React.ReactNode;
}

/** Between the steps, and the only thing `density` touches. */
const trailGapClasses: Record<PlassDensity, Record<PlassSize, string>> = {
  default: { xs: 'gap-1', sm: 'gap-1.5', md: 'gap-2', lg: 'gap-2.5', xl: 'gap-3' },
  compact: { xs: 'gap-0.5', sm: 'gap-1', md: 'gap-1', lg: 'gap-1.5', xl: 'gap-2' }
};

/**
 * A step's corner, read two steps down the radius ladder.
 *
 * `radiusClasses.md` is 12px, which on a line of text 20px tall is most of the
 * way to a pill — and a breadcrumb step is not a `PlChip`. What the hover tint
 * needs is a rectangle with the corners taken off, which is what the ladder says
 * everywhere else; it just has to be read further down for something this short.
 */
const stepRadiusClasses: Record<PlassSize, string> = {
  xs: radiusClasses.xs,
  sm: radiusClasses.xs,
  md: radiusClasses.xs,
  lg: radiusClasses.sm,
  xl: radiusClasses.sm
};

/**
 * The four marks.
 *
 * The two that point are glyphs turned rather than redrawn, the same allowance
 * the no-transform rule makes for the chevron on a `PlAccordion`: the wedge is
 * drawn pointing down once, and a trail turns it a quarter. Both turn back under
 * RTL, because a trail runs the way the language does.
 */
function separatorMark(separator: PlBreadcrumbSeparator): React.ReactNode {
  switch (separator) {
    case 'chevron':
      return (
        <span className="flex -rotate-90 items-center rtl:rotate-90">
          <ChevronIcon />
        </span>
      );
    case 'arrow':
      return (
        <span className="flex items-center rtl:rotate-180">
          <ArrowRightIcon />
        </span>
      );
    case 'slash':
      return <span className="opacity-70">/</span>;
    case 'dot':
      return <span className="opacity-70">·</span>;
    default:
      return null;
  }
}

const separatorNames: PlBreadcrumbSeparator[] = ['chevron', 'arrow', 'slash', 'dot'];

/**
 * The words in a step, with everything that is not a word left out.
 *
 * A step's label is a `ReactNode` and `name` in the structured data is a string,
 * so the tree is walked for its text. Only `children` is read — a `startIcon` is
 * a picture of the thing rather than its name, and a home glyph contributing
 * nothing is exactly right.
 */
function textOf(node: React.ReactNode): string {
  if (typeof node === 'string' || typeof node === 'number') {
    return String(node);
  }

  if (Array.isArray(node)) {
    return node.map(textOf).join('');
  }

  if (React.isValidElement(node)) {
    return textOf((node.props as { children?: React.ReactNode }).children);
  }

  return '';
}

/**
 * A step's `href` as a search engine wants it: absolute.
 *
 * `new URL` is what resolves `../guide` against a base rather than pasting the
 * two together, and it throws on anything it cannot make sense of — a base that
 * is not a URL, an `href` that is a router-only path. Falling back to the `href`
 * as written is better than dropping the entry: a relative URL is a weaker
 * signal, an absent one is none.
 */
function absoluteHref(href: string, baseUrl?: string): string {
  if (!baseUrl) {
    return href;
  }

  try {
    return new URL(href, baseUrl).href;
  } catch {
    return href;
  }
}

/**
 * The trail as `schema.org`'s `BreadcrumbList`.
 *
 * `item` is omitted where a step has no `href`, which is the last step's usual
 * case: a crawler reads a final entry without one as the page being looked at,
 * and a `ListItem` pointing at nothing would be worse than one pointing nowhere.
 */
function breadcrumbListData(
  steps: React.ReactElement<PlBreadcrumbItemProps>[],
  baseUrl?: string
): string {
  const itemListElement = steps.map((step, index) => {
    const { href, children } = step.props;

    return {
      '@type': 'ListItem',
      position: index + 1,
      name: textOf(children),
      ...(href ? { item: absoluteHref(href, baseUrl) } : null)
    };
  });

  // `<` is escaped because this string is written into a `<script>`: a label
  // holding `</script>` would otherwise close the tag and turn the rest of the
  // JSON into markup.
  return JSON.stringify({
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement
  }).replace(/</g, '\\u003c');
}

function isSeparatorName(value: unknown): value is PlBreadcrumbSeparator {
  return typeof value === 'string' && separatorNames.includes(value as PlBreadcrumbSeparator);
}

/**
 * The trail of pages above the one being read.
 *
 * Two things make this more than a row of links. The first is that the last step
 * is where the reader already is, so it is not a link at all — it carries
 * `aria-current="page"` and stops being pressable, and the component works that
 * out rather than asking every caller to remember it. The second is the fold: a
 * trail seven levels deep is a trail nobody reads, so the middle collapses to a
 * `…` that puts it back when pressed.
 *
 * The separators are drawn by the trail rather than by the steps. A step does
 * not know whether anything follows it, and a mark that belonged to a step would
 * have to be taken off the last one by hand.
 *
 * There is no `variant` and no `elevation`: a trail is a line of text above the
 * page, not a surface laid on it.
 */
export const PlBreadcrumb = /* @__PURE__ */ React.forwardRef<HTMLElement, PlBreadcrumbProps>(
  function PlBreadcrumb(
    {
      size = 'md',
      color = 'primary',
      density = 'default',
      separator = 'chevron',
      maxItems,
      itemsBeforeCollapse = 1,
      itemsAfterCollapse = 1,
      expandable = true,
      label = 'Breadcrumb',
      expandLabel = 'Show the hidden steps',
      structuredData = false,
      baseUrl,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const [unfolded, setUnfolded] = React.useState(false);

    const steps = React.Children.toArray(children).filter(
      React.isValidElement
    ) as React.ReactElement<PlBreadcrumbItemProps>[];
    const total = steps.length;

    /*
     * The last step is the page you are on — unless a step says it is. Exactly one
     * element in a trail may carry `aria-current="page"`, so a caller who marks an
     * earlier step has to take the mark off the last one, and doing that by hand
     * would mean writing `current={false}` on a step that never asked for it.
     */
    const claimed = steps.some((step) => step.props.current === true);

    const folding =
      !unfolded &&
      maxItems !== undefined &&
      total > Math.max(maxItems, 1) &&
      // A fold has to actually remove something. With `1` before and `1` after on
      // a three-step trail the `…` would stand in for exactly one step, which is
      // longer than the step it replaced.
      total - itemsBeforeCollapse - itemsAfterCollapse > 1;

    const shown = folding
      ? [
          ...steps.slice(0, Math.max(0, itemsBeforeCollapse)),
          null,
          ...steps.slice(total - Math.max(0, itemsAfterCollapse))
        ]
      : steps;

    const mark = isSeparatorName(separator) ? separatorMark(separator) : separator;

    const foldClassNames = cx(
      'inline-flex items-center rounded-(--plass-radius-xs) px-0.5',
      'text-(--plass-muted-fg)',
      transitionClasses,
      iconClasses,
      expandable
        ? cx('cursor-pointer hover:bg-(--p-soft) hover:text-(--p-accent)', focusRingClasses)
        : ''
    );

    return (
      <nav
        ref={ref}
        aria-label={label}
        className={cx('flex', controlTextClasses[size], iconClasses, className)}
        style={
          {
            '--p-accent': `var(--plass-${color}-accent)`,
            '--p-soft': `var(--plass-${color}-soft)`,
            '--p-ring': `var(--plass-${color}-ring)`,
            ...style
          } as React.CSSProperties
        }
        {...props}
      >
        {/* Beside the markup rather than instead of it: the `<ol>` is what a
          reader gets and this is what a crawler reads. Every step is in it,
          including any the fold is hiding — what is collapsed is a question of
          room, and the path is the path either way. */}
        {structuredData && total > 0 ? (
          <script
            type="application/ld+json"
            dangerouslySetInnerHTML={{ __html: breadcrumbListData(steps, baseUrl) }}
          />
        ) : null}

        <ol
          // `role="list"` said out loud: Tailwind's reset takes the bullets off
          // every `<ol>`, and Safari takes the list semantics off with them.
          role="list"
          className={cx(
            'flex list-none flex-wrap items-center p-0',
            trailGapClasses[density][size]
          )}
        >
          {shown.map((step, index) => (
            <React.Fragment key={step ? (step.key ?? index) : 'fold'}>
              {index > 0 ? (
                <li
                  aria-hidden="true"
                  className="flex shrink-0 items-center text-(--plass-muted-fg) select-none"
                >
                  {mark}
                </li>
              ) : null}

              {step ? (
                <BreadcrumbContext.Provider
                  value={{ size, last: !claimed && index === shown.length - 1 }}
                >
                  {step}
                </BreadcrumbContext.Provider>
              ) : (
                <li className="flex shrink-0 items-center">
                  {expandable ? (
                    <button
                      type="button"
                      className={foldClassNames}
                      aria-label={expandLabel}
                      onClick={() => setUnfolded(true)}
                    >
                      <EllipsisIcon />
                    </button>
                  ) : (
                    <span className={foldClassNames} aria-hidden="true">
                      <EllipsisIcon />
                    </span>
                  )}
                </li>
              )}
            </React.Fragment>
          ))}
        </ol>
      </nav>
    );
  }
);

/**
 * One step of the trail.
 *
 * It renders three different things and the caller picks by what they pass: an
 * `<a>` with an `href`, a `<button>` with an `onClick`, and a plain `<span>` with
 * neither — which is what the last step is, because the page you are already on
 * is not somewhere to go.
 */
export const PlBreadcrumbItem = /* @__PURE__ */ React.forwardRef<
  HTMLLIElement,
  PlBreadcrumbItemProps
>(function PlBreadcrumbItem(
  { href, onClick, startIcon, endIcon, current, disabled = false, className, children, ...props },
  ref
) {
  const { size, last } = React.useContext(BreadcrumbContext);
  const isCurrent = current ?? last;
  const interactive = Boolean(href || onClick) && !isCurrent && !disabled;

  const stepClassNames = cx(
    'inline-flex min-w-0 items-center px-1',
    gapClasses[size],
    stepRadiusClasses[size],
    transitionClasses,
    // An if/else rather than stacked variants: two Tailwind classes of equal
    // specificity resolve by their order in the generated stylesheet.
    disabled
      ? 'cursor-not-allowed text-(--plass-muted-fg) opacity-50'
      : isCurrent
        ? 'font-medium text-(--plass-fg)'
        : interactive
          ? cx(
              'cursor-pointer text-(--plass-muted-fg)',
              'hover:bg-(--p-soft) hover:text-(--p-accent)',
              focusRingClasses
            )
          : 'text-(--plass-muted-fg)'
  );

  const body = (
    <>
      {hasContent(startIcon) ? (
        <span className="flex h-[1lh] shrink-0 items-center">{startIcon}</span>
      ) : null}
      <span className="truncate">{children}</span>
      {hasContent(endIcon) ? (
        <span className="flex h-[1lh] shrink-0 items-center">{endIcon}</span>
      ) : null}
    </>
  );

  return (
    <li ref={ref} className={cx('flex min-w-0 items-center', className)} {...props}>
      {interactive && href ? (
        <a href={href} className={stepClassNames} onClick={onClick}>
          {body}
        </a>
      ) : interactive ? (
        <button type="button" className={stepClassNames} onClick={onClick}>
          {body}
        </button>
      ) : (
        // `aria-current="page"` rather than `"true"`: a trail is navigation,
        // and the step the reader is on is a *page*, not the chosen one of a
        // set of options.
        <span
          className={stepClassNames}
          aria-current={isCurrent ? 'page' : undefined}
          aria-disabled={disabled || undefined}
        >
          {body}
        </span>
      )}
    </li>
  );
});
