---
title: PlIcon
order: 5
---

# PlIcon

<p class="plass-lede">정해진 크기와 정해진 색으로 놓이는 글리프입니다. Plass는 자체 아이콘 세트를 그리지 않습니다 — 앱이 고른 세트에 나머지 컴포넌트와 같은 두 축을 붙여 줄 뿐입니다.</p>

<Demo src="icon/hero" :min-height="140" />

::: fw react

```tsx
import { PlIcon } from 'plass-ui';

<PlIcon icon={<BoltIcon />} />;
<PlIcon icon={<BoltIcon />} size="lg" color="warning" label="Fast" />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlIcon(icon: BoltGlyph());
const PlIcon(icon: BoltGlyph(), size: PlassSize.lg, color: PlassColor.warning, label: 'Fast');
```

:::

## Props

<PropsTable name="PlIcon" />

::: fw react

네이티브 `<span>` 속성은 그대로 전달됩니다. `color`는 여기서 Plass의 prop이라 전달 대상에서 제외됩니다.

:::

::: fw flutter

`color`는 `PlassColor`가 아니라 `PlassColor?`이고 기본값은 `null`입니다 — `inherit`이라는 키워드가 없는 언어에서 "물려받는다"를 쓰는 방법입니다.

:::

`variant`도 `elevation`도 없습니다. 아이콘은 표면이 아니라 잉크이고, 디자인 언어가 잉크에 대해 할 말은 어느 색 계열로 그리느냐뿐입니다.

라이브러리 전체에서 공유 축(`size` `color`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### icon

글리프는 `children`이 아니라 prop입니다. 아이콘 세트는 직접 그리지 않은 요소를 건네주는데, 그 요소에 대해 늘 바꾸고 싶은 두 가지 — 크기와 색 — 는 그것이 무언가의 자식이 되고 나면 손댈 수 없는 두 가지입니다.

::: fw react

상자는 `inline-flex`이고 글리프는 그 상자를 채우도록 지시받으며, `font-size`도 같은 길이로 설정됩니다. 그래서 자체 `width`를 가진 `<svg>`, `em`으로 그려진 `<svg>`, 문자 하나, `<img>`가 모두 같은 크기로 나옵니다.

:::

::: fw flutter

글리프에는 크기가 세 갈래로 동시에 전해집니다 — `IconTheme`으로, `DefaultTextStyle`로, 그리고 놓이는 상자 자체가 정확히 그 크기라는 사실로. 그래서 `Icon`도, `ImageIcon`도, `IconTheme.of(context)`를 읽는 `CustomPaint`도, 문자 하나도 모두 같은 크기로 나옵니다.

:::

<Demo src="icon/anything" :min-height="140">

::: fw react

<<< @/.vitepress/demos/icon/anything.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/icon/anything.dart

:::

</Demo>

### size

컨트롤 높이에서 한 칸 물러난 값이 아니라 자기 사다리입니다 — 14, 16, 20, 24, 28px. 아이콘은 컨트롤이 아니기 때문입니다. 아이콘은 콘텐츠이고, 놓인 행이 아니라 옆에 놓인 글자를 기준으로 재집니다.

<Demo src="icon/sizes" :min-height="160">

::: fw react

<<< @/.vitepress/demos/icon/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/icon/sizes.dart

:::

</Demo>

### color

기본값은 `inherit`이고, 라이브러리에서 `color`가 `primary`가 아닌 유일한 컴포넌트입니다. 아이콘은 대개 콘텐츠의 색을 이미 정해 놓은 무언가 안에 놓입니다 — 버튼의 라벨, 흐린 캡션, alert 자신의 색 계열 — 그리고 미리 색이 입혀진 채 도착한 아이콘은 그 모든 자리에서 다시 꺼야 합니다.

<Demo src="icon/colors" :min-height="120">

::: fw react

<<< @/.vitepress/demos/icon/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/icon/colors.dart

:::

</Demo>

### 다른 컴포넌트 안에서

::: fw react

`PlButton`이나 `PlAlert`에 넘긴 글리프는 이미 그 컴포넌트가 `em`으로 크기를 정하므로 라벨을 따라갑니다. `PlIcon`으로 감싸는 것은 대신 고정 크기여야 할 때, 또는 아이콘이 홀로 설 때를 위한 것입니다.

<Demo src="icon/inside" :min-height="220">

<<< @/.vitepress/demos/icon/inside.tsx

</Demo>

:::

::: fw flutter

`PlButton`이나 `PlAlert`에 넘긴 글리프는 이미 그 컴포넌트의 `IconTheme`이 라벨의 1.2배로 크기를 정하므로 라벨을 따라갑니다. `PlIcon`으로 감싸는 것은 대신 고정 크기여야 할 때, 또는 아이콘이 홀로 설 때를 위한 것입니다.

<Demo src="icon/inside" :min-height="220">

<<< @/../packages/flutter/example/lib/demos/icon/inside.dart

</Demo>

:::

## Accessibility

::: fw react

- `label`이 없으면 아이콘은 `aria-hidden`이고 role도 없습니다. 그것이 옳은 기본값입니다 — 대부분의 아이콘 옆에는 같은 말을 하는 단어가 이미 있고, 둘 다 읽는 것은 하나만 읽는 것보다 나쁩니다.
- `label`이 있으면 그 이름을 가진 `role="img"`가 됩니다. 글리프가 혼자서 뜻을 나르고 있을 때만 넘기세요.
- 세 번째 경우는 없습니다. 장식용 글리프에 붙은 `role="img"`는 스크린리더가 "그래픽"이라고 말하게 되는 가장 흔한 경로입니다.
- 버튼 전체가 아이콘 하나라면 아이콘은 버튼 옆이 아니라 버튼 안에 있어야 합니다. `PlButton`에 `aria-label`을 주고 아이콘은 숨긴 채로 두세요.

:::

::: fw flutter

- `label`이 없으면 아이콘은 접근성 트리에서 통째로 제외됩니다. 그것이 옳은 기본값입니다 — 대부분의 아이콘 옆에는 같은 말을 하는 단어가 이미 있고, 둘 다 읽는 것은 하나만 읽는 것보다 나쁩니다.
- `label`이 있으면 그 이름을 가진 이미지 노드가 됩니다. 글리프가 혼자서 뜻을 나르고 있을 때만 넘기세요.
- 세 번째 경우는 없습니다. 장식용 글리프에 이름을 붙이는 것은 스크린리더가 "그래픽"이라고 말하게 되는 가장 흔한 경로입니다.
- 버튼 전체가 아이콘 하나라면 아이콘은 버튼 옆이 아니라 버튼 안에 있어야 합니다. `PlButton`에 `semanticLabel`을 주고 아이콘에는 이름을 붙이지 마세요.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `color="inherit"` | `color: null` | Dart에는 `inherit` 키워드가 없고, nullable enum이 이름 하나를 덜 쓰고 같은 말을 합니다. |
| `aria-label` | `label` | 이름은 그대로이고 하는 일도 같습니다 — 다만 만들어지는 것은 `role`이 아니라 이미지 노드입니다. |
| `className`, `style`, 네이티브 속성 | — | 전달할 클래스 목록도 style 속성도 없습니다. |

라이브러리는 여전히 아이콘 세트를 그리지 않습니다. Flutter는 Material 밖에 아이콘 세트를 두지 않고 이 패키지는 Material을 가져오지 않으므로, 이 미리보기의 글리프는 갤러리가 직접 그린 것입니다 — 앱이 자기가 고른 세트로 하는 일 그대로입니다.

:::
