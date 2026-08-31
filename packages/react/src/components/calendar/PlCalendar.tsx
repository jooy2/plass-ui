'use client';

import * as React from 'react';
import { Calendar, usePickerLabels, type PlassPickerLabels } from '../../internal/calendar.js';
import { popupPaddingClasses } from '../../internal/picker.js';
import {
  isValidDate,
  localeWeekStart,
  mergeDateAndTime,
  startOfDay,
  startOfMonth,
  today,
  toISODate,
  toISOMonth,
  toISOYear
} from '../../internal/date.js';
import {
  controlTextLeadingClasses,
  cx,
  disabledClasses,
  radiusClasses,
  sheetRestClasses,
  surfaceSlots
} from '../../internal/styles.js';
import type {
  PlassColor,
  PlassElevation,
  PlassSize,
  PlassVariant,
  PlassWeekday
} from '../../types.js';

/** The smallest unit the calendar hands back. The same three a picker takes. */
export type PlCalendarPrecision = 'day' | 'month' | 'year';

/** How the hidden input spells the value, which is the machine-readable half. */
const spellings: Record<PlCalendarPrecision, (date: Date) => string> = {
  day: toISODate,
  month: toISOMonth,
  year: toISOYear
};

export interface PlCalendarProps extends Omit<
  React.ComponentPropsWithoutRef<'div'>,
  'color' | 'defaultValue' | 'onSelect'
> {
  /**
   * What the surface is made of.
   *
   * `ghost` is the one to reach for when the calendar is already inside
   * something that draws a sheet — a `PlCard`, a `PlPopover` — because a second
   * bordered rectangle inside the first is a second rectangle.
   * @default 'glass'
   */
  variant?: PlassVariant;
  /** @default 'md' */
  size?: PlassSize;
  /** @default 'primary' */
  color?: PlassColor;
  /** @default 1 */
  elevation?: PlassElevation;
  /** The chosen day. Use with `onValueChange` for a controlled calendar. */
  value?: Date | null;
  /** The day it starts on, for an uncontrolled one. */
  defaultValue?: Date | null;
  onValueChange?: (value: Date | null) => void;
  /**
   * The smallest unit this calendar hands back, and a **floor** rather than a
   * starting view: at `month` the month grid is the last grid and pressing a
   * cell in it answers, so there is no day grid under it at all. A card's
   * expiry is a month, and a control that made somebody answer *which day of
   * December 2027* is one that will be answered wrongly.
   *
   * The value is normalised to the start of what was chosen — the 1st of the
   * month, the 1st of January — never whichever day the cursor was resting on.
   * @default 'day'
   */
  precision?: PlCalendarPrecision;
  /** The month on screen. Use with `onMonthChange` to control it. */
  month?: Date;
  /** The month it opens on, for an uncontrolled one. Defaults to the value's. */
  defaultMonth?: Date;
  onMonthChange?: (month: Date) => void;
  /** Nothing before this day can be chosen. Read at the calendar's `precision`. */
  minDate?: Date | null;
  /** Nothing after it can be chosen. Read at the calendar's `precision`. */
  maxDate?: Date | null;
  /**
   * Blocks individual days — weekends, holidays, a booked date. Day-granular,
   * so a `month` or `year` calendar never consults it.
   */
  shouldDisableDate?: (date: Date) => boolean;
  /**
   * The BCP 47 tag the month names, the weekday initials and the first day of
   * the week come from. The page's own locale by default.
   */
  locale?: string;
  /**
   * Which day the week starts on, as `Date` counts them — Sunday is `0`.
   * Worked out from `locale` when it is not given.
   */
  weekStartsOn?: PlassWeekday;
  /**
   * Draws the leading and trailing days belonging to the neighbouring months.
   * @default true
   */
  showOutsideDays?: boolean;
  /** Takes the focus on mount. Off, because a calendar in a page is not a popup. */
  autoFocus?: boolean;
  /**
   * Greys the whole calendar out and takes it out of the tab order.
   *
   * There is no `readOnly` beside it, and that is not an omission: a read-only
   * field still shows a value a reader can select and copy, and a calendar has
   * nothing to copy — a grid whose every cell is inert *is* the disabled one.
   * To block some days rather than all of them, use `shouldDisableDate`.
   * @default false
   */
  disabled?: boolean;
  /**
   * Submits the value with a form, under this name. The spelling follows
   * `precision`: `YYYY-MM-DD`, then `YYYY-MM` and `YYYY`, which is what the
   * native inputs of the same shape submit.
   */
  name?: string;
  /** The strings `Intl` has no opinion about — the buttons and the headings. */
  labels?: Partial<PlassPickerLabels>;
}

