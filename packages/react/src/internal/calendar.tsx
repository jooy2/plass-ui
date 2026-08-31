import * as React from 'react';
import { useDefaults } from './defaults.js';
import { PlButton } from '../components/button/PlButton.js';
import { ChevronIcon } from './icons.js';
import { dateFormatter } from './format.js';
import {
  addDays,
  addMonths,
  addYears,
  calendarWeeks,
  compareDay,
  isDayOutside,
  isMonthBeforeYear,
  isMonthOutside,
  isSameDay,
  isSameMonth,
  isValidDate,
  isYearOutside,
  makeDate,
  meridiemLabels,
  monthLabels,
  startOfDay,
  startOfMonth,
  today,
  weekdayLabels,
  withTime,
  YEAR_PAGE_SIZE,
  yearPageStart,
  type CalendarView,
  type TimeUnit
} from './date.js';
import {
  controlHeightClasses,
  controlTextClasses,
  cx,
  gapClasses,
  metaTextClasses,
  srOnlyClasses,
  transitionClasses
} from './styles.js';
import type { PlassColor, PlassDensity, PlassSize, PlassWeekday } from '../types.js';

/**
 * The calendar grid and the clock columns, written once for the four pickers.
 *
 * They live in `internal/` for the reason `button-group.ts` does: a
 * `PlDateTimePicker` is a date picker and a time picker in one popup and a
 * `PlDateRangePicker` is two calendars, so three components need this and none
 * of them should have to import another. The one thing it reaches *up* for is
 * `PlButton` — the header's steppers are buttons, they are not a new kind of
 * control, and `PlPagination` already makes that argument.
 *
 * The day cells are deliberately **not** `PlButton`s. A cell has states a
 * button has no vocabulary for — inside a range, at the end of a range, today,
 * belonging to the month next door — and four of them have to be told apart at
 * a glance in a grid of forty-two.
 */

/* ---------------------------------------------------------------------------
 * Words
 * ------------------------------------------------------------------------- */

/**
 * Every string a picker says that is not a date.
 *
 * One object rather than eighteen props. These are a set: a caller who has to
 * translate "Previous month" has to translate "Next month" in the same breath,
 * and a component with eighteen `*Label` props is a component whose signature is
 * mostly apology. The dates themselves are never in here — those come from
 * `Intl`, which already knows what July is called in more languages than this
 * file ever will.
 */
export interface PlassPickerLabels {
  /** The calendar's steppers, in day view. */
  previousMonth: string;
  nextMonth: string;
  /** The same steppers in month view, where they move by a year. */
  previousYear: string;
  nextYear: string;
  /** And in year view, where they move by a page of twelve. */
  previousYears: string;
  nextYears: string;
  /** The two header buttons that open the month grid and the year grid. */
  chooseMonth: string;
  chooseYear: string;
  /** The footer's actions. */
  today: string;
  /** The same shortcut on a picker that only asks for a month or a year. */
  thisMonth: string;
  thisYear: string;
  now: string;
  clear: string;
  done: string;
  /** The clock's columns. */
  hour: string;
  minute: string;
  second: string;
  meridiem: string;
  /** Which end of a range the calendar is currently asking for. */
  start: string;
  end: string;
}

export const defaultPickerLabels: PlassPickerLabels = {
  previousMonth: 'Previous month',
  nextMonth: 'Next month',
  previousYear: 'Previous year',
  nextYear: 'Next year',
  previousYears: 'Previous years',
  nextYears: 'Next years',
  chooseMonth: 'Choose a month',
  chooseYear: 'Choose a year',
  today: 'Today',
  thisMonth: 'This month',
  thisYear: 'This year',
  now: 'Now',
  clear: 'Clear',
  done: 'Done',
  hour: 'Hour',
  minute: 'Minute',
  second: 'Second',
  meridiem: 'AM/PM',
  start: 'Start',
  end: 'End'
};

/**
 * The labels a picker says, resolved once per render.
 *
 * Three layers, narrowest last: the English defaults above, whatever a
 * `PlassProvider` set for the application, and the component's own overrides.
 * That order is what lets an application translate the vocabulary once and a
 * single picker still say something different — a "Check in" where the rest of
 * the app says "Start".
 */
export function usePickerLabels(overrides?: Partial<PlassPickerLabels>): PlassPickerLabels {
  const { labels } = useDefaults();

  return React.useMemo(
    () =>
      labels || overrides
        ? { ...defaultPickerLabels, ...labels, ...overrides }
        : defaultPickerLabels,
    [labels, overrides]
  );
}

/** How far down each view drills, so a `precision` can be read as a floor. */
const viewDepth: Record<CalendarView, number> = { year: 0, month: 1, day: 2 };

/* ---------------------------------------------------------------------------
 * Scale
 * ------------------------------------------------------------------------- */

/**
 * The width of one day cell, as a length rather than as a class.
 *
 * It goes in an inline `--p-cell` slot for the reason the design language gives
 * for every per-instance value: Tailwind only sees class names written out
 * literally, and the grid needs this number in places that are not a `size-*`
 * utility — the panel's own width (`7 × cell`), the height the three views share
 * so switching between them does not resize the popup, and the clock's columns.
 *
 * The numbers are `controlHeightClasses` as lengths: a `md` day cell is 40px,
 * which is a `md` PlButton, which is a `md` PlTextField. A calendar dropped
 * beside a form is on the form's grid.
 */
