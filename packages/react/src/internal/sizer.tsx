/**
 * Holds a control open at the width of the widest thing it could ever say.
 *
 * A control that is not `fullWidth` is sized by what it is *currently* saying,
 * which for anything whose value changes means the box changes with it. A
 * PlSelect showing `Seoul` is narrower than the same one showing
 * `Washington DC`. Either way the field moves under the pointer that just used
 * it, and the whole row of controls beside it shuffles along.
 *
 * So the alternatives are laid out too, one to a line in a box clipped to no
 * height. The control's intrinsic width becomes the widest line and stops
 * depending on the value.
 *
 * The lines are one element. Every sample goes into one attribute, a newline
 * between each two, and `white-space: pre` breaks the line there and nowhere
 * else, so the box is as wide as its widest line. An element per sample drew
 * the same box and cost a select of 250 countries 250 elements, each with a
 * generated box of its own to style and lay out.
 *
 * Three things it deliberately is not:
 *
 * - **Not `hidden`, and not `display: none`.** Both take the box out of layout,
 *   and a box that is not laid out reserves nothing.
 * - **Not read out.** `aria-hidden`, or a screen reader would announce every
 *   value the control might hold before the one it does.
 * - **Not text.** The samples are drawn as generated content off a data
 *   attribute rather than as a text node. `content: attr(…)` lays out exactly
 *   like text, so it reserves the same width — but it leaves nothing for
 *   `getByText` or a screen reader's find-in-page to trip over, and a caller's
 *   test asking for the option they selected keeps finding one element rather
 *   than two.
 *
 * Which is why a sample is a string and never a node. A label that is a node
 * reaches here as its text, through `textOf`: laid out for real, a list of
 * countries with a flag in each would ask for every flag to hold one field
 * open, and a picture carries no width a reader could not do without.
 */
export function WidthSizer({ samples }: { samples: readonly string[] }) {
  if (samples.length === 0) {
    return null;
  }

  return (
    <span
      aria-hidden="true"
      data-sample={samples.map(oneLine).join('\n')}
      className="invisible block h-0 min-h-0 overflow-hidden whitespace-pre before:content-[attr(data-sample)]"
    />
  );
}

/**
 * A sample as the line the browser lays out from it.
 *
 * `pre` keeps every space it is given, and a sample used to be drawn with
 * `nowrap`, which keeps none it does not need: a run of spaces, tabs and line
 * breaks is one space there, and none is left at either end of the line. Doing
 * the same here first is what keeps a label with a stray space or a line break
 * in it exactly as wide as it was. A no-break space is not white space to CSS,
 * so it stays, as it would have.
 */
function oneLine(sample: string): string {
  return sample.replace(/[ \t\n\r]+/g, ' ').replace(/^ | $/g, '');
}
