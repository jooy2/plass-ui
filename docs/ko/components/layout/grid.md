---
title: PlGrid
order: 3
---

# PlGrid

<p class="plass-lede">12칸짜리 한 줄과 그 안의 칸들입니다. 칸 수와 두 방향의 간격은 줄이 들고, 한 칸이 몇 칸을 차지하는지는 칸이 듭니다. 그리고 그 값은 브레이크포인트마다 달라질 수 있습니다.</p>

<Demo src="grid/hero" :min-height="260" />

::: fw react

```tsx
import { PlGrid, PlGridItem } from 'plass-ui';

<PlGrid spacing={3}>
  <PlGridItem span={{ xs: 12, md: 8 }}>{main}</PlGridItem>
  <PlGridItem span={{ xs: 12, md: 4 }}>{aside}</PlGridItem>
</PlGrid>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlGrid(
  spacing: const PlassResponsive<double>(3),
  items: <PlGridItem>[
    PlGridItem(span: const PlassResponsive<int>(12, md: 8), child: main),
    PlGridItem(span: const PlassResponsive<int>(12, md: 4), child: aside),
  ],
);
```

:::

## Props

<PropsTable name="PlGrid" />

### PlGridItem

<PropsTable name="PlGridItem" />

::: fw react

네이티브 `<div>` 속성은 둘 다 그대로 전달됩니다.

:::

::: fw flutter

`PlGridItem`은 위젯이 아니라 **설명**입니다. 이 패키지가 아코디언의 접힘과 테이블의 열에 이미 쓰고 있는 관용구이고, 여기 있는 이유도 같습니다 — 그리드는 각 칸이 몇 칸을 쓰는지를 보고 줄로 묶는데, `Widget`은 불투명합니다. 위젯에게 "너는 얼마나 넓을 셈이냐"고 물을 방법이 없습니다.

:::

둘 다 `variant`도 `color`도 `elevation`도 `size`도 `density`도 받지 않습니다. 그리드는 표면이 아니라 그 안에 든 표면들의 배치이고, 시트를 그리는 칸은 `span`을 시각적 결정으로 만들어 버립니다. 여기에는 패딩도 없습니다. 페이지 둘레의 여백은 [`PlContainer`](./container)의 것이고 내용 둘레의 여백은 `PlCard`의 것이라, 그리드까지 자기 트랙을 들면 맞춰 둘 트랙이 셋이 됩니다. 이 컴포넌트가 가진 유일한 치수는 `spacing`이고, 칸 *사이*의 자리입니다.

## Examples

### span

한 칸의 너비는 줄의 `columns` 중 `span`만큼입니다. 그래서 `span={6}`은 기본 12칸의 절반이고 `columns={24}`의 4분의 1입니다.

줄보다 넓은 span은 페이지 밖으로 넘치지 않고 줄에 맞춰 잘립니다. 호출자가 뜻한 것이 그것이기 때문입니다. `span`이 아예 없는 칸은 줄을 다 채웁니다.

<Demo src="grid/span" :min-height="300">

::: fw react

<<< @/.vitepress/demos/grid/span.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/grid/span.dart

:::

</Demo>

### 반응형 값

`span` · `offset` · `columns`, 그리고 세 가지 간격은 반응형 값을 받습니다. 각 항목은 **자기 브레이크포인트부터 위로** 적용되어서, 보통 두 개면 레이아웃 하나가 설명됩니다.

::: fw react

값 하나는 어디서나 적용되고, 맵은 브레이크포인트별입니다. <code v-pre>span={{ xs: 12, md: 6 }}</code>은 폰에서 전체 너비, 48rem부터 절반입니다.

맵은 "여기부터는 이것으로"이지 "그 아래에는 아무것도"가 아닙니다. `md`만 적어도 그 아래에는 prop의 기본값이 그대로 살아 있고, CSS의 폴백으로 조용히 떨어지지 않습니다.

:::

::: fw flutter

Dart에는 "숫자 또는 맵"을 담을 유니온 타입이 없습니다. 그래서 `PlassResponsive<T>`이고, 기준값이 위치 인자, 덮어쓰기가 이름 인자입니다. `PlassResponsive<int>(12, md: 6)`은 폰에서 전체 너비, 768부터 절반입니다. 기준값이 위치 인자라는 점이 흔한 경우를 짧게 유지합니다 — `PlassResponsive(6)`이 "어디서나 여섯 칸"의 전부입니다. 그리고 그 덕분에 "그 아래에는 아무것도"를 실수로 쓸 수가 없습니다.

