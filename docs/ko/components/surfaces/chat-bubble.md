---
title: PlChatBubble
order: 4
---

# PlChatBubble

<p class="plass-lede">대화 속 메시지 하나입니다. 버블 주위의 모든 것은 선택이고, <code>side</code>가 정하는 것은 행이 어느 쪽으로 놓이는지와 시트의 어느 모서리가 짧게 잘리는지뿐입니다.</p>

<Demo src="chat-bubble/hero" :min-height="320" />

```tsx
import { PlChatBubble } from 'plass-ui';

<PlChatBubble name="Ada Lovelace" time="09:12" avatar={<PlAvatar name="Ada Lovelace" />}>
  Have a look at the new fills.
</PlChatBubble>;

<PlChatBubble side="end" variant="solid" status="read">
  Already did.
</PlChatBubble>;
```

## Props

<PropsTable name="PlChatBubble" />

네이티브 `<div>` 속성은 행에 그대로 전달됩니다. `color`와 `title`은 둘 다 여기서는 Plass의 prop이라 전달 대상에서 제외됩니다.

### PlChatBubbleLinkPreview

<PropsTable name="PlChatBubbleLinkPreview" />

라이브러리 전체에서 공유 축(`side` `variant` `size` `color` `density` `elevation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### side

`them`/`me`나 `left`/`right`가 아니라 `start`와 `end`입니다. 대화는 언어가 흐르는 방향으로 흐르고, 이 두 단어는 라이브러리의 다른 모든 자리에서 이미 그 뜻입니다.

말하는 쪽에 가까운 모서리가 짧게 잘립니다. 라이브러리가 가진 유일한 대화 어휘이고, 다른 곳에서 꼬리를 그려 하는 일을 대신합니다 — 곧은 날로 잘렸어야 할 유리판에 삼각형을 매달지 않고서. 모든 크기에서 4px 고정인데, 반지름 사다리가 8px에서 16px까지밖에 가지 않아서 4px 차이는 누구도 의미로 읽지 않기 때문입니다.

<Demo src="chat-bubble/sides" :min-height="180">

::: fw react

<<< @/.vitepress/demos/chat-bubble/sides.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chat_bubble/sides.dart

:::

</Demo>

### variant

버블은 색을 입는 **대상 자체**입니다 — 남의 내용을 담기에 시트에 색이 들어가지 않는 `PlCard`와 다릅니다 — 그래서 `solid`가 안을 채우고 글자는 그 계열의 잉크로 넘어갑니다. 내가 보낸 메시지의 세로줄이 한 줄씩이 아니라 한눈에 내 것으로 읽히게 하는 것이 그것입니다.

`side`와 묶여 있지 않은 것은 일부러입니다. 오른쪽 줄을 채우는 것은 관습이지 법이 아니고, 어느 쪽도 채우지 않는 대화도 아주 좋은 대화입니다.

<Demo src="chat-bubble/variants" :min-height="260">

::: fw react

<<< @/.vitepress/demos/chat-bubble/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chat_bubble/variants.dart

:::

</Demo>

### status

다섯 중 둘만 색을 답니다. 도착한 것과 도착하지 못한 것. 그 사이의 셋은 그저 일이 흘러가는 보통의 모습이고, 모든 메시지가 색으로 표시된 대화는 색이 아무 뜻도 갖지 않게 된 대화입니다.

`failed`는 사다리의 다섯 번째 칸이 아닙니다. 가지 못한 메시지이고, 그래서 다른 계열로 그려지는 유일한 하나입니다.

<Demo src="chat-bubble/status" :min-height="320">

::: fw react

<<< @/.vitepress/demos/chat-bubble/status.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chat_bubble/status.dart

:::

</Demo>

### typing

차례로 밝아지는 점 세 개입니다. 색만 바뀝니다. 점은 움직이지 않으므로, 누군가 입력 중인 버블이 다른 사람이 읽고 있는 대화 안에서 통통 튀지 않습니다.

<Fw react="children" flutter="child" code />가 담고 있던 것은 그대로 두므로, 메시지가 도착하면 같은 버블이 그것으로 되돌아옵니다.

### media와 preview

`media`는 글 위에 가장자리까지 그려지고, 버블 자신의 모서리가 그것을 잘라 냅니다 — 버블의 여백이 시트가 아니라 각 구획에 놓여 있는 이유입니다.

링크 카드의 표면은 토큰이 아니라 `currentColor`에서 섞여 나옵니다. 버블에서 채워진 표면과 맨 표면 양쪽에서 모두 동작해야 하는 유일한 부분이기 때문입니다.

<Demo src="chat-bubble/media" :min-height="420">

::: fw react

<<< @/.vitepress/demos/chat-bubble/media.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chat_bubble/media.dart

:::

</Demo>

### actions

손잡이는 행에 손이 닿기 전까지 메시지의 길에서 비켜서 있습니다. 그러지 않으면 읽고 있는 대화 한가운데에 놓이게 됩니다 — 그리고 hover할 수 없는 포인터에는 그것을 드러낼 방법이 없으므로, 터치에서는 그냥 언제나 거기 있습니다.

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

- 그려지는 것은 전달 표시뿐이고, 그 뒤의 말은 시각적으로 숨겨진 상자에 들어 있습니다 — 이중 체크가 아무 말도 하지 않는 독자를 위해서입니다. `statusLabel`이 그 말을 바꿉니다.
- 입력 중 점은 `role="status"`입니다. 그래서 누군가 쓰고 있다는 사실이 프레임마다가 아니라 한 번 읽힙니다.
- 링크 카드는 진짜 `<a>`이고, `newTab`은 새 페이지가 `window.opener`로 되돌아오지 못하게 하는 `rel`을 함께 붙입니다.
- `media`에는 자기 `alt`를 주세요. 컴포넌트는 그 사진이 무엇의 사진인지 알지 못합니다.
- 버블은 자기 role을 더하지 않습니다. 대화는 목록이고, 그 목록은 페이지의 것입니다 — 가상화된 대화도 여전히 목록일 수 있게 하는 것이 그것입니다.

:::

::: fw flutter

- 그려지는 것은 전달 표시뿐이고, 그 뒤의 말은 표시의 이름입니다 — 이중 체크가 아무 말도 하지 않는 독자를 위해서입니다. `statusLabel`이 그 말을 바꿉니다.
- 입력 중 점은 이름이 붙은 live region입니다. 그래서 누군가 쓰고 있다는 사실이 프레임마다가 아니라 한 번 읽힙니다. 점은 **색만** 바뀌고 움직이지 않으므로, 누군가 입력 중인 버블이 다른 사람이 읽고 있는 대화 안에서 통통 튀지 않습니다.
- 링크 카드는 링크로 읽히고 키보드의 누름에도 답하며, 그 둘레에 focus ring이 그려집니다.
- `media`에는 자기 이름을 주세요. 컴포넌트는 그 사진이 무엇의 사진인지 알지 못합니다.
- 버블은 자기 role을 더하지 않습니다. 대화는 목록이고, 그 목록은 페이지의 것입니다 — 게으르게 만들어지는 대화도 여전히 목록일 수 있게 하는 것이 그것입니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `preview.url`과 `newTab` | `preview.onPressed` | Flutter에는 자기 내비게이션이 없으므로 링크가 어디로 가는지는 앱의 몫입니다. |
| `src`인 `preview.image` | `ImageProvider` | Flutter에서 모든 이미지가 갖는 모양입니다 — 애셋, 파일, 네트워크 URL, 또는 그려진 것. |
| `children` | `child` | Flutter의 이름입니다. |
| hover에서 나타나는 손잡이 | 언제나 있는 손잡이 | 여기에는 포인터가 확실히 있는 화면이라는 것이 없으니, 닿을 수 있는 쪽이 정직한 답입니다. |
| 점의 `role="status"` | 이름이 붙은 live region | Flutter는 상태를 노드 자체에 적습니다. |
| `className`, `style`, 네이티브 속성 | — | 전달할 클래스 목록도 style 속성도 없습니다. |

:::
