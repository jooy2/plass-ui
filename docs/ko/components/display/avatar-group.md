---
title: PlAvatarGroup
order: 15
---

# PlAvatarGroup

<p class="plass-lede">겹쳐 쌓은 avatar들, 그리고 자리에 들어가지 못한 나머지를 숫자로 보여 줍니다. 축을 쌓기 전체에 한 번에 정하고, 그중 하나만 따로 표시하는 것도 그대로 됩니다.</p>

<Demo src="avatar-group/hero" :min-height="120" />

::: fw react

```tsx
import { PlAvatar, PlAvatarGroup } from 'plass-ui';

<PlAvatarGroup max={4} total={11}>
  <PlAvatar name="Ada Lovelace" src="/ada.jpg" />
  <PlAvatar name="Grace Hopper" />
</PlAvatarGroup>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlAvatarGroup(
  max: 4,
  total: 11,
  avatars: <PlAvatar>[
    PlAvatar(name: 'Ada Lovelace', image: NetworkImage('/ada.jpg')),
    PlAvatar(name: 'Grace Hopper'),
  ],
);
```

:::

## Props

<PropsTable name="PlAvatarGroup" />

::: fw react

네이티브 `<div>` 속성은 모두 그대로 전달됩니다. `color`는 여기서 Plass의 prop이라 제외됩니다.

:::

공용 축이 라이브러리 전체에서 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## 축은 쌓기의 것입니다

`size`, `shape`, `variant`, `color`, `elevation`은 avatar마다가 아니라 여기서 정합니다. 네 번째 얼굴만 크기가 다른 쌓기는 쌓기가 아닙니다.

avatar 자신의 prop은 여전히 이깁니다. 나머지에서 하나를 따로 표시할 수 있게 하는 것이 그것입니다 — 지금 당번인 사람, 이것을 소유한 계정, 곧 지울 사람.

<Demo src="avatar-group/variants" :min-height="120">

::: fw react

<<< @/.vitepress/demos/avatar-group/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/avatar_group/variants.dart

:::

</Demo>

::: fw react

직계 자식만이 아니라 어디에 있든 avatar에 닿습니다. 하나를 [`PlTooltip`](../feedback/tooltip)으로 감싸거나 `.map()`으로 만들어도 달라지는 것이 없습니다.

:::

::: fw flutter

avatar는 축을 inherited widget으로 읽으므로, 얼굴이 얼마나 깊이 들어가 있든 그대로 닿습니다.

:::

## 예제

### max와 total

`max`는 얼굴을 몇 개까지 그릴지이고, 그 뒤는 전부 `+n`이 됩니다.

`total`은 흔한 경우를 위한 것입니다 — 백스물여덟 명 중 앞의 다섯만 넘긴 경우. 없으면 넘어온 것에서 세는데, 그것은 전부 넘겼을 때만 맞습니다.

<Demo src="avatar-group/max" :min-height="200">

::: fw react

<<< @/.vitepress/demos/avatar-group/max.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/avatar_group/max.dart

:::

</Demo>

### overlap

각 avatar가 앞의 것 아래로 얼마나 들어가는지입니다. 없으면 `size`의 일정 비율입니다 — 어느 단계에서나 대략 상자의 3분의 1로, 쌓기가 쌓기로 읽힐 만큼은 되고 얼굴이 다음 것 뒤로 숨을 만큼은 되지 않습니다.

`0`은 서로 닿기만 하는 행을 만듭니다. 로고를 늘어놓을 때 보통 원하는 모양입니다.

::: fw flutter

CSS 길이가 아니라 논리 픽셀 `double`이고, 한 칸의 폭은 그룹 자신의 `size`에서 나옵니다 — 그래서 쌓기 안에서 `size`를 따로 준 avatar도 쌓기의 보폭으로 겹칩니다.

:::

<Demo src="avatar-group/overlap" :min-height="200">

::: fw react

<<< @/.vitepress/demos/avatar-group/overlap.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/avatar_group/overlap.dart

:::

</Demo>

### size

<Demo src="avatar-group/sizes" :min-height="280">

::: fw react

<<< @/.vitepress/demos/avatar-group/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/avatar_group/sizes.dart

:::

</Demo>

### ring은 선이 아니라 구멍입니다

비슷한 톤의 원 둘을 겹쳐 놓으면 그 사이에 경계가 아예 없고, 쌓기가 하나의 뭉개진 형태로 읽힙니다. 반투명 hairline은 도움이 되지 않습니다. 그 뒤에 있는 것이 다른 avatar이기 때문입니다.

그래서 각 얼굴은 `--plass-surface`로 ring을 두릅니다. 페이지 자신의 시트 색이고, 라이브러리에서 유일한 불투명 외곽선입니다. 무언가를 둘러 그린 선이 아니라 빈 자리로 읽히고, 그래서 쌓기는 Plass 표면에 단단한 모서리가 허용되는 유일한 자리입니다.

각 얼굴은 앞의 것 위로 겹칩니다. 그래서 목록의 마지막 avatar가 맨 앞이고, 가장 마지막에 오는 `+n`이 그 전부 위에 앉습니다.

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| 조합된 자식 | `avatars: List<PlAvatar>` | 다음 얼굴을 얹으려면 앞의 얼굴이 얼마나 넓은지 알아야 하고, 잴 수 있는 것은 타입이 정해진 목록입니다. |
| 음수 `margin-inline-start` | 한 칸씩 밀어 놓은 얼굴들의 `Stack` | `EdgeInsets`가 음수를 거부하므로 쓸 수 있는 음수 margin이 없습니다. `Stack`은 가장 넓은 자식의 크기를 가지므로, 행은 여전히 그리는 만큼 정확히 재집니다. |
| 숫자 **또는** CSS 길이인 `overlap` | `double?` | `1.5rem`을 풀어 줄 스타일시트가 없습니다. |
| 상자 바깥에 그리는 2px `ring` | 얼굴 뒤에 놓인 2px 더 큰 판 | Flutter의 `Border`는 상자 안쪽에 그려집니다. 2px 더 큰 채워진 상자가 같은 그림이고, 어느 쪽이든 생각은 같습니다 — 가까운 얼굴이 오려져 나온 구멍입니다. |
| avatar 자신의 `size`도 제대로 겹침 | 한 칸의 폭은 그룹의 `size`에서 옴 | 여기서 보폭은 레이아웃이 아니라 산술이라, 크기가 다른 얼굴도 쌓기 자신의 보폭으로 밀립니다. |
| `className`, `style`, 네이티브 속성 | — | 전달할 클래스 목록도 style 속성도 없습니다. |

:::

## 접근성

- 그룹 자체에는 role이 없습니다. 얼굴을 쌓은 것은 어떤 집합의 그림이고, 그것이 _무엇의_ 집합인지는 옆의 문장입니다. 쌓기만이 그것을 말하고 있다면 이름을 주세요 — React에서는 `aria-label`, Flutter에서는 `semanticLabel`입니다.
- 각 avatar는 혼자 있을 때와 똑같이 자기 이름을 말합니다. 그림은 `name`을 가져가고, 이니셜을 보여 주는 fallback은 두 글자가 아니라 이름으로 읽힙니다.
- `+n`은 이름 없는 avatar로 그려지므로 보이는 문자 그대로 읽힙니다. 숫자가 문장이어야 할 때는 — "외 38명" — 그것을 그룹에 두세요.