브레이크포인트는 그리드 자기 상자가 아니라 **창**을 기준으로 풀립니다. CSS 미디어 쿼리가 재는 것이 그것이고, 그래서 카드 세 겹 안에 중첩된 그리드도 화면의 나머지와 같은 너비에서 모양을 바꿉니다.

:::

너비는 Tailwind의 것 그대로입니다 — <Fw react="sm 40rem, md 48rem, lg 64rem, xl 80rem" flutter="sm 640, md 768, lg 1024, xl 1280" />, `xs`는 0부터. 그래서 Plass 그리드와 `md:` 유틸리티가 같은 순간에 바뀝니다. 16px 루트 기준의 `rem`과 논리 픽셀은 같은 길이라, 두 패키지는 같은 너비에서 꺾입니다.

<Demo src="grid/responsive" :min-height="240">

::: fw react

<<< @/.vitepress/demos/grid/responsive.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/grid/responsive.dart

:::

</Demo>

### offset

칸 **앞**에 비워 두는 칸 수입니다. 줄 안의 절대 위치가 아니라 앞으로 밀어 넣는 자리입니다. 12칸 줄의 첫 번째에서 `span={4}`에 `offset={4}`는 가운데 3분의 1이고, 이미 네 칸을 쓴 칸 뒤에서 같은 offset은 네 칸을 더 건너뛰어 마지막 3분의 1에 놓입니다.

<Demo src="grid/offset" :min-height="200">

::: fw react

<<< @/.vitepress/demos/grid/offset.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/grid/offset.dart

:::

</Demo>

### spacing

Material의 8px가 아니라 Tailwind의 spacing 스케일입니다. 간격 `4`는 <Fw react="1rem" flutter="논리 픽셀 16" />이고, 그것은 `gap-4`가 이미 뜻하는 길이이자 패딩 표가 이미 쓰는 값입니다. 분수가 핵심입니다 — `1.5`는 `0.375rem`입니다. 이 라이브러리의 다른 모든 수가 그 사다리 위에 있고, 둘레의 카드와 다른 방식으로 간격을 재는 그리드는 호출자가 멈춰서 환산해야 하는 유일한 지점이 됩니다.

`rowSpacing`과 `columnSpacing`은 각각 한 축만 덮어쓰고, 없으면 `spacing`으로 떨어집니다.

간격은 줄이 아니라 **칸**에서 빠져나옵니다. 그래서 절반 둘에 간격 하나를 더하면 정확히 줄의 너비이고, 그리드는 옆에 있는 것에 딱 붙을 수 있습니다.

<Demo src="grid/spacing" :min-height="300">

::: fw react

<<< @/.vitepress/demos/grid/spacing.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/grid/spacing.dart

:::

</Demo>

### alignItems, alignContent, alignSelf

`alignItems`는 한 줄 안에서 칸들이 서로에 대해 어떻게 놓이는가이고, 기본값은 `stretch`입니다. 아무도 시키지 않았는데 카드 한 줄의 높이가 맞는 이유가 그것입니다. `alignSelf`는 그것을 칸 하나에서만 덮어씁니다. `alignContent`는 그리드가 담긴 상자보다 짧을 때 줄들이 어디에 놓이는가이고, 자기 높이를 가진 그리드에서만 보입니다.

::: fw flutter

`alignSelf`에는 `baseline`이 없습니다. CSS는 기준선을 항목마다 풀지만, Flutter의 줄은 하나의 기준선으로 정렬되거나 아예 정렬되지 않습니다. 그래서 줄이 쓰지 않는 기준선에 칸 하나만 올라탈 수가 없습니다. `alignItems`는 여전히 받습니다.

:::

<Demo src="grid/alignment" :min-height="220">

::: fw react

<<< @/.vitepress/demos/grid/alignment.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/grid/alignment.dart

:::

</Demo>

## 중첩

그리드는 **칸** 안에 들어갑니다. 칸이면서 동시에 그리드인 것이 아닙니다. 안쪽 그리드는 자기 서브트리에 대해 칸 수를 다시 선언하고, 그것을 감싼 칸은 바깥 그리드가 준 너비를 그대로 지킵니다. 8칸짜리 영역을 바깥의 12칸에 대고 계산하지 않고도 3등분할 수 있는 이유가 그것입니다.

::: fw flutter

## 구성