const cellSizes: Record<PlassSize, string> = {
  xs: '1.5rem',
  sm: '2rem',
  md: '2.5rem',
  lg: '3rem',
  xl: '3.5rem'
};

/** A cell's corner, one step *down* the radius ladder from the popup it sits in. */
const cellRadiusClasses: Record<PlassSize, string> = {
  xs: 'rounded-(--plass-radius-xs)',
  sm: 'rounded-(--plass-radius-xs)',
  md: 'rounded-(--plass-radius-sm)',
  lg: 'rounded-(--plass-radius-md)',
  xl: 'rounded-(--plass-radius-lg)'
};

/** The same corner on one side only, for where a range band stops. */
const cellRadiusStartClasses: Record<PlassSize, string> = {
  xs: 'rounded-s-(--plass-radius-xs)',
  sm: 'rounded-s-(--plass-radius-xs)',
  md: 'rounded-s-(--plass-radius-sm)',
  lg: 'rounded-s-(--plass-radius-md)',
  xl: 'rounded-s-(--plass-radius-lg)'
};

const cellRadiusEndClasses: Record<PlassSize, string> = {
  xs: 'rounded-e-(--plass-radius-xs)',
  sm: 'rounded-e-(--plass-radius-xs)',
  md: 'rounded-e-(--plass-radius-sm)',
  lg: 'rounded-e-(--plass-radius-md)',
  xl: 'rounded-e-(--plass-radius-lg)'
};

/**
 * What every cell in every one of the three views is drawn on.
 *
 * The house transition, unchanged, and **no `transform` anywhere near it**: a
 * grid of forty-two cells that each grew a pixel under the pointer would be the
 * single worst place in the library to break that rule.
 *
 * The ring is written as the `outline` shorthand — never `outline-none`, which
 * zeroes the variable Tailwind routes the style through — and pulled *inside*
 * the cell rather than sitting outside it, because a ring drawn outside a cell
 * in a gapless grid is a ring drawn on the neighbours.
 */
const cellBaseClasses = /* @__PURE__ */ [
  'relative flex items-center justify-center tabular-nums select-none',
  '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
  transitionClasses,
  'focus-visible:z-10 focus-visible:[outline:2px_solid_var(--p-ring)]',
  'focus-visible:[outline-offset:-2px]'
].join(' ');

/* ---------------------------------------------------------------------------
 * The cell
 * ------------------------------------------------------------------------- */

/**
 * Where a cell sits in a run of banded days, so the band knows where to stop.
 * `null` is the ordinary case: not in a band at all, so fully rounded.
 */
type RangeEdge = 'start' | 'end' | 'both' | 'middle' | null;

interface CellProps {
  children: React.ReactNode;
  /** What a screen reader hears. Always the full date, never the bare number. */
  label: string;
  selected: boolean;
  /** Between the two ends of a range, or between one end and the pointer. */
  inRange?: boolean;
  rangeEdge?: RangeEdge;
  /** Today, this month, this year — whichever unit the grid is showing. */
  current?: boolean;
  /** Belongs to the month next door. */
  muted?: boolean;
  disabled?: boolean;
  /** The grid's single tab stop. */
  focused?: boolean;
  size: PlassSize;
  className?: string;
  onClick: () => void;
  onPointerEnter?: () => void;
  onKeyDown?: React.KeyboardEventHandler<HTMLButtonElement>;
}

/**
 * One pressable square in a grid.
 *
 * The state branch is an if/else chain rather than a stack of Tailwind
 * variants, which the design language asks for by name: two utilities of equal
 * specificity resolve by their order in the generated stylesheet, and "chosen"
 * beating "inside the range" is not something a component may leave to that.
 *
 * The order is the order of importance. Unavailable first — a blocked day still
 * wearing the range's tint would be advertising that it is part of a range it
 * cannot join. Then chosen, then inside the range, then today, then the days
 * belonging to the month next door.
 *
 * A chosen cell is the family's **gradient**, which makes it the one filled
 * token in the popup: the sheet under it is undyed glass, so what a reader is
 * looking for in a grid of forty-two is the only coloured thing on it.
 */
