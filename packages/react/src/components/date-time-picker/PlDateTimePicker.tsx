'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import { PlButton } from '../button/PlButton.js';
import {
  Calendar,
  TimeGrid,
  usePickerLabels,
  type PlassPickerLabels
} from '../../internal/calendar.js';
import { CalendarIcon } from '../../internal/icons.js';
import {
  PickerDivider,
  PickerFooter,
  PickerShell,
  type PlassPickerShellProps
} from '../../internal/picker.js';
import {
  displaySamples,
  formatDate,
  isDayOutside,
  isHour12,
  isValidDate,
  localeWeekStart,
  mergeDateAndTime,
  startOfDay,
  startOfMonth,
  timeUnitSpan,
  toISODateTime,
  today,
  withPlaceholder,
  withTime,
  type TimeUnit
} from '../../internal/date.js';
import { cx, gapClasses } from '../../internal/styles.js';
import type { PlassWeekday } from '../../types.js';

export interface PlDateTimePickerProps extends PlassPickerShellProps {
  /** The chosen moment. Use with `onValueChange` for a controlled picker. */
  value?: Date | null;
  defaultValue?: Date | null;
  onValueChange?: (value: Date | null) => void;
  open?: boolean;
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /** Which month the calendar opens on when there is no value. */
  defaultMonth?: Date;
  /**
   * The earliest moment that may be chosen. Unlike a `PlDatePicker`'s, this one
   * is read at full precision: the day it falls on stays available and the clock
   * columns block the hours before it.
   */
  minDate?: Date | null;
  /** The latest moment that may be chosen, likewise at full precision. */
  maxDate?: Date | null;
  shouldDisableDate?: (date: Date) => boolean;
  shouldDisableTime?: (value: Date, unit: TimeUnit) => boolean;
  /**
   * BCP 47 tag deciding the month and weekday names, whether the clock is on a
   * 12-hour dial, and how the trigger writes the moment.
   */
  locale?: string;
  weekStartsOn?: PlassWeekday;
  /**
   * How the trigger writes the chosen moment. Passed straight to `Intl`.
   * @default { dateStyle: 'medium', timeStyle: 'short' }
   */
  format?: Intl.DateTimeFormatOptions;
  /** A 12-hour dial with an AM/PM column. Defaults to whatever the locale does. */
  hour12?: boolean;
  showSeconds?: boolean;
  hourStep?: number;
  minuteStep?: number;
  secondStep?: number;
  placeholder?: React.ReactNode;
  clearable?: boolean;
  /** Offers the shortcut to this moment in the footer. @default true */
  showNowButton?: boolean;
  /**
   * Closes the popup as soon as a day is chosen. `false` here and `true` on a
   * `PlDatePicker`, because a moment is a day *and* a time and closing on the
   * first of the two would leave the second unanswered.
   * @default false
   */
  closeOnSelect?: boolean;
  /** The strings the picker says. Every one has an English default. */
  labels?: Partial<PlassPickerLabels>;
  /** Identifies the field when a form is submitted, as `YYYY-MM-DDTHH:MM`. */
  name?: string;
}

/**
 * A day and a time, in one popup.
 *
 * Not a date picker that grew a clock and not a time picker that grew a
 * calendar: the two panels sit side by side at exactly the same height — seven
 * rows of cells each, which is why the calendar's grid and the clock's columns
 * share the `--p-cell` ladder — so the popup is one rectangle rather than two of
 * different sizes pushed together.
 *
 * The bounds do more work here than anywhere else. `minDate` is read at **full
 * precision**, so a minimum of 09:30 on the 27th leaves the 27th selectable in
 * the calendar and greys out the morning in the clock. That is the behaviour a
 * "not before now" rule needs, and it is the one a day-granular check cannot
 * give.
 */
export const PlDateTimePicker = /* @__PURE__ */ React.forwardRef<
  HTMLButtonElement,
  PlDateTimePickerProps
