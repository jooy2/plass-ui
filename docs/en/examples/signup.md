---
title: Sign-up
order: 3
aside: false
---

# Sign-up

<p class="plass-lede">Signing up for Halyard, in three steps and one column. A form is where a component library either holds together or does not: every control here is a different component, and they have to agree about height, about where a label sits, and about what an error looks like.</p>

<Demo src="examples/signup" :flutter="false" :min-height="760" />

The whole flow is one file: `docs/.vitepress/demos/examples/signup.tsx`. It is live — submit the first step empty and watch the errors arrive, then type any six digits to get past the code.

## Composition

| Block | Components | Worth noticing |
| --- | --- | --- |
| Progress | `PlTimeline` `PlProgressLinear` | A horizontal timeline rather than a bar alone, because the steps have names and a bar cannot say them |
| Account | `PlTextField` `PlCheckbox` `PlDivider` `PlButton` `PlTextLink` | `error` on a field replaces its `description` and wires up `aria-describedby`; the checkbox takes one too |
| Social sign-in | `PlButton` | `startIcon` and `fullWidth`, so the two buttons are one row on a wide canvas and a stack on a narrow one |
| Verify | `PlOtpField` `PlPopover` `PlButton` | `groupSize={3}` splits six boxes into two groups, and paste fills all six at once |
| Profile | `PlTextField` `PlCombobox` `PlDatePicker` `PlFilePicker` `PlRadioGroup` `PlSwitch` | At the same `size` a field, a combobox and a date picker are the same height, so the two-column grid keeps its baselines |
| Done | `PlAlert` `PlIcon` `PlButton` | One `success` alert, and nothing else competing with it |
| Aside | `PlCard` `PlList` `PlBlockquote` `PlAvatar` `PlTextLink` | Reassurance, not navigation — so it is an `<aside>` and it disappears first |

## Notes

- Validation is ordinary React state. Nothing is marked wrong until the reader has tried to continue, which is why `tried` exists — a form that turns red while you are still typing in the first field is a form that is shouting.
- The step is a number and the sections are plain conditionals. There is no wizard component in Plass and there does not need to be: a step is a piece of state and the rest is layout.
- `PlOtpField` is what the "Verify" button waits on. Six digits enable it; the field itself handles paste, backspace across boxes and the numeric keypad.

## Next

- Two more whole screens: [Admin dashboard](./dashboard) and [Landing page](./landing).
- Per-component props and examples are under [Components](../components/).
