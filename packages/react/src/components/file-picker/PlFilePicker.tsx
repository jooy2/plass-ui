import * as React from 'react';
import { CloseIcon } from '../../internal/icons';
import {
  controlTextLeadingClasses,
  disabledClasses,
  focusRingClasses,
  gapClasses,
  glassClasses,
  hasContent,
  iconClasses,
  metaTextClasses,
  radiusClasses,
  readOnlyFilterClasses,
  sheetTitleClasses,
  stackGapClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles';
import type {
  PlassColor,
  PlassDensity,
  PlassElevation,
  PlassSize,
  PlassStyleProps,
  PlassVariant
} from '../../types';

/** Why a file was turned away. One reason per file, in the order they are checked. */
export type PlFileRejectionReason = 'type' | 'size' | 'count';

export interface PlFileRejection {
  file: File;
  reason: PlFileRejectionReason;
}

export interface PlFilePickerProps
  extends
    PlassStyleProps,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'defaultValue' | 'title' | 'children'> {
  /**
   * Drop shadow depth. `0` is the default — a dropzone is cut into the page
   * rather than floating over it.
   * @default 0
   */
  elevation?: PlassElevation;
  /**
   * Which files the browser's own picker offers, in the `accept` grammar —
   * `'image/*,.pdf'`. Dropped files are checked against it too, which the
   * attribute alone does not do.
   */
  accept?: string;
  /** Whether more than one file may be chosen. @default false */
  multiple?: boolean;
  /** The largest a single file may be, in bytes. */
  maxSize?: number;
  /**
   * How many files may be held at once. Implies `multiple`, and is checked
   * against what is already chosen rather than against one drop.
   */
  maxFiles?: number;
  /** The chosen files. Use with `onFilesChange` for a controlled picker. */
  value?: readonly File[];
  /** The initially chosen files, for an uncontrolled one. */
  defaultValue?: readonly File[];
  onFilesChange?: (files: File[]) => void;
  /**
   * Called with everything that was turned away, and why. Without it a rejected
   * file disappears silently, which is the single worst thing a dropzone does.
   */
  onReject?: (rejections: PlFileRejection[]) => void;
  /** Label above the box. */
  label?: React.ReactNode;
  /** Helper text below the box. */
  description?: React.ReactNode;
  /** Error message below. Its presence also turns the picker invalid. */
  error?: React.ReactNode;
  /**
   * Forces the invalid state without a message — for when an external form
   * library owns the validity. Defaults to whether `error` has content.
   */
  invalid?: boolean;
  /** The line inside the box. Defaults to an English sentence. */
  title?: React.ReactNode;
  /** The line under it — what is accepted, how big, how many. */
  hint?: React.ReactNode;
  /** The glyph above the title. Pass `null` for a box with no picture in it. */
  icon?: React.ReactNode;
  /**
   * Lists the chosen files under the box, each with a way to remove it.
   * @default true
   */
  showList?: boolean;
  /** Accessible name of a file's remove button. Receives the file's name. */
  removeLabel?: (name: string) => string;
  /** Stretches to the width of the container. @default true */
  fullWidth?: boolean;
  /** Unavailable. */
  disabled?: boolean;
  /** The files are shown but cannot be added to or removed. */
  readOnly?: boolean;
  /** Whether a file must be chosen before the form is submitted. */
  required?: boolean;
  /** Identifies the field when a form is submitted. */
  name?: string;
  id?: string;
}

/**
 * The box's inner padding. Its own ladder rather than the sheet's, because a
 * dropzone is sized by the gesture it has to catch rather than by what is
 * written in it: a target the height of one line of text is a target you miss.
 */
const zonePaddingClasses: Record<PlassDensity, Record<PlassSize, string>> = {
  default: { xs: 'p-4', sm: 'p-5', md: 'p-6', lg: 'p-8', xl: 'p-10' },
  compact: { xs: 'p-2', sm: 'p-3', md: 'p-4', lg: 'p-5', xl: 'p-6' }
};

/**
 * The three materials, said the way a *container* says them — the sheet is
 * never dyed. What is dropped on it is other people's content.
 *
 * The dashed edge is the one thing all three share, and the one place the
 * library draws a line that is not solid. It is not decoration: a dashed
 * rectangle is the established sign for "this area accepts a drop", and a
 * dropzone that looks like a PlCard is a PlCard nobody tries to drop on.
 *
 * The edge is neutral at rest and takes the family only once the pointer is on
 * it, which is the same arrangement a `glass` PlButton has: the colour is what
 * happens when you engage with the thing, not what the thing is.
 */
const zoneRestClasses: Record<PlassVariant, string> = {
  solid: [
    glassClasses,
    'border-2 border-dashed text-(--plass-fg) bg-(--plass-glass-press)',
    '[border-color:var(--plass-border)]',
    '[box-shadow:var(--p-elev),var(--plass-gloss-glass)]'
  ].join(' '),
  glass: [
    glassClasses,
    'border-2 border-dashed text-(--plass-fg) bg-(--plass-glass)',
    '[border-color:var(--plass-border)]',
    '[box-shadow:var(--p-elev),var(--plass-gloss-glass)]'
  ].join(' '),
  ghost:
    'border-2 border-dashed text-(--plass-fg) bg-transparent [border-color:var(--plass-border)]'
};

const zoneHoverClasses: Record<PlassVariant, string> = {
  solid: 'hover:bg-(--plass-glass-hover) hover:[border-color:var(--p-line-hover)]',
  glass: 'hover:bg-(--plass-glass-hover) hover:[border-color:var(--p-line-hover)]',
  ghost: 'hover:bg-(--p-soft) hover:[border-color:var(--p-line-hover)]'
};

/**
 * While a file is over the box.
 *
 * Colour and edge only, and the same two the hover state already uses, one step
 * further along — a dropzone that grows or lifts under the pointer moves the
 * target while the reader is aiming at it.
 */
const zoneOverClasses = 'bg-(--p-soft-hover) [border-color:var(--p-ring)]';

function UploadIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path
        d="M8 10.5V2.75m0 0L5.25 5.5M8 2.75 10.75 5.5"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M2.75 9.75v1.75a1.75 1.75 0 0 0 1.75 1.75h7a1.75 1.75 0 0 0 1.75-1.75V9.75"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
    </svg>
  );
}

