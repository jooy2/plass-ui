---
title: Landing page
order: 2
aside: false
---

# Landing page

<p class="plass-lede">The marketing page of Halyard, a product that does not exist. A landing page asks a component library the opposite question from an app — not whether it can hold six hundred rows, but whether these parts make one page somebody wants to read.</p>

<Demo src="examples/landing" :flutter="false" :min-height="1000" />

The whole page is one file: `docs/.vitepress/demos/examples/landing.tsx`. It is live — switch the pricing to monthly, page through the quotes, open a question in the FAQ.

## What it is made of

| Block | Components | Worth noticing |
| --- | --- | --- |
| Nav | `PlToolbar` `PlTextLink` `PlButton` | `render={<header />}` makes it a real landmark, and `position="sticky"` keeps the call to action reachable |
| Hero | `PlChip` `PlTypography` `PlButton` `PlAvatar` `PlRating` | The stacked avatars are a negative margin and a ring — there is no `PlAvatarGroup`, on purpose |
| Product views | `PlTabs` `PlTab` `PlTabPanel` `PlAspectRatio` | Three panels of the same shape, so switching between them does not move the page |
| Features | `PlGrid` `PlGridItem` `PlCard` `PlIcon` | One responsive `span` on each item — twelve, then six, then three — is the whole rule for that row |
| Voices | `PlCarousel` `PlBlockquote` | Built on scroll snap, so it swipes on a phone and reverses under RTL |
| Pricing | `PlSegmentedButton` `PlCard` `PlChip` `PlIcon` `PlButton` | Monthly and yearly are one value out of two, and the featured plan is `elevation={3}` rather than a different colour |
| FAQ | `PlAccordion` `PlAccordionItem` | One panel starts open, because a closed accordion looks like a list of headings |
| Sign-up strip | `PlTextField` `PlButton` `PlTextLink` | A real `<form>` with a real `type="submit"`, so Enter works from inside the field |
| Footer | `PlDivider` `PlTextLink` | `underline="hover"` — a row of permanently underlined links reads as a warning |

## Notes

- The featured plan is marked with **elevation and a chip**, not a saturated fill. A page of coloured cards has nothing left to emphasise with.
- The section backgrounds are `--plass-glass-press`, the same token the library uses for a recessed surface. The bands are the page's own structure rather than a palette invented for this file.
- Every heading is a `PlTypography` `level`, so the type scale on this page is the library's, not a set of Tailwind sizes chosen per section.

## Next

- Two more whole screens: [Admin dashboard](./dashboard) and [Sign-up](./signup).
- Per-component props and examples are under [Components](../components/).
