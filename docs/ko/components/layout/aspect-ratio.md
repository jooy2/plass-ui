---
title: PlAspectRatio
order: 1
---

# PlAspectRatio

<p class="plass-lede">어떤 너비를 받든 비율을 지키는 상자입니다. 아무것도 그리지 않습니다. 하는 일은 자리를 미리 잡아 두는 것이고, 그래서 늦게 도착한 사진이 페이지를 다시 흐트러뜨리지 않습니다.</p>

<Demo src="aspect-ratio/hero" :min-height="240" />

::: fw react

```tsx
import { PlAspectRatio } from 'plass-ui';

<PlAspectRatio ratio="16 / 9" rounded>
  <img src="/cover.jpg" alt="" />
</PlAspectRatio>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlAspectRatio(
  ratio: 16 / 9,
  rounded: true,
  child: Image(image: cover),
);
```

:::

## Props

<PropsTable name="PlAspectRatio" />

::: fw react

네이티브 `<div>` 속성은 그대로 전달됩니다.

:::

::: fw flutter

`ratio`는 `double`이고 `16 / 9`처럼 나눗셈으로 씁니다. Flutter가 다른 곳에서도 종횡비를 말하는 방식입니다. 그리고 값을 자르지 않고 단언합니다 — 0인 비율은 모양이 아니라 실수입니다.

:::

여기서 공유 축은 `size` 하나뿐이고, 그 `size`는 *시트*의 크기입니다 — `rounded`가 어떤 반경 단계를 쓸지를 정합니다. `variant`도 `color`도 `elevation`도 없습니다. 표면을 그리는 레이아웃 컴포넌트는 비율을 시각적 결정으로 만들어 버립니다. 라이브러리 전체에서 공유 축이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### ratio

CSS의 `aspect-ratio` 그대로입니다. 숫자든 비든 쓴 그대로 속성에 닿습니다. 이미 `16 / 9`를 알고 있는 사람이 따로 찾아볼 것이 없습니다.

<Demo src="aspect-ratio/ratios" :min-height="220">

::: fw react

<<< @/.vitepress/demos/aspect-ratio/ratios.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/aspect_ratio/ratios.dart

:::

</Demo>

### fit

비율 위에 얹힌 단 하나의 편의입니다. 네 단어는 `object-fit`의 것 그대로입니다 — `cover`는 상자를 채우고 넘치는 것을 잘라 내고, `contain`은 레터박스를 만들며, `fill`은 늘이고, `none`은 제 크기 그대로 그립니다.

썸네일이 원하는 것은 `cover`입니다. 스스로 레터박스를 만드는 썸네일은 회색 띠 두 줄이 든 썸네일이기 때문입니다. `contain`은 그림 전체가 의미인 경우 — 도해, 로고, 스캔 — 를 위한 것입니다.

::: fw react

직계 자식인 `img` · `video` · `canvas` · `svg` · `picture` 하나를 상자 전체로 늘린 다음 맞춥니다. 이 컴포넌트를 쓸 때마다 맨 앞에 쓰게 되는 선언 두 줄이 바로 그것입니다. 그 밖의 것은 보통대로 배치되고 `fit`이 닿지 않습니다. `iframe`은 크기는 받지만 맞춤은 받지 않습니다. 임베드는 자기 내용을 스스로 배치하므로 `object-fit`이 작용할 대상이 없습니다.

:::

::: fw flutter

**여기서는 기본값이 `null`입니다. React의 기본값은 `cover`입니다.** 브라우저에서 `object-fit`은 대체 요소만 응답하는 속성이라, React는 기본값을 주어도 글이 든 `<div>`에는 조용히 닿지 않습니다. Flutter에는 그런 구분이 없습니다 — 여기서 맞춤은 자식이 무엇이든 그 둘레의 `FittedBox`이고, 기본으로 걸리면 글 한 단까지 늘어납니다. 그래서 요청해야만 걸리고, 걸리면 무엇에든 걸립니다.

이미 자기 `BoxFit`을 들고 있는 `Image`라면 여기서 줄 것이 없습니다.

:::

<Demo src="aspect-ratio/fit" :min-height="240">

::: fw react

<<< @/.vitepress/demos/aspect-ratio/fit.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/aspect_ratio/fit.dart

:::

</Demo>

### rounded

기본은 꺼져 있습니다. 모서리를 깎은 사진은 상자가 아니라 사진에 대한 결정입니다. 다만 그 결정이 워낙 흔해서, 그것 하나 때문에 <Fw react="className" flutter="ClipRRect" />을 잡게 만드는 것은 심술입니다. 그래서 boolean이고, 단계는 `size`가 고릅니다.

깎든 안 깎든 상자는 넘치는 것을 잘라 냅니다. 그러지 않으면 `cover` 자식이 방금 받은 비율 밖으로 그대로 흘러나가고, 컴포넌트는 자리만 잡아 둘 뿐 아무것도 붙들지 못합니다.

<Demo src="aspect-ratio/embed" :min-height="240">

::: fw react

<<< @/.vitepress/demos/aspect-ratio/embed.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/aspect_ratio/embed.dart

:::

</Demo>

## Accessibility

- 상자는 자기 role도, 자기 시맨틱 노드도 만들지 않습니다. 치수일 뿐이고, 치수는 스크린 리더가 읽어야 할 것이 아닙니다.
- 안에 든 그림에 대한 설명은 여기서 주지 않습니다. 그 그림은 호출자의 것이고, 그것이 무엇을 뜻하는지도 호출자의 몫입니다.

::: fw react

- `render`는 상자가 내용이 실제로 요구하는 요소가 되는 방법입니다 — 캡션이 딸린 사진이면 `<figure>`, 카드의 커버라면 `<a>`.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `fit` 기본값 `'cover'` | `fit` 기본값 `null` | `object-fit`은 대체 요소에만 닿아서 React는 기본값을 주어도 해가 없습니다. `FittedBox`는 받은 것에 무엇이든 닿고, 기본으로 걸리면 글 한 단까지 늘어납니다. |
| `ratio`가 `'16 / 9'` | `ratio`가 `16 / 9` | 나눗셈으로 쓰는 `double`이고, Flutter가 다른 곳에서도 종횡비를 말하는 방식입니다. 파싱할 문자열 형태가 없습니다. |
| `render` | — | 바꿔 끼울 요소가 없습니다. 링크나 figure여야 하는 위젯은 그것으로 감쌉니다. |
| `children` | `child` | Flutter의 이름입니다. |
| `className`, `style` | — | 전달할 클래스 목록도 style 속성도 없습니다. |

:::