function Cell({
  children,
  label,
  selected,
  inRange = false,
  rangeEdge = null,
  current = false,
  muted = false,
  disabled = false,
  focused = false,
  size,
  className,
  onClick,
  onPointerEnter,
  onKeyDown
}: CellProps) {
  const stateClasses = disabled
    ? 'cursor-not-allowed text-(--plass-muted-fg) opacity-50'
    : selected
      ? 'cursor-pointer font-semibold text-(--p-on-solid) [background-image:var(--p-fill)] hover:brightness-105 active:brightness-95'
      : inRange
        ? 'cursor-pointer bg-(--p-soft) text-(--plass-fg) hover:bg-(--p-soft-hover) active:bg-(--p-soft-press)'
        : current
          ? 'cursor-pointer font-semibold text-(--p-accent) hover:bg-(--p-soft) active:bg-(--p-soft-hover)'
          : muted
            ? 'cursor-pointer text-(--plass-muted-fg) hover:bg-(--p-soft) active:bg-(--p-soft-hover)'
            : 'cursor-pointer text-(--plass-fg) hover:bg-(--p-soft) active:bg-(--p-soft-hover)';

  // Square through the middle of a run and rounded where the run stops, so a
  // week of banded days reads as one shape rather than as seven tokens.
  const shapeClasses =
    rangeEdge === 'start'
      ? cellRadiusStartClasses[size]
      : rangeEdge === 'end'
        ? cellRadiusEndClasses[size]
        : rangeEdge === 'middle'
          ? 'rounded-none'
          : cellRadiusClasses[size];

  return (
    <button
      type="button"
      role="gridcell"
      aria-label={label}
      aria-selected={selected}
      aria-current={current ? 'date' : undefined}
      aria-disabled={disabled || undefined}
      // Not the `disabled` attribute. A disabled button leaves the tab order and
      // the grid's arrow-key path with it, so a reader arrowing across a month
      // would fall into a hole at every blocked day.
      tabIndex={focused ? 0 : -1}
      data-focus-target={focused ? 'true' : undefined}
      className={cx(cellBaseClasses, shapeClasses, stateClasses, className)}
      onClick={() => {
        if (!disabled) {
          onClick();
        }
      }}
      onPointerEnter={onPointerEnter}
      onKeyDown={onKeyDown}
    >
      {children}
      {/* Today's mark. A dot rather than a ring, because the ring belongs to the
          focus indicator and two rings in one cell is a cell saying nothing. It
          inherits `currentColor`, so it turns white the moment the cell fills. */}
      {current ? (
        <span
          aria-hidden="true"
          className="absolute bottom-[0.18em] size-[0.22em] rounded-full bg-current"
        />
      ) : null}
    </button>
  );
}

/* ---------------------------------------------------------------------------
 * The header
 * ------------------------------------------------------------------------- */

interface HeaderProps {
  size: PlassSize;
  color: PlassColor;
  view: CalendarView;
  /** The view the calendar returns to when a disclosure is pressed shut. */
  precision: CalendarView;
  month: Date;
  locale: string | undefined;
  labels: PlassPickerLabels;
  showPreviousButton: boolean;
  showNextButton: boolean;
  onStep: (direction: -1 | 1) => void;
  onViewChange: (view: CalendarView) => void;
}

/**
 * The two steppers and, between them, the way into the other two views.
 *
 * This is what the component is for. A calendar that only steps a month at a
 * time puts a birthday thirty years back a hundred and eighty clicks away, so
 * the month and the year are each a button that opens a grid of its own: two
 * clicks to any month of the year on screen, three to any year at all.
 *
 * The two buttons are printed in the order the locale writes them — `July 2026`
 * in English, `2026년 7월` in Korean. `Intl` is asked which part comes first
 * rather than being guessed at, because a header in the wrong order reads as
 * broken to exactly the readers it is wrong for.
 *
 * A calendar that stops at a month or a year has fewer of them. `precision` is
 * the floor, so a month picker's header is the year button alone and a year
 * picker's is the page range it already was — there is nothing to disclose
 * below the unit the picker is asking for.
 */
function Header({
  size,
  color,
  view,
  precision,
  month,
  locale,
  labels,
  showPreviousButton,
  showNextButton,
  onStep,
  onViewChange
}: HeaderProps) {
  const monthName = monthLabels(locale, 'long')[month.getMonth()];
  const yearName = String(month.getFullYear());
  const monthFirst = isMonthBeforeYear(locale);

  const stepLabels =
    view === 'day'
      ? [labels.previousMonth, labels.nextMonth]
      : view === 'month'
        ? [labels.previousYear, labels.nextYear]
        : [labels.previousYears, labels.nextYears];

  const stepper = (direction: -1 | 1, shown: boolean) =>
    shown ? (
      <PlButton
        variant="ghost"
        size={size}
        color={color}
        density="compact"
        aria-label={stepLabels[direction === -1 ? 0 : 1]}
        onClick={() => onStep(direction)}
        startIcon={
          <span
            className={cx(
              'flex items-center',
              direction === -1 ? 'rotate-90 rtl:-rotate-90' : '-rotate-90 rtl:rotate-90'
            )}
          >
            <ChevronIcon />
          </span>
        }
      />
    ) : (
      // A hole the size of the button that is not there, so two panels side by
      // side keep their headings on the same centre line.
      <span aria-hidden="true" className={cx(controlHeightClasses[size], 'w-(--p-cell)')} />
    );

  const disclosure = (open: boolean) => (
    <span
      className={cx(
        'flex items-center text-(--plass-muted-fg)',
        '[transition:rotate_var(--plass-duration)_var(--plass-ease)]',
        open && 'rotate-180'
      )}
    >
      <ChevronIcon />
    </span>
  );

  const monthButton = (
    <PlButton
      key="month"
      variant="ghost"
      size={size}
      color={color}
      density="compact"
      aria-label={labels.chooseMonth}
      aria-expanded={view === 'month'}
      onClick={() => onViewChange(view === 'month' ? precision : 'month')}
      endIcon={disclosure(view === 'month')}
    >
      {monthName}
    </PlButton>
  );

  const yearButton = (
    <PlButton
      key="year"
      variant="ghost"
      size={size}
      color={color}
      density="compact"
      className="tabular-nums"
      aria-label={labels.chooseYear}
      aria-expanded={view === 'year'}
      onClick={() => onViewChange(view === 'year' ? precision : 'year')}
      endIcon={disclosure(view === 'year')}
    >
      {yearName}
    </PlButton>
  );

  const pageStart = yearPageStart(month.getFullYear());

  return (
    <div className="flex items-center justify-between gap-1">
      {stepper(-1, showPreviousButton)}

      <div className={cx('flex min-w-0 flex-1 items-center justify-center', gapClasses[size])}>
        {view === 'year' ? (
          // A range, not a control: there is nothing above a page of years to
          // open. It keeps the row's height so switching views never moves it.
          <span
            className={cx(
              'flex items-center font-semibold tabular-nums text-(--plass-fg)',
              controlHeightClasses[size],
              controlTextClasses[size]
            )}
          >
            {`${pageStart}–${pageStart + YEAR_PAGE_SIZE - 1}`}
          </span>
        ) : view === 'month' ? (
          yearButton
        ) : monthFirst ? (
          <React.Fragment>
            {monthButton}
            {yearButton}
          </React.Fragment>
        ) : (
          <React.Fragment>
            {yearButton}
            {monthButton}
          </React.Fragment>
        )}
      </div>

      {stepper(1, showNextButton)}
    </div>
  );
}

