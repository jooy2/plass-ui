/**
 * The English for the label set's `loading`, on its own.
 *
 * `PlButton` says this one word and nothing else from the set, and a button is
 * the one component nearly every page imports. Reading it through `useLabels`
 * would put all of the English in `labels.ts` into every bundle that has a
 * button in it, and so would importing it from there: the set is shared with
 * code a bundler splits off, and it moves the whole module into the shared
 * chunk. So the word lives here, the button takes a provider's word from
 * `useDefaults` and falls back to this, and the set reads it from here too so
 * the two cannot disagree.
 */
export const loadingLabel = 'Loading';
