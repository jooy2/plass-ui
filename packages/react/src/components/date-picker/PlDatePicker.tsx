'use client';

import * as React from 'react';
import { PlButton } from '../button/PlButton.js';
import { Calendar, usePickerLabels, type PlassPickerLabels } from '../../internal/calendar.js';
import { CalendarIcon } from '../../internal/icons.js';
import { PickerFooter, PickerShell, type PlassPickerShellProps } from '../../internal/picker.js';
import {
  displaySamples,
  formatDate,
  isDayOutside,
  isMonthOutside,
  isValidDate,
  isYearOutside,
  localeWeekStart,
  mergeDateAndTime,
  startOfDay,
  startOfMonth,
  startOfYear,
  toISODate,
  toISOMonth,
  toISOYear,
  today,
  withPlaceholder
} from '../../internal/date.js';
import { cx } from '../../internal/styles.js';
import type { PlassWeekday } from '../../types.js';

/** The strings a picker says that `Intl` has no opinion about. */
export type PlPickerLabels = PlassPickerLabels;

/**
 * The smallest unit the picker asks for.
 *
 * A birthday is a day, an expiry is a month and a model year is a year, and a
 * control that makes someone answer a question it did not need the answer to —
 * *which* day of December 2027 does this card expire? — is a control that will
 * be answered wrongly.
 */
export type PlDatePickerPrecision = 'day' | 'month' | 'year';

/** What the trigger writes when the caller has not said. One per precision. */
const defaultFormats: Record<PlDatePickerPrecision, Intl.DateTimeFormatOptions> = {
  day: { dateStyle: 'medium' },
  month: { year: 'numeric', month: 'long' },
  year: { year: 'numeric' }
};

/** And how the hidden input spells it, which is the machine-readable half. */
const spellings: Record<PlDatePickerPrecision, (date: Date) => string> = {
  day: toISODate,
  month: toISOMonth,
  year: toISOYear
};

export interface PlDatePickerProps extends PlassPickerShellProps {
  /** The chosen day. Use with `onValueChange` for a controlled picker. */
  value?: Date | null;
  /** The day the picker starts on, for an uncontrolled one. */
  defaultValue?: Date | null;
  onValueChange?: (value: Date | null) => void;
  /**
   * How far down the picker goes: a day, a month or a year.
   *
   * The calendar opens on the grid for that unit and pressing a cell in it
   * answers — a `month` picker never shows a day grid at all. The value is
   * always a `Date`, normalised to the start of whatever was chosen: the 1st of
   * the month, or the 1st of January.
   *
   * `minDate` and `maxDate` are then read at the same precision. A `minDate` of
   * 15 July leaves July pickable on a `month` picker and hands back 1 July,
   * because a bound on a control that returns a month is a bound on months.
   * `shouldDisableDate` is day-granular and is not consulted at all.
   * @default 'day'
   */
  precision?: PlDatePickerPrecision;
  /** Whether the calendar is open. Use with `onOpenChange` to control it. */
  open?: boolean;
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /** Which month the calendar opens on when there is no value. @default this one */
  defaultMonth?: Date;
  /** The earliest day that may be chosen. Day-granular — the time is ignored. */
  minDate?: Date | null;
  /** The latest day that may be chosen. */
  maxDate?: Date | null;
  /**
   * Blocks individual days that are inside the range but still not available —
   * weekends, holidays, a room that is already booked.
   */
  shouldDisableDate?: (date: Date) => boolean;
  /**
   * BCP 47 tag deciding the month and weekday names, the order of the header's
   * two buttons, and how the trigger writes the date. Defaults to the browser's.
   */
  locale?: string;
  /** Which day the week starts on. Defaults to whatever the locale says. */
  weekStartsOn?: PlassWeekday;
  /**
   * How the trigger writes the chosen date. Passed straight to `Intl`, so
   * `{ dateStyle: 'full' }` and `{ year: '2-digit', month: 'narrow' }` both work.
   *
   * The default follows `precision`: a medium date, a long month and year, or a
   * bare year.
   * @default { dateStyle: 'medium' }
   */
  format?: Intl.DateTimeFormatOptions;
  /** Shown in the trigger while nothing is chosen. */
  placeholder?: React.ReactNode;
  /** Offers the × that empties the control. @default false */
  clearable?: boolean;
  /**
   * Offers the shortcut to today in the footer — to this month or this year on
   * a picker whose `precision` says so. @default true
   */
  showTodayButton?: boolean;
  /** Closes the popup as soon as a day is chosen. @default true */
  closeOnSelect?: boolean;
  /** The strings the picker says. Every one has an English default. */
  labels?: Partial<PlassPickerLabels>;
  /**
   * Identifies the field when a form is submitted, as `YYYY-MM-DD` — or as
   * `YYYY-MM` and `YYYY` at the two shorter precisions, which is what a native
   * `<input type="month">` submits.
   */
  name?: string;
}

