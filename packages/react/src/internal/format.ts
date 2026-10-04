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

/*
 * A date formatter reads the runtime's time zone once, when it is built, and a
 * browser's zone can change while a page is open: the machine travels, or its
 * owner changes the setting. A formatter cached before that goes on writing the
 * old zone's wall clock, while every date the pickers build is a local midnight
 * in the new one, so the 1st of a month written in a zone to the west comes out
 * as the last day of the month before.
 *
 * Asking for the zone by name costs a formatter of its own, several hundred
 * lookups' worth, so it is not asked on every call. The offset from UTC at two
 * instants half a year apart costs a fraction of a lookup, and it moves when
 * the zone does, in winter or in summer: when it moves, the date formatters are
 * dropped and built again in the new zone. Two zones that share both offsets
 * write the same day for nearly every date; what this misses is a date on which
 * one of them has moved its clocks and the other has not, or one from a year
 * their rules differed.
 */

/** 1 January and 1 July 2021, at midnight UTC. */
const winter = /* @__PURE__ */ new Date(1_609_459_200_000);
const summer = /* @__PURE__ */ new Date(1_625_097_600_000);

/** The offsets the cached date formatters were built under. Unknown until the first call. */
let winterOffset = Number.NaN;
let summerOffset = Number.NaN;

/** Has the runtime's zone changed since the date formatters were built? */
function zoneHasMoved(): boolean {
  const nowWinter = winter.getTimezoneOffset();
  const nowSummer = summer.getTimezoneOffset();

  if (nowWinter === winterOffset && nowSummer === summerOffset) {
    return false;
  }

  winterOffset = nowWinter;
  summerOffset = nowSummer;

  return true;
}

/**
 * A memoised `Intl.DateTimeFormat`, built again when the runtime's time zone
 * has changed since it was.
 */
export function dateFormatter(
  locale: string | undefined,
  options: Intl.DateTimeFormatOptions
): Intl.DateTimeFormat {
  if (zoneHasMoved()) {
    dateFormatters.clear();
  }

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
