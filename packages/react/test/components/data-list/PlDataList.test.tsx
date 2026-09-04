import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlDataList, PlDataListItem } from 'plass-ui';

function list(): HTMLElement {
  return document.querySelector<HTMLElement>('.list-under-test')!;
}

function rows(): HTMLElement[] {
  return Array.from(list().querySelectorAll<HTMLElement>(':scope > div'));
}

describe('PlDataList', () => {
  describe('the markup', () => {
    it('is a real description list', async () => {
      await render(
        <PlDataList className="list-under-test">
          <PlDataListItem label="Owner" value="Ada Lovelace" />
        </PlDataList>
      );

      // The whole reason it is a component: a `<dl>` says that "Owner" names
      // "Ada Lovelace", where a grid of `<div>`s says nothing at all.
      expect(list().tagName).toBe('DL');
      expect(list().querySelector('dt')!.textContent).toBe('Owner');
      expect(list().querySelector('dd')!.textContent).toBe('Ada Lovelace');
    });

    it('groups each pair in a `<div>`, which is what lets a row be laid out', async () => {
      await render(
        <PlDataList className="list-under-test">
          <PlDataListItem label="Owner" value="Ada" />
          <PlDataListItem label="Plan" value="Team" />
        </PlDataList>
      );

      expect(rows().length).toBe(2);
      expect(rows()[0].querySelector('dt')).not.toBeNull();
      expect(rows()[0].querySelector('dd')).not.toBeNull();
    });

    it('takes the value as children when it is more than a string', async () => {
      const screen = await render(
        <PlDataList className="list-under-test">
          <PlDataListItem label="Owner">
            <a href="/ada">Ada Lovelace</a>
          </PlDataListItem>
        </PlDataList>
      );

      await expect.element(screen.getByRole('link')).toHaveAttribute('href', '/ada');
    });
  });

  describe('orientation', () => {
    it('puts the label beside the value by default', async () => {
      await render(
        <PlDataList className="list-under-test">
          <PlDataListItem label="Owner" value="Ada" />
        </PlDataList>
      );

      expect(rows()[0].classList.contains('flex-row')).toBe(true);
      // A label column measured in a length rather than left to the longest
      // label, so two panels on one screen line up.
      expect(rows()[0].querySelector<HTMLElement>('dt')!.style.width).toBe('10rem');
    });

    it('stacks them when it was told to, and drops the label column', async () => {
      await render(
        <PlDataList className="list-under-test" orientation="vertical">
          <PlDataListItem label="Owner" value="Ada" />
        </PlDataList>
      );

      expect(rows()[0].classList.contains('flex-col')).toBe(true);
      expect(rows()[0].querySelector<HTMLElement>('dt')!.style.width).toBe('');
    });

    it('takes any length for the label column', async () => {
      await render(
        <PlDataList className="list-under-test" labelWidth="12ch">
          <PlDataListItem label="Owner" value="Ada" />
        </PlDataList>
      );

      // A label column is measured in characters, which no ladder of `rem` can
      // spell.
      expect(rows()[0].querySelector<HTMLElement>('dt')!.style.width).toBe('12ch');
    });

    it('takes a number as pixels', async () => {
      await render(
        <PlDataList className="list-under-test" labelWidth={96}>
          <PlDataListItem label="Owner" value="Ada" />
        </PlDataList>
      );

      expect(rows()[0].querySelector<HTMLElement>('dt')!.style.width).toBe('96px');
    });
  });

  describe('divider', () => {
    it('draws none unless it was asked for one', async () => {
      await render(
        <PlDataList className="list-under-test">
          <PlDataListItem label="Owner" value="Ada" />
          <PlDataListItem label="Plan" value="Team" />
        </PlDataList>
      );

      expect(rows()[1].className).not.toContain('border-t');
    });

    it('rules between the rows and not above the first', async () => {
      await render(
        <PlDataList className="list-under-test" divider>
          <PlDataListItem label="Owner" value="Ada" />
          <PlDataListItem label="Plan" value="Team" />
        </PlDataList>
      );

      expect(rows()[1].className).toContain('border-t');
      expect(rows()[0].className).toContain('first:border-t-0');
    });
  });

  describe('the axes', () => {
    it('hands the size and the density down to every row', async () => {
      await render(
        <PlDataList className="list-under-test" size="sm" density="compact">
          <PlDataListItem label="Owner" value="Ada" />
        </PlDataList>
      );

      expect(list().className).toContain('text-[0.8125rem]');
    });

    it('hides an icon from a screen reader, since the label already says it', async () => {
      await render(
        <PlDataList className="list-under-test">
          <PlDataListItem label="Owner" value="Ada" icon={<svg viewBox="0 0 16 16" />} />
        </PlDataList>
      );

      expect(rows()[0].querySelector('dt > span')!.getAttribute('aria-hidden')).toBe('true');
    });
  });
});
