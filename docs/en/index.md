---
layout: home

title: Plass
titleTemplate: The glass-and-gradient component library for React and Flutter
description: A component library made of glass and gradients — smooth tinted surfaces, shadows in their own colour, and light that follows the pointer. One design language shipped for React and for Flutter, with dark mode, accessibility and types already in the box.

hero:
  name: Plass
  text: Smooth glass with a turn of colour
  tagline: One design language, shipped for React and for Flutter. A material rather than a theme, with dark mode, accessibility and types already in the box.
  actions:
    - theme: brand
      text: Get started
      link: /guide/getting-started
    - theme: alt
      text: All components
      link: /components/
    - theme: alt
      text: Design language
      link: /design/design-language
  image:
    src: /logo-32.png
    alt: Plass

features:
  - title: Two materials, one language
    details: A tinted pane you press, and a blurred sheet that holds things. Every component is one or the other, and that is the whole design system.
    link: /design/design-language
    linkText: Design language
  - title: Two frameworks, one library
    details: The same hundred and twenty-two components in React and in Flutter — same props, same tokens, same numbers. One page documents both.
  - title: Dark mode built in
    details: Follows the platform, and can be forced either way on any subtree. No second theme to write, no colours to redeclare.
  - title: One shared vocabulary
    details: size, color, variant, density, elevation. An md means the same thing on every component, in either framework.
    link: /design/prop-conventions
    linkText: Prop conventions
---

## Why Plass

<div class="plass-why">
  <div class="plass-why-card">
    <h3>A material, not a theme file</h3>
    <p>Every surface answers one question — is this pressed, or does it hold something? The answer decides the fill, the edge, the shadow and the press.</p>
  </div>
  <div class="plass-why-card">
    <h3>No relief, no lacquer</h3>
    <p>No bevels and no highlights. A gradient that turns in hue carries the form, and a soft bloom follows your pointer across the control.</p>
  </div>
  <div class="plass-why-card">
    <h3>Tested, not asserted</h3>
    <p>Every component carries its own tests, run on every change: the React package in a real browser across three engines, the Flutter package as widget tests, both on three operating systems.</p>
  </div>
  <div class="plass-why-card">
    <h3>Accessible by default</h3>
    <p>Roles, labels, keyboard operation and focus management live inside the components rather than being bolted on later.</p>
  </div>
  <div class="plass-why-card">
    <h3>Contrast that was checked</h3>
    <p>Every gradient stop clears 4.5:1 against its own label — including the lightest corner, which is what fixes the fill lightness.</p>
  </div>
  <div class="plass-why-card">
    <h3>Nothing you did not ask for</h3>
    <p>The npm package is ESM and tree-shakeable, so only what you import is bundled — and its second dependency, the syntax highlighter, arrives only when a code block asks for it. The pub package has none at all, and no assets or plugins either.</p>
  </div>
  <div class="plass-why-card">
    <h3>No build-side setup</h3>
    <p>React is one package and one CSS import — Tailwind builds this library, not yours. Flutter is the package and nothing else: no stylesheet, no provider.</p>
  </div>
</div>

## Component preview

What follows is running inside this page — the React build, because a Flutter frame is a whole engine. Type into it, and press save.

<Demo src="showcase/app" :flutter="false" :min-height="420" />

Per-component props and examples are under [Components](./components/). Installing and wiring it up is one page: [Getting started](./guide/getting-started).