/**
 * `1.4 MB`, in the units a person reading a file list expects.
 *
 * Base 1000 rather than 1024, and `MB` rather than `MiB`: it is the number
 * every operating system's file browser shows, and a picker that disagrees with
 * the Finder about how big the file is has picked a fight it cannot win.
 */
export function formatFileSize(bytes: number): string {
  if (bytes < 1000) {
    return `${bytes} B`;
  }

  const units = ['kB', 'MB', 'GB', 'TB'];
  let value = bytes / 1000;
  let unit = 0;

  while (value >= 1000 && unit < units.length - 1) {
    value /= 1000;
    unit += 1;
  }

  return `${value < 10 ? value.toFixed(1) : Math.round(value)} ${units[unit]}`;
}

/**
 * Whether a file matches an `accept` string.
 *
 * The browser applies `accept` to its own picker and to nothing else, so a file
 * that arrives by drag has never been checked against it. This is that check:
 * the same three forms the attribute takes — `.ext`, `type/subtype`, `type/*`.
 */
function matchesAccept(file: File, accept: string): boolean {
  const name = file.name.toLowerCase();
  const type = file.type.toLowerCase();

  return accept
    .split(',')
    .map((entry) => entry.trim().toLowerCase())
    .filter(Boolean)
    .some((entry) => {
      if (entry.startsWith('.')) {
        return name.endsWith(entry);
      }
      if (entry.endsWith('/*')) {
        return type.startsWith(entry.slice(0, -1));
      }
      return type === entry;
    });
}

/**
 * A box you drop files on, or click to open the file dialog.
 *
 * There is no Base UI primitive under this, and the fallback the library allows
 * — plain React and DOM — is the right one: a dropzone is a `<div>` listening
 * for four drag events and an `<input type="file">` it clicks for you. There is
 * no popup to position, no focus to trap and no roving anything.
 *
 * What that leaves is the part every hand-rolled dropzone gets wrong. The drag
 * counter is one: `dragenter` and `dragleave` both fire as the pointer crosses
 * a *child* of the zone, so a zone that toggles a boolean flickers the whole
 * time a file is dragged across its own contents. Counting them is the fix. The
 * other is `accept`, which the browser enforces on its own dialog and never on
 * a drop, so a dropzone that only sets the attribute accepts anything the
 * moment a file arrives by drag.
 *
 * The shell is a `<div>` and the pressable area inside it is a real `<button>`,
 * with the file list outside that button — the remove buttons cannot be nested
 * inside the browse button.
 */
