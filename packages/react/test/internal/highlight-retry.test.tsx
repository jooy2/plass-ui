import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-react';
import { PlCodeBlock } from 'plass-ui';
import { highlight } from '../../src/internal/highlight.js';

/**
 * Chunks that fail the first time they are asked for and arrive after that, the
 * way one does when the connection drops while it is in flight.
 *
 * The failure is in the chunk's default export rather than in the import: a
 * `vi.mock` factory that throws takes the test runner down with it, and a
 * browser may keep a module that failed to load. The module code reads the
 * default export of every chunk it asks for, so a default export that is a
 * thenable failing once is, to that code, a chunk that failed once.
 */
const chunks = vi.hoisted(() => {
  const flaky = () => {
    const state = { asked: 0, real: undefined as unknown };

    return {
      state,
      thenable: {
        then(resolve: (value: unknown) => void, reject: (error: unknown) => void) {
          state.asked += 1;

          if (state.asked === 1) {
            reject(new TypeError('Failed to fetch dynamically imported module'));
          } else {
            resolve(state.real);
          }
        }
      }
    };
  };

  return { core: flaky(), python: flaky(), ruby: flaky() };
});

vi.mock('highlight.js/lib/core', async (importOriginal) => {
  const real = await importOriginal<typeof import('highlight.js/lib/core')>();

  chunks.core.state.real = real.default;

  return { ...real, default: chunks.core.thenable };
});

vi.mock('highlight.js/lib/languages/python', async (importOriginal) => {
  const real = await importOriginal<typeof import('highlight.js/lib/languages/python')>();

  chunks.python.state.real = real.default;

  return { ...real, default: chunks.python.thenable };
});

vi.mock('highlight.js/lib/languages/ruby', async (importOriginal) => {
  const real = await importOriginal<typeof import('highlight.js/lib/languages/ruby')>();

  chunks.ruby.state.real = real.default;

  return { ...real, default: chunks.ruby.thenable };
});

/** How many coloured runs the block with this test id draws. */
const coloured = (id: string) =>
  Array.from(document.querySelectorAll(`[data-testid="${id}"] [class*="hljs-"]`)).length;

describe('highlight, when a chunk does not arrive', () => {
  it('asks for the core again for the next block once it failed', async () => {
    await expect(highlight('let a = 1;', 'typescript')).rejects.toThrow(TypeError);

    const lines = await highlight('let b = 2;', 'typescript');

    expect(lines?.[0]).toContainEqual({ text: 'let', token: 'hljs-keyword' });
    expect(chunks.core.state.asked).toBe(2);
  });

  it('asks for a grammar again for the next block once it failed', async () => {
    await expect(highlight('def f(): pass', 'python')).rejects.toThrow(TypeError);

    const lines = await highlight('def g(): pass', 'python');

    expect(lines?.[0]).toContainEqual({ text: 'def', token: 'hljs-keyword' });
    expect(chunks.python.state.asked).toBe(2);
  });

  it('keeps a block plain while its chunk fails, and colours the next one', async () => {
    const one = <PlCodeBlock key="one" data-testid="one" code="def one; end" language="ruby" />;
    const screen = await render(one);

    // The failure lands in the same task as the ask, so by the time the poll
    // sees the ask the block has been told, and it still draws its words plain.
    await expect.poll(() => chunks.ruby.state.asked).toBe(1);
    expect(coloured('one')).toBe(0);
    await expect.element(screen.getByText('def one; end')).toBeVisible();

    await screen.rerender(
      <>
        {one}
        <PlCodeBlock key="two" data-testid="two" code="def two; end" language="ruby" />
      </>
    );

    await expect.poll(() => coloured('two')).toBeGreaterThan(0);
    // One more ask, for the block that needed it, and no colours put on the
    // block that failed: it is drawn plain until it is drawn again.
    expect(chunks.ruby.state.asked).toBe(2);
    expect(coloured('one')).toBe(0);
  });
});
