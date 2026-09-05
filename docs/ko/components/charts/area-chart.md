---
title: PlAreaChart
order: 2
---

# PlAreaChart

<p class="plass-lede">아래 공간이 채워진 선입니다. 그 채움이 차트의 주제를 바꿉니다. 선은 값이 어디로 갔는지를 말하고, 면적은 무언가가 얼마나 있었는지를, 쌓으면 그 양이 무엇으로 이루어졌는지를 말합니다.</p>

<Demo src="area-chart/hero" :min-height="320" />

::: fw react

```tsx
import { PlAreaChart } from 'plass-ui';

<PlAreaChart series={traffic} categories={months} stacked />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlAreaChart(
  series: traffic,
  categories: months,
  stacking: PlAreaStacking.total,
);
```

:::

[선 차트](./line-chart) 대신 이것을 쓸지 판단하는 기준은 그것뿐입니다. 그 양이 무엇으로도 합쳐지지 않는다면 — 온도, 비율, 점수 — 아래의 채움은 장식이고, 그런 것이 둘 있는 차트는 서로 싸우는 두 개의 wash입니다.

## Props

<PropsTable name="PlAreaChart" />

데이터는 모든 차트가 받는 같은 [`PlassChartSeries`](./line-chart#plasschartseries)이고, 여기서도 `null`은 빈 곳입니다. 오히려 더 눈에 띕니다. 없는 달을 가로질러 닫힌 채움은 이어 붙인 선보다 더 넓은 면적에 지어낸 숫자를 칠하니까요.

라이브러리 전체에서 공유 축이 뜻하는 바는 [prop 규약](../../design/prop-conventions)에 있습니다.

## Examples

### stacked

각 띠가 아래 것들의 합계 위에 올라타고, 맨 위 가장자리가 합입니다. 쌓은 면적 차트가 대개 그것을 보이려고 그려지는 것이니까요.

**쌓인 띠에는 위쪽 선을 따로 긋지 않습니다.** 그러면 위의 띠가 색 있는 선으로 분리되고, 두 마크 사이의 선은 데이터가 아닌 잉크입니다. 둘을 가르는 것은 아래의 간격입니다.

### 크기가 아니라 비중

`'full'`은 각 category를 100%로 정규화해서, 차트가 크기가 아니라 **비중**에 대한 것이 되게 합니다. 값 축은 백분율이 되고 그렇다고 말합니다.

<Demo src="area-chart/share" :min-height="320">

::: fw react

<<< @/.vitepress/demos/area-chart/share.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/area_chart/share.dart

:::

</Demo>

정규화는 그림이 아니라 **데이터**에 대한 변경입니다. 축과 툴팁과 표가 모두 그 숫자가 비중이라는 데 동의하게 하는 것이 그것입니다. 툴팁은 넘긴 원래 숫자를 그대로 지닙니다 — 백분율밖에 말하지 못하는 차트는 데이터를 버린 차트입니다.

::: fw flutter

`stacking`은 React의 `boolean | 'full'` 대신 세 상태를 가진 enum 하나입니다. Dart에는 union 타입이 없고, 예외를 덧붙인 boolean보다 이름 붙은 세 상태가 낫습니다.

:::

### 쌓지 않은 띠는 겹칩니다

쌓지 않으면 각 띠가 기준선에서 시작해 서로 위에 놓입니다. 채움은 판이 아니라 **아래로 흐려지는 wash**입니다. 둘이 겹쳐도 읽히고, 값을 나르는 것은 위쪽의 선입니다.

<Demo src="area-chart/overlap" :min-height="320">

::: fw react

<<< @/.vitepress/demos/area-chart/overlap.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/area_chart/overlap.dart

:::

</Demo>

쌓인 띠는 대신 더 평평하고 불투명한 색을 씁니다. 거기서는 채움이 **곧** 마크이고, 흐려지는 띠에는 아래 가장자리가 없기 때문입니다.

### 기준선은 언제나 0

선과 달리 면적은 채움이 곧 크기이므로, 기준선이 0이 아니면 띠의 두께가 아무 뜻도 없어집니다. 축을 자를 수 있는 [`PlLineChart`](./line-chart)와 이 차트가 공유하지 않는 유일한 축 규칙입니다.

## Accessibility

[`PlLineChart`](./line-chart#accessibility)가 말하는 모든 것이 그대로 적용됩니다. 이름과 series별 요약, 진짜 컨트롤인 범례, 그리고 React 쪽의 숨은 표.
