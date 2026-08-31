'use client';

import * as React from 'react';
import { useDefaults } from '../../internal/defaults.js';
import { PlButton } from '../button/PlButton.js';
import {
  TimeGrid,
  usePickerLabels,
  type PlassPickerLabels,
  type TimeUnit
} from '../../internal/calendar.js';
import { ClockIcon } from '../../internal/icons.js';
import { PickerFooter, PickerShell, type PlassPickerShellProps } from '../../internal/picker.js';
import {
  displaySamples,
  formatDate,
  isHour12,
  isValidDate,
  secondsOfDay,
  timeUnitSpan,
  toISOTime,
  withPlaceholder,
  withTime
} from '../../internal/date.js';
import { cx } from '../../internal/styles.js';

/**
 * Which column of the clock a row belongs to. Re-exported so a caller writing a
 * `shouldDisableTime` rule can name the argument it is handed.
 */
export type { TimeUnit };

export interface PlTimePickerProps extends PlassPickerShellProps {
  /** The chosen time. A `Date`, so it carries a day as well — see `referenceDate`. */
  value?: Date | null;
  defaultValue?: Date | null;
  onValueChange?: (value: Date | null) => void;
  open?: boolean;
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /**
   * The day a chosen time is written onto while there is no value yet.
   * @default today
   */
  referenceDate?: Date;
  /** The earliest time of day that may be chosen. Only the clock is read. */
  minTime?: Date | null;
  /** The latest time of day that may be chosen. */
  maxTime?: Date | null;
  /**
   * Blocks individual rows. Called once per row per column with the instant that
   * row would produce and the column it is in, so a rule may be as coarse as
   * "no afternoons" or as fine as one minute.
   */
  shouldDisableTime?: (value: Date, unit: TimeUnit) => boolean;
  /** A 12-hour dial with an AM/PM column. Defaults to whatever the locale does. */
  hour12?: boolean;
  /** Adds the seconds column. @default false */
  showSeconds?: boolean;
  /** How far apart the rows of each column are. @default 1 */
  hourStep?: number;
  minuteStep?: number;
  secondStep?: number;
  /**
   * BCP 47 tag deciding whether the clock is on a 12-hour dial, what AM and PM
   * are called, and how the trigger writes the time. Defaults to the browser's.
   */
  locale?: string;
  /**
   * How the trigger writes the chosen time. Passed straight to `Intl`.
   * @default { hour: 'numeric', minute: '2-digit' }, plus seconds when shown
   */
  format?: Intl.DateTimeFormatOptions;
  /** Shown in the trigger while nothing is chosen. */
  placeholder?: React.ReactNode;
  /** Offers the × that empties the control. @default false */
  clearable?: boolean;
  /** Offers the shortcut to the current time in the footer. @default true */
  showNowButton?: boolean;
  /**
   * Closes the popup as soon as any column is touched. `false` by default and
   * unlike `PlDatePicker`, because a time is two answers and closing after the
   * first one would make choosing 9:30 a matter of opening the popup twice.
   * @default false
   */
  closeOnSelect?: boolean;
  /** The strings the picker says. Every one has an English default. */
  labels?: Partial<PlassPickerLabels>;
  /** Identifies the field when a form is submitted, as `HH:MM` (`HH:MM:SS`). */
  name?: string;
}

/**
 * A time of day, chosen from columns.
 *
 * Columns because they are the shape that answers what a time picker is actually
 * asked: "half past nine" is two glances, and "any time at all, on the hour" is
 * a column you never touch. A clock face is prettier and needs a `transform` to
 * read, which this library does not have.
 *
 * The bounds are checked at the granularity of the column being drawn, which is
 * the detail that separates a working time picker from a frustrating one. With a
 * `minTime` of 09:30 the hour `9` stays available — the hour *contains* allowed
 * minutes — and it is the minute column that greys out `00` through `25`. The
 * naive check compares the whole candidate instant, hides the 9 entirely, and
 * makes half past nine unreachable.
 *
 * The value is a `Date` rather than a string or a number of minutes, because
 * everything else in this library that carries a moment is one, and because a
 * time on its own has nowhere to record that it crossed a DST boundary.
 * `referenceDate` is the day a bare time is written onto.
 */
