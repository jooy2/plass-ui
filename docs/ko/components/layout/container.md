---
title: PlContainer
order: 2
---

# PlContainer

<p class="plass-lede">좌우 여백을 주고, 원하면 최대 너비까지 정해 줍니다. 페이지에서 가장 바깥에 놓이는 요소이고, 바로 그래서 아무것도 그리지 않습니다.</p>

<Demo src="container/hero" :min-height="200" />

::: fw react

```tsx
import { PlContainer } from 'plass-ui';

<PlContainer maxWidth="lg" render={<main />}>
  {page}
</PlContainer>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlContainer(
  maxWidth: const PlassResponsive<PlContainerWidth?>(PlContainerWidth.rung(PlassSize.lg)),
  child: page,
);
```

:::

## Props

<PropsTable name="PlContainer" />

::: fw react

네이티브 `<div>` 속성은 그대로 전달됩니다.

:::

::: fw flutter

`maxWidth`는 `PlassResponsive<PlContainerWidth?>`를 받습니다. `PlContainerWidth.rung(PlassSize.lg)`는 사다리의 한 칸이고 `PlContainerWidth.pixels(720)`은 정확한 너비입니다. nullable 한 쌍이 아니라 생성자 둘인 이유는 둘 중 하나만 참일 수 있고 Dart에는 태그 없는 union이 없기 때문입니다. `null`이 "한계 없음"이고, React는 그것을 `'none'`으로 씁니다. TypeScript의 유니온은 단어를 하나 더 얹을 수 있지만, Dart에는 바로 그 뜻의 `null`이 있습니다.

:::

`variant`도 `color`도 `elevation`도 없습니다. 페이지에서 가장 바깥에 있는 요소는 페이지가 어떻게 보일지를 결정하지 말아야 할 단 하나이고, 시트를 든 컨테이너는 그 위의 모든 카드 뒤에 판을 한 장 더 깔아 버립니다. 시트가 필요하면 `PlCard`로 감싸세요. 라이브러리 전체에서 공유 축이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### maxWidth

브레이크포인트와 같은 사다리입니다. `xs` 30rem, `sm` 40rem, `md` 48rem, `lg` 64rem, `xl` 80rem. 프레임워크의 자체 컨테이너 스케일을 가져오는 대신 `rem`으로 직접 씁니다. 그래야 컨테이너의 `lg`와 `lg:` 유틸리티가 같은 너비에서 바뀝니다. 한 페이지에 `lg`라는 이름의 사다리가 둘이면, 레이아웃은 나중에 아무도 원인을 찾지 못하는 몇 픽셀만큼 어긋나기 시작합니다.

기본값은 <Fw react="'none'" flutter="null" code />입니다. 컨테이너가 하는 일은 여백이고, 최대 너비는 두 번째 결정입니다. 페이지가 요청해야 합니다.

::: fw react

**길이도 그대로 받습니다.** 편의 기능이 아닙니다. 다섯 칸은 `rem`인데, 문단이 실제로 원하는 measure는 *글자 수*입니다. `maxWidth="72ch"`는 어떤 사다리로도 쓸 수 없는 값입니다. 숫자는 픽셀입니다.

**그리고 반응형입니다**. `maxWidth`는 `{ xs: 'none', md: 'lg' }`를 받습니다. JavaScript가 아니라 **CSS**에서 풀리고, 그것이 이 방식이 공짜인 이유입니다. 서버가 보내는 첫 페인트가 이미 모든 너비에서 맞고, 창을 끄는 동안 리렌더가 없습니다. [브레이크포인트](../../design/breakpoints) 참고.

:::

<Demo src="container/widths" :min-height="220">

::: fw react

<<< @/.vitepress/demos/container/widths.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/container/widths.dart

:::

</Demo>

### padded, size, density

여백은 컨트롤 트랙이 아니라 **시트** 트랙입니다. 컨테이너 안에 들어 있는 것은 페이지이고, 페이지가 창 가장자리에서 유지하는 여백은 카드가 문단 둘레에 두는 여백이지 라벨이 자기가 찍힌 키의 가장자리 옆에 필요로 하는 자리가 아닙니다.

여기서 `size`는 시트의 크기입니다. 높이도 타입 스케일도 건드리지 않고, `maxWidth`와도 아무 상관이 없습니다. 그쪽은 내용이 얼마나 넓어지는가이고, 이쪽은 가장자리에서 얼마나 떨어지는가입니다. `padded`를 끄면 여백만 내려놓고 나머지는 그대로 둡니다. 이미 여백을 주는 컨테이너 안에 다시 들어간 컨테이너가 원하는 것이 그것입니다.

여백은 한계의 **안쪽**에서 재어집니다. 그래서 `lg` 컨테이너는 컨테이너 64rem이지, 내용 64rem에 양옆 여백을 더한 것이 아닙니다. <Fw react="번들된 리셋이 이미 걸어 두는 box-sizing: border-box입니다." flutter="ConstrainedBox가 Padding의 안쪽이 아니라 바깥쪽에 앉아 있기 때문입니다." />

<Demo src="container/padding" :min-height="280">

::: fw react

<<< @/.vitepress/demos/container/padding.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/container/padding.dart

:::

</Demo>

### centered

기본은 켜져 있고, `maxWidth`가 화면보다 좁아지기 전까지는 아무 일도 하지 않습니다. 최대 너비가 없으면 가운데로 놓을 남는 자리도 없습니다.

꺼면 내용은 왼쪽이 아니라 **시작하는 쪽** 가장자리에 붙습니다. RTL에서는 오른쪽으로 갑니다.

<Demo src="container/centered" :min-height="260">

::: fw react

<<< @/.vitepress/demos/container/centered.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/container/centered.dart

:::

</Demo>

## Accessibility

- 자기 role도, 자기 시맨틱 노드도 만들지 않습니다. 컨테이너는 여백이고, 여백은 스크린 리더가 읽어야 할 것이 아닙니다.

::: fw react

- `render={<main />}`은 이 상자가 페이지에 실제로 필요한 랜드마크가 되는 방법입니다. 그것은 문서에 대한 결정이라서 컴포넌트가 절대 넘겨짚지 않습니다. 한 페이지에 `<main>`이 둘이면 아예 없는 것보다 나쁩니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `maxWidth="none"` | `maxWidth: null` | Dart에는 이미 "설정하지 않음"에 해당하는 말이 있고, 여섯 번째 값이 들어간 `PlassSize`는 두 번째 크기 사다리가 됩니다. |
| `render` | — | 바꿔 끼울 요소도, 선언할 랜드마크 role도 없습니다. 스캐폴드가 필요한 앱은 이것을 그 안에 넣습니다. |
| `children` | `child` | Flutter의 이름입니다. |
| `className`, `style` | — | 전달할 클래스 목록도 style 속성도 없습니다. |

최대 너비 사다리는 단위까지 같은 사다리입니다. React 패키지는 16px 루트 기준의 `rem`으로 쓰고, 논리 픽셀은 같은 단위입니다. `sm`은 그쪽에서 `40rem`, 여기서 640입니다.

:::
