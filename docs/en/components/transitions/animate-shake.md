---
title: PlAnimateShake
order: 14
---

# PlAnimateShake

<p class="plass-lede">A refusal. The one effect in the set that is a response rather than an entrance, so it starts held still, and <code>replay</code> is how a caller says "again".</p>

<Demo src="animate-shake/hero" :min-height="240" />

::: fw react

```tsx
import { PlAnimateShake } from 'plass-ui';

<PlAnimateShake replay={attempts}>
  <PlTextField label="Password" type="password" error={error} invalid />
</PlAnimateShake>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlAnimateShake(
  replay: attempts,
  child: PlTextField(label: const Text('Password'), error: error, invalid: true),
);
```

:::

## Props

<PropsTable name="PlAnimateShake" />

What the shared animation props mean is on any of the other [transitions](./animate-fade).

## replay is why it exists

A refusal can happen **twice**, and `play` (being a boolean) cannot say "again". Replaying with it means toggling off and on: two renders for one event, and a piece of state whose only job is to be flipped back.

A value that has changed is the closest React has to an event, and the count of failed attempts a form already keeps is exactly that value.

```tsx
const [attempts, setAttempts] = useState(0);

<PlAnimateShake replay={attempts}>…</PlAnimateShake>;
```

It never plays on the first render. A shake that shook itself on mount would be answering an event that has not happened.

## A reaction to an event

Every other effect here answers "how does this content arrive" and starts on **mount**. This one answers something the reader did, so it starts **held still** (`trigger` defaults to `manual`), and plays only when it is told to.

It is also not in `PlassAnimation`, the union `mode` and `stagger` are built on, for [`PlAnimateFloat`](./animate-float)'s reason: that union is the set of ways content can arrive, and a response is not an arrival.

## The rest position

Three shudders either side of home and back to nothing.

That matters more here than anywhere else in the group, because this is the one effect a caller will run over content that is **still being typed into**. A field left a few pixels off its label would be a worse defect than the error it was reporting.

## Examples

### A locked control

```tsx
<PlAnimateShake replay={refusals}>
  <PlButton disabled>Delete workspace</PlButton>
</PlAnimateShake>
```

### A shorter, wider shudder

```tsx
<PlAnimateShake replay={attempts} distance={10} duration={300}>
```

## Accessibility

- **A reader who asked for less motion sees none of it**, and that is exactly why the words matter more than the shake. Whatever the refusal is saying has to be said in **text** as well (an `error` on the field, a message in a live region), and the shake is emphasis, never the message.
- Shaking a field does not tell a screen reader anything. Pair it with the field's own `error` and `invalid`, which do.
- It is decoration around the content, not a wrapper that changes what the content is: what is inside keeps its own role, its own focus and its own name.
