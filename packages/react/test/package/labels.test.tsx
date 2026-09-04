/**
 * That the library's own vocabulary is one set, and that a translation of it
 * reaches every component.
 *
 * A test of the *package* rather than of a component, like the two beside it:
 * the failure it guards is a word that quietly stays English in one place while
 * the rest of the interface is translated, and no component test would see
 * that.
 */
import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlAlert, PlPagination, PlassProvider, defaultLabels } from 'plass-ui';
import * as locales from '../../src/locales/index.js';

const packs = Object.entries(locales);

describe('the label set', () => {
  it('ships more than one language', () => {
    expect(packs.length).toBeGreaterThan(1);
  });

  it.each(packs)('%s answers every key and invents none', (_name, pack) => {
    // A type error catches a missing key at build time; this catches the other
    // half — a key that was renamed in the set and left behind in a pack.
    expect(Object.keys(pack).sort()).toEqual(Object.keys(defaultLabels).sort());
  });

  it.each(packs)('%s translates every one of them', (name, pack) => {
    if (name === 'en') {
      return;
    }

    const untranslated = Object.entries(pack).filter(
      ([key, value]) => value === defaultLabels[key as keyof typeof defaultLabels]
    );

    // A handful of strings genuinely survive translation — `AM/PM`, `Overlay`,
    // `Minute` — so the check is that a pack is a translation rather than a
    // copy, not that every single word differs.
    expect(untranslated.length).toBeLessThan(6);
  });
});

describe('a translated provider', () => {
  it('reaches a component that says a word of its own', async () => {
    await render(
      <PlassProvider labels={locales.ko}>
        <PlAlert className="alert-under-test" onClose={() => {}}>
          저장했습니다
        </PlAlert>
      </PlassProvider>
    );

    expect(document.querySelector('.alert-under-test button')?.getAttribute('aria-label')).toBe(
      '닫기'
    );
  });

  it('reaches every word of a component that says several', async () => {
    await render(
      <PlassProvider labels={locales.ko}>
        <PlPagination className="pager-under-test" count={10} page={5} />
      </PlassProvider>
    );

    const names = Array.from(document.querySelectorAll('.pager-under-test [aria-label]')).map(
      (one) => one.getAttribute('aria-label')
    );

    expect(names).toContain('이전 페이지');
    expect(names).toContain('다음 페이지');
  });

  it('leaves a word the pack did not answer in English', async () => {
    await render(
      <PlassProvider labels={{ close: '닫기' }}>
        <PlAlert className="alert-under-test" onClose={() => {}}>
          Saved
        </PlAlert>
      </PlassProvider>
    );

    // `labels` is a partial: replacing one string does not mean owning the
    // other sixty. An alert's × is `dismiss`, not `close`.
    expect(document.querySelector('.alert-under-test button')?.getAttribute('aria-label')).toBe(
      'Dismiss'
    );
  });

  it("still loses to the component's own prop", async () => {
    await render(
      <PlassProvider labels={locales.ko}>
        <PlAlert className="alert-under-test" onClose={() => {}} closeLabel="지금은 그만">
          저장했습니다
        </PlAlert>
      </PlassProvider>
    );

    // Three layers, narrowest last: English, the application's, the component's.
    expect(document.querySelector('.alert-under-test button')?.getAttribute('aria-label')).toBe(
      '지금은 그만'
    );
  });
});
