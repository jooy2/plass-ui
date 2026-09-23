---
title: PlLineChart
order: 1
---

# PlLineChart

<p class="plass-lede">시간에 대한, 또는 순서가 있는 무엇에 대한 값입니다. 선은 <em>변화</em>를 나타내는 마크입니다. 두 점 사이의 공간이 별개의 두 사실이 아니라 하나의 움직임으로 읽힙니다.</p>

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

category를 섞어도 잃을 것이 없다면 막대 차트를 쓰세요. 제품 둘 사이의 선은 데이터에 없는 관계를 선언합니다.

선을 둘러싼 모든 것(축, 격자, crosshair, 범례, 툴팁, 그리고 스크린 리더가 그림 대신 받는 것)은 공유 프레임에서 옵니다. 한 대시보드의 서로 다른 차트 둘이 두 개의 그림이 아니라 하나의 그림으로 읽히는 이유입니다.

## Props

<PropsTable name="PlLineChart" />

### PlassChartSeries

<PropsTable name="PlassChartSeries" />

datum은 맨 숫자이거나, `null`이거나, 자기에 대해 더 설명하는 point입니다. **`null`은 빈 곳이지 절대 0이 아닙니다**. 꺼져 있던 센서, 아직 마감되지 않은 달. 없는 데이터를 0으로 그리는 차트는 장애를 붕괴로 보고하는 차트입니다.

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

### <Fw react="PlassChartAxis" flutter="PlChartAxis" />

모든 차트에서 `xAxis`는 category 축, `yAxis`는 값 축이며 방향과 관계없습니다. 막대 차트를 옆으로 눕혀도 옵션은 같은 prop에 그대로 둡니다.

<PropsTable name="PlassChartAxis" />

### <Fw react="PlassChartLegend" flutter="PlChartLegend" />

<PropsTable name="PlassChartLegend" />

### <Fw react="PlassChartTooltip" flutter="PlChartTooltip" />

<PropsTable name="PlassChartTooltip" />

라이브러리 전체에서 공유 축이 뜻하는 바는 [prop 규약](../../design/prop-conventions)에 있습니다.

## Examples

### curve

`linear`가 기본이고, 데이터에 없는 것을 하나도 더하지 않는 유일한 값입니다. `smooth`는 일반 spline이 아니라 **monotone cubic**입니다. 굽지만, 이웃 둘이 모두 위에 있는 값 아래로 내려가지는 않습니다. 차트는 굽어도 되지만 데이터에 없는 값을 보여 줄 수는 없습니다. `step`은 두 측정 사이에 요율이나 등급이나 설정이 실제로 한 일이고, 그것이 흘러갔다고 흉내 내는 대각선이 아닙니다.

<Demo src="line-chart/curve" :min-height="380">

::: fw react

<<< @/.vitepress/demos/line-chart/curve.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/line_chart/curve.dart

:::

</Demo>

### dashed

`dashed`를 단 series는 실선 대신 **6px 대시와 4px 간격**으로 그려집니다. 그 선이 측정값이 아니라 예측이나 목표, 작년임을 읽는 사람에게 알려 주는 표시입니다. 색은 이미 그 선이 어느 대상의 것인지를 말하고 있으니, 얼마나 확실한지까지 색에 맡기면 한 통로에 두 가지 일을 시키는 셈입니다.

<Demo src="line-chart/dashed" :min-height="320">

::: fw react

<<< @/.vitepress/demos/line-chart/dashed.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/line_chart/dashed.dart

:::

</Demo>

간격은 크기 사다리를 따라 늘어나지 않고 고정입니다. 그래야 `sm` 차트와 `lg` 차트에서 점선이 같은 리듬으로 읽힙니다. 점선으로 만들 선이 있어야 뜻이 있으므로 막대에서는 아무 일도 하지 않고, 쌓인 띠에서도 마찬가지입니다. 띠는 채움이 곧 표시라 위쪽에 그어진 선이 없습니다. legend 스와치는 둘 다 같은 사각형이니, `dashed`에는 그 선이 무엇인지 말하는 이름을 함께 붙이세요.

### Gaps

`null`은 **선을 끊습니다**. 기본값이고, 데이터가 말하지 않은 것을 덧붙이지 않는 유일한 답입니다. 비어 있다는 것이 곧 측정이 없었다는 뜻이니까요. 나머지 둘은 `nulls`에 있습니다. `connect`는 양쪽을 잇습니다. 아무 일도 없던 기간이 아니라 수집 방식의 부산물인 공백에 씁니다. `zero`는 그 자리를 0으로 읽습니다. 행이 없다는 것이 정말 0을 뜻할 때 씁니다.

<Demo src="line-chart/gaps" :min-height="320">

::: fw react

<<< @/.vitepress/demos/line-chart/gaps.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/line_chart/gaps.dart

:::

</Demo>

양옆이 빈 점은 버리지 않고 dot으로 그립니다. 그것도 측정값이고, 이을 곳이 없는 측정값도 측정값입니다.

`zero`는 그림이 아니라 **데이터**를 바꿉니다. 0이 값 축을 움직이고 툴팁의 한 줄을 채우며 차트 아래 표에도 들어갑니다. 그래서 그림과 숫자가 그 시각에 무슨 일이 있었는지를 같게 말합니다. `connectNulls`는 그대로 동작하고 `nulls="connect"`와 같은 뜻이며, `nulls`를 주지 않았을 때만 읽습니다.

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

### 기준선

