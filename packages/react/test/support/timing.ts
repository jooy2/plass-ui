import { act } from 'react';

/**
 * Runs `work` inside React's `act`, so every render it causes is committed by
 * the time this resolves. `act` does that only while the page says it is a test
 * environment, which `vitest-browser-react` says only for the length of its own
 * `render` and `rerender`, so it is said here for the length of this.
 */
export async function committed(work: () => void | Promise<void>): Promise<void> {
  const page = globalThis as { IS_REACT_ACT_ENVIRONMENT?: boolean };
  const was = page.IS_REACT_ACT_ENVIRONMENT;

  page.IS_REACT_ACT_ENVIRONMENT = true;

  try {
    await act(async () => {
      await work();
    });
  } finally {
    page.IS_REACT_ACT_ENVIRONMENT = was;
  }
}

/**
 * Takes the frame clock away from the page: every frame the page asks for waits
 * until the test draws it, and carries the time the test gives it.
 *
 * A component that reads the time only off the frames it is handed, as the
 * animated count and the scrambled line do, is then measured by its own clock
 * rather than by how long the runner took to deliver a render, a frame and a
 * poll.
 */
export function frameClock(): { draw: (now: number) => Promise<void>; restore: () => void } {
  const request = window.requestAnimationFrame;
  const cancel = window.cancelAnimationFrame;
  const asked = new Map<number, FrameRequestCallback>();
  let handles = 0;

  window.requestAnimationFrame = (callback) => {
    handles += 1;
    asked.set(handles, callback);

    return handles;
  };

  window.cancelAnimationFrame = (handle) => {
    asked.delete(handle);
  };

  return {
    /** Draws one frame at `now`, and waits for what it renders. */
    draw(now) {
      const due = [...asked.values()];

      asked.clear();

      return committed(() => {
        for (const callback of due) {
          callback(now);
        }
      });
    },
    restore() {
      window.requestAnimationFrame = request;
      window.cancelAnimationFrame = cancel;
    }
  };
}
