---
layout: home

title: Plass
titleTemplate: The glass-and-gradient React component library
description: A React component library made of glass and gradients — smooth tinted surfaces, shadows in their own colour, and light that follows the pointer. Dark mode, TypeScript types and one shared prop vocabulary, in a single install.

hero:
  name: Plass
  text: Smooth glass with a turn of colour
  tagline: A React component library with a material, not a theme. Dark mode, accessibility and types are already in the box.
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
    src: /logo.svg
    alt: Plass

features:
  - title: Two materials, one language
    details: A tinted pane you press, and a blurred sheet that holds things. Every component is one or the other, and that is the whole design system.
    link: /design/design-language
    linkText: Design language
  - title: TypeScript first
    details: Declarations ship with the package. Your editor knows the prop names and the values they take before you do.
  - title: Dark mode built in
    details: One class on an ancestor and every component follows. No second theme to write, no colours to redeclare.
  - title: One shared vocabulary
    details: size, color, variant, density, elevation. An md means the same thing on every component.
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
    <p>Every component carries its own tests, run in a real browser across three operating systems and three engines on every change.</p>
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
    <h3>Built for a modern front end</h3>
    <p>Published as ESM and tree-shakeable, so only what you import ends up in the bundle. One runtime dependency.</p>
  </div>
  <div class="plass-why-card">
    <h3>No build-side setup</h3>
    <p>One package, one CSS import. Tailwind builds this library; it does not have to be installed in yours.</p>
  </div>
</div>

## Component preview

What follows is running inside this page. Type into it, and press save.

<Demo src="showcase/app" :min-height="420" />

Per-component props and examples are under [Components](./components/). Installing and wiring it up is one page: [Getting started](./guide/getting-started).