export const PlFilePicker = React.forwardRef<HTMLInputElement, PlFilePickerProps>(
  function PlFilePicker(
    {
      variant = 'glass',
      size = 'md',
      color = 'primary',
      density = 'default',
      elevation = 0,
      accept,
      multiple = false,
      maxSize,
      maxFiles,
      value,
      defaultValue,
      onFilesChange,
      onReject,
      label,
      description,
      error,
      invalid,
      title,
      hint,
      icon,
      showList = true,
      removeLabel = (name) => `Remove ${name}`,
      fullWidth = true,
      disabled = false,
      readOnly = false,
      required = false,
      name,
      id,
      className,
      style,
      ...props
    },
    ref
  ) {
    const inputRef = React.useRef<HTMLInputElement>(null);
    React.useImperativeHandle(ref, () => inputRef.current as HTMLInputElement);

    const [uncontrolled, setUncontrolled] = React.useState<File[]>(() => [...(defaultValue ?? [])]);
    // The copy is what stops a caller's array being the one held here, and it
    // has to be memoised: the handlers below close over this list, and a fresh
    // array every render would rebuild all of them every render.
    const files = React.useMemo(() => (value ? [...value] : uncontrolled), [value, uncontrolled]);

    // `dragenter`/`dragleave` fire for every child the pointer crosses, so a
    // boolean flickers the whole time a file is over the box. The depth counter
    // is the only thing that survives a zone with content in it.
    const dragDepth = React.useRef(0);
    const [over, setOver] = React.useState(false);

    const hasError = hasContent(error);
    const isInvalid = invalid ?? hasError;
    // Invalid re-points the whole slot family at `danger`, so the edge, the ring
    // and the message all turn over together — the same wiring PlTextField uses.
    const family: PlassColor = isInvalid ? 'danger' : color;
    const inert = disabled || readOnly;
    const descriptionId = React.useId();

    const commit = React.useCallback(
      (next: File[]) => {
        if (!value) {
          setUncontrolled(next);
        }
        onFilesChange?.(next);
      },
      [onFilesChange, value]
    );

    /**
     * Sorts an incoming batch into kept and rejected.
     *
     * The count is checked against what is *already* held rather than against
     * the batch, which is the difference between "you may drop five files" and
     * "you may end up with five files" — only the second is what `maxFiles`
     * means.
     */
    const accepting = React.useCallback(
      (incoming: File[]) => {
        const kept: File[] = [];
        const rejections: PlFileRejection[] = [];
        const room = multiple ? (maxFiles ?? Number.POSITIVE_INFINITY) : 1;
        const held = multiple ? files.length : 0;

        for (const file of incoming) {
          if (accept && !matchesAccept(file, accept)) {
            rejections.push({ file, reason: 'type' });
          } else if (maxSize !== undefined && file.size > maxSize) {
            rejections.push({ file, reason: 'size' });
          } else if (held + kept.length >= room) {
            rejections.push({ file, reason: 'count' });
          } else {
            kept.push(file);
          }
        }

        return { kept, rejections };
      },
      [accept, files.length, maxFiles, maxSize, multiple]
    );

    const add = React.useCallback(
      (incoming: File[]) => {
        const { kept, rejections } = accepting(incoming);

        if (rejections.length > 0) {
          onReject?.(rejections);
        }
        if (kept.length > 0) {
          commit(multiple ? [...files, ...kept] : kept);
        }
      },
      [accepting, commit, files, multiple, onReject]
    );

    const browse = () => {
      if (inert) {
        return;
      }
      // Cleared first, so choosing the same file twice in a row still fires
      // `change` — the input holds its value otherwise and the second pick is
      // silently dropped.
      if (inputRef.current) {
        inputRef.current.value = '';
        inputRef.current.click();
      }
    };

    const zoneClassNames = [
      'flex w-full flex-col items-center justify-center text-center',
      'cursor-pointer select-none',
      zonePaddingClasses[density][size],
      radiusClasses[size],
      gapClasses[size],
      transitionClasses,
      iconClasses,
      focusRingClasses,
      // An if/else rather than stacked variants: two Tailwind classes of equal
      // specificity resolve by their order in the generated stylesheet.
      disabled
        ? `${disabledClasses[variant]} border-2 border-dashed`
        : readOnly
          ? `${zoneRestClasses[variant]} ${readOnlyFilterClasses} cursor-default`
          : zoneRestClasses[variant],
      !inert ? zoneHoverClasses[variant] : '',
      over && !inert ? zoneOverClasses : ''
    ]
      .filter(Boolean)
      .join(' ');

    return (
      <div
        className={[
          'flex-col align-top',
          stackGapClasses[size],
          fullWidth ? 'flex w-full' : 'inline-flex',
          className ?? ''
        ]
          .filter(Boolean)
          .join(' ')}
        style={{ ...surfaceSlots(family, elevation), ...style }}
        {...props}
      >
        {hasContent(label) ? (
          <span
            className={[
              metaTextClasses[size],
              'font-semibold',
              disabled ? 'text-(--plass-muted-fg)' : 'text-(--plass-fg)'
            ].join(' ')}
          >
            {label}
          </span>
        ) : null}

        {/* The drag listeners belong to the shell rather than to the button: a
            drop is a gesture over an *area*, and the file list under the box is
            part of the same area as far as the pointer is concerned. */}
        <div
          className="flex w-full flex-col"
          onDragEnter={(event) => {
            if (inert) {
              return;
            }
            event.preventDefault();
            dragDepth.current += 1;
            setOver(true);
          }}
          onDragOver={(event) => {
            if (inert) {
              return;
            }
            // Without this the browser navigates to the file instead of
            // dropping it, which is the default and is never what anybody wants.
            event.preventDefault();
            event.dataTransfer.dropEffect = 'copy';
          }}
          onDragLeave={() => {
            if (inert) {
              return;
            }
            dragDepth.current = Math.max(0, dragDepth.current - 1);
            if (dragDepth.current === 0) {
              setOver(false);
            }
          }}
          onDrop={(event) => {
            if (inert) {
              return;
            }
            event.preventDefault();
            dragDepth.current = 0;
            setOver(false);
            add(Array.from(event.dataTransfer.files));
          }}
        >
          <button
            type="button"
            id={id}
            disabled={disabled}
            aria-describedby={hasContent(description) || hasError ? descriptionId : undefined}
            aria-invalid={isInvalid || undefined}
            className={zoneClassNames}
            onClick={browse}
          >
            {icon === undefined ? (
              <span className="flex items-center text-(--p-accent) [&_svg]:size-[1.8em]">
                <UploadIcon />
              </span>
            ) : hasContent(icon) ? (
              <span className="flex items-center text-(--p-accent) [&_svg]:size-[1.8em]">
                {icon}
              </span>
            ) : null}

            <span className={`font-semibold ${sheetTitleClasses[size]}`}>
              {title ?? 'Drop files here, or click to browse'}
            </span>

            {hasContent(hint) ? (
              <span className={`text-(--plass-muted-fg) ${metaTextClasses[size]}`}>{hint}</span>
            ) : null}
          </button>

          {/*
            The real control, kept off-screen rather than hidden: `display: none`
            and `visibility: hidden` both make an input unfocusable in some
            browsers, and this one still has to be reachable to a form and to a
            `required` validation message.
          */}
          <input
            ref={inputRef}
            type="file"
            name={name}
            accept={accept}
            multiple={multiple}
            required={required && files.length === 0}
            disabled={inert}
            tabIndex={-1}
            aria-hidden="true"
            className="absolute size-px overflow-hidden opacity-0 [clip-path:inset(50%)]"
            onChange={(event) => add(Array.from(event.target.files ?? []))}
          />
        </div>

        {showList && files.length > 0 ? (
          <ul
            role="list"
            className={`flex w-full flex-col ${stackGapClasses[size]} m-0 list-none p-0`}
          >
            {files.map((file, index) => (
              <li
                key={`${file.name}-${file.size}-${file.lastModified}-${index}`}
                className={[
                  'flex w-full items-center gap-2 px-2 py-1.5',
                  radiusClasses.xs,
                  controlTextLeadingClasses[size],
                  'bg-(--p-soft) text-(--plass-fg)'
                ].join(' ')}
              >
                <span className="min-w-0 flex-1 truncate">{file.name}</span>
                <span
                  className={`shrink-0 text-(--plass-muted-fg) tabular-nums ${metaTextClasses[size]}`}
                >
                  {formatFileSize(file.size)}
                </span>
                {inert ? null : (
                  <button
                    type="button"
                    aria-label={removeLabel(file.name)}
                    className={[
                      'inline-flex shrink-0 cursor-pointer items-center justify-center rounded-full',
                      'size-[1.3em] text-(--plass-muted-fg) opacity-70',
                      '[transition:opacity_var(--plass-duration)_var(--plass-ease),color_var(--plass-duration)_var(--plass-ease)]',
                      '[&_svg]:size-[0.9em]',
                      'hover:text-(--plass-fg) hover:opacity-100 focus-visible:opacity-100',
                      focusRingClasses
                    ].join(' ')}
                    onClick={() => commit(files.filter((_, at) => at !== index))}
                  >
                    <CloseIcon />
                  </button>
                )}
              </li>
            ))}
          </ul>
        ) : null}

        {hasContent(description) && !hasError ? (
          <span id={descriptionId} className={`${metaTextClasses[size]} text-(--plass-muted-fg)`}>
            {description}
          </span>
        ) : null}

        {hasError ? (
          <span id={descriptionId} className={`${metaTextClasses[size]} text-(--p-accent)`}>
            {error}
          </span>
        ) : null}
      </div>
    );
  }
);
