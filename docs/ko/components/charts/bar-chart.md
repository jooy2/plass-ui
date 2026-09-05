---
title: PlBarChart
order: 3
---

# PlBarChart

<p class="plass-lede">비교되는 길이입니다. 막대는 <em>얼마나</em>를 말하고, 더 길어지는 것으로 그것을 말합니다. 축이 0에서 시작하고 그 점만은 설득당하지 않는 이유가 그것입니다.</p>

<Demo src="bar-chart/hero" :min-height="320" />

::: fw react

```tsx
import { PlBarChart } from 'plass-ui';

<PlBarChart series={revenue} categories={regions} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlBarChart(series: revenue, categories: regions);
```

:::

축을 자르면 두 배 긴 막대가 두 배를 뜻하기를 그만두고, 읽는 사람은 그런 일이 있었는지 알 길이 없습니다. 각 값의 크기가 아니라 변화의 모양이 중요하다면 [선 차트](./line-chart)를 쓰세요.

## Props

<PropsTable name="PlBarChart" />

데이터는 모든 차트가 받는 같은 [`PlassChartSeries`](./line-chart#plasschartseries)입니다. 여기서도 `null`은 빈 곳이고, 그런 값에는 막대를 **그리지 않습니다**. 이 차트에서 가장 중요한 구분입니다. 길이 0인 막대와 없는 막대는 같은 그림이고, 그중 정직한 것은 하나뿐이니까요.

라이브러리 전체에서 공유 축이 뜻하는 바는 [prop 규약](../../design/prop-conventions)에 있습니다.

## Examples

### orientation

category 이름이 낱말이라면 `horizontal`이 맞습니다. 이름을 위한 열이 통째로 있고, 세로 차트에는 막대 하나의 너비밖에 없습니다.

<Demo src="bar-chart/orientation" :min-height="320">

::: fw react

<<< @/.vitepress/demos/bar-chart/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/bar_chart/orientation.dart

:::

</Demo>

모든 것이 함께 바뀝니다. 각 축이 어느 띠를 잡는지, 격자가 어느 방향인지, crosshair가 어느 쪽으로 가는지, 막대의 어느 끝이 둥근지.

### stacked

나란한 막대는 "여기서 어느 series가 더 큰가"에 답합니다. 쌓인 막대는 "이 합계는 무엇으로 이루어졌나"에 답합니다. 서로 다른 질문이고, 차트에는 한 번에 하나만 물어야 합니다.

<Demo src="bar-chart/stacked" :min-height="400">

::: fw react

<<< @/.vitepress/demos/bar-chart/stacked.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/bar_chart/stacked.dart

:::

</Demo>

`'full'`은 모든 막대를 같은 길이로 만들어 차트를 크기가 아니라 **비중**에 대한 것으로 바꿉니다. [면적 차트](./area-chart)와 똑같고, 같은 이유로 그림이 아니라 데이터를 정규화합니다.

쌓인 두 조각 사이의 간격은 각자의 먼 쪽 끝에서 떼어 냅니다. 그래야 쌓인 전체가 여전히 옳은 길이가 되고, 이음매가 그 위에 그은 선이 아니라 **비쳐 보이는 시트**가 됩니다. 막대를 두른 테두리는 데이터가 아닌 잉크입니다.

### 음수

두 팔은 따로 누적되므로, 내려가는 series가 위의 것을 짧게 만들지 않습니다. 음수 막대는 기준선에서 아래로, 양수는 위로 자랍니다.

<Demo src="bar-chart/negative" :min-height="320">

::: fw react

<<< @/.vitepress/demos/bar-chart/negative.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/bar_chart/negative.dart

:::

</Demo>

**기준선은 막대 위에 다시 그립니다.** 모든 막대가 거기서 시작하고 그 선이 그렇다고 말합니다. 아래에 두면 막대마다 첫 픽셀에 반쯤 가려집니다.

### rounded

모서리는 각 막대의 **데이터** 쪽 끝에서만 깎입니다. 기준선 쪽은 각진 채로 둡니다. 값이 시작하는 곳이고, 둥근 발은 축을 물결지게 만듭니다.

### barSize와 density

`barSize`는 너비가 아니라 상한입니다. 막대가 앉는 band는 plot을 category 수로 나눈 것이고, 상한 아래에서는 그 몫을 채우며, 넘으면 남는 만큼이 여백으로 남습니다. `density`는 막대가 애초에 band에서 차지할 수 있는 비율입니다.

## Accessibility

[`PlLineChart`](./line-chart#accessibility)가 말하는 모든 것이 그대로 적용됩니다. 이름과 series별 요약, 진짜 컨트롤인 범례, 그리고 React 쪽의 숨은 표.
