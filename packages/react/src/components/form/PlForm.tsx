'use client';

import * as React from 'react';
import { Form as BaseUIForm } from '@base-ui/react/form';
import { cx, sheetSectionGapClasses } from '../../internal/styles.js';
import type { PlassSize } from '../../types.js';

/**
 * When a field decides whether it is valid.
 *
 * Base UI's own three, kept under its own spelling because they are what a
 * caller will read about everywhere else and a nicer synonym would only be a
 * word to translate back.
 */
export type PlFormValidationMode = 'onSubmit' | 'onBlur' | 'onChange';

/** Errors that came from somewhere else, keyed by the field's `name`. */
export type PlFormErrors = Record<string, string | string[]>;

export interface PlFormProps extends Omit<React.ComponentPropsWithoutRef<'form'>, 'onSubmit'> {
  /**
   * When a field validates.
   *
   * - `onSubmit` — on submit, and on every change afterwards. The default, and
   *   the only one that does not tell somebody their email is wrong while they
   *   are still typing it.
   * - `onBlur` — when a field loses focus.
   * - `onChange` — on every keystroke.
   * @default 'onSubmit'
   */
  validationMode?: PlFormValidationMode;
  /**
   * Errors from outside the browser's own validation — a server, a form action,
   * a schema — keyed by the `name` of the field each belongs to. They are shown
   * on the field, and cleared as soon as that field changes.
   */
  errors?: PlFormErrors;
  /**
   * Called on a valid submit, with the form's values. The native submit event is
   * prevented, so nothing navigates.
   */
  onSubmit?: (values: Record<string, unknown>) => void;
  /**
   * The gap between the form's children. A form is a stack, and this is which
   * rung of the ladder it stacks on.
   * @default 'md'
   */
  size?: PlassSize;
  children?: React.ReactNode;
}

/**
 * A `<form>` that knows which of its fields is wrong.
 *
 * On its own, a page of `PlTextField`s validates one field at a time and a
 * failed submit leaves the reader to find the red one. What this adds is the
 * part that has to be owned *above* the fields: a submit collects every field's
 * validity at once, focuses the first one that failed, and `errors` puts a
 * server's answer back on the field it belongs to rather than in a banner at
 * the top.
 *
 * It is **not a form library**. There is no schema, no resolver and no field
 * array here — a project that wants those keeps them and hands the result to
 * `errors`, which is the seam this is built around.
 *
 * It draws no surface either. A form is a stack of controls, and the sheet it
 * sits on is a `PlCard` or a `PlBox` when one is wanted.
 */
export const PlForm = /* @__PURE__ */ React.forwardRef<HTMLFormElement, PlFormProps>(
  function PlForm(
    { validationMode = 'onSubmit', errors, onSubmit, size = 'md', className, children, ...props },
    ref
  ) {
    return (
      <BaseUIForm
        ref={ref}
        validationMode={validationMode}
        errors={errors}
        onFormSubmit={(values) => onSubmit?.(values)}
        className={cx('flex flex-col', sheetSectionGapClasses[size], className)}
        {...props}
      >
        {children}
      </BaseUIForm>
    );
  }
);
