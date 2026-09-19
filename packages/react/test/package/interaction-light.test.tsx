/**
 * That every surface the design language says answers a pointer actually does.
 *
 * A test of a *contract* rather than of a component, which is why it is here
 * and not under `test/components/`. `.plass-glow` is three separate pieces — the
 * class, `position: relative` for the two layers to hang off, and a
 * `pointermove` that writes `--p-mx`/`--p-my` — and a component can be given one
 * or two of them and look completely finished: the light simply never appears,
 * or appears pinned to the middle of the box. Nothing else in the suite notices,
 * because no component test loads CSS and a missing bloom breaks no assertion.
 *
 * The second list is the half that keeps this honest. The light is for a surface
 * big enough for a gradient to be a gradient, so a tick-scale control is
 * deliberately without one, and an entry moved from the second list to the first
 * has to be a decision somebody made rather than a class somebody copied.
 */
import type * as React from 'react';
import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import {
  PlCheckbox,
  PlChip,
  PlColorPicker,
  PlCombobox,
  PlDatePicker,
  PlDateRangePicker,
  PlDateTimePicker,
  PlFilePicker,
  PlNumberField,
  PlOtpField,
  PlRadio,
  PlRadioGroup,
  PlRating,
  PlSegment,
  PlSegmentedButton,
  PlSelect,
  PlSwitch,
  PlTextField,
  PlTimePicker,
  PlToggle,
  PlTreeSelect
} from 'plass-ui';

const items = [
  { value: 'seoul', label: 'Seoul' },
  { value: 'busan', label: 'Busan' }
];

const tree = [{ id: 'kr', label: 'Korea', children: [{ id: 'seoul', label: 'Seoul' }] }];

/** The element the light is drawn on, marked the way every field marks it. */
const classNames = { control: 'lit-under-test' };

type Extra = { disabled?: boolean; readOnly?: boolean };

/**
 * Where the lit box is. Almost every field marks it with `classNames.control`;
 * `PlColorPicker` takes no `classNames` yet, so its trigger shell is found the
 * way the DOM describes it — the box the trigger button sits in.
 */
type Locate = () => HTMLElement | null;

const byControl: Locate = () => document.querySelector('.lit-under-test');

/**
 * Everything that carries the light, and how to render it with and without the
 * two states that take it away.
 */
const lit: Array<[string, (extra?: Extra) => React.ReactElement, Locate]> = [
  [
    'PlTextField',
    (extra) => <PlTextField label="City" classNames={classNames} {...extra} />,
    byControl
  ],
  [
    'PlNumberField',
    (extra) => <PlNumberField label="Age" classNames={classNames} {...extra} />,
    byControl
  ],
  [
    'PlSelect',
    (extra) => <PlSelect items={items} label="City" classNames={classNames} {...extra} />,
    byControl
  ],
  [
    'PlCombobox',
    (extra) => <PlCombobox items={items} label="City" classNames={classNames} {...extra} />,
    byControl
  ],
  [
    'PlDatePicker',
    (extra) => <PlDatePicker label="Day" classNames={classNames} {...extra} />,
    byControl
  ],
  [
    'PlDateRangePicker',
    (extra) => <PlDateRangePicker label="Stay" classNames={classNames} {...extra} />,
    byControl
  ],
  [
    'PlDateTimePicker',
    (extra) => <PlDateTimePicker label="When" classNames={classNames} {...extra} />,
    byControl
  ],
  [
    'PlTimePicker',
    (extra) => <PlTimePicker label="Time" classNames={classNames} {...extra} />,
    byControl
  ],
  [
    'PlColorPicker',
    (extra) => <PlColorPicker label="Brand" className="picker-under-test" {...extra} />,
    () => document.querySelector('.picker-under-test button')?.parentElement ?? null
  ],
  [
    'PlTreeSelect',
    (extra) => <PlTreeSelect items={tree} label="Where" classNames={classNames} {...extra} />,
    byControl
  ]
];

