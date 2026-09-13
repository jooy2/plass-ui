import * as React from 'react';
import { Field } from '@base-ui/react/field';

/**
 * How a control whose visible part is not an `<input>` takes part in a form.
 *
 * Base UI's `Form` validates, focuses and collects only the controls registered
 * with a `Field`, and the one public way to register is `Field.Control`, which
 * is an `<input>` holding a string. A picker's trigger is a button and a file
 * picker's is a drop zone, so on their own they were invisible to a `PlForm`:
 * missing from its values, never blocking a submit, and never showing the error
 * it had for their `name`.
 *
 * `FormControl` is that input, kept off screen. It holds the value as a string,
 * so `required` is the browser's own check, and it hands the focus a form moves
 * to it on to the control a reader actually uses. What a string cannot carry —
 * the two ends of a range, several selections, a list of files — is reported to
 * the `PlForm` around it through `useFormReport`, and `PlForm` lays those over
 * the values Base UI collected.
 */

/** Values reported to a `PlForm` by name, read when the form is submitted. */
export type FormReport = Map<string, () => unknown>;

export const FormReportContext = /* @__PURE__ */ React.createContext<FormReport | null>(null);

/**
 * Reports `read()` as the value of `name` to the `PlForm` around the caller,
 * for as long as `enabled` holds. Outside a `PlForm` it does nothing.
 */
export function useFormReport(name: string | undefined, read: () => unknown, enabled = true) {
  const report = React.useContext(FormReportContext);
  const latest = React.useRef(read);

  React.useEffect(() => {
    latest.current = read;
  });

  React.useEffect(() => {
    if (!report || !name || !enabled) {
      return undefined;
    }

    const entry = () => latest.current();

    report.set(name, entry);

    return () => {
      if (report.get(name) === entry) {
        report.delete(name);
      }
    };
  }, [report, name, enabled]);
}

/**
 * Tells a `FormControl` the reader has left the control it stands behind, so a
 * form that validates on blur checks it then. The input never has the focus
 * itself, so the event it would have had is sent to it.
 */
export function leaveFormControl(input: HTMLInputElement | null) {
  input?.dispatchEvent(new FocusEvent('focusout', { bubbles: true }));
}

/** Off screen but not `display: none`, which would bar it from validation. */
const offScreenClasses =
  'pointer-events-none absolute size-px overflow-hidden opacity-0 [clip-path:inset(50%)]';

export interface FormControlProps {
  /** The name the value submits under, and the key a form's `errors` use. */
  name?: string;
  /**
   * The value as a form submits it: one string, or one entry per row. An empty
   * string, a list with an empty entry and an empty list are no value, which is
   * what `required` checks.
   */
  value: string | readonly string[];
  required: boolean;
  disabled: boolean;
  /** The element a reader uses, which takes the focus a form moves here. */
  standIn: () => HTMLElement | null | undefined;
}

/**
 * The input a `Field` registers for a control that is not one. Renders inside a
 * `Field.Root`.
 */
export const FormControl = /* @__PURE__ */ React.forwardRef<HTMLInputElement, FormControlProps>(
  function FormControl({ name, value, required, disabled, standIn }, ref) {
    const list = Array.isArray(value);
    const filled = list ? value.length > 0 && value.every((entry) => entry !== '') : value !== '';

    useFormReport(name, () => [...value], list && !disabled);

    return (
      <>
        <Field.Control
          ref={ref}
          name={name}
          value={list ? (filled ? value.join('\n') : '') : value}
          required={required}
          disabled={disabled}
          tabIndex={-1}
          aria-hidden="true"
          autoComplete="off"
          className={offScreenClasses}
          onFocus={() => standIn()?.focus()}
          // A list submits one row per entry below, so the input that decides
          // its validity must not submit a row of its own.
          render={list ? (props) => <input {...props} name={undefined} /> : undefined}
        />

        {list && name
          ? value.map((entry, index) => (
              <input key={index} type="hidden" name={name} value={entry} disabled={disabled} />
            ))
          : null}
      </>
    );
  }
);
