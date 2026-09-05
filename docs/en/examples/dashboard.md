---
title: Admin dashboard
order: 1
aside: false
---

# Admin dashboard

<p class="plass-lede">The back office of Grange, a shop that does not exist. A rail, an app bar, four figures, a filter row and a table with an action on every row, all on one screen and all at the same <code>size</code>, which is the arrangement that shows whether a size ladder actually holds.</p>

<Demo src="examples/dashboard" :flutter="false" :min-height="900" />

The whole screen is one file: `docs/.vitepress/demos/examples/dashboard.tsx`. It is live, search the table, filter it by channel or status, tick some rows and the bulk actions appear.

## Composition

| Block | Components | Worth noticing |
| --- | --- | --- |
| Rail | `PlList` `PlListItem` `PlIcon` `PlBadge` `PlPill` `PlCard` `PlProgressLinear` | `render={<nav />}` makes the list a real landmark, `selected` marks the current row, and the unread count sits in `endIcon` |
| App bar | `PlToolbar` `PlBreadcrumb` `PlBadge` `PlIconButton` `PlTooltip` `PlAvatar` | `position="sticky"` keeps the actions reachable while the page scrolls under them |
| Alert | `PlAlert` | One thing needs attention, said once, at the top, with its own `action` |
| Figures | `PlCard` `PlTypography` `PlProgressLinear` `PlProgressCircular` | A bar for progress towards a target, a ring where the figure _is_ a share of a whole |
| Filters | `PlTextField` `PlSelect` `PlDateRangePicker` `PlSegmentedButton` | At `size="sm"` the field, the select and the range picker are the same height, so the row keeps one baseline |
| Table | `PlTable` `PlCheckbox` `PlChip` `PlMenu` `PlIconButton` `PlPagination` | Select-all is an `indeterminate` checkbox in the header cell, and every row carries its own `PlMenu` |
| Bulk actions | `PlButton` `PlModal` `PlToast` | They appear only with a selection; the destructive one confirms in a `PlModal` and reports with an undoable toast |
| Bottom row | `PlCard` `PlTimeline` `PlSwitch` `PlDivider` | What happened, and what reaches you, the same card at the same elevation, twice |
| Settings | `PlDrawer` `PlSelect` `PlSwitch` | The settings that do not belong on the screen, in a sheet that slides over it |

## Notes

- The status filter is a `PlSegmentedButton` rather than `PlTabs`. Nothing below it is a panel, it is the same table either way, and a segmented button is one value out of four.
- Filtering is ordinary React state. `PlTable` renders whatever it is handed and shows `empty` when that is nothing.
- Every row action has an accessible name that says which row it belongs to, because `label` on the trigger `PlIconButton` includes the order id.
- The bulk-action `PlModal` passes `modal="trap-focus"`. A fully modal dialog makes the page behind it inert, which is right in an app and wrong inside a documentation preview.

## Next

- Two more whole screens: [Landing page](./landing) and [Sign-up](./signup).
- Per-component props and examples are under [Components](../components/).