`reference`는 목표나 평균, 한계를 plot을 가로질러 긋습니다. **데이터가 아니고**, 그것을 아는 것처럼 그립니다. 점선이고, muted 잉크를 쓰며, mark 아래에 놓입니다.

<Demo src="line-chart/reference" :min-height="320">

::: fw react

<<< @/.vitepress/demos/line-chart/reference.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/line_chart/reference.dart

:::

</Demo>

**값 축** 위에 서므로 같은 선이 세로 차트에서는 가로로, 가로 차트에서는 세로로 지나갑니다. 막대 차트를 옆으로 눕혀도 옮겨 적을 것이 없습니다. `color`는 페이지에서 이미 뜻을 지닌 색으로 선을 옮기고, `dashed: false`는 실선으로 만듭니다. 각 줄은 차트와 함께 화면 낭독기에 건네는 설명에도 적힙니다. 목표는 그림 위의 장식이 아니라 그림에 관한 사실이기 때문입니다.

### 값 축은 0을 뺍니다

선이 encode하는 것은 **위치**이므로, 축을 잘라도 모든 점이 같은 만큼 움직이고 모양은 살아남습니다. 막대가 encode하는 것은 **길이**이고, 98부터 시작하는 순간 아무 뜻도 없어집니다. 막대 차트의 축이 0을 포함하고 이 축이 포함하지 않는 이유입니다.

98과 99 사이에 사는 series는 0부터 시작하는 축에서 평평한 선입니다. 필요하면 축의 `min`으로 요청하세요.

```tsx
<PlLineChart series={series} yAxis={{ min: 0 }} />
```

### Colour

팔레트는 **고정된 순서의 여덟 색**이고, 이 라이브러리에서 색이 의미 역할이 아닌 유일한 곳입니다. series는 개체(지역, 요금제, 경쟁사)이고, 그것에 대해 성공이나 위험을 말하는 것은 아무것도 없습니다.

자리는 series가 **넘겨진 배열에서의 index**로 배분되고, 현재 보이는 것들 사이의 위치로는 절대 배분되지 않습니다. Europe이 파랑이라고 배운 사람에게서 필터가 그것을 도로 가져갈 수는 없습니다. 아홉 번째 series는 아홉 번째 색이 아닙니다. "기타" 행이거나 두 번째 차트입니다.

토큰은 `--plass-chart-1`부터 `--plass-chart-8`까지이고, 브랜드에 맞춰야 하는 프로젝트는 차트마다가 아니라 한 번 덮어씁니다.

## Accessibility

- 그림 전체에 이름이 있습니다.
- 그림은 tab 정거장입니다. <kbd>←</kbd>와 <kbd>→</kbd>로 category를 하나씩 옮겨 다니고, <kbd>Home</kbd>과 <kbd>End</kbd>로 첫 category와 마지막 category로 갑니다. <kbd>Escape</kbd>로 읽던 값을 지우고, 닿는 category마다 거기서 보이는 series의 값과 함께 live region으로 읽힙니다. tooltip을 끄면 키는 아무것도 하지 않고 읽히는 것도 없습니다.
- 범례는 진짜 컨트롤의 줄입니다. 각 항목이 자기 series가 켜져 있는지 보여 주고, 누르면 바뀝니다.
- 포인터가 올라간 범례 항목은 자기를 밝히는 대신 **나머지를** 흐립니다. 포인터가 올라갔다고 색이 바뀌는 차트는 그동안 범례가 거짓말을 하는 차트입니다.

::: fw react

- 그림은 `role="img"`입니다. 그림에 포커스가 가면 이름에 이어 한 줄 요약이 읽힙니다. 보이는 계열마다 이름과 마지막 값을 이은 것으로, "Web 40, App 8" 같은 모양입니다. 모든 값이 담긴 진짜 `<table>`도 그림의 형제로 함께 그립니다. 눈에는 보이지 않지만 접근성 트리에서는 빠지지 않으므로, 포커스할 때마다 값 사백 개를 듣는 대신 한 걸음 옆에서 꺼내 볼 수 있습니다.

:::

::: fw flutter

- tab 정거장은 차트 자신의 semantics 노드이므로, Tab으로 들어온 사람은 이름과 아래의 글을 듣습니다. <kbd>Escape</kbd>는 읽고 있는 값이 있을 때만 차트가 가져갑니다. 그 밖에는 차트를 담은 쪽으로 넘어가므로, 차트를 품은 sheet도 그대로 닫힙니다.
- 그림은 값으로 **안에 있는 숫자 전부**를 답니다. 보이는 series마다 값이 있는 카테고리와 그 자리의 값을 잇습니다. "Revenue: Jan 12; Feb 19; Mar 15. Cost: Jan 8; Feb 11; Mar 9" 같은 모양입니다. 이쪽에는 React와 달리 숨은 표가 없어서, 이 글이 숫자에 닿는 유일한 길입니다. 빈 칸은 카테고리만 읽히지 않도록 빼고, `categories`를 받지 않은 차트는 자리 번호도 뺍니다. 읽는 순서가 이미 그 자리를 담고 있기 때문입니다.
- `semanticValue`는 그 글을 갈아끼웁니다. 요약이 "각 series와 그 값들"이 아닌 차트를 위한 것이고, 어느 series가 켜져 있는지를 받습니다.
- 탭하면 툴팁이 **남아 있고**, 같은 열을 한 번 더 탭하면 내려갑니다. 뗄 때 지우면 포인터 없는 사람은 끝내 읽지 못하는 툴팁이 됩니다. 터치 화면에서 누름과 뗌은 0.1초 차이입니다. 드래그하면 축을 따라 훑습니다.

:::
