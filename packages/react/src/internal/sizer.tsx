import type * as React from 'react';

/**
 * Holds a control open at the width of the widest thing it could ever say.
 *
 * A control that is not `fullWidth` is sized by what it is *currently* saying,
 * which for anything whose value changes means the box changes with it. A
 * PlSelect showing `Seoul` is narrower than the same one showing
 * `Washington DC`. Either way the field moves under the pointer that just used
 * it, and the whole row of controls beside it shuffles along.
 *
 * So the alternatives are laid out too, stacked in a box clipped to no height.
 * The control's intrinsic width becomes the widest of them and stops depending
 * on the value.
 *
 * Three things it deliberately is not:
 *
 * - **Not `hidden`, and not `display: none`.** Both take the box out of layout,
 *   and a box that is not laid out reserves nothing.
 * - **Not read out.** `aria-hidden`, or a screen reader would announce every
 *   value the control might hold before the one it does.
 * - **Not text.** A string sample is drawn as generated content off a data
 *   attribute rather than as a text node. `content: attr(…)` lays out exactly
 *   like text, so it reserves the same width — but it leaves nothing for
 *   `getByText` or a screen reader's find-in-page to trip over, and a caller's
 *   test asking for the option they selected keeps finding one element rather
 *   than two. Only a sample that is not a string — an option whose label is a
 *   node — has to be rendered for real, because there is nothing to put in an
 *   attribute.
 */
export function WidthSizer({ samples }: { samples: readonly React.ReactNode[] }) {
  if (samples.length === 0) {
    return null;
  }

  return (
    <span aria-hidden="true" className="invisible h-0 min-h-0 overflow-hidden">
      {samples.map((sample, index) =>
        typeof sample === 'string' ? (
          <span
            key={`${index}:${sample}`}
            data-sample={sample}
            className="block whitespace-nowrap before:content-[attr(data-sample)]"
          />
        ) : (
          <span key={index} className="block whitespace-nowrap">
            {sample}
          </span>
        )
      )}
    </span>
  );
}
