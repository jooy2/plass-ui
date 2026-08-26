---
title: PlChatBubble
order: 4
---

# PlChatBubble

<p class="plass-lede">One message in a conversation. Everything around the bubble is optional, and <code>side</code> decides only which way the row runs and which corner of the sheet is cut short.</p>

<Demo src="chat-bubble/hero" :min-height="320" />

::: fw react

```tsx
import { PlChatBubble } from 'plass-ui';

<PlChatBubble name="Ada Lovelace" time="09:12" avatar={<PlAvatar name="Ada Lovelace" />}>
  Have a look at the new fills.
</PlChatBubble>;

<PlChatBubble side="end" variant="solid" status="read">
  Already did.
</PlChatBubble>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlChatBubble(
  name: Text('Ada Lovelace'),
  time: Text('09:12'),
  avatar: PlAvatar(name: 'Ada Lovelace'),
  child: Text('Have a look at the new fills.'),
);

const PlChatBubble(
  side: PlChatBubbleSide.end,
  variant: PlassVariant.solid,
  status: PlChatBubbleStatus.read,
  child: Text('Already did.'),
);
```

:::

## Props

<PropsTable name="PlChatBubble" />

::: fw react

Every native `<div>` attribute passes straight through, onto the row. `color` and `title` are excluded from the pass-through because both are Plass props here.

:::

::: fw flutter

The row runs the other way for the reader's own message by **reversing the direction**, not the list, so a thread in Arabic is mirrored without being told twice — and the column inside is set back the right way up, or everything in it would be mirrored along with the row.

:::

### PlChatBubbleLinkPreview

<PropsTable name="PlChatBubbleLinkPreview" />

What the shared axes (`side` `variant` `size` `color` `density` `elevation`) mean across the library is in [prop conventions](../../design/prop-conventions).

## Examples

### side

`start` and `end` rather than `them`/`me` or `left`/`right`: a thread runs the way the language does, and the same two words already mean this everywhere else in the library.

The corner nearest the speaker is cut short. That is the library's one piece of chat vocabulary, and it does the job a drawn tail does elsewhere — without hanging a triangle off a sheet of glass that is supposed to have been cut with a straight edge. It is a flat 4px at every size, because the radius ladder only runs 8px to 16px and a four-pixel difference is not something anyone reads as meaning something.

<Demo src="chat-bubble/sides" :min-height="180">

::: fw react

<<< @/.vitepress/demos/chat-bubble/sides.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chat_bubble/sides.dart

:::

</Demo>

### variant

A bubble **is** the thing being coloured — unlike a `PlCard`, which holds other people's content and so keeps its sheet undyed — so `solid` floods it and the text switches to the family's own ink. That is what makes a column of your own messages read as yours at a glance rather than one line at a time.

It is deliberately not tied to `side`. Filling the right-hand column is a convention, not a law, and a thread that fills neither is a perfectly good thread.

<Demo src="chat-bubble/variants" :min-height="260">

::: fw react

<<< @/.vitepress/demos/chat-bubble/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chat_bubble/variants.dart

:::

</Demo>

### status

Only two of the five carry a colour: the one that arrived and the one that did not. The three in between are the ordinary course of events, and a thread where every message is marked in colour is a thread where the colour has stopped meaning anything.

`failed` is not a fifth step on the ladder — it is the message that did not go, which is why it is the only one drawn in another family.

<Demo src="chat-bubble/status" :min-height="320">

::: fw react

<<< @/.vitepress/demos/chat-bubble/status.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chat_bubble/status.dart

:::

</Demo>

### typing

Three dots that light in sequence, in colour only. The dots never move, so a bubble being typed into does not bounce in a thread somebody is reading.

What <Fw react="children" flutter="child" code /> holds is left alone, so the same bubble goes back to the message when it arrives.

### media and preview

`media` is drawn edge to edge above the text, so the bubble's own corners crop it — which is why a bubble's padding lives on its sections rather than on the sheet.

The link card's surface is mixed out of <Fw react="`currentColor`" flutter="the bubble's own ink" /> rather than out of a token, because it is the one part of a bubble that has to work on both a filled surface and a bare one: on `solid` the text is white and the card is a white wash, on `glass` the text is the page's ink and the card is a grey one. A fixed token would be invisible against one of the two.

::: fw flutter

`preview` takes an `onPressed` rather than a `url`, and an `ImageProvider` rather than a `src`. Flutter has no navigation of its own, so where a link goes is the app's — the same trade a [`PlTextLink`](../display/text-link) makes.

:::

<Demo src="chat-bubble/media" :min-height="420">

::: fw react

<<< @/.vitepress/demos/chat-bubble/media.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chat_bubble/media.dart

:::

</Demo>

### actions

::: fw react

The handle stays out of the way of the message until the row is reached for. It would otherwise sit in the middle of a conversation being read — and a pointer that cannot hover has nothing to reveal it, so on touch it is simply always there.

:::

::: fw flutter

The handle sits beside the message and **stays there**. The React build fades it in on hover and reveals it unconditionally where hover does not exist; here there is no such thing as a screen that certainly has a pointer, so the honest answer is the one that is always reachable.

:::

<Demo src="chat-bubble/actions" :min-height="140">

::: fw react

<<< @/.vitepress/demos/chat-bubble/actions.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chat_bubble/actions.dart

:::

</Demo>

### size

<Demo src="chat-bubble/sizes" :min-height="420">

::: fw react

<<< @/.vitepress/demos/chat-bubble/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chat_bubble/sizes.dart

:::

</Demo>

## Accessibility

::: fw react

- The delivery mark is the whole of what is drawn, and the word behind it is in a visually hidden box — for the readers a double tick says nothing to. `statusLabel` is what changes that word.
- The typing dots are a `role="status"`, so a message being written is announced once rather than on every frame.
- The link card is a real `<a>`, and `newTab` brings the `rel` that stops the new page reaching back through `window.opener`.
- `media` should carry its own `alt`. The component does not know what the picture is of.
- The bubble adds no role of its own. A thread is a list, and the list belongs to the page — which is what lets a virtualised one still be one.

:::

::: fw flutter

- The delivery mark is the whole of what is drawn, and the word behind it is the mark's name — for the readers a double tick says nothing to. `statusLabel` is what changes that word.
- The typing dots are a live region with a name, so a message being written is announced once rather than on every frame. They light in **colour only** and never move, so a bubble being typed into does not bounce in a thread somebody is reading.
- The link card is announced as a link and answers a press from the keyboard, with the focus ring drawn round it.
- `media` should carry its own name. The component does not know what the picture is of.
- The bubble adds no role of its own. A thread is a list, and the list belongs to the page — which is what lets a lazily built one still be one.

:::

::: fw flutter

## Differences from the React build

| React | Flutter | Why |
| --- | --- | --- |
| `preview.url` and `newTab` | `preview.onPressed` | Flutter has no navigation of its own, so where a link goes is the app's. |
| `preview.image` as a `src` | an `ImageProvider` | The shape every image in Flutter has: an asset, a file, a network URL, or something drawn. |
| `children` | `child` | Flutter's name. |
| the handle fades in on hover | the handle is always there | There is no screen here that certainly has a pointer, so the reachable answer is the honest one. |
| `role="status"` on the dots | a named live region | Flutter names the state on the node itself. |
| `className`, `style`, native attributes | — | There is no class list and no style attribute to pass through. |

:::