/* ---------------------------------------------------------------------------
 * The calendar
 * ------------------------------------------------------------------------- */

export interface CalendarProps {
  size: PlassSize;
  color: PlassColor;
  locale?: string;
  weekStartsOn: PlassWeekday;
  /** The month on screen. Controlled, so two panels can be kept a month apart. */
  month: Date;
  onMonthChange: (month: Date) => void;
  /**
   * The smallest unit this calendar hands back.
   *
   * `day` is the calendar everyone means. `month` and `year` stop the drilling
   * one and two steps short: the grid the caller lands on is the last one, so
   * pressing a cell in it selects rather than opening the grid below. The day
   * grid is not merely hidden — it is unreachable, which is what makes the
   * value the picker returns honest.
   * @default 'day'
   */
  precision?: CalendarView;
  /** The days drawn filled — one for a single picker, up to two for a range. */
  selected: readonly (Date | null | undefined)[];
  /** The two ends the band is drawn between. Both `null` outside range mode. */
  rangeStart?: Date | null;
  rangeEnd?: Date | null;
  onSelect: (date: Date) => void;
  /** The day under the pointer, for a range that is only half chosen. */
  onPreviewChange?: (date: Date | null) => void;
  minDate?: Date | null;
  maxDate?: Date | null;
  shouldDisableDate?: (date: Date) => boolean;
  /**
   * Draws the leading and trailing days that belong to the neighbouring months.
   *
   * On by default, because clicking the 1st of next month from this month's
   * panel is a real shortcut. A two-month range picker turns it *off*, and not
   * as a matter of taste: with both panels showing six full weeks, the 1st of
   * August appears twice — once as a trailing day of July and once as itself —
   * and two cells with the same name in the same popup is ambiguous to a
   * pointer and outright broken to a screen reader.
   * @default true
   */
  showOutsideDays?: boolean;
  /** Takes the focus on mount — the popup has just opened. */
  autoFocus?: boolean;
  showPreviousButton?: boolean;
  showNextButton?: boolean;
  labels: PlassPickerLabels;
  className?: string;
}

/**
 * One month, with a way to reach every other one.
 *
 * Three views on the same footprint: the days of a month, the twelve months of
 * a year, twelve years at a time. They are deliberately the same width *and*
 * the same height — the day view is seven rows counting its header, and the
 * other two stretch four rows and three rows across that same height — so
 * switching view never resizes the popup under the pointer that opened it.
 *
 * Arrow keys move by one cell, `PageUp`/`PageDown` by a month (a year with
 * Shift), `Home`/`End` to the ends of the week, and running off an edge steps
 * the calendar rather than stopping. One roving tab stop, so `Tab` leaves the
 * grid instead of walking forty-two cells — the pattern the ARIA date-picker
 * practice describes, and the reason none of the cells is a `disabled` button.
 */