describe.each(lit)('%s', (name, field, locate) => {
  it('carries the interaction light on the box a pointer is over', async () => {
    await render(field());

    const control = locate() as HTMLElement;

    expect(control, `${name}: no control`).not.toBeNull();
    expect(control).toHaveClass('plass-glow');
    // The two layers are `position: absolute; inset: 0`, so without this they
    // hang off whatever ancestor happens to be positioned.
    expect(control.className.split(' ')).toContain('relative');
  });

  it('moves the light to the pointer without re-rendering', async () => {
    await render(field());

    const control = locate() as HTMLElement;

    control.dispatchEvent(
      new PointerEvent('pointermove', { bubbles: true, clientX: 40, clientY: 12 })
    );

    // Written straight to the element rather than held in state: this runs at
    // pointer rate.
    expect(control.style.getPropertyValue('--p-mx')).not.toBe('');
    expect(control.style.getPropertyValue('--p-my')).not.toBe('');
  });

  it('puts the light out while it is disabled or read-only', async () => {
    await render(field({ disabled: true }));
    expect(locate()).not.toHaveClass('plass-glow');

    await render(field({ readOnly: true }));
    expect(locate()).not.toHaveClass('plass-glow');
  });
});

describe('the rest of what the light is on', () => {
  it('is on a pressable PlChip and not on a plain one', async () => {
    const screen = await render(<PlChip onClick={() => {}}>Seoul</PlChip>);

    expect(screen.getByText('Seoul').element().closest('.plass-glow')).not.toBeNull();

    await screen.rerender(<PlChip>Seoul</PlChip>);
    expect(screen.getByText('Seoul').element().closest('.plass-glow')).toBeNull();
  });

  it('is on each segment of a PlSegmentedButton', async () => {
    await render(
      <PlSegmentedButton defaultValue="day">
        <PlSegment value="day">Day</PlSegment>
        <PlSegment value="week" disabled>
          Week
        </PlSegment>
      </PlSegmentedButton>
    );

    const segments = document.querySelectorAll('[data-segment]');

    expect(segments[0]).toHaveClass('plass-glow');
    expect(segments[1]).not.toHaveClass('plass-glow');
  });

  it('is on a PlFilePicker’s drop zone, which is the largest of them', async () => {
    const screen = await render(<PlFilePicker />);

    expect(screen.getByRole('button').element()).toHaveClass('plass-glow');
  });

  it('is on a PlToggle that can be pressed', async () => {
    const screen = await render(<PlToggle>Bold</PlToggle>);

    expect(screen.getByRole('button').element()).toHaveClass('plass-glow');
  });
});

/**
 * The deliberate exclusions.
 *
 * A tick, a radio and a switch track are the size of the text beside them, and a
 * 6rem bloom inside a 20px box is not a bloom — it is a flat wash that moves,
 * which reads as a rendering fault rather than as light. The design language
 * already draws this line for the edge a tick takes; it is the same line.
 *
 * `PlOtpField` is out for a different and harder reason: its slot **is** an
 * `<input>`, and a replaced element renders no `::before` or `::after`. Lighting
 * it would mean wrapping every slot in a box, which is a change to the control
 * rather than to its paint.
 */
describe('what the light is deliberately not on', () => {
  const unlit: Array<[string, React.ReactElement]> = [
    ['PlCheckbox', <PlCheckbox label="Remember me" />],
    ['PlSwitch', <PlSwitch label="Dark mode" />],
    [
      'PlRadioGroup',
      <PlRadioGroup label="City">
        <PlRadio value="seoul" label="Seoul" />
      </PlRadioGroup>
    ],
    ['PlRating', <PlRating defaultValue={3} />],
    ['PlOtpField', <PlOtpField label="Code" />]
  ];

  it.each(unlit)('%s', async (name, element) => {
    await render(element);

    expect(document.querySelector('.plass-glow'), `${name} carries the light`).toBeNull();
  });
});
