---
title: PlSidebar
order: 9
---

# PlSidebar

<p class="plass-lede">A column beside the page's content, and a drawer once the window is too narrow to hold one. Two presentations of one panel, so a caller never swaps components at a breakpoint.</p>

<Demo src="sidebar/hero" :flutter="false" :min-height="360" />

::: fw react

```tsx
import { PlPageLayout, PlSidebar } from 'plass-ui';

<PlPageLayout sidebar={<PlSidebar label="Main navigation">{nav}</PlSidebar>}>{page}</PlPageLayout>;
```

:::

## Props

<PropsTable name="PlSidebar" />

::: fw react

Every native `<aside>` attribute passes straight through. `color` and `title` are excluded because both are Plass props here.

:::

### PlSidebarTrigger

<PropsTable name="PlSidebarTrigger" />

Everything else is [`PlIconButton`](../inputs/icon-button)'s, unchanged.

What the shared axes (`variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Two shapes, one panel

Above `collapseBelow` the sidebar is an `<aside>` in the layout that the content is laid out around. Below it, the same children are a [`PlDrawer`](../feedback/drawer) over a scrim, with a focus trap, an <kbd>Esc</kbd> and a way back to the trigger.

They are one component because they are one thing — and because the children then exist **once** either way, rather than being rendered twice into the document for a screen reader to read twice.

Which of the two is showing is a media query, and it is answered in CSS for the first paint and in JavaScript from then on. That split is deliberate: the markup a server sends is the column, so a narrow screen would draw a full-width sidebar and throw it away a moment later. The class that hides it below the breakpoint is what stops that; `matchMedia` is what decides, once there is a window to ask, that the drawer should exist at all.

## Examples

### side

Logical rather than physical: `start` is the left of an English page and the right of an Arabic one, because a navigation rail is beside the text it belongs to in every writing direction.

Inside a [`PlPageLayout`](./page-layout) it is already decided by which slot the sidebar was handed to, and setting it again is only a way of disagreeing with the layout.

<Demo src="sidebar/sides" :flutter="false" :min-height="260">

<<< @/.vitepress/demos/sidebar/sides.tsx

</Demo>

### collapseBelow

The window width below which the column becomes a drawer. It defaults to the layout's own `collapseBelow`, and to `none` outside a layout — a sidebar that collapsed with nothing on the page able to bring it back would be a sidebar the reader has lost.

`PlSidebarTrigger` is what brings it back. Put it in a [`PlHeader`](./header)'s `brand` slot, ahead of the logo, which is where thirty years of hamburgers have taught readers to look. It is hidden by the **same media query** rather than by a piece of state, so it is in the markup a server sends rather than popping into the header a moment after the page arrives.

`title` is drawn only while the sidebar is a drawer: a column has the page around it to say what it is, and a panel that has covered the page does not.

<Demo src="sidebar/collapse" :flutter="false" :min-height="300">

<<< @/.vitepress/demos/sidebar/collapse.tsx

</Demo>

### resizable

Off by default. A sidebar that can be resized is a sidebar whose width is the reader's to remember, so a caller who turns this on usually also stores what `onResizeEnd` reports.

The dragged width is written straight onto the element rather than into state: nothing in the tree depends on the number except one CSS declaration, and a `setState` per pointer move would re-render every row in the panel. The caller still hears every step through `onResize`.

The handle straddles the edge rather than sitting inside it — a hairline one pixel wide is a target one pixel wide — which is the same split between what is drawn and what can be grabbed that a scrollbar makes.

<Demo src="sidebar/resizable" :flutter="false" :min-height="260">

<<< @/.vitepress/demos/sidebar/resizable.tsx

</Demo>

### variant

The three materials, read the way a **container** reads them. The panel is never dyed: what is on a sidebar is somebody's navigation, and it arrives with colours of its own.

`divider` rules the **inner** edge — the one facing the content. The outer edge is against the window, where there is nothing on the other side to be separated from.

<Demo src="sidebar/variants" :flutter="false" :min-height="220">

<<< @/.vitepress/demos/sidebar/variants.tsx

</Demo>

### sticky

On by default, and it costs nothing when it is not needed. With the page scrolling, the column is `sticky` and as tall as what is left of the window under the header — which is what `--p-layout-header` and `--p-layout-footer` are measured for. With only the content scrolling, the column is already as tall as the layout and this changes nothing.

## Accessibility

- The column is a real `<aside>`, which is the `complementary` landmark.
- `label` is required in practice and defaults to `Sidebar`. A page with two sidebars **must** give each one a name, or a screen reader offers two regions called "complementary".
- Collapsed, it is a dialog: focus is trapped, <kbd>Esc</kbd> closes it, the page behind it is inert, and focus returns to whatever opened it. All of that is [`PlDrawer`](../feedback/drawer)'s, which is Base UI's.
- The trigger carries `aria-expanded`, so a screen reader is told whether the panel is open before it is pressed.
- The resize handle is a `role="separator"` with `aria-orientation="vertical"`, a tab stop while `resizable`, and moved by <kbd>←</kbd> <kbd>→</kbd>. A key press fires `onResizeEnd` as well as `onResize`, because it is a whole gesture on its own.
- A drag takes the page's text selection away as `-webkit-user-select` — the only name WebKit implements — rather than calling `preventDefault`, which would stop the browser focusing the handle.