`PlGrid`는 `Column` 안에 줄마다 `Row` 하나를 만들고, 너비를 비교하는 대신 **칸 수**를 세어 줄로 묶습니다. 모든 칸이 정수 개의 칸이라서, 칸을 세는 것은 `double` 둘을 비교할 때처럼 반올림된 픽셀 하나로 스스로와 어긋날 수가 없습니다.

한 칸의 너비는 줄의 몫이므로, 칸을 만들기 전에 줄을 재야 합니다. 그것이 `LayoutBuilder`입니다. 계산은 React 패키지의 것을 그대로 풀어 쓴 것 — `(width + gap) / columns × span − gap` — 이고, 나누기 전에 간격 하나를 더해 두는 것이 모든 칸이 하나씩 돌려줄 수 있게 만듭니다. 그래서 칸 수의 합이 전체 칸 수와 같은 줄은 정확히 줄의 너비입니다.

모든 줄은 `IntrinsicHeight` 안에서 **stretch**로 배치되고, 각 칸은 받은 높이 안에서 자리를 잡습니다. `alignSelf`가 표현 가능해지는 지점이 그것입니다. Flutter에는 자식별 교차축 정렬이 없어서, stretch가 아닌 칸은 자식 하나를 한쪽 끝에 붙들고 있는 전체 높이짜리 `Column`입니다.

:::

::: fw react

## 구성

`PlGrid`는 flex 한 줄이고 `PlGridItem`은 그 안의 너비입니다. CSS에 자체 그리드가 생기기 훨씬 전부터 12칸 그리드가 가져온 모양이고, 지금도 칸이 명시적인 라인 번호 없이 시작 offset을 들 수 있고 줄에 "줄바꿈하지 마라"를 시킬 수 있는 유일한 모양입니다.

칸이 스스로 알 수 없는 세 수, 곧 칸 수와 두 방향의 간격은 React 컨텍스트가 아니라 **상속되는 커스텀 속성**으로 내려갑니다. 그 값들은 반응형이고, 미디어 쿼리는 React가 모르는 사이에 상속된 커스텀 속성을 바꿀 수 있습니다. 그래서 칸이 배치 기준으로 삼는 칸 수는 언제나 지금 화면에 있는 수입니다. 컨텍스트로 같은 말을 하려면 브레이크포인트마다 트리를 다시 렌더링해야 합니다.

너비 자체는 `(100% + gap) × span / columns − gap`이고, 클래스 이름이 아니라 스타일시트에 있습니다. `columns`는 호출자가 고르는 수이고 `span`은 네 지점에서 바뀌므로 클래스는 런타임에 조립되어야 하는데, 런타임에 조립되는 클래스 이름은 Tailwind가 결코 보지 못하는 이름입니다.

:::

## Accessibility

- 둘 다 role도 시맨틱 노드도 붙이지 않습니다. 그리드는 배치이고, 배치는 스크린 리더가 읽어야 할 것이 아닙니다.
- 문서 순서가 곧 읽는 순서입니다. `offset`은 줄의 순서를 바꾸지 않고 여백으로 칸을 밀기 때문에, 스크린 리더가 읽는 것과 눈으로 보는 것이 같은 차례로 남습니다.

::: fw react

- 줄에 `render={<ul />}`, 칸에 `render={<li />}`는 정말로 목록인 것들의 그리드가 그렇다고 말하는 방법입니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `<PlGridItem>` children | `items: List<PlGridItem>` | 그리드는 각 칸이 쓰는 칸 수를 보고 줄로 묶는데 `Widget`은 불투명합니다. 설명 목록은 `PlAccordion`과 `PlTable`이 이미 쓰는 관용구입니다. |
| 값 하나 또는 맵 | `PlassResponsive<T>` | Dart에는 유니온 타입이 없습니다. 기준값이 위치 인자라 `PlassResponsive(6)`은 짧게 유지됩니다. |
| `alignSelf="baseline"` | — | CSS는 기준선을 항목마다 풀지만 Flutter의 줄은 하나의 기준선으로 정렬되거나 아예 아닙니다. `alignItems`는 여전히 받습니다. |
| `justify="space-between"` | `PlassJustify.spaceBetween` | Dart의 enum 값은 lowerCamelCase입니다. 같은 값, 같은 뜻입니다. |
| `wrap={false}`은 넘칩니다 | `wrap: false`는 옆으로 스크롤합니다 | Flutter 화면에는 스크롤을 맡길 페이지 단위의 넘침이 없고, 넘치는 `Row`는 독자가 닿을 수 있는 것이 아니라 디버그 배너입니다. |
| `className`, `style` | — | 전달할 클래스 목록도 style 속성도 없습니다. |

:::
