/**
 * That the two light layers actually resolve to something drawable.
 *
 * `.plass-glow` is written in `src/styles.css` and painted on `::before` and
 * `::after`, so none of it can be read off the element a component test has —
 * and all three ways it fails are silent. A missing `--p-glow` leaves a gradient
 * that runs transparent to transparent, which paints nothing and throws nothing.
 * A missing `position: relative` hangs the layers off some ancestor, which draws
 * a bloom in the wrong box. A class on the wrong element draws the bloom over
 * the page instead of over the control. Every one of those passes a class-list
 * assertion, which is why this file loads the stylesheet.
 *
 * It asserts no design value — not a radius, a shade or a duration. Those move
 * with the design language, and a test that pins them turns a decision into a
 * failure. What is pinned here is that each piece reaches the next one.
 */
import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';
import { commands, userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-react';
import {
  PlButton,
  PlCombobox,
  PlNumberField,
  PlSegment,
  PlSegmentedButton,
  PlTextField
} from 'plass-ui';
import standaloneCss from '../../src/standalone.css?inline';

let sheet: HTMLStyleElement;

beforeAll(() => {
  sheet = document.createElement('style');
  sheet.textContent = standaloneCss;
  document.head.append(sheet);
});

afterAll(() => {
  sheet.remove();
});

/**
 * The colour of the bloom's first stop, as the browser resolved it.
 *
 * Matched as a colour function rather than cut at the next comma, because the
 * browser writes one in whichever space it landed in — `color(srgb … / a)` for
 * a plain token and `oklab(… / a)` for one that went through a `color-mix` —
 * and a legacy `rgba()` has commas of its own inside it.
 */
function firstStop(layer: CSSStyleDeclaration): string {
  const [stop] =
    /(?:rgba?|hsla?|oklab|oklch|lab|lch|color)\([^)]*\)/.exec(layer.backgroundImage) ?? [];

  return stop ?? '';
}

/**
 * How much of that colour there is. Every modern syntax writes the alpha after
 * a slash; `rgba()` and `hsla()` write it as a fourth argument. A colour that
 * gives none is opaque.
 */
function alphaOf(color: string): number {
  const slashed = /\/\s*([\d.]+)\s*\)$/.exec(color);

  if (slashed) {
    return Number(slashed[1]);
  }

  const parts = /^\w+\(([^)]*)\)$/.exec(color)?.[1].split(',') ?? [];

  return parts.length === 4 ? Number(parts[3]) : 1;
}

/** The shell a field's light is drawn on, marked by the test's own class. */
function litShell(): HTMLElement {
  return document.querySelector('.lit-under-test') as HTMLElement;
}

/** Waits out whatever the last change set easing, so a value is read settled. */
async function settle(element: HTMLElement): Promise<void> {
  await Promise.all(element.getAnimations({ subtree: true }).map((one) => one.finished));
}

