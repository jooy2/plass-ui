---
title: PlAvatar
order: 6
---

# PlAvatar

<p class="plass-lede">사람이나 사물의 사진을 정해진 크기로 놓되, 절대 빈 상자가 되지 않습니다. 사진이 없으면 이니셜이, 이니셜도 없으면 실루엣이 그려집니다.</p>

<Demo src="avatar/hero" :min-height="140" />

::: fw react

```tsx
import { PlAvatar } from 'plass-ui';

<PlAvatar name="Nadia Rowan" src="/nadia-rowan.webp" />;
<PlAvatar name="Nadia Rowan" />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlAvatar(name: 'Nadia Rowan', image: NetworkImage('/nadia-rowan.webp'));
const PlAvatar(name: 'Nadia Rowan');
```

:::

## Props

<PropsTable name="PlAvatar" />

::: fw react

네이티브 `<span>` 속성은 그대로 전달됩니다. `color`는 여기서 Plass의 prop이라 전달 대상에서 제외됩니다.

:::

::: fw flutter

`image`는 URL이 아니라 `ImageProvider`입니다. Flutter에서 이미지가 가지는 모양이 그것이고, `NetworkImage`도 `AssetImage`도 `MemoryImage`도 캐싱 패키지가 주는 provider도, 컴포넌트가 어느 쪽인지 알 필요 없이 그대로 들어맞습니다.

:::

`density`는 없습니다 — avatar에는 좁힐 여백이 없습니다. 자체 상태 점도 가지지 않습니다. 초록 점이 붙은 avatar는 avatar를 담은 [`PlBadge`](./badge)입니다.

