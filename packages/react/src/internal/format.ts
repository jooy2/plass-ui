/**
 * The `Intl` formatters, memoised.
 *
 * Here rather than inline for one reason: constructing a formatter is the
 * expensive half of using one. On V8, `new Intl.DateTimeFormat(...).format(d)`
 * costs about 16us and `format(d)` on a formatter that already exists costs
 * about 0.3us — fifty-five times the work for the same string.
 *
 * That ratio only matters where the call is in a loop or in a render, and in the
 * pickers it is both: a calendar builds seven weekday names and twelve month
 * names for a 42-cell month view, and it builds them again on every step, every
 * hover and every keystroke.
 *
 * The cache is unbounded on purpose. The keys are not user data — they come from
 * a component's own option objects, of which any one page has a handful — so
 * there is nothing here that grows with the size of anything.
 *
 * The options object is deliberately **not** part of the key by identity. A
 * caller writing `format={{ dateStyle: 'medium' }}` inline hands over a new
 * object on every render, which is the ordinary way that prop gets written, and
 * keying on identity would miss every time and cache nothing but garbage.
 */

/**
 * `undefined` locale means the runtime's own, and is a key of its own. The two
 * halves are parted by a NUL, which no locale tag and no option name can
 * contain, so no two different pairs of inputs can spell the same key.
 */
function cacheKey(locale: string | undefined, options: object | undefined): string {
  return `${locale ?? ''}\u0000${options ? JSON.stringify(options) : ''}`;
}

const dateFormatters = new Map<string, Intl.DateTimeFormat>();

/** A memoised `Intl.DateTimeFormat`. */
export function dateFormatter(
  locale: string | undefined,
  options: Intl.DateTimeFormatOptions
): Intl.DateTimeFormat {
  const key = cacheKey(locale, options);
  let formatter = dateFormatters.get(key);

  if (!formatter) {
    formatter = new Intl.DateTimeFormat(locale, options);
    dateFormatters.set(key, formatter);
  }

  return formatter;
}

const numberFormatters = new Map<string, Intl.NumberFormat>();

/** A memoised `Intl.NumberFormat`. */
export function numberFormatter(
  locale: string | undefined,
  options?: Intl.NumberFormatOptions
): Intl.NumberFormat {
  const key = cacheKey(locale, options);
  let formatter = numberFormatters.get(key);

  if (!formatter) {
    formatter = new Intl.NumberFormat(locale, options);
    numberFormatters.set(key, formatter);
  }

  return formatter;
}