export function Calendar({
  size,
  color,
  locale,
  weekStartsOn,
  month,
  onMonthChange,
  precision = 'day',
  selected,
  rangeStart = null,
  rangeEnd = null,
  onSelect,
  onPreviewChange,
  minDate,
  maxDate,
  shouldDisableDate,
  showOutsideDays = true,
  autoFocus = false,
  showPreviousButton = true,
  showNextButton = true,
  labels,
  className
}: CalendarProps) {
  const [openedView, setView] = React.useState<CalendarView>(precision);
  // Clamped rather than stored raw, so a `precision` that tightens after the
  // calendar is already up cannot leave a day grid on screen in a month picker.
  const view = viewDepth[openedView] > viewDepth[precision] ? precision : openedView;
  const chosen = React.useMemo(() => selected.filter(isValidDate), [selected]);

  // The one cell that carries the tab stop. It starts on the chosen day, or on
  // today when today is on screen, or on the 1st — never nowhere, because a grid
  // whose tab stop is nowhere cannot be reached by a keyboard at all.
  const [focusedDate, setFocusedDate] = React.useState<Date>(() => {
    const preferred = chosen.find((date) => isSameMonth(date, month));

    if (preferred) {
      return startOfDay(preferred);
    }

    return isSameMonth(today(), month) ? today() : startOfMonth(month);
  });

  // Set only by the interactions that *move* the focus — an arrow key, a view
  // change — so the effect below never yanks focus out from under a pointer user
  // doing something else on the page.
  const pendingFocus = React.useRef(autoFocus);
  const rootRef = React.useRef<HTMLDivElement | null>(null);

  // Following the month keeps the tab stop inside the grid the reader is looking
  // at: stepping a month and then pressing an arrow lands somewhere sensible
  // instead of scrolling the panel back where it came from.
  React.useEffect(() => {
    // The tab stop follows a prop, and the updater is a no-op unless the month
    // actually changed — so this settles in one pass rather than cascading.
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setFocusedDate((current) => (isSameMonth(current, month) ? current : startOfMonth(month)));
  }, [month]);

  React.useLayoutEffect(() => {
    if (!pendingFocus.current) {
      return;
    }

    pendingFocus.current = false;
    // `preventScroll`, because on the very first pass this runs before the popup
    // has been positioned — it is still at the top-left of the page, and the
    // browser's own "scroll the focused element into view" would drag the
    // document up there with it.
    rootRef.current
      ?.querySelector<HTMLElement>('[data-focus-target="true"]')
      ?.focus({ preventScroll: true });
  });

  const isDisabled = React.useCallback(
    (date: Date) => isDayOutside(date, minDate, maxDate) || (shouldDisableDate?.(date) ?? false),
    [minDate, maxDate, shouldDisableDate]
  );

  /** Moves the tab stop, pulling the month along when it lands outside. */
  const moveFocus = (next: Date) => {
    pendingFocus.current = true;
    setFocusedDate(next);

    if (!isSameMonth(next, month)) {
      onMonthChange(startOfMonth(next));
    }
  };

  const step = (direction: -1 | 1) => {
    if (view === 'day') {
      onMonthChange(addMonths(month, direction));
    } else if (view === 'month') {
      onMonthChange(addYears(month, direction));
    } else {
      onMonthChange(addYears(month, direction * YEAR_PAGE_SIZE));
    }
  };

  const changeView = (next: CalendarView) => {
    pendingFocus.current = true;
    setView(next);
  };

  /** In month and year view the header's `month` *is* the cursor. */
  const moveCursor = (next: Date) => {
    pendingFocus.current = true;
    onMonthChange(next);
  };

  return (
    <div
      ref={rootRef}
      className={cx('flex flex-col', gapClasses[size], className)}
      style={{ '--p-cell': cellSizes[size] } as React.CSSProperties}
      onPointerLeave={() => onPreviewChange?.(null)}
    >
      <Header
        size={size}
        color={color}
        view={view}
        precision={precision}
        month={month}
        locale={locale}
        labels={labels}
        showPreviousButton={showPreviousButton}
        showNextButton={showNextButton}
        onStep={step}
        onViewChange={changeView}
      />

      {/* Seven rows of cells, whichever view is drawn into it. */}
      <div className="h-[calc(var(--p-cell)*7)] w-[calc(var(--p-cell)*7)]">
        {view === 'day' ? (
          <DayGrid
            size={size}
            locale={locale}
            weekStartsOn={weekStartsOn}
            month={month}
            chosen={chosen}
            rangeStart={rangeStart}
            rangeEnd={rangeEnd}
            focusedDate={focusedDate}
            showOutsideDays={showOutsideDays}
            isDisabled={isDisabled}
            onSelect={(date) => {
              setFocusedDate(date);
              onSelect(date);
            }}
            onPreviewChange={onPreviewChange}
            onMoveFocus={moveFocus}
          />
        ) : view === 'month' ? (
          <MonthGrid
            size={size}
            locale={locale}
            month={month}
            chosen={chosen}
            minDate={minDate}
            maxDate={maxDate}
            onMoveCursor={moveCursor}
            onPick={(index) => {
              const picked = makeDate(month.getFullYear(), index, 1);

              onMonthChange(picked);

              // The floor. A month picker's month grid is the last one, so
              // pressing a cell in it answers the question rather than opening
              // the grid below.
              if (precision === 'month') {
                onSelect(picked);
              } else {
                changeView('day');
              }
            }}
          />
        ) : (
          <YearGrid
            size={size}
            month={month}
            chosen={chosen}
            minDate={minDate}
            maxDate={maxDate}
            onMoveCursor={moveCursor}
            onPick={(year) => {
              // January, not whichever month the cursor happened to be on: the
              // value a year picker hands back has to *be* a year, and one
              // carrying an arbitrary month is a date wearing a year's clothes.
              const picked = makeDate(year, precision === 'year' ? 0 : month.getMonth(), 1);

              onMonthChange(picked);

              if (precision === 'year') {
                onSelect(picked);
              } else {
                changeView('month');
              }
            }}
          />
        )}
      </div>
    </div>
  );
}

/* ---------------------------------------------------------------------------
 * The three grids
 * ------------------------------------------------------------------------- */

/** The two ends of a band, smallest first, whichever way round they arrived. */
function orderedRange(a: Date | null, b: Date | null): [Date, Date] | null {
  if (!isValidDate(a) || !isValidDate(b)) {
    return null;
  }

  return compareDay(a, b) <= 0 ? [a, b] : [b, a];
}

interface DayGridProps {
  size: PlassSize;
  locale: string | undefined;
  weekStartsOn: PlassWeekday;
  month: Date;
  chosen: Date[];
  rangeStart: Date | null;
  rangeEnd: Date | null;
  focusedDate: Date;
  showOutsideDays: boolean;
  isDisabled: (date: Date) => boolean;
  onSelect: (date: Date) => void;
  onPreviewChange?: (date: Date | null) => void;
  onMoveFocus: (date: Date) => void;
}