/**
 * A month, on the page rather than in a popup.
 *
 * It is the same grid a `PlDatePicker` opens — the three views, the roving tab
 * stop, the arrow keys that step the month when they run off an edge — with the
 * trigger and the popup taken away. That is the whole difference and it is the
 * reason to have both: a picker is a field that happens to open a calendar, and
 * this is a calendar that is not standing in for a field. A booking page, a
 * dashboard's date rail and an availability view all want the grid *visible*,
 * and none of them wants a text box above it.
 *
 * Because it is not a field it has no label, no description and no error line —
 * put it in a `PlFieldset` if it needs one. What it does keep is `name`, so a
 * plain form can submit what it holds.
 */
export const PlCalendar = /* @__PURE__ */ React.forwardRef<HTMLDivElement, PlCalendarProps>(
  function PlCalendar(
    {
      variant = 'glass',
      size = 'md',
      color = 'primary',
      elevation = 1,
      value: valueProp,
      defaultValue,
      onValueChange,
      precision = 'day',
      month: monthProp,
      defaultMonth,
      onMonthChange,
      minDate,
      maxDate,
      shouldDisableDate,
      locale,
      weekStartsOn,
      showOutsideDays = true,
      autoFocus = false,
      disabled = false,
      name,
      labels: labelOverrides,
      className,
      style,
      ...props
    },
    ref
  ) {
    const labels = usePickerLabels(labelOverrides);
    const firstDay = weekStartsOn ?? localeWeekStart(locale);

    const [uncontrolledValue, setUncontrolledValue] = React.useState<Date | null>(
      defaultValue ?? null
    );
    // `null` is a value a controlled calendar legitimately holds — an emptied
    // one — so the test is against `undefined` and never against falsiness.
    const value = valueProp !== undefined ? valueProp : uncontrolledValue;

    const [uncontrolledMonth, setUncontrolledMonth] = React.useState(() =>
      startOfMonth(isValidDate(value) ? value : (defaultMonth ?? today()))
    );
    const month = monthProp ?? uncontrolledMonth;

    const setMonth = (next: Date) => {
      if (monthProp === undefined) {
        setUncontrolledMonth(next);
      }

      onMonthChange?.(next);
    };

    const select = (date: Date) => {
      // The day changes; the time of day, if the value had one, does not. A
      // calendar bound to something that also carries a time should not
      // silently reset it to midnight every time the day is corrected.
      const next = isValidDate(value) ? mergeDateAndTime(date, value) : startOfDay(date);

      if (valueProp === undefined) {
        setUncontrolledValue(next);
      }

      onValueChange?.(next);

      // The grid never navigates itself, so a day picked out of a trailing week
      // would otherwise be selected in a month that is no longer on screen.
      setMonth(startOfMonth(next));
    };

    return (
      <div
        ref={ref}
        // `inert` rather than a `disabled` on forty-two cells: it takes the
        // whole subtree out of the tab order and off the pointer in one
        // attribute, which is what "this control is unavailable" means for a
        // composite widget.
        inert={disabled || undefined}
        className={cx(
          'inline-flex flex-col',
          sheetRestClasses[variant],
          radiusClasses[size],
          popupPaddingClasses[size],
          controlTextLeadingClasses[size],
          disabled ? disabledClasses[variant] : '',
          className
        )}
        style={{ ...surfaceSlots(color, elevation), ...style }}
        {...props}
      >
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
          showOutsideDays={showOutsideDays}
          autoFocus={autoFocus}
          labels={labels}
        />

        {name ? (
          <input
            type="hidden"
            name={name}
            value={isValidDate(value) ? spellings[precision](value) : ''}
          />
        ) : null}
      </div>
    );
  }
);
