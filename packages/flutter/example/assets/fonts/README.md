# Inter, Latin subset

Two weights of [Inter](https://rsms.me/inter/) v4.1, cut down to Latin.

**They are here because of a rendering artefact, not a design preference.** Flutter
ships one font face with the engine — Roboto **Regular** — and synthesises every
other weight by widening its strokes. `PlButton` sets its label to weight 600, so
in a gallery with no font of its own every label came out as faux-bold: thicker
than the design asks for, and visibly smeared. Roboto cannot fix it either; the
family goes 400 → 500 → 700 with no 600 in it.

Inter has a real SemiBold, and it is also the closest of the open families to the
`system-ui` the React previews are drawn in — which is what makes the two halves
of a component page comparable.

Subset with `pyftsubset` to `U+0000-00FF` plus the usual punctuation and symbol
ranges, which takes 830 KB of TTF down to about 130 KB. The demos are written in
English; anything outside the subset falls back to the engine's own font.

Licensed under the SIL Open Font License 1.1 — see `OFL.txt`, which has to travel
with the files.