function DayGrid({
  size,
  locale,
  weekStartsOn,
  month,
  chosen,
  rangeStart,
  rangeEnd,
  focusedDate,
  showOutsideDays,
  isDisabled,
  onSelect,
  onPreviewChange,
  onMoveFocus
}: DayGridProps) {
  const weeks = calendarWeeks(month, weekStartsOn);
  const short = weekdayLabels(locale, weekStartsOn, 'short');
  const long = weekdayLabels(locale, weekStartsOn, 'long');
  const fullDate = dateFormatter(locale, { dateStyle: 'full' });
  const band = orderedRange(rangeStart, rangeEnd);
  const now = today();

  const onKeyDown = (event: React.KeyboardEvent<HTMLButtonElement>, date: Date) => {
    const offsetInWeek = (date.getDay() - weekStartsOn + 7) % 7;
    const moves: Record<string, () => Date> = {
      ArrowLeft: () => addDays(date, -1),
      ArrowRight: () => addDays(date, 1),
      ArrowUp: () => addDays(date, -7),
      ArrowDown: () => addDays(date, 7),
      Home: () => addDays(date, -offsetInWeek),
      End: () => addDays(date, 6 - offsetInWeek),
      PageUp: () => addMonths(date, event.shiftKey ? -12 : -1),
      PageDown: () => addMonths(date, event.shiftKey ? 12 : 1)
    };

    const move = moves[event.key];

    if (!move) {
      return;
    }

    event.preventDefault();
    onMoveFocus(move());
  };

  return (
    <div role="grid" className="flex h-full flex-col">
      <div role="row" className="grid grid-cols-7">
        {short.map((label, index) => (
          <span
            key={index}
            role="columnheader"
            aria-label={long[index]}
            className={cx(
              'flex h-(--p-cell) items-center justify-center font-semibold text-(--plass-muted-fg) select-none',
              metaTextClasses[size]
            )}
          >
            {label}
          </span>
        ))}
      </div>

      {weeks.map((week, weekIndex) => (
        <div role="row" key={weekIndex} className="grid grid-cols-7">
          {week.map((date) => {
            const outside = !isSameMonth(date, month);

            // A hole the size of a cell rather than a missing one: the grid has
            // to keep its seven columns and six rows whatever month it is on.
            if (outside && !showOutsideDays) {
              return (
                <span
                  key={date.getTime()}
                  role="gridcell"
                  aria-hidden="true"
                  className="size-(--p-cell)"
                />
              );
            }

            const isChosen = chosen.some((entry) => isSameDay(entry, date));
            const within =
              band !== null && compareDay(date, band[0]) >= 0 && compareDay(date, band[1]) <= 0;
            const atStart = band !== null && within && isSameDay(date, band[0]);
            const atEnd = band !== null && within && isSameDay(date, band[1]);

            return (
              <Cell
                key={date.getTime()}
                size={size}
                label={fullDate.format(date)}
                selected={isChosen}
                inRange={within && !isChosen}
                rangeEdge={
                  !within
                    ? null
                    : atStart && atEnd
                      ? 'both'
                      : atStart
                        ? 'start'
                        : atEnd
                          ? 'end'
                          : 'middle'
                }
                current={isSameDay(date, now) && !isChosen}
                muted={outside}
                disabled={isDisabled(date)}
                focused={isSameDay(date, focusedDate)}
                className={cx('size-(--p-cell)', controlTextClasses[size])}
                onClick={() => onSelect(date)}
                onPointerEnter={() => onPreviewChange?.(date)}
                onKeyDown={(event) => onKeyDown(event, date)}
              >
                {date.getDate()}
              </Cell>
            );
          })}
        </div>
      ))}
    </div>
  );
}

interface MonthGridProps {
  size: PlassSize;
  locale: string | undefined;
  month: Date;
  chosen: Date[];
  minDate?: Date | null;
  maxDate?: Date | null;
  onMoveCursor: (month: Date) => void;
  onPick: (index: number) => void;
}

/**
 * Twelve months, three across.
 *
 * The tab stop is the header's own month, so moving it *is* moving the header —
 * arrowing right off December lands on January of the next year and the year
 * button follows, which is one fewer thing for the reader to keep track of.
 */
function MonthGrid({
  size,
  locale,
  month,
  chosen,
  minDate,
  maxDate,
  onMoveCursor,
  onPick
}: MonthGridProps) {
  const short = monthLabels(locale, 'short');
  const long = monthLabels(locale, 'long');
  const year = month.getFullYear();
  const now = new Date();

  const onKeyDown = (event: React.KeyboardEvent<HTMLButtonElement>) => {
    const steps: Record<string, number> = {
      ArrowLeft: -1,
      ArrowRight: 1,
      ArrowUp: -3,
      ArrowDown: 3,
      PageUp: -12,
      PageDown: 12
    };
    const step = steps[event.key];

    if (step === undefined) {
      return;
    }

    event.preventDefault();
    onMoveCursor(addMonths(startOfMonth(month), step));
  };

  return (
    // The rows are spread over the height the day view occupies rather than
    // stretched to fill it: the popup keeps its size across a view change, and a
    // month cell stays a cell rather than becoming a panel.
    <div role="grid" className="flex h-full flex-col justify-evenly">
      {[0, 1, 2, 3].map((row) => (
        <div role="row" key={row} className="grid grid-cols-3 gap-1">
          {[0, 1, 2].map((column) => {
            const index = row * 3 + column;

            return (
              <Cell
                key={index}
                size={size}
                label={`${long[index]} ${year}`}
                selected={chosen.some(
                  (entry) => entry.getFullYear() === year && entry.getMonth() === index
                )}
                current={now.getFullYear() === year && now.getMonth() === index}
                // A month is out of bounds only when every day in it is: the
                // month a `minDate` falls in is still reachable, it just starts
                // late.
                disabled={isMonthOutside(makeDate(year, index, 1), minDate, maxDate)}
                focused={index === month.getMonth()}
                className={cx('h-(--p-cell) w-full', controlTextClasses[size])}
                onClick={() => onPick(index)}
                onKeyDown={onKeyDown}
              >
                {short[index]}
              </Cell>
            );
          })}
        </div>
      ))}
    </div>
  );
}