>(function PlDateTimePicker(
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
    shouldDisableTime,
    locale: localeProp,
    weekStartsOn: weekStartsOnProp,
    format = { dateStyle: 'medium', timeStyle: 'short' },
    hour12: hour12Prop,
    showSeconds = false,
    hourStep = 1,
    minuteStep = 1,
    secondStep = 1,
    placeholder,
    clearable = false,
    showNowButton = true,
    closeOnSelect = false,
    labels: labelOverrides,
    name,
    size: sizeProp,
    color: colorProp,
    density: densityProp,
    readOnly = false,
    disabled = false,
    startIcon,
    ...shell
  },
  ref
) {
  const defaults = useDefaults();
  const locale = localeProp ?? defaults.locale;
  const size = sizeProp ?? defaults.size ?? 'md';
  const color = colorProp ?? defaults.color ?? 'primary';
  const density = densityProp ?? defaults.density ?? 'default';

  const labels = usePickerLabels(labelOverrides);
  const firstDay = weekStartsOnProp ?? defaults.weekStartsOn ?? localeWeekStart(locale);
  const hour12 = hour12Prop ?? isHour12(locale);

  const [uncontrolledValue, setUncontrolledValue] = React.useState<Date | null>(
    defaultValue ?? null
  );
  const value = valueProp !== undefined ? valueProp : uncontrolledValue;

  const [uncontrolledOpen, setUncontrolledOpen] = React.useState(defaultOpen ?? false);
  const open = openProp ?? uncontrolledOpen;

  const [month, setMonth] = React.useState(() =>
    startOfMonth(isValidDate(value) ? value : (defaultMonth ?? today()))
  );

  React.useEffect(() => {
    if (open) {
      setMonth(startOfMonth(isValidDate(value) ? value : (defaultMonth ?? today())));
    }
    // Only when the popup opens — following `value` here would drag the calendar
    // out from under someone typing into a form elsewhere.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open]);

  const setOpen = (next: boolean) => {
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

  /**
   * Blocks a clock row whose whole span falls outside the bounds — the same span
   * test a `PlTimePicker` makes, moved onto the absolute timeline so the check
   * knows which day the columns are writing into.
   */
  const isTimeBlocked = React.useCallback(
    (candidate: Date, unit: TimeUnit) => {
      const [from, to] = timeUnitSpan(unit, candidate);
      const midnight = startOfDay(candidate).getTime();

      if (isValidDate(minDate) && midnight + to * 1000 < minDate.getTime()) {
        return true;
      }

      if (isValidDate(maxDate) && midnight + from * 1000 > maxDate.getTime()) {
        return true;
      }

      return shouldDisableTime?.(candidate, unit) ?? false;
    },
    [minDate, maxDate, shouldDisableTime]
  );

  const selectDay = (date: Date) => {
    // The day changes, the clock does not. A picker that reset the time to
    // midnight every time the date was corrected would make choosing a moment an
    // ordered task, and nobody reads a popup in the order it was written.
    const next = isValidDate(value) ? mergeDateAndTime(date, value) : startOfDay(date);

    commit(next);
    setMonth(startOfMonth(next));

    if (closeOnSelect) {
      setOpen(false);
    }
  };

  const nowMoment = new Date();
  const nowValue = withTime(nowMoment, { seconds: showSeconds ? nowMoment.getSeconds() : 0 });
  const nowBlocked =
    isDayOutside(nowValue, minDate, maxDate) ||
    (shouldDisableDate?.(nowValue) ?? false) ||
    isTimeBlocked(nowValue, 'second');

  // Holds the trigger open at the width of the longest moment it could show, so
  // choosing an earlier one does not shrink the field.
  const samples = React.useMemo(
    () => withPlaceholder(displaySamples(locale, format), placeholder),
    [locale, format, placeholder]
  );

  return (
    <PickerShell
      {...shell}
      size={size}
      color={color}
      density={density}
      readOnly={readOnly}
      disabled={disabled}
      triggerRef={ref}
      // The calendar glyph alone, not both: a control cannot say two things at
      // once, and the date is the part a reader scans for.
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
          ? [{ name, value: isValidDate(value) ? toISODateTime(value, showSeconds) : '' }]
          : undefined
      }
    >
      <div className="flex flex-col gap-1.5">
        <div className={cx('flex items-stretch', gapClasses[size])}>
          <Calendar
            size={size}
            color={color}
            locale={locale}
            weekStartsOn={firstDay}
            month={month}
            onMonthChange={setMonth}
            selected={[value]}
            onSelect={selectDay}
            minDate={minDate}
            maxDate={maxDate}
            shouldDisableDate={shouldDisableDate}
            labels={labels}
            autoFocus
          />

          <PickerDivider />

          <TimeGrid
            size={size}
            density={density}
            locale={locale}
            value={isValidDate(value) ? value : null}
            // With no day chosen yet the clock writes onto today, and picking a
            // day afterwards keeps whatever time was set.
            referenceDate={isValidDate(value) ? value : today()}
            onChange={commit}
            hour12={hour12}
            showSeconds={showSeconds}
            hourStep={hourStep}
            minuteStep={minuteStep}
            secondStep={secondStep}
            shouldDisableTime={isTimeBlocked}
            labels={labels}
          />
        </div>

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
          {showNowButton ? (
            <PlButton
              variant="ghost"
              size={size}
              color={color}
              density="compact"
              disabled={nowBlocked}
              onClick={() => {
                commit(nowValue);
                setMonth(startOfMonth(nowValue));
              }}
            >
              {labels.now}
            </PlButton>
          ) : null}
          <PlButton
            variant="solid"
            size={size}
            color={color}
            density="compact"
            onClick={() => setOpen(false)}
          >
            {labels.done}
          </PlButton>
        </PickerFooter>
      </div>
    </PickerShell>
  );
});
