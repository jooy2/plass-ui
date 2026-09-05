---
layout: home

title: Plass
titleTemplate: The glass component library for React and Flutter
description: 127 components made of tinted glass and gradients, shipped for React and for Flutter under one design language. Dark mode, accessibility and types are included, and there is no theme file to fill in.

hero:
  name: Plass
  text: One design language, in React and in Flutter
  tagline: 127 components made of tinted glass and gradients. Dark mode, accessibility and types are included, and there is nothing to set up before the first screen.
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
  - title: Two frameworks, one library
    details: The same 127 components in React and in Flutter, under the same names, with the same props and the same numbers. One page documents both.
  - title: Finished when you install it
    details: The colours, shadows, blur and motion are already decided and already agree with each other. There is no theme file to fill in.
    link: /design/design-language
    linkText: Design language
  - title: Dark mode included
    details: It follows the platform and can be forced either way on any part of the page. No second palette to write.
  - title: Five props to learn
    details: size, color, variant, density and elevation mean the same thing everywhere, so the tenth component costs nothing to learn after the first.
    link: /design/prop-conventions
    linkText: Prop conventions
---

## Highlights

<div class="plass-why">
  <div class="plass-why-card">
    <h3>One material, two answers</h3>
    <p>Every surface is either a tinted pane you press or a clear sheet that holds something. That single question decides the fill, the edge, the shadow and the press.</p>
  </div>
  <div class="plass-why-card">
    <h3>No bevels, no highlights</h3>
    <p>A gradient that turns in hue carries the form, and a soft bloom follows your pointer across the control.</p>
  </div>
  <div class="plass-why-card">
    <h3>Accessible by default</h3>
    <p>Roles, labels, keyboard operation and focus management live inside the components rather than being added later.</p>
  </div>
  <div class="plass-why-card">
    <h3>Readable because it was measured</h3>
    <p>Every gradient stop clears 4.5:1 against its own label. A colour choice here is not a contrast bug waiting for an audit.</p>
  </div>
  <div class="plass-why-card">
    <h3>Tested on every change</h3>
    <p>Every component carries its own tests: the React package in real browsers, the Flutter package as widget tests, both on three operating systems.</p>
  </div>
  <div class="plass-why-card">
    <h3>Small by default</h3>
    <p>The npm package is ESM and tree-shakeable, so only what you import is bundled. The pub package has no dependencies at all.</p>
  </div>
  <div class="plass-why-card">
    <h3>One line to set up</h3>
    <p>React is one package and one CSS import. Flutter is the package and nothing else: no stylesheet, no provider.</p>
  </div>
</div>

## Component preview

Everything below is running in this page, in the React build. Type into it, and press save.

<Demo src="showcase/app" :flutter="false" :min-height="420" />

Every component has a page of its own under [Components](./components/), and setup is one page: [Getting started](./guide/getting-started).