interface YearGridProps {
  size: PlassSize;
  month: Date;
  chosen: Date[];
  minDate?: Date | null;
  maxDate?: Date | null;
  onMoveCursor: (month: Date) => void;
  onPick: (year: number) => void;
}

/** Twelve years, four across, and the same trick with the cursor. */
function YearGrid({ size, month, chosen, minDate, maxDate, onMoveCursor, onPick }: YearGridProps) {
  const pageStart = yearPageStart(month.getFullYear());
  const now = new Date().getFullYear();

  const onKeyDown = (event: React.KeyboardEvent<HTMLButtonElement>) => {
    const steps: Record<string, number> = {
      ArrowLeft: -1,
      ArrowRight: 1,
      ArrowUp: -4,
      ArrowDown: 4,
      PageUp: -YEAR_PAGE_SIZE,
      PageDown: YEAR_PAGE_SIZE
    };
    const step = steps[event.key];

    if (step === undefined) {
      return;
    }

    event.preventDefault();
    onMoveCursor(addYears(startOfMonth(month), step));
  };

  return (
    <div role="grid" className="flex h-full flex-col justify-evenly">
      {[0, 1, 2].map((row) => (
        <div role="row" key={row} className="grid grid-cols-4 gap-1">
          {[0, 1, 2, 3].map((column) => {
            const year = pageStart + row * 4 + column;

            return (
              <Cell
                key={year}
                size={size}
                label={String(year)}
                selected={chosen.some((entry) => entry.getFullYear() === year)}
                current={year === now}
                disabled={isYearOutside(makeDate(year, 0, 1), minDate, maxDate)}
                focused={year === month.getFullYear()}
                className={cx('h-(--p-cell) w-full', controlTextClasses[size])}
                onClick={() => onPick(year)}
                onKeyDown={onKeyDown}
              >
                {year}
              </Cell>
            );
          })}
        </div>
      ))}
    </div>
  );
}

/* ---------------------------------------------------------------------------
 * The clock
 * ------------------------------------------------------------------------- */

export type { TimeUnit };

export interface TimeGridProps {
  size: PlassSize;
  density: PlassDensity;
  locale?: string;
  /** The time on screen, or `null` while nothing has been chosen. */
  value: Date | null;
  /** The day the columns write into while `value` is still `null`. */
  referenceDate: Date;
  onChange: (value: Date) => void;
  /** A 12-hour dial with an AM/PM column. Defaults to whatever the locale does. */
  hour12: boolean;
  showSeconds: boolean;
  hourStep: number;
  minuteStep: number;
  secondStep: number;
  shouldDisableTime?: (value: Date, unit: TimeUnit) => boolean;
  /** Takes the focus on mount — the popup has just opened. */
  autoFocus?: boolean;
  labels: PlassPickerLabels;
  className?: string;
}

/**
 * Brings a row into view *inside its own column*, and nowhere else.
 *
 * `scrollIntoView` walks every scrollable ancestor up to the document, and the
 * popup this runs in has not been positioned yet when the effect fires — it is
 * still at the top-left of the page. So the browser dutifully scrolled the whole
 * document to the top to reveal a row that was about to move anyway, which is
 * the "opening a picker jumps the page" bug. Setting `scrollTop` on the column
 * cannot touch anything above it.
 */
function revealInColumn(row: HTMLElement) {
  const column = row.parentElement;

  if (!column) {
    return;
  }

  // Measured rather than read off `offsetTop`, which is relative to whichever
  // ancestor happens to be positioned and not necessarily to the column.
  const rowBox = row.getBoundingClientRect();
  const columnBox = column.getBoundingClientRect();
  const top = rowBox.top - columnBox.top - column.clientTop + column.scrollTop;
  const bottom = top + rowBox.height;

  if (top < column.scrollTop) {
    column.scrollTop = top;
  } else if (bottom > column.scrollTop + column.clientHeight) {
    column.scrollTop = bottom - column.clientHeight;
  }
}

/**
 * Hours, minutes and — when asked for — seconds, as columns you scroll rather
 * than as a dial you drag.
 *
 * Columns because they are the shape that answers what a time picker is actually
 * asked: "half past nine" is two glances, and "any time at all, on the hour" is
 * a column you never touch. A clock face is prettier and needs a `transform` to
 * read, which this library does not have.
 *
 * The chosen row in each column is scrolled into view once, on open. That is the
 * only imperative work here and it is not optional: a column of sixty minutes
 * that opens at `00` while the value is `45` has hidden its own answer.
 */