/**
 * One day, chosen from a calendar.
 *
 * The trigger is a `PlTextField`'s shell wearing a calendar glyph, on purpose
 * and for the reason a `PlSelect`'s is: a form where the date field is a
 * different height, radius or material from the fields around it is a form that
 * looks assembled.
 *
 * What the calendar is actually for is the header. A picker that only steps a
 * month at a time puts a birthday thirty years back a hundred and eighty clicks
 * away, so the month name and the year are each a button that opens a grid of
 * its own — twelve months, then twelve years at a time. Any month of the year on
 * screen is two clicks; any year at all is three.
 *
 * `precision` stops the drilling short. A card's expiry is a month and a model
 * year is a year, and a control that makes someone answer a question it did not
 * need the answer to is a control that will be answered wrongly — so a `month`
 * picker's month grid is the last grid, and it has no day grid under it at all.
 *
 * There is no typing into the trigger. Parsing a date out of free text is
 * locale-dependent in a way that cannot be done honestly without a date library,
 * and a field that understands `27/7/26` in one browser and not in the next is
 * worse than one that never claimed to.
 */
export const PlDatePicker = /* @__PURE__ */ React.forwardRef<HTMLButtonElement, PlDatePickerProps>(
  function PlDatePicker(
    {
      value: valueProp,
      defaultValue,
      onValueChange,
      precision = 'day',
      open: openProp,
      defaultOpen,
      onOpenChange,
      defaultMonth,
      minDate,
      maxDate,
      shouldDisableDate,
      locale,
      weekStartsOn,
      format: formatProp,
      placeholder,
      clearable = false,
      showTodayButton = true,
      closeOnSelect = true,
      labels: labelOverrides,
      name,
      size = 'md',
      color = 'primary',
      readOnly = false,
      disabled = false,
      startIcon,
      ...shell
    },
    ref
  ) {
    const labels = usePickerLabels(labelOverrides);
    const firstDay = weekStartsOn ?? localeWeekStart(locale);
    const format = formatProp ?? defaultFormats[precision];

    const [uncontrolledValue, setUncontrolledValue] = React.useState<Date | null>(
      defaultValue ?? null
    );
    // `null` is a value a controlled picker legitimately holds — an emptied one —
    // so the test is against `undefined` and never against falsiness.
    const value = valueProp !== undefined ? valueProp : uncontrolledValue;

    const [uncontrolledOpen, setUncontrolledOpen] = React.useState(defaultOpen ?? false);
    const open = openProp ?? uncontrolledOpen;

    const [month, setMonth] = React.useState(() =>
      startOfMonth(isValidDate(value) ? value : (defaultMonth ?? today()))
    );

    // Opening puts the calendar back on the chosen day. Without this, a picker
    // left on 2019 while browsing stays there the next time it is opened, which
    // reads as the control having forgotten its own value.
    React.useEffect(() => {
      if (open) {
        setMonth(startOfMonth(isValidDate(value) ? value : (defaultMonth ?? today())));
      }
      // Only when the popup opens — following `value` here would drag the
      // calendar out from under someone typing into a form elsewhere.
      // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [open]);

    const setOpen = (next: boolean) => {
      // A read-only picker does not open. What it holds is something to read, and
      // a calendar whose every cell was inert would be a menu of nothing.
      if (next && (readOnly || disabled)) {
        return;
      }

      if (openProp === undefined) {
        setUncontrolledOpen(next);
      }

      onOpenChange?.(next);
    };

    const commit = (next: Date | null) => {
      if (valueProp === undefined) {
        setUncontrolledValue(next);
      }

      onValueChange?.(next);
    };

    const select = (date: Date) => {
      // The day changes; the time of day, if the value had one, does not. A
      // picker bound to a field that also carries a time should not silently
      // reset it to midnight every time the day is corrected.
      const next = isValidDate(value) ? mergeDateAndTime(date, value) : startOfDay(date);

      commit(next);
      setMonth(startOfMonth(next));

      if (closeOnSelect) {
        setOpen(false);
      }
    };

    const now = today();

    // The footer's shortcut, which is "today" only on a picker that asks for a
    // day. On the other two it is this month and this year, blocked by the same
    // rule their grids grey a cell out with — `shouldDisableDate` is
    // day-granular and has nothing to say about either.
    const shortcut =
      precision === 'day' ? now : precision === 'month' ? startOfMonth(now) : startOfYear(now);
    const shortcutLabel =
      precision === 'day'
        ? labels.today
        : precision === 'month'
          ? labels.thisMonth
          : labels.thisYear;
    const shortcutBlocked =
      precision === 'day'
        ? isDayOutside(now, minDate, maxDate) || (shouldDisableDate?.(now) ?? false)
        : precision === 'month'
          ? isMonthOutside(now, minDate, maxDate)
          : isYearOutside(now, minDate, maxDate);

    const hasFooter = showTodayButton || clearable;

    // Holds the trigger open at the width of the longest date it could show, so
    // choosing the 1st after the 28th does not shrink the field.
    const samples = React.useMemo(
      () => withPlaceholder(displaySamples(locale, format), placeholder),
      [locale, format, placeholder]
    );

    return (
      <PickerShell
        {...shell}
        size={size}
        color={color}
        readOnly={readOnly}
        disabled={disabled}
        triggerRef={ref}
        startIcon={startIcon ?? <CalendarIcon />}
        display={isValidDate(value) ? formatDate(value, locale, format) : (placeholder ?? '')}
        samples={samples}
        empty={!isValidDate(value)}
        clearable={clearable}
        onClear={() => commit(null)}
        open={open}
        onOpenChange={setOpen}
        labels={labels}
        hiddenValues={
          name
            ? [{ name, value: isValidDate(value) ? spellings[precision](value) : '' }]
            : undefined
        }
      >
        <div className={cx('flex flex-col', hasFooter && 'gap-1.5')}>
          <Calendar
            size={size}
            color={color}
            locale={locale}
            weekStartsOn={firstDay}
            month={month}
            onMonthChange={setMonth}
            precision={precision}
            selected={[value]}
            onSelect={select}
            minDate={minDate}
            maxDate={maxDate}
            shouldDisableDate={shouldDisableDate}
            labels={labels}
            autoFocus
          />

          {hasFooter ? (
            <PickerFooter size={size}>
              {clearable ? (
                <PlButton
                  variant="ghost"
                  size={size}
                  color={color}
                  density="compact"
                  onClick={() => {
                    commit(null);
                    setOpen(false);
                  }}
                >
                  {labels.clear}
                </PlButton>
              ) : null}
              {showTodayButton ? (
                <PlButton
                  variant="ghost"
                  size={size}
                  color={color}
                  density="compact"
                  disabled={shortcutBlocked}
                  onClick={() => select(shortcut)}
                >
                  {shortcutLabel}
                </PlButton>
              ) : null}
            </PickerFooter>
          ) : null}
        </div>
      </PickerShell>
    );
  }
);
