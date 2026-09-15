import { describe, expect, it } from 'vitest';
import { textOf } from '../../src/internal/text';

/** A component, to stand for anything that only decides what it draws when it renders. */
function Badge() {
  return <span>New</span>;
}

describe('textOf', () => {
  it('reads a string and a number as themselves', () => {
    expect(textOf('Guide')).toBe('Guide');
    expect(textOf(42)).toBe('42');
  });

  it('joins a list with nothing between its parts', () => {
    expect(textOf(['Ship ', 'faster'])).toBe('Ship faster');
  });

  it('walks into an element for its text and leaves the markup behind', () => {
    expect(
      textOf(
        <span>
          Ship <strong>faster</strong>
        </span>
      )
    ).toBe('Ship faster');
  });

  it('has nothing to say about what is not text', () => {
    expect(textOf(null)).toBe('');
    expect(textOf(undefined)).toBe('');
    expect(textOf(false)).toBe('');
  });

  it('reads nothing out of a component, which has not drawn anything yet', () => {
    // A picture of a thing is not its name, and what a component draws is only
    // decided when it renders.
    expect(textOf(<Badge />)).toBe('');
    expect(textOf(<span>Docs</span>)).toBe('Docs');
  });
});
