import * as React from 'react';
import { PlButton } from '../button/PlButton.js';
import { Calendar, usePickerLabels, type PlassPickerLabels } from '../../internal/calendar.js';
import { ArrowRightIcon, CalendarIcon } from '../../internal/icons.js';
import { PickerFooter, PickerShell, type PlassPickerShellProps } from '../../internal/picker.js';
import { WidthSizer } from '../../internal/sizer.js';
import {
  addMonths,
  compareDay,
  displaySamples,
  formatDate,
  isValidDate,
  localeWeekStart,
  startOfDay,
  startOfMonth,
  toISODate,
  today,
  withPlaceholder
} from '../../internal/date.js';
import { cx, gapClasses, metaTextClasses } from '../../internal/styles.js';
import type { PlassWeekday } from '../../types.js';

/**
 * Two ends, either of which may be missing.
 *
 * An object rather than a `[Date, Date]` tuple, and rather than two props. A
 * range is one value — it is chosen in one gesture, cleared in one gesture and
 * validated as a whole — and the two names are what stop a caller writing the
 * end into the start. Half a range is a real state: it is what the picker holds
 * between the first click and the second.
 */
export interface PlDateRange {
  start: Date | null;
  end: Date | null;
}

/** A named range offered as a shortcut beside the calendars. */
export interface PlDateRangePreset {
  label: React.ReactNode;
  /**
   * The range it stands for. A function when it depends on today, which is
   * almost always — "the last 7 days" computed at module scope is a range that
   * would be wrong for anyone who left the tab open overnight.
   */
  value: PlDateRange | (() => PlDateRange);
}

const EMPTY: PlDateRange = { start: null, end: null };

export interface PlDateRangePickerProps extends PlassPickerShellProps {
  /** The chosen range. Use with `onValueChange` for a controlled picker. */
  value?: PlDateRange | null;
  defaultValue?: PlDateRange | null;
  /** Always called with an object. A cleared range is `{ start: null, end: null }`. */
  onValueChange?: (value: PlDateRange) => void;
  open?: boolean;
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /** Which month the left calendar opens on when there is no value. */
  defaultMonth?: Date;
  /** The earliest day that may be chosen. Day-granular — the time is ignored. */
  minDate?: Date | null;
  /** The latest day that may be chosen. */
  maxDate?: Date | null;
  /** Blocks individual days that are inside the range but still not available. */
  shouldDisableDate?: (date: Date) => boolean;
  /**
   * BCP 47 tag deciding the month and weekday names, the order of the header's
   * two buttons, and how the trigger writes the dates. Defaults to the browser's.
   */
  locale?: string;
  /** Which day the week starts on. Defaults to whatever the locale says. */
  weekStartsOn?: PlassWeekday;
  /** @default { dateStyle: 'medium' } */
  format?: Intl.DateTimeFormatOptions;
  /**
   * How many months are on screen at once. Two is the default because a range
   * that crosses a month boundary is the ordinary case, not the exception.
   * @default 2
   */
  monthCount?: 1 | 2;
  /** Shown in each half of the trigger while that end is unchosen. */
  startPlaceholder?: React.ReactNode;
  endPlaceholder?: React.ReactNode;
  /** Shortcuts listed beside the calendars — "Last 7 days", "This month". */
  presets?: readonly PlDateRangePreset[];
  /** Offers the × that empties the control. @default false */
  clearable?: boolean;
  /** Closes the popup once both ends are chosen. @default true */
  closeOnSelect?: boolean;
  /** The strings the picker says. Every one has an English default. */
  labels?: Partial<PlassPickerLabels>;
  /**
   * Identifies the field when a form is submitted. Two hidden inputs of the
   * same name, so the two ends arrive as `FormData.getAll(name)`.
   */
  name?: string;
}

/**
 * A span between two days.
 *
 * Two months side by side, because a range that crosses a month boundary is the
 * ordinary case and a one-month picker makes it a two-step navigation problem.
 * The two panels are one calendar in two halves: the left one has no forward
 * stepper, the right one has no back stepper, and either header's month and year
 * buttons move both.
 *
 * The band between the ends is drawn as the pointer moves, before the second
 * click lands. That preview is the whole affordance — without it the first click
 * has no visible consequence and the control looks broken for the second or so
 * between the two.
 */
