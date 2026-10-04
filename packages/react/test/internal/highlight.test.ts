import { describe, expect, it, vi } from 'vitest';
import type { HighlightOptions } from 'highlight.js';
import { highlight } from '../../src/internal/highlight.js';

/**
 * The two chunks a TypeScript block needs, each held at the door until the test
 * lets it through, and the order they were asked for in.
 *
 * The core is fetched once per page, so the test that watches it being asked
 * for comes first in this file and every later one finds it loaded.
 */
const chunks = vi.hoisted(() => {
  const gate = () => {
    let open = () => {};
    const shut = new Promise<void>((resolve) => {
      open = resolve;
    });

    return { shut, open };
  };

  return { asked: [] as string[], core: gate(), grammar: gate() };
});

vi.mock('highlight.js/lib/core', async (importOriginal) => {
  chunks.asked.push('core');
  await chunks.core.shut;

  return importOriginal();
});

vi.mock('highlight.js/lib/languages/typescript', async (importOriginal) => {
  chunks.asked.push('typescript');
  await chunks.grammar.shut;

  return importOriginal();
});

/** Puts `value` in place of the browser's `scheduler` and hands back the undo. */
function replaceScheduler(value: unknown): () => void {
  const before = Object.getOwnPropertyDescriptor(globalThis, 'scheduler');

  Object.defineProperty(globalThis, 'scheduler', { configurable: true, writable: true, value });

  return () => {
    if (before) Object.defineProperty(globalThis, 'scheduler', before);
    else delete (globalThis as { scheduler?: unknown }).scheduler;
  };
}

/**
 * A `scheduler.yield` that gives the turn back only when the test says so, with
 * every turn it was asked for in `turns`. `undo` puts the browser's back and
 * lets every turn still held go, so a test that failed half way does not leave
 * the next one queued behind it.
 */
function heldScheduler() {
  const turns: (() => void)[] = [];
  const replaced = replaceScheduler({
    yield: () => new Promise<void>((resolve) => turns.push(resolve))
  });

  return {
    turns,
    undo: () => {
      replaced();
      turns.forEach((resolve) => resolve());
    }
  };
}

/** The core the module loaded, with `highlight` counted. */
async function countedCore() {
  const hljs = (await import('highlight.js/lib/core')).default;
  const original = hljs.highlight.bind(hljs);
  const calls: string[] = [];
  const counted = (code: string, options: HighlightOptions) => {
    calls.push(code);

    return original(code, options);
  };
  // The cast picks the overload the module calls, out of the two `highlight` has.
  const spy = vi.spyOn(hljs, 'highlight').mockImplementation(counted as typeof hljs.highlight);

  return { calls, restore: () => spy.mockRestore() };
}

describe('highlight', () => {
  it('asks for the core and the grammar at once', async () => {
    const lines = highlight('const a = 1;', 'typescript');

    try {
      // Neither has arrived, and both have been asked for.
      await expect.poll(() => chunks.asked).toEqual(['core', 'typescript']);
    } finally {
      // Let through whatever happens, or every test after this one waits on it.
      chunks.core.open();
      chunks.grammar.open();
    }

    expect((await lines)?.[0]).toContainEqual({ text: 'const', token: 'hljs-keyword' });
  });

  it('colours one block a turn, and gives the browser the thread before each', async () => {
    const { turns, undo } = heldScheduler();
    const { calls, restore } = await countedCore();

    try {
      const first = highlight('let a = 1;', 'typescript');
      const second = highlight('let b = 2;', 'typescript');

      await expect.poll(() => turns.length).toBe(1);
      expect(calls).toEqual([]);

      turns[0]();
      await first;

      // The second block is still waiting for a turn of its own.
      expect(calls).toEqual(['let a = 1;']);
      await expect.poll(() => turns.length).toBe(2);
      expect(calls).toEqual(['let a = 1;']);

      turns[1]();

      expect((await second)?.[0]).toContainEqual({ text: 'let', token: 'hljs-keyword' });
      expect(calls).toEqual(['let a = 1;', 'let b = 2;']);
    } finally {
      restore();
      undo();
    }
  });

  it('colours nothing for a block that went away while it waited', async () => {
    const { turns, undo } = heldScheduler();
    const { calls, restore } = await countedCore();
    const gone = new AbortController();

    try {
      const first = highlight('let a = 1;', 'typescript', gone.signal);
      const second = highlight('let b = 2;', 'typescript');

      await expect.poll(() => turns.length).toBe(1);
      gone.abort();
      turns[0]();

      expect(await first).toBeNull();
      await expect.poll(() => turns.length).toBe(2);
      turns[1]();

      expect(await second).not.toBeNull();
      expect(calls).toEqual(['let b = 2;']);
    } finally {
      restore();
      undo();
    }
  });

  it('takes a task per block where there is no `scheduler.yield`', async () => {
    const undo = replaceScheduler(undefined);
    const { calls, restore } = await countedCore();
    let byTheEndOfTheFirst: string[] | null = null;

    try {
      const first = highlight('let a = 1;', 'typescript').then((lines) => {
        // Queued behind the first block's colouring. In the same task as the
        // second block's, this would run after it.
        queueMicrotask(() => {
          byTheEndOfTheFirst = [...calls];
        });

        return lines;
      });
      const second = highlight('let b = 2;', 'typescript');

      expect(await Promise.all([first, second])).not.toContain(null);
      expect(byTheEndOfTheFirst).toEqual(['let a = 1;']);
      expect(calls).toEqual(['let a = 1;', 'let b = 2;']);
    } finally {
      restore();
      undo();
    }
  });
});