describe('the interaction light', () => {
  // A control is rendered at the top of the page, which is where an earlier
  // file can leave the real mouse. A bloom under it starts easing in, and a
  // test that reads the light at rest would read it part of the way up.
  beforeEach(async () => {
    await commands.parkPointer();
  });

  it('resolves a colour on a key, whose slots come from `controlSlots`', async () => {
    const screen = await render(<PlButton>Save</PlButton>);
    const key = screen.getByRole('button').element() as HTMLElement;
    const bloom = getComputedStyle(key, '::before');

    expect(bloom.content).toBe('""');
    // Nothing is painted until a pointer arrives, which is what makes a page of
    // controls nobody is touching free.
    expect(bloom.opacity).toBe('0');
    expect(getComputedStyle(key).position).toBe('relative');
    expect(firstStop(bloom)).not.toBe('rgba(0, 0, 0, 0)');
  });

  it('resolves one on a field, whose slots come from `fieldSlots`', async () => {
    await render(<PlTextField label="City" classNames={{ control: 'lit-under-test' }} />);

    const shell = document.querySelector('.lit-under-test') as HTMLElement;
    const bloom = getComputedStyle(shell, '::before');

    expect(bloom.content).toBe('""');
    expect(bloom.opacity).toBe('0');
    expect(getComputedStyle(shell).position).toBe('relative');
    expect(firstStop(bloom)).not.toBe('rgba(0, 0, 0, 0)');
  });

  it('moves both layers to wherever the pointer was written', async () => {
    await render(<PlTextField label="City" classNames={{ control: 'lit-under-test' }} />);

    const shell = document.querySelector('.lit-under-test') as HTMLElement;
    const centred = getComputedStyle(shell, '::before').backgroundImage;

    shell.dispatchEvent(
      new PointerEvent('pointermove', { bubbles: true, clientX: 42, clientY: 11 })
    );

    const moved = getComputedStyle(shell, '::before').backgroundImage;
    const flash = getComputedStyle(shell, '::after').backgroundImage;

    expect(moved).not.toBe(centred);
    // Both read the same two slots, so the press lands where the bloom is
    // rather than in the middle of the box.
    expect(/at ([\d.]+px [\d.]+px)/.exec(moved)?.[1]).toBe(
      /at ([\d.]+px [\d.]+px)/.exec(flash)?.[1]
    );
  });

  it('paints the bloom under what is written on the surface and the flash over it', async () => {
    const screen = await render(<PlButton>Save</PlButton>);
    const key = screen.getByRole('button').element() as HTMLElement;

    // A positioned pseudo-element paints above in-flow content, so without the
    // negative depth the bloom is laid over the label — faint on a white one and
    // not on dark ink, which is what a field is written in.
    expect(getComputedStyle(key, '::before').zIndex).toBe('-1');
    expect(getComputedStyle(key, '::after').zIndex).toBe('auto');
    // And the depth only means anything inside a stacking context the surface
    // owns; without one it falls through to whatever ancestor has the nearest.
    expect(getComputedStyle(key).isolation).toBe('isolate');
  });

  it('gives a segment the light of whatever it is standing on', async () => {
    await render(
      <PlSegmentedButton variant="solid" defaultValue="day">
        <PlSegment value="day">Day</PlSegment>
        <PlSegment value="week">Week</PlSegment>
      </PlSegmentedButton>
    );

    const [chosen, other] = [...document.querySelectorAll('[data-segment]')] as HTMLElement[];

    // The chosen one rides the tile, which on `solid` is a coloured fill and
    // takes white light. The other sits on the trough, which is a sheet, and
    // white light on a near-white sheet is nothing at all.
    expect(getComputedStyle(chosen).getPropertyValue('--p-glow')).not.toBe(
      getComputedStyle(other).getPropertyValue('--p-glow')
    );
    expect(getComputedStyle(other, '::before').backgroundImage).not.toContain('rgba(0, 0, 0, 0),');
  });

  it('lights a field more faintly than a key of the same family', async () => {
    const screen = await render(
      <>
        <PlButton variant="glass">Save</PlButton>
        <PlTextField label="City" classNames={{ control: 'lit-under-test' }} />
      </>
    );
    const key = screen.getByRole('button', { name: 'Save' }).element() as HTMLElement;

    // Both read the family's own soft tint; the field reads it mixed down, so
    // the bloom under a sentence being typed does not compete with the ink.
    expect(alphaOf(firstStop(getComputedStyle(litShell(), '::before')))).toBeLessThan(
      alphaOf(firstStop(getComputedStyle(key, '::before')))
    );
  });

  it("puts a field's bloom away while it is typed into, and brings it back on a move", async () => {
    const screen = await render(
      <PlTextField label="City" classNames={{ control: 'lit-under-test' }} />
    );
    const shell = litShell();
    const field = screen.getByRole('textbox');

    await userEvent.hover(field);
    await settle(shell);
    expect(getComputedStyle(shell, '::before').opacity).toBe('1');

    // The hand has left the mouse for the keyboard. The light is no longer
    // following anything, and what it is doing is sitting under the words.
    await userEvent.click(field);
    await userEvent.keyboard('Seoul');
    await settle(shell);

    expect(shell).toHaveAttribute('data-quiet');
    expect(getComputedStyle(shell, '::before').opacity).toBe('0');

    // And back the moment the pointer is a pointer again. Parked first, so the
    // move that follows is a real one rather than a hover onto the same spot.
    await commands.parkPointer();
    await userEvent.hover(field);
    await settle(shell);

    expect(shell).not.toHaveAttribute('data-quiet');
    expect(getComputedStyle(shell, '::before').opacity).toBe('1');
  });

  it.each([
    [
      'PlTextField',
      <PlTextField label="City" classNames={{ control: 'lit-under-test' }} />,
      'textbox',
      'a'
    ],
    [
      'PlNumberField',
      <PlNumberField label="Age" value={null} classNames={{ control: 'lit-under-test' }} />,
      'textbox',
      // A digit, because a number field refuses a letter and stops the key
      // where it lands — nothing was typed, so nothing should have dimmed.
      '5'
    ],
    [
      'PlCombobox',
      <PlCombobox
        label="City"
        items={[{ value: 'kr-11', label: 'Seoul' }]}
        classNames={{ control: 'lit-under-test' }}
      />,
      'combobox',
      'a'
    ]
  ] as const)(
    'reaches the shell of a %s, whose control is a Base UI part',
    async (_name, field, role, key) => {
      const screen = await render(field);

      await expect.element(screen.getByRole(role)).toBeInTheDocument();

      // The shell is not the control, so the key has to *bubble* to it. Base UI
      // owns the element in the middle on two of these three.
      screen
        .getByRole(role)
        .element()
        .dispatchEvent(new KeyboardEvent('keydown', { key, bubbles: true }));

      await expect.poll(() => litShell().hasAttribute('data-quiet')).toBe(true);
    }
  );

  it('draws no layers at all on a field that is locked', async () => {
    await render(<PlTextField label="City" disabled classNames={{ control: 'lit-under-test' }} />);

    const shell = document.querySelector('.lit-under-test') as HTMLElement;

    expect(getComputedStyle(shell, '::before').content).toBe('none');
  });
});
