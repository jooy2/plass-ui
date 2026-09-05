---
title: PlLineChart
order: 1
---

# PlLineChart

<p class="plass-lede">시간에 대한, 또는 순서가 있는 무엇에 대한 값입니다. 선은 <em>변화</em>를 말하는 마크입니다. 두 점 사이의 공간이 별개의 두 사실이 아니라 하나의 여정이라고 주장합니다.</p>

<Demo src="line-chart/hero" :min-height="320" />

::: fw react

```tsx
import { PlLineChart } from 'plass-ui';

<PlLineChart
  series={[{ name: 'Europe', data: [42, 45, 51, 49] }]}
  categories={['Jan', 'Feb', 'Mar', 'Apr']}
/>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlLineChart(
  series: const <PlassChartSeries>[
    PlassChartSeries(
      name: 'Europe',
      data: <PlassChartDatum>[
        PlassChartDatum(42), PlassChartDatum(45), PlassChartDatum(51),
      ],
    ),
  ],
  categories: const <PlassChartCategory>[
    PlassChartCategory.text('Jan'),
    PlassChartCategory.text('Feb'),
    PlassChartCategory.text('Mar'),
  ],
);
```

:::

category를 섞어도 잃을 것이 없다면 막대 차트를 쓰세요. 제품 둘 사이의 선은 데이터에 없는 관계를 주장합니다.

선을 둘러싼 모든 것 — 축, 격자, crosshair, 범례, 툴팁, 그리고 스크린 리더가 그림 대신 받는 것 — 은 공유 프레임에서 옵니다. 한 대시보드의 서로 다른 차트 둘이 두 개의 그림이 아니라 하나의 그림으로 읽히는 이유입니다.

## Props

<PropsTable name="PlLineChart" />

### PlassChartSeries

<PropsTable name="PlassChartSeries" />

datum은 맨 숫자이거나, `null`이거나, 자기에 대해 더 말하는 point입니다. **`null`은 빈 곳이지 절대 0이 아닙니다** — 꺼져 있던 센서, 아직 마감되지 않은 달. 없는 데이터를 0으로 그리는 차트는 장애를 붕괴로 보고하는 차트입니다.

::: fw react

```tsx
data: [42, null, 51, { y: 49, label: 'Revised' }];
```

:::

::: fw flutter

```dart
data: const <PlassChartDatum>[
  PlassChartDatum(42),
  PlassChartDatum.gap(),
  PlassChartDatum(51),
  PlassChartDatum.point(PlassChartPoint(y: 49, label: 'Revised')),
],
```

React의 `number | null | object` 대신 닫힌 union입니다. union 타입이 없는 Dart가 주는 것입니다.

:::

라이브러리 전체에서 공유 축이 뜻하는 바는 [prop 규약](../../design/prop-conventions)에 있습니다.

## Examples

### curve

`linear`가 기본이고, 데이터가 말하지 않은 것을 아무것도 주장하지 않는 유일한 값입니다. `smooth`는 일반 spline이 아니라 **monotone cubic**입니다. 굽지만, 이웃 둘이 모두 위에 있는 값 아래로 내려가지는 않습니다 — 차트는 굽어도 되지만 데이터에 없는 값을 보여 줄 수는 없습니다. `step`은 두 측정 사이에 요율이나 등급이나 설정이 실제로 한 일이고, 그것이 흘러갔다고 흉내 내는 대각선이 아닙니다.

<Demo src="line-chart/curve" :min-height="380">

::: fw react

<<< @/.vitepress/demos/line-chart/curve.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/line_chart/curve.dart

:::

</Demo>

### Gaps

`null`은 **선을 끊습니다**. `connectNulls`는 대신 이어 붙이는데, 그 공백이 아무 일도 없던 기간이 아니라 수집 방식의 부산물임을 아는 경우가 아니라면 꺼 두어야 합니다.

<Demo src="line-chart/gaps" :min-height="320">

::: fw react

<<< @/.vitepress/demos/line-chart/gaps.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/line_chart/gaps.dart

:::

</Demo>

양옆이 빈 점은 버리지 않고 dot으로 그립니다. 그것도 측정값이고, 이을 곳이 없는 측정값도 측정값입니다.

### valueLabels

`last`는 각 series가 어디서 끝났는지를 적습니다. 선 차트가 대개 받는 질문이고, 차트가 값 축을 통째로 버릴 수 있게 하는 설정입니다.

<Demo src="line-chart/labels" :min-height="300">

::: fw react

<<< @/.vitepress/demos/line-chart/labels.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/line_chart/labels.dart

:::

</Demo>

`extremes`는 최고와 최저를, `all`은 전부를 적습니다. 모든 점에 숫자가 적힌 차트는 잘못 그린 표입니다.

### 값 축은 0을 뺍니다

선이 encode하는 것은 **위치**이므로, 축을 잘라도 모든 점이 같은 만큼 움직이고 모양은 살아남습니다. 막대가 encode하는 것은 **길이**이고, 98부터 시작하는 순간 아무 뜻도 없어집니다 — 막대 차트의 축이 0을 포함하고 이 축이 포함하지 않는 이유입니다.

98과 99 사이에 사는 series는 0부터 시작하는 축에서 평평한 선입니다. 필요하면 축의 `min`으로 요청하세요.

```tsx
<PlLineChart series={series} yAxis={{ min: 0 }} />
```

### Colour

팔레트는 **고정된 순서의 여덟 색**이고, 이 라이브러리에서 색이 의미 역할이 아닌 유일한 곳입니다. series는 개체 — 지역, 요금제, 경쟁사 — 이고, 그것에 대해 성공이나 위험을 말하는 것은 아무것도 없습니다.

자리는 series가 **넘겨진 배열에서의 index**로 배분되고, 현재 보이는 것들 사이의 위치로는 절대 배분되지 않습니다. Europe이 파랑이라고 배운 사람에게서 필터가 그것을 도로 가져갈 수는 없습니다. 아홉 번째 series는 아홉 번째 색이 아닙니다. "기타" 행이거나 두 번째 차트입니다.

토큰은 `--plass-chart-1`부터 `--plass-chart-8`까지이고, 브랜드에 맞춰야 하는 프로젝트는 차트마다가 아니라 한 번 덮어씁니다.

## Accessibility

- 그림 전체에 이름이 있고, 값으로 **보이는 각 series와 그것이 끝난 자리**를 답니다. 표를 칸마다 읊는 대신, 눈으로 보는 사람이 모양에서 가져가는 그 읽기입니다.
- 범례는 진짜 컨트롤의 줄입니다. 각 항목이 자기 series가 켜져 있는지 말하고, 누르면 바뀝니다.
- 포인터가 올라간 범례 항목은 자기를 밝히는 대신 **나머지를** 흐립니다. 포인터가 올라갔다고 색이 바뀌는 차트는 그동안 범례가 거짓말을 하는 차트입니다.

::: fw react

- 차트는 데이터의 진짜 `<table>`도 함께 그립니다. 눈에는 보이지 않고, 스크린 리더가 그림 대신 읽는 것입니다.

:::

::: fw flutter

- 탭하면 툴팁이 **남아 있고**, 같은 열을 한 번 더 탭하면 내려갑니다. 뗄 때 지우면 포인터 없는 사람은 끝내 읽지 못하는 툴팁이 됩니다 — 터치 화면에서 누름과 뗌은 0.1초 차이입니다. 드래그하면 축을 따라 훑습니다.

:::
