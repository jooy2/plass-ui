---
title: PlDivider
order: 4
---

# PlDivider

<p class="plass-lede">두 가지 사이에 놓이는 선입니다. children이 없으면 헤어라인 하나와 진짜 <code>role="separator"</code>이고, children이 있으면 선이 라벨을 둘러싸며 끊어집니다.</p>

<Demo src="divider/hero" :min-height="160" />

::: fw react

```tsx
import { PlDivider } from 'plass-ui';

<PlDivider />;
<PlDivider>OR</PlDivider>;
<PlDivider orientation="vertical" />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlDivider();
const PlDivider(child: Text('OR'));
const PlDivider(orientation: PlassOrientation.vertical);
```

:::

## Props

<PropsTable name="PlDivider" />

::: fw react

네이티브 `<div>` 속성은 그대로 전달됩니다. `color`와 `children`은 둘 다 여기서는 Plass의 prop이라 전달 대상에서 제외됩니다.

:::

::: fw flutter

`color`는 `PlassColor?`이고 기본값은 `null`입니다. `undefined`가 없는 언어에서 "계열 없음, 중립 헤어라인"을 쓰는 방법입니다.

:::

`variant`도 `elevation`도 없습니다. divider는 표면이 아닙니다. 유리로 만들어지지 않았고, 빛을 받지 않으며, 그림자를 드리우지도 않습니다.

라이브러리 전체에서 공유 축(`orientation` `color` `size` `textAlign`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### orientation

vertical divider는 자기 높이를 가지지 않습니다. 높이를 주는 무언가에 맞춰 늘어나며, 이것이 툴바의 두 그룹 사이에 놓인 선이 해야 할 일입니다. 놓인 행보다 짧아야 한다면 `length`를 주세요.

::: fw flutter

"높이를 주는 무언가"가 CSS보다 더 많은 일을 합니다. `Row`는 자기가 받은 높이를 자식에게 그대로 넘기므로, 그 안의 vertical divider에는 늘어날 대상이 생기려면 위에 `IntrinsicHeight`가(또는 `length`가) 있어야 합니다. 아래 예제는 앞의 방법을 씁니다.

:::

<Demo src="divider/orientation" :min-height="200">

::: fw react

<<< @/.vitepress/demos/divider/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/divider/orientation.dart

:::

</Demo>

### children과 textAlign

`center`는 선을 반으로 나눕니다. `start`와 `end`는 가까운 쪽에 짧은 선을 남겨, 라벨이 선 위에 떠 있는 것이 아니라 선 _안에_ 놓인 것으로 읽히게 합니다.

<Demo src="divider/label" :min-height="200">

::: fw react

<<< @/.vitepress/demos/divider/label.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/divider/label.dart

:::

</Demo>

### color

기본값이 없습니다. `PlTextLink`가 하는 것과 같은 선택입니다. 생략하면 중립 헤어라인이 그려집니다. 페이지 바탕이든 유리 시트든 카드 위든, 라이브러리가 가진 모든 바탕에서 보이는 선입니다. 시트 자신의 흰 헤어라인은 반투명한 판 위의 흰 빛이라, divider가 불투명한 것 위에 놓이는 순간 사라집니다.

색 계열을 주면 선에 그 틴트가 들어갑니다.

<Demo src="divider/colors" :min-height="240">

::: fw react

<<< @/.vitepress/demos/divider/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/divider/colors.dart

:::

</Demo>

### length와 thickness

`width`가 아니라 `length`인 이유는, divider가 긴 축이 `orientation`을 따라 도는 유일한 컴포넌트이기 때문입니다.

::: fw react

숫자는 px이고, 문자열은 임의의 CSS 길이라 `'50%'`와 `'12rem'`이 모두 동작합니다.

:::

::: fw flutter

둘 다 `double`입니다. 패키지의 다른 모든 길이와 같은 논리 픽셀입니다. 퍼센트는 없습니다. 부모의 몇 분의 몇은 divider를 `FractionallySizedBox`로 감싸는 일이고, 그 두 번째 표기를 컴포넌트 안에 또 만드는 것은 표기를 둘로 만드는 일입니다.

`length`는 부모가 준 tight 제약을 이깁니다. 맨 `SizedBox`라면 그러지 못합니다. divider는 `crossAxisAlignment: stretch`인 `Column` 안에 놓이는 일이 아주 흔하고 거기서는 tight한 너비를 받아 지기 때문에, 상자를 `Align`으로 감싸 느슨한 제약이 내려가게 했습니다.

:::

<Demo src="divider/length" :min-height="200">

::: fw react

<<< @/.vitepress/demos/divider/length.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/divider/length.dart

:::

</Demo>

### size

`size`는 라벨의 타입 스케일이고 그뿐입니다. 라벨이 없는 divider에는 정할 크기가 없습니다.

<Demo src="divider/sizes" :min-height="240">

::: fw react

<<< @/.vitepress/demos/divider/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/divider/sizes.dart

:::

</Demo>

## Accessibility

::: fw react

- Base UI의 `Separator`를 렌더링하므로, 알맞은 `aria-orientation`이 붙은 진짜 `role="separator"`입니다.
- `separator`는 내용에서 이름을 가져오는 role이 아니라, 눈에 보이는 라벨이 그것만으로 접근 가능한 이름이 되지는 않습니다. **문자열** 라벨은 `aria-label`로 복사되고, 그보다 복잡한 것은 그대로 둡니다. 그중 어느 부분이 이름인지는 호출하는 쪽만 압니다.
- 순전히 장식인 divider(이미 여백으로 나뉘어 있는 카드 안의 선) 에는 `role="presentation"`을 주는 편이 낫고, 이 값은 그대로 전달됩니다.
- 라벨 양옆의 두 선 조각은 `aria-hidden`입니다. 라벨은 separator의 이름으로 한 번만 읽힙니다.

:::

::: fw flutter

- divider는 `semanticLabel`을 주지 않는 한 아무 말도 하지 않습니다. 정직한 기본값입니다. 두 가지 사이의 선은 대개 내용이 아니라 레이아웃이 하는 말입니다.
- 이름을 주면 그 이름이 붙은 semantics 노드가 됩니다. 선이 뜻을 나르고 있을 때 넘기세요. 두 로그인 경로 사이의 "OR"은 그렇고, 카드 안의 선은 아닙니다.
- 선 안에 놓인 라벨은 그대로 텍스트로 그려지므로 있는 자리에서 읽힙니다. `semanticLabel`은 divider 자신을 위한 것입니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `aria-orientation`이 붙은 `role="separator"` | 이름이 붙은 semantics 노드, 또는 없음 | Flutter의 semantics 트리에는 separator role이 없습니다. 이름 없는 선은 장식이고, 트리에 들어가지 않는 것으로 그렇게 알립니다. |
| `children` | `child` | Flutter의 이름입니다. |
| 문자열 라벨이 `aria-label`이 됨 | `semanticLabel` | `Widget`의 어느 부분이 이름인지는 여기서 알 수 없으니, 추측하는 대신 물어봅니다. |
| CSS 길이로서의 `length`/`thickness` | `double` | 패키지의 다른 모든 곳과 같은 논리 픽셀입니다. 부모의 몇 분의 몇은 `FractionallySizedBox`입니다. |
| `className`, `style` | — | 전달할 클래스 목록도 style 속성도 없습니다. |

:::