export function TimeGrid({
  size,
  density,
  locale,
  value,
  referenceDate,
  onChange,
  hour12,
  showSeconds,
  hourStep,
  minuteStep,
  secondStep,
  shouldDisableTime,
  autoFocus = false,
  labels,
  className
}: TimeGridProps) {
  const base = value ?? referenceDate;
  const rootRef = React.useRef<HTMLDivElement | null>(null);
  const [am, pm] = React.useMemo(() => meridiemLabels(locale), [locale]);

  React.useEffect(() => {
    const root = rootRef.current;

    root?.querySelectorAll<HTMLElement>('[data-chosen="true"]').forEach(revealInColumn);

    if (autoFocus) {
      const first = root?.querySelector<HTMLElement>('[role="listbox"]');

      (
        first?.querySelector<HTMLElement>('[data-chosen="true"]') ??
        first?.querySelector<HTMLElement>('[role="option"]')
      )?.focus({ preventScroll: true });
    }
    // Once, on open. Re-running it on every change would drag a column back
    // under the pointer that is scrolling it.
  }, [autoFocus]);

  const hours = React.useMemo(() => {
    const count = Math.ceil((hour12 ? 12 : 24) / hourStep);
    const raw = Array.from({ length: count }, (_, index) => index * hourStep);

    // 12, 1, 2 … 11 — the order a 12-hour dial is read in, not 0…11.
    return hour12 ? raw.map((hour) => (hour === 0 ? 12 : hour)) : raw;
  }, [hour12, hourStep]);

  const minutes = React.useMemo(
    () => Array.from({ length: Math.ceil(60 / minuteStep) }, (_, index) => index * minuteStep),
    [minuteStep]
  );

  const seconds = React.useMemo(
    () => Array.from({ length: Math.ceil(60 / secondStep) }, (_, index) => index * secondStep),
    [secondStep]
  );

  /** The instant choosing this row would produce. */
  const candidate = (unit: TimeUnit, raw: number): Date => {
    if (unit === 'hour') {
      return withTime(base, {
        hours: hour12 ? (raw % 12) + (base.getHours() >= 12 ? 12 : 0) : raw
      });
    }

    if (unit === 'minute') {
      return withTime(base, { minutes: raw });
    }

    if (unit === 'second') {
      return withTime(base, { seconds: raw });
    }

    // `raw` is 0 for the first half of the day and 1 for the second.
    return withTime(base, { hours: (base.getHours() % 12) + raw * 12 });
  };

  const pad = (raw: number) => String(raw).padStart(2, '0');
  const displayHour = hour12 ? base.getHours() % 12 || 12 : base.getHours();

  const column = (
    unit: TimeUnit,
    name: string,
    rows: number[],
    isChosen: (raw: number) => boolean,
    render: (raw: number) => string
  ) => (
    <div
      key={unit}
      role="listbox"
      aria-label={name}
      className={cx(
        'flex flex-col gap-0.5 overflow-y-auto overscroll-contain',
        // The same height as the calendar beside it, so a PlDateTimePicker's
        // popup is one rectangle rather than two of different heights.
        'h-[calc(var(--p-cell)*7)] w-[calc(var(--p-cell)*1.75)]',
        'scroll-py-0.5 [scrollbar-width:thin]'
      )}
    >
      {rows.map((raw) => {
        const at = candidate(unit, raw);
        const chosen = value !== null && isChosen(raw);
        const disabled = shouldDisableTime?.(at, unit) ?? false;

        return (
          <button
            key={raw}
            type="button"
            role="option"
            aria-selected={chosen}
            aria-disabled={disabled || undefined}
            data-chosen={chosen ? 'true' : undefined}
            className={cx(
              cellBaseClasses,
              cellRadiusClasses[size],
              controlHeightClasses[size],
              controlTextClasses[size],
              'w-full shrink-0',
              disabled
                ? 'cursor-not-allowed text-(--plass-muted-fg) opacity-50'
                : chosen
                  ? 'cursor-pointer font-semibold text-(--p-on-solid) [background-image:var(--p-fill)] hover:brightness-105 active:brightness-95'
                  : 'cursor-pointer text-(--plass-fg) hover:bg-(--p-soft) active:bg-(--p-soft-hover)'
            )}
            onClick={() => {
              if (!disabled) {
                onChange(at);
              }
            }}
          >
            {render(raw)}
          </button>
        );
      })}
    </div>
  );

  return (
    <div
      ref={rootRef}
      className={cx('flex', density === 'compact' ? 'gap-0.5' : 'gap-1', className)}
      style={{ '--p-cell': cellSizes[size] } as React.CSSProperties}
    >
      {column(
        'hour',
        labels.hour,
        hours,
        (raw) => raw === displayHour,
        (raw) => (hour12 ? String(raw) : pad(raw))
      )}
      {column('minute', labels.minute, minutes, (raw) => raw === base.getMinutes(), pad)}
      {showSeconds
        ? column('second', labels.second, seconds, (raw) => raw === base.getSeconds(), pad)
        : null}
      {hour12
        ? column(
            'meridiem',
            labels.meridiem,
            [0, 1],
            (raw) => (base.getHours() >= 12 ? 1 : 0) === raw,
            (raw) => (raw === 0 ? am : pm)
          )
        : null}

      {/* Three unlabelled lists of numbers, to anyone reading the screen rather
          than looking at it. This is the sentence that says what they add up to. */}
      <span className={srOnlyClasses} aria-live="polite">
        {value === null
          ? ''
          : dateFormatter(locale, {
              hour: 'numeric',
              minute: '2-digit',
              ...(showSeconds ? { second: '2-digit' as const } : {})
            }).format(value)}
      </span>
    </div>
  );
}
