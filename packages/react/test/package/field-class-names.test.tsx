/**
 * That `classNames` means the same four things on every labelled control.
 *
 * A test of a *contract* rather than of a component, which is why it is here
 * rather than under `test/components/`: what it asserts is precisely the part
 * no single component's file can say, that `label`, `control`, `description`
 * and `error` land on the same four parts across all twelve of them. Twelve
 * separate blocks would each pass while the vocabulary drifted apart between
 * them, which is the only way this can really break.
 *
 * `control` is the one worth stating out loud. A field's `className` goes on
 * the *stack* — the wrapper holding the label, the control and the two lines
 * under it — because that is what a caller positions and sizes. It is the wrong
 * element for almost every other override, and `control` is the right one: the
 * box a `PlTextField` is typed into, the button a `PlSelect` opens, the tick,
 * the track, the row of radios, the trigger a picker's calendar hangs off.
 */
import type * as React from 'react';
import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import {
  PlCheckbox,
  PlCombobox,
  PlDatePicker,
  PlDateRangePicker,
  PlDateTimePicker,
  PlNumberField,
  PlOtpField,
  PlRadio,
  PlRadioGroup,
  PlSelect,
  PlSwitch,
  PlTextField,
  PlTimePicker
} from 'plass-ui';

const classNames = {
  label: 'label-under-test',
  control: 'control-under-test',
  description: 'description-under-test',
  error: 'error-under-test'
};

/** The three text slots, written the same way on every field. */
const text = { label: 'City', description: 'Where you live', error: 'Required.' };

const items = [
  { value: 'seoul', label: 'Seoul' },
  { value: 'busan', label: 'Busan' }
];

/** Anything a single test wants to add on top of the four slots. */
type Extra = { className?: string };

const fields: Array<[string, (extra?: Extra) => React.ReactElement]> = [
  ['PlTextField', (extra?: Extra) => <PlTextField {...text} classNames={classNames} {...extra} />],
  [
    'PlSelect',
    (extra?: Extra) => <PlSelect items={items} {...text} classNames={classNames} {...extra} />
  ],
  [
    'PlCombobox',
    (extra?: Extra) => <PlCombobox items={items} {...text} classNames={classNames} {...extra} />
  ],
  [
    'PlNumberField',
    (extra?: Extra) => <PlNumberField {...text} classNames={classNames} {...extra} />
  ],
  ['PlOtpField', (extra?: Extra) => <PlOtpField {...text} classNames={classNames} {...extra} />],
  ['PlCheckbox', (extra?: Extra) => <PlCheckbox {...text} classNames={classNames} {...extra} />],
  ['PlSwitch', (extra?: Extra) => <PlSwitch {...text} classNames={classNames} {...extra} />],
  [
    'PlRadioGroup',
    (extra?: Extra) => (
      <PlRadioGroup {...text} classNames={classNames} {...extra}>
        <PlRadio value="seoul" label="Seoul" />
      </PlRadioGroup>
    )
  ],
  [
    'PlDatePicker',
    (extra?: Extra) => <PlDatePicker {...text} classNames={classNames} {...extra} />
  ],
  [
    'PlDateRangePicker',
    (extra?: Extra) => <PlDateRangePicker {...text} classNames={classNames} {...extra} />
  ],
  [
    'PlDateTimePicker',
    (extra?: Extra) => <PlDateTimePicker {...text} classNames={classNames} {...extra} />
  ],
  ['PlTimePicker', (extra?: Extra) => <PlTimePicker {...text} classNames={classNames} {...extra} />]
];

describe.each(fields)('%s', (name, field) => {
  it('puts each of the four classes on exactly one element', async () => {
    await render(field());

    for (const [slot, className] of Object.entries(classNames)) {
      expect(
        document.querySelectorAll(`.${className}`),
        `${name}: ${slot} landed on ${document.querySelectorAll(`.${className}`).length} elements`
      ).toHaveLength(1);
    }
  });

  it('puts them on four different elements', async () => {
    await render(field());

    const found = Object.values(classNames).map((className) =>
      document.querySelector(`.${className}`)
    );

    expect(new Set(found).size).toBe(4);
  });

  it('joins the classes the component already had rather than replacing them', async () => {
    await render(field());

    for (const className of Object.values(classNames)) {
      const element = document.querySelector(`.${className}`) as HTMLElement;

      // Every one of the four carries library classes of its own — a type
      // scale, a colour, a layout — so a class list of exactly one means the
      // caller's class arrived *instead of* them.
      expect(element.classList.length).toBeGreaterThan(1);
    }
  });

  it('leaves the stack itself to `className`', async () => {
    await render(field({ className: 'stack-under-test' }));

    const stack = document.querySelector('.stack-under-test') as HTMLElement;
    const control = document.querySelector('.control-under-test') as HTMLElement;

    // Two different elements, always, and in this order: `className` is what
    // positions and sizes the field, `control` is the part inside it a reader
    // acts on.
    expect(stack).not.toBe(control);
    expect(stack.contains(control)).toBe(true);
  });
});
