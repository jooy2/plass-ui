/**
 * The arithmetic behind `PlAnimateScramble`, and the one decision in it worth
 * writing down.
 *
 * **The pool a character is drawn from is the text's own characters**, not a
 * table of Latin letters. Every scrambler that ships with a default alphabet
 * ships an English one, and English noise over a Korean, Greek or Arabic
 * headline is not a word resolving — it is a different script flickering where
 * a word is about to be. Shuffling the string's own glyphs is script-agnostic
 * for nothing, and it also keeps the line's colour and width steady, because
 * every frame is drawn out of exactly the characters the finished line is made
 * of.
 *
 * `characters` overrides it for the caller who genuinely wants a terminal look.
 */

/** Everything in the text that is worth scrambling: no spaces, no repeats. */
export function poolOf(text: string): string {
  const seen = new Set<string>();

  for (const character of text) {
    if (character.trim() !== '') {
      seen.add(character);
    }
  }

  return Array.from(seen).join('');
}

/**
 * The line as it looks part of the way through.
 *
 * `progress` is `0`…`1`, and what it decides is **how many characters have
 * settled**, counted from the start. Resolving left to right rather than at
 * random is what makes it read as a word arriving rather than as a slot
 * machine: a reader can follow it, and a reader who looks away and back has not
 * lost their place.
 *
 * Whitespace is never scrambled. The gaps between words are what makes a line
 * of noise still look like a sentence, and a space that flickers into a letter
 * changes the word count on every frame.
 */
export function scrambleAt(text: string, pool: string, progress: number, seed: number): string {
  const characters = Array.from(text);
  const settled = Math.floor(characters.length * Math.max(0, Math.min(1, progress)));

  if (pool.length === 0) {
    return text;
  }

  return characters
    .map((character, index) => {
      if (index < settled || character.trim() === '') {
        return character;
      }

      // A seed rather than `Math.random`, so one frame is one draw for the
      // whole line and a re-render mid-frame does not reshuffle what has
      // already been painted.
      return pool[(index * 31 + seed * 17) % pool.length];
    })
    .join('');
}