export const PlTimePicker = /* @__PURE__ */ React.forwardRef<HTMLButtonElement, PlTimePickerProps>(
  function PlTimePicker(
    {
      value: valueProp,
      defaultValue,
      onValueChange,
      open: openProp,
      defaultOpen,
      onOpenChange,
      referenceDate,
      minTime,
      maxTime,
      shouldDisableTime,
      hour12: hour12Prop,
      showSeconds = false,
      hourStep = 1,
      minuteStep = 1,
      secondStep = 1,
      locale: localeProp,
      format,
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
    const hour12 = hour12Prop ?? isHour12(locale);

    const [uncontrolledValue, setUncontrolledValue] = React.useState<Date | null>(
      defaultValue ?? null
    );
    const value = valueProp !== undefined ? valueProp : uncontrolledValue;

    const [uncontrolledOpen, setUncontrolledOpen] = React.useState(defaultOpen ?? false);
    const open = openProp ?? uncontrolledOpen;

    // Held still for as long as the picker is mounted, so a popup left open
    // across midnight does not quietly move the value it is writing onto a new
    // day.
    const [fallbackDay] = React.useState(() => referenceDate ?? new Date());

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

    const isBlocked = React.useCallback(
      (candidate: Date, unit: TimeUnit) => {
        const [from, to] = timeUnitSpan(unit, candidate);

        if (isValidDate(minTime) && to < secondsOfDay(minTime)) {
          return true;
        }

        if (isValidDate(maxTime) && from > secondsOfDay(maxTime)) {
          return true;
        }

        return shouldDisableTime?.(candidate, unit) ?? false;
      },
      [minTime, maxTime, shouldDisableTime]
    );

    /* Memoised because `samples` below is keyed on it, and the fallback is a
       fresh object every render — which is the case that runs by default, since
       `format` is optional. Left bare, the sizer re-formatted all twenty-four
       sample instants on every render the picker saw. */
    const displayFormat = React.useMemo<Intl.DateTimeFormatOptions>(
      () =>
        format ?? {
          hour: 'numeric',
          minute: '2-digit',
          ...(showSeconds ? { second: '2-digit' as const } : {})
        },
      [format, showSeconds]
    );

    const now = new Date();
    const nowValue = withTime(referenceDate ?? fallbackDay, {
      hours: now.getHours(),
      minutes: now.getMinutes(),
      seconds: showSeconds ? now.getSeconds() : 0
    });
    const hasFooter = showNowButton || clearable || !closeOnSelect;

    // Holds the trigger open at the width of the longest time it could show.
    const samples = React.useMemo(
      () => withPlaceholder(displaySamples(locale, displayFormat), placeholder),
      [locale, displayFormat, placeholder]
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
        startIcon={startIcon ?? <ClockIcon />}
        display={
          isValidDate(value) ? formatDate(value, locale, displayFormat) : (placeholder ?? '')
        }
        samples={samples}
        empty={!isValidDate(value)}
        clearable={clearable}
        onClear={() => commit(null)}
        open={open}
        onOpenChange={setOpen}
        labels={labels}
        hiddenValues={
          name
            ? [{ name, value: isValidDate(value) ? toISOTime(value, showSeconds) : '' }]
            : undefined
        }
      >
        <div className={cx('flex flex-col', hasFooter && 'gap-1.5')}>
          <TimeGrid
            size={size}
            density={density}
            locale={locale}
            value={isValidDate(value) ? value : null}
            referenceDate={referenceDate ?? fallbackDay}
            onChange={(next) => {
              commit(next);

              if (closeOnSelect) {
                setOpen(false);
              }
            }}
            hour12={hour12}
            showSeconds={showSeconds}
            hourStep={hourStep}
            minuteStep={minuteStep}
            secondStep={secondStep}
            shouldDisableTime={isBlocked}
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
              {showNowButton ? (
                <PlButton
                  variant="ghost"
                  size={size}
                  color={color}
                  density="compact"
                  disabled={isBlocked(nowValue, 'second')}
                  onClick={() => {
                    commit(nowValue);
                    setOpen(false);
                  }}
                >
                  {labels.now}
                </PlButton>
              ) : null}
              {/* The popup stays open while the columns are being read, so there
                  has to be something to press that means "that is the one". */}
              {!closeOnSelect ? (
                <PlButton
                  variant="solid"
                  size={size}
                  color={color}
                  density="compact"
                  onClick={() => setOpen(false)}
                >
                  {labels.done}
                </PlButton>
              ) : null}
            </PickerFooter>
          ) : null}
        </div>
      </PickerShell>
    );
  }
);
