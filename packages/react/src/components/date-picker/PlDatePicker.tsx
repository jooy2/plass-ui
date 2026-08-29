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
  isValidDate,
  localeWeekStart,
  mergeDateAndTime,
  startOfDay,
  startOfMonth,
  toISODate,
  today,
  withPlaceholder
} from '../../internal/date.js';
import { cx } from '../../internal/styles.js';
import type { PlassWeekday } from '../../types.js';

/** The strings a picker says that `Intl` has no opinion about. */
export type PlPickerLabels = PlassPickerLabels;

export interface PlDatePickerProps extends PlassPickerShellProps {
  /** The chosen day. Use with `onValueChange` for a controlled picker. */
  value?: Date | null;
  /** The day the picker starts on, for an uncontrolled one. */
  defaultValue?: Date | null;
  onValueChange?: (value: Date | null) => void;
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
   * @default { dateStyle: 'medium' }
   */
  format?: Intl.DateTimeFormatOptions;
  /** Shown in the trigger while nothing is chosen. */
  placeholder?: React.ReactNode;
  /** Offers the × that empties the control. @default false */
  clearable?: boolean;
  /** Offers the shortcut to today in the footer. @default true */
  showTodayButton?: boolean;
  /** Closes the popup as soon as a day is chosen. @default true */
  closeOnSelect?: boolean;
  /** The strings the picker says. Every one has an English default. */
  labels?: Partial<PlassPickerLabels>;
  /** Identifies the field when a form is submitted, as `YYYY-MM-DD`. */
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
      open: openProp,
      defaultOpen,
      onOpenChange,
      defaultMonth,
      minDate,
      maxDate,
      shouldDisableDate,
      locale,
      weekStartsOn,
      format = { dateStyle: 'medium' },
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
    const todayBlocked = isDayOutside(now, minDate, maxDate) || (shouldDisableDate?.(now) ?? false);
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
          name ? [{ name, value: isValidDate(value) ? toISODate(value) : '' }] : undefined
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
                  disabled={todayBlocked}
                  onClick={() => select(now)}
                >
                  {labels.today}
                </PlButton>
              ) : null}
            </PickerFooter>
          ) : null}
        </div>
      </PickerShell>
    );
  }
);