라이브러리 전체에서 공유 축(`variant` `size` `color` `elevation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### 폴백

그려질 수 있는 것은 세 가지이고, 한 번에 정확히 하나입니다. `src`가 주어졌고 로드되면 사진, 아니면 그 자리를 대신하는 것 — `children`, `initials`, 또는 `name`에서 파생한 이니셜 — 그리고 그 셋 다 없으면 실루엣.

::: fw react

어느 것이 보일지는 Base UI의 `Avatar`가 정합니다. "이미지가 로드됐는가"는 답이 넷이고 중간에 race가 끼어 있는 질문이기 때문입니다.

:::

::: fw flutter

어느 것이 보일지는 `Image` 자신이 정합니다. `frameBuilder`가 첫 프레임이 올 때까지 폴백을 보여 주고, `errorBuilder`가 끝내 오지 않으면 계속 보여 줍니다. 로딩 상태 enum이 없는 이유는, 아직 오지 않은 사진과 끝내 오지 않을 사진이 그 시간 동안은 같은 경우이기 때문입니다.

`delay`도 없습니다. React 빌드에 그것이 있는 이유는 캐시된 이미지 앞에서 이니셜이 번쩍이지 않게 하기 위해서인데, 여기서는 이미지 캐시에 이미 있는 사진이 동기적으로 디코드되어 폴백이 아예 만들어지지 않습니다.

:::

파생 규칙은 첫 단어의 첫 글자와 마지막 단어의 첫 글자입니다 — "Jane Doe"는 `JD`. 단어가 하나면 글자도 하나인데, 한국어·일본어·중국어 이름의 두 글자는 40px에서 얼룩이고 한 글자는 이름이기 때문입니다.

<Demo src="avatar/fallback" :min-height="180">

::: fw react

<<< @/.vitepress/demos/avatar/fallback.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/avatar/fallback.dart

:::

</Demo>

### variant

avatar는 색을 입는 **대상 자체**입니다 — 특정한 한 사람의 초상이므로, `PlAlert`이 그렇듯 시트가 틴트를 받습니다. `PlCard`와는 다릅니다. 가장자리는 시트 자신의 흰 헤어라인이 아니라 중립 헤어라인입니다. avatar는 불투명한 것 위에 놓이는 일이 아주 흔하고, 거기서 잘린 가장자리에 걸린 흰 빛은 뒤에 있지도 않은 페이지 바탕에 대한 주장이 되기 때문입니다.

기본값이 `solid`가 아니라 `ghost`인 것은 `PlButton`과 정반대입니다. 디렉터리는 avatar로 가득한 페이지이고, 채도 높은 원으로 가득한 페이지에서는 아무도 이름을 읽어 내지 못합니다.

<Demo src="avatar/variants" :min-height="120">

::: fw react

<<< @/.vitepress/demos/avatar/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/avatar/variants.dart

:::

</Demo>

### shape

기본값은 `circle`입니다. 초상이라는 것이 있어 온 내내 초상은 그런 모양이었습니다. `square`는 대신 라이브러리 자신의 필렛을 씁니다. 로고나 저장소 아이콘이 원하는 모양이 그것입니다 — 그런 그림은 사각형 가장자리까지 그려져 있어서 원형 크롭이 잘라먹습니다.

<Demo src="avatar/shapes" :min-height="120">

::: fw react

<<< @/.vitepress/demos/avatar/shapes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/avatar/shapes.dart

:::

</Demo>

### size

컨트롤 높이와 같은 사다리라, 툴바에서 avatar와 그 옆 버튼이 같은 baseline에 놓입니다.

<Demo src="avatar/sizes" :min-height="120">

::: fw react

<<< @/.vitepress/demos/avatar/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/avatar/sizes.dart

:::

</Demo>

### color

<Demo src="avatar/colors" :min-height="120">

::: fw react

<<< @/.vitepress/demos/avatar/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/avatar/colors.dart

:::

</Demo>

### 겹쳐 쌓기

얼굴을 겹쳐 쌓고 끝에 `+n`을 붙인 것은 avatar를 담은 [`PlStack`](../layout/stack)입니다. avatar 전용이 아니라 일반적인 더미이므로 담은 것에 축을 정해 주지 않습니다 — `size`와 `color`는 `PlassProvider`로 감싸고, 나머지는 avatar에 직접 쓰세요.

## Accessibility

::: fw react

- 사진은 `alt`를 받고, 없으면 `name`, 그것도 없으면 **빈** `alt`를 씁니다. 비우는 것과 빼는 것은 다릅니다 — 행 안에서 사람 이름 옆에 놓인 avatar는 장식이고, `alt`를 아예 빼면 스크린리더가 파일 이름을 읽습니다.
- `JD`를 소리 내 읽으면 사람이 아니라 글자 두 개입니다. 이름이 있으면 그것이 폴백의 접근 가능한 이름이 되고, 이니셜은 그것이 대신하고 있는 그림으로 남아 숨겨집니다.
- 실루엣은 아무 말도 하지 않습니다. 읽을 이름이 없고, "그래픽"은 정보가 아닙니다.
- 링크나 버튼이기도 한 avatar는 진짜 그것이어야 합니다. 진짜 `<a>`나 `<button>` 안에 넣고, 이름은 그 요소에 주세요.

:::

::: fw flutter

- avatar는 `semanticLabel`을 받고, 없으면 `name`, 그것도 없으면 아무 이름도 갖지 않습니다. 추측하는 대신 비워 둡니다 — 행 안에서 사람 이름 옆에 놓인 avatar는 장식이고, 이름을 두 번 말하는 것은 한 번 말하는 것보다 나쁩니다.
- `JD`를 소리 내 읽으면 사람이 아니라 글자 두 개입니다. 이름이 있으면 그것이 접근 가능한 이름이 되고, 이니셜은 그것이 대신하고 있는 그림으로 남아 semantics에서 제외됩니다. 이름이 없으면 이니셜이 가진 전부이고, 그때는 읽힙니다.
- 실루엣은 아무 말도 하지 않습니다. 읽을 이름이 없고, "그래픽"은 정보가 아닙니다.
- 링크나 버튼이기도 한 avatar는 그것 안에 들어가야 합니다. `onPressed`가 있는 `PlButton`이나 `PlCard` 안에 넣고, 이름은 거기에 주세요.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `src` / `srcSet` / `imageProps` | `image` | `ImageProvider`가 Flutter에서 이미지가 가지는 모양이고, 해상도 변형도 헤더도 캐싱도 이미 그 안에 있습니다. |
| `alt` | `semanticLabel` | Flutter의 이름입니다. 안쪽 요소가 없으니 안쪽 요소가 아니라 avatar 자체에 이름을 붙입니다. |
| `delay` | — | 캐시된 이미지가 동기적으로 디코드되므로 폴백이 번쩍이지 않고, 기다려 넘길 것도 없습니다. |
| `onLoadingStatusChange` | — | 보고할 네 단계 상태가 없습니다. 프레임이 올 때까지, 오지 않으면 계속 폴백입니다. 상태가 필요한 호출자는 `ImageProvider`의 `ImageStream`으로 갑니다. |
| `children` | `child` | Flutter의 이름입니다. |
| `className`, `style` | — | 전달할 클래스 목록도 style 속성도 없습니다. |

:::
