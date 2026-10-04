'use client';

import * as React from 'react';

/**
 * A part of a component that is a download of its own, and that steps back
 * rather than throwing when the download fails.
 *
 * Four components keep a piece most pages never show behind an `import()`:
 * `PlConfirmProvider` its dialog, `PlSidebar` the drawer it becomes on a narrow
 * window, `PlImage` its preview and `PlGallery` its viewer. `React.lazy` on its
 * own throws to the nearest error boundary when that chunk cannot be fetched —
 * a connection that dropped, or a deploy that replaced the chunk under a page
 * that was already open — and the boundary takes down everything it holds over
 * a part the reader may only have pointed at.
 *
 * So the import is tried a second time, and if that fails as well the part
 * renders nothing and says so once through `onUnavailable`, which is where the
 * component that asked for it steps back: closes what it was opening, answers
 * what it was asking. A failed attempt is forgotten, so the next mount tries
 * again. Chromium keeps a module whose fetch failed for the life of the page,
 * so there a second try, now or later, fails at once without a request; Firefox
 * and WebKit fetch it again.
 */

/** A part's own props, and the one it adds. */
export type LazyPartProps<P> = P & {
  /** Called once, after the second try has failed. The part then renders nothing. */
  onUnavailable?: () => void;
};

export interface LazyPart<P> {
  (props: LazyPartProps<P>): React.ReactElement;
  /** Starts the download without rendering anything. A failure is kept quiet. */
  preload: () => void;
}

/**
 * What a part renders once it knows it cannot have its chunk.
 *
 * It says so from a layout effect, so the owner's answer — taking the part away
 * — is rendered before the browser handles anything else. Told from a passive
 * effect, the news can wait for the next event, and WebKit does hold it until
 * then: the press meant to be the next try lands in the same render as the
 * failure, the part never leaves, and that press and every later one open
 * nothing.
 */
function Unavailable({ onUnavailable }: { onUnavailable?: () => void }) {
  const told = React.useRef(false);

  React.useLayoutEffect(() => {
    if (told.current) return;

    told.current = true;
    onUnavailable?.();
  });

  return null;
}

/**
 * `React.lazy` with one retry and a quiet failure. Render the result inside a
 * `Suspense` as a lazy component would be, and unmount it when it reports
 * `onUnavailable`, so that the next mount is the next attempt.
 */
export function lazyPart<P extends object>(
  load: () => Promise<React.ComponentType<P>>
): LazyPart<P> {
  let pending: Promise<React.ComponentType<P> | null> | null = null;

  // One download at a time, shared by a preload and a render. A download that
  // failed twice is dropped, so the next one asks the network again.
  const download = () => {
    pending ??= load()
      .catch(() => load())
      .catch(() => {
        pending = null;

        return null;
      });

    return pending;
  };

  type Attempt = React.LazyExoticComponent<React.ComponentType<LazyPartProps<P>>>;

  const attempt = (): Attempt => {
    const lazy: Attempt = React.lazy(async () => {
      const Loaded = await download();

      if (!Loaded) {
        // The attempt is retired once the failure has been committed, not when
        // it is known: a part that suspended has not mounted yet, so it would
        // pick a fresh attempt up on its retry and set off another download,
        // and another after that.
        const retire = () => {
          if (latest === lazy) latest = attempt();
        };

        function Failed({ onUnavailable }: LazyPartProps<P>) {
          return (
            <Unavailable
              onUnavailable={() => {
                retire();
                onUnavailable?.();
              }}
            />
          );
        }

        return { default: Failed };
      }

      const Component: React.ComponentType<P> = Loaded;

      function Ready(
        // Named only to take it out of the rest, which the part itself would
        // otherwise hand on to the DOM as an attribute nobody knows.
        // eslint-disable-next-line @typescript-eslint/no-unused-vars
        { onUnavailable, ...props }: LazyPartProps<P>
      ) {
        return <Component {...(props as P)} />;
      }

      return { default: Ready };
    });

    return lazy;
  };

  let latest = attempt();

  function Part(props: LazyPartProps<P>) {
    // The attempt this mount started with, kept for as long as it is mounted:
    // a part that failed is taken away by its owner, not retried in a loop,
    // and the next mount starts the next attempt.
    const [Current] = React.useState(() => latest);

    return <Current {...props} />;
  }

  Part.preload = () => {
    void download();
  };

  return Part;
}
