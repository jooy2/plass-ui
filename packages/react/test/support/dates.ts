/**
 * The date strings the pickers write, asked of the API they ask.
 *
 * A day cell's accessible name and a trigger's text are CLDR data rather than
 * constants, and the browsers in the test matrix do not carry the same CLDR:
 * `en-GB` lost the comma after the weekday in `dateStyle: 'full'`, so a literal
 * `'Monday, 27 July 2026'` passes against one bundled ICU and fails against a
 * newer one. Formatting the expectation with the same options the component
 * uses keeps these tests about the component rather than about the runner.
 *
 * `en-GB` is the default because that is the locale the picker tests pass.
 */
export function fullDate(date: Date, locale = 'en-GB'): string {
  return new Intl.DateTimeFormat(locale, { dateStyle: 'full' }).format(date);
}

/** What a picker's trigger writes: `format` defaults to `{ dateStyle: 'medium' }`. */
export function mediumDate(date: Date, locale = 'en-GB'): string {
  return new Intl.DateTimeFormat(locale, { dateStyle: 'medium' }).format(date);
}

/** And what it writes at `precision="month"`, where the day is not asked for. */
export function monthAndYear(date: Date, locale = 'en-GB'): string {
  return new Intl.DateTimeFormat(locale, { year: 'numeric', month: 'long' }).format(date);
}