export const PlDateRangePicker = /* @__PURE__ */ React.forwardRef<
  HTMLButtonElement,
  PlDateRangePickerProps
>(function PlDateRangePicker(
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
    monthCount = 2,
    startPlaceholder,
    endPlaceholder,
    presets,
    clearable = false,
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

  const [uncontrolledValue, setUncontrolledValue] = React.useState<PlDateRange>(
    defaultValue ?? EMPTY
  );
  const value = valueProp !== undefined ? (valueProp ?? EMPTY) : uncontrolledValue;
  const start = isValidDate(value.start) ? value.start : null;
  const end = isValidDate(value.end) ? value.end : null;

  const [uncontrolledOpen, setUncontrolledOpen] = React.useState(defaultOpen ?? false);
  const open = openProp ?? uncontrolledOpen;

  // The first of the two clicks. Held here rather than in `value` so a
  // controlled caller is never handed a range with only one end — half a
  // selection is this component's business, not the form's.
  const [anchor, setAnchor] = React.useState<Date | null>(null);
  const [preview, setPreview] = React.useState<Date | null>(null);

  const [month, setMonth] = React.useState(() => startOfMonth(start ?? defaultMonth ?? today()));

  React.useEffect(() => {
    if (open) {
      setMonth(startOfMonth(start ?? defaultMonth ?? today()));
    } else {
      // An abandoned half-selection does not survive the popup closing.
      setAnchor(null);
      setPreview(null);
    }
    // Only when the popup opens — following `start` here would drag the calendar
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

  const commit = (next: PlDateRange) => {
    if (valueProp === undefined) {
      setUncontrolledValue(next);
    }

    onValueChange?.(next);
  };

  const select = (date: Date) => {
    const day = startOfDay(date);

    // The first click of a new selection — either there is no anchor, or the
    // range is already complete and this click starts over.
    if (anchor === null) {
      setAnchor(day);
      setPreview(day);
      commit({ start: day, end: null });

      return;
    }

    // The second. Clicking backwards is not a mistake to be rejected, it is the
    // same range typed in the other order.
    const [from, to] = compareDay(day, anchor) < 0 ? [day, anchor] : [anchor, day];

    setAnchor(null);
    setPreview(null);
    commit({ start: from, end: to });

    if (closeOnSelect) {
      setOpen(false);
    }
  };

  const applyPreset = (preset: PlDateRangePreset) => {
    const range = typeof preset.value === 'function' ? preset.value() : preset.value;

    setAnchor(null);
    setPreview(null);
    commit(range);

    if (isValidDate(range.start)) {
      setMonth(startOfMonth(range.start));
    }

    if (closeOnSelect) {
      setOpen(false);
    }
  };

  // What the band is drawn between: the finished range, or the anchor and
  // whatever the pointer is currently over.
  const bandStart = anchor ?? start;
  const bandEnd = anchor !== null ? preview : end;

  const write = (date: Date | null, fallback: React.ReactNode) =>
    isValidDate(date) ? (
      formatDate(date, locale, format)
    ) : (
      <span className="text-(--plass-muted-fg)">{fallback ?? ''}</span>
    );

  const secondMonth = addMonths(month, 1);
  const twoUp = monthCount === 2;

  // Every date either half could show, so neither end of the trigger changes
  // width as the range is filled in.
  const dateSamples = React.useMemo(() => displaySamples(locale, format), [locale, format]);

  // Which end the next click will fill. The trigger says the same thing with its
  // two halves, but the trigger is behind the popup while the popup is up, so
  // the footer is the only place that can say it where it will be read.
  const hint = anchor !== null ? labels.end : start === null ? labels.start : null;

  const calendarProps = {
    size,
    color,
    locale,
    weekStartsOn: firstDay,
    selected: [start, end, anchor],
    rangeStart: bandStart,
    rangeEnd: bandEnd,
    onSelect: select,
    onPreviewChange: (date: Date | null) => {
      if (anchor !== null) {
        setPreview(date ?? anchor);
      }
    },
    minDate,
    maxDate,
    shouldDisableDate,
    // With both panels showing six full weeks, the 1st of August is a trailing
    // day of the July panel *and* the first day of the August one. Two cells
    // with the same name in one popup is ambiguous to a pointer and outright
    // broken to a screen reader.
    showOutsideDays: false,
    labels
  };

  return (
    <PickerShell
      {...shell}
      size={size}
      color={color}
      readOnly={readOnly}
      disabled={disabled}
      triggerRef={ref}
      startIcon={startIcon ?? <CalendarIcon />}
      display={
        // Neither half is `flex-1`. Two equal halves would size the trigger to
        // twice the *shorter* of the two, which truncates a date next to a word
        // like "Check out"; letting each take its own width sizes the control to
        // what it actually has to say.
        //
        // Each half carries its own sizer for the same reason it carries its own
        // width: one sizer across both would reserve the widest of the two twice
        // over, and the trigger would sit wider than anything it can hold.
        <span className="flex min-w-0 items-center gap-1.5">
          <span className="flex min-w-0 flex-col">
            <span className="truncate">{write(start, startPlaceholder)}</span>
            <WidthSizer samples={withPlaceholder(dateSamples, startPlaceholder)} />
          </span>
          <span
            aria-hidden="true"
            className="flex shrink-0 items-center text-(--plass-muted-fg) rtl:rotate-180"
          >
            <ArrowRightIcon />
          </span>
          <span className="flex min-w-0 flex-col">
            <span className="truncate">{write(end, endPlaceholder)}</span>
            <WidthSizer samples={withPlaceholder(dateSamples, endPlaceholder)} />
          </span>
        </span>
      }
      empty={start === null && end === null}
      clearable={clearable}
      onClear={() => commit(EMPTY)}
      open={open}
      onOpenChange={setOpen}
      labels={labels}
      hiddenValues={
        name
          ? [
              { name, value: start ? toISODate(start) : '' },
              { name, value: end ? toISODate(end) : '' }
            ]
          : undefined
      }
    >
      <div className="flex flex-col gap-1.5">
        <div className={cx('flex items-stretch', gapClasses[size])}>
          {presets && presets.length > 0 ? (
            <div
              className={cx(
                'flex max-h-[calc(var(--p-cell,2.5rem)*8)] flex-col overflow-y-auto border-e pe-1.5',
                '[border-color:var(--plass-divider)]'
              )}
            >
              {presets.map((preset, index) => (
                <PlButton
                  key={index}
                  variant="ghost"
                  size={size}
                  color={color}
                  density="compact"
                  className="justify-start whitespace-nowrap"
                  onClick={() => applyPreset(preset)}
                >
                  {preset.label}
                </PlButton>
              ))}
            </div>
          ) : null}

          <Calendar
            {...calendarProps}
            month={month}
            onMonthChange={setMonth}
            showNextButton={!twoUp}
            autoFocus
          />

          {twoUp ? (
            <Calendar
              {...calendarProps}
              month={secondMonth}
              // The right panel is a month ahead, so moving it means moving the
              // pair. Both headers drive one number.
              onMonthChange={(next) => setMonth(addMonths(next, -1))}
              showPreviousButton={false}
            />
          ) : null}
        </div>

        {clearable || hint !== null ? (
          <PickerFooter size={size}>
            {hint !== null ? (
              <span className={cx('me-auto text-(--plass-muted-fg)', metaTextClasses[size])}>
                {hint}
              </span>
            ) : null}
            {clearable ? (
              <PlButton
                variant="ghost"
                size={size}
                color={color}
                density="compact"
                onClick={() => {
                  setAnchor(null);
                  setPreview(null);
                  commit(EMPTY);
                  setOpen(false);
                }}
              >
                {labels.clear}
              </PlButton>
            ) : null}
          </PickerFooter>
        ) : null}
      </div>
    </PickerShell>
  );
});
