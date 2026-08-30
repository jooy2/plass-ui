---
title: PlPageLayout
order: 6
---

# PlPageLayout

<p class="plass-lede">The skeleton a page is hung on: a header, a footer, one sidebar or two, and the content between them. It draws no surface of its own — what it contributes is the arrangement and the landmarks.</p>

<Demo src="page-layout/hero" :flutter="false" :min-height="360" />

::: fw react

```tsx
import { PlPageLayout } from 'plass-ui';

<PlPageLayout header={<header>…</header>} sidebar={<nav>…</nav>} footer={<footer>…</footer>}>
  {page}
</PlPageLayout>;
```

:::

## Props

<PropsTable name="PlPageLayout" />

::: fw react

Every native `<div>` attribute passes straight through to the root. `color` is excluded because it is a Plass prop here.

:::

What the shared axes mean across the library is in [prop conventions](../../design/prop-conventions).

## What it is for

The landmarks. A page assembled out of `<div>`s is a page a screen reader offers as one undifferentiated region and a search engine reads as one undifferentiated blob; the same page built out of `<header>`, `<nav>`, `<aside>`, `<main>` and `<footer>` is a page with a table of contents.

Those tags come from the components this one arranges. What the layout itself contributes to the document is exactly one element, plus the `<main>` and the skip link that jumps to it.

It draws no gutter and no measure either. That is [`PlContainer`](./container)'s job — put one inside, where a page can have a wide dashboard on one route and a narrow article on the next.

## Examples

### headerSpan · footerSpan

Which of the header and the sidebars takes the top corner.

`full` is the arrangement of a website: one bar across the whole width, and the columns beginning underneath it. `content` is the arrangement of an application: the sidebars run the full height of the window and the bar sits between them, belonging to the view rather than to the site.

The footer answers the same question separately, because a dashboard with a full-height navigation rail still usually wants its copyright line under the content rather than under the rail.

<Demo src="page-layout/spans" :flutter="false" :min-height="260">

<<< @/.vitepress/demos/page-layout/spans.tsx

</Demo>

### scroll · height

`scroll="page"` is the default and is what almost every page wants: the document scrolls, the browser's own address bar hides on a phone, the scroll position is restored on a back navigation, and a `sticky` header holds its place without anything having to be padded out of its way.

`scroll="content"` takes the layout to exactly the height of the window and scrolls only the region between the bars. Reach for it when the page is a workspace rather than a document.

`height` is `viewport` by default, `auto` for a layout that is not the page — a preview, a pane of a larger tool — or any CSS length. It is a floor while the page scrolls and an exact height while only the content does.

<Demo src="page-layout/scroll" :flutter="false" :min-height="300">

<<< @/.vitepress/demos/page-layout/scroll.tsx

</Demo>

### skipLink

On by default, and it is the one thing here that is not a style decision. A keyboard reader arriving on a page whose navigation holds forty links has to walk past all forty on every page before reaching the article; this is the one link that spares them, and it costs a sighted reader nothing because it is invisible until it is tabbed to.

`mainId` renames both halves of the pair together — the `id` on the `<main>` and the `href` the link points at.

<Demo src="page-layout/skip-link" :flutter="false" :min-height="220">

<<< @/.vitepress/demos/page-layout/skip-link.tsx

</Demo>

### collapseBelow

The window width below which the sidebars stop being columns and become drawers. `none` keeps them as columns at every width, which is what a layout with no sidebar wants and what these previews use.

The layout also owns whether each drawer is open, so a route change can close one: `sidebarOpen` / `onSidebarOpenChange` for the leading column and `endSidebarOpen` / `onEndSidebarOpenChange` for the trailing one.

## How a bar is measured

A sidebar that holds its place has to start below a header whose height nobody but the header knows, so the layout measures the two bars and writes what they take out of the window onto its own root: `--p-layout-header` and `--p-layout-footer`, plus an `-inset` for each.

They are two rather than one because a bar takes two different things away depending on how it is positioned. A `sticky` bar is still in the flow, so nothing has to be reserved for it — but it is permanently across the top of the window, so a column has to start below it. A `fixed` bar is out of the flow, so the page _does_ have to reserve its height. Which of the two a bar is is read off the element rather than plumbed through a prop.

A bar that never registered itself is left at zero: the measurement is a contract a slot opts into, not a `querySelector`, so a bar rendered through `render={<MyBar />}` is found as reliably as one that is not.

## Accessibility

- The children are inside a real `<main>`, which is the `main` landmark. There is exactly one per page, and the layout is what guarantees it.
- The skip link is the first thing in the document and is clipped to a pixel rather than hidden, so the Tab key can find it. `hidden` would take it off the accessibility tree along with the screen and leave nothing to tab to.
- The `<main>` is not given a `tabindex`. Jumping to it moves the reading position, which is the whole point; making it focusable would add a tab stop to every page.
- `mainProps` is where an `aria-label` goes when a page has more than one region worth naming.
- The layout claims no role of its own. It contributes one `<div>`, and the landmarks come from the tags the components inside it render.
