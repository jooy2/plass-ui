---
title: PlHeatmapChart
order: 8
---

# PlHeatmapChart

<p class="plass-lede">칸마다의 크기를 길이가 아니라 색으로 나타냅니다. 한 생각의 두 모양입니다. 두 축이 모두 category면 격자, 전체의 부분이면 treemap입니다.</p>

<Demo src="heatmap-chart/hero" :min-height="320" />

::: fw react

```tsx
import { PlHeatmapChart } from 'plass-ui';

<PlHeatmapChart series={week} categories={hours} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlHeatmapChart(series: week, categories: hours);
```

:::

두 축이 모두 category이고 묻는 것이 _어디_ 일 때 격자를 쓰세요. 어느 요일의 몇 시인지, 어느 코호트의 몇째 주인지. 같은 데이터의 [막대 차트](./bar-chart)는 아무도 훑을 수 없는 막대 마흔 개가 됩니다.

**여기서 색은 정체가 아니라 크기를 담습니다.** 그래서 category 팔레트가 아니라 한 가지 색조의 사다리에서 옵니다. 여덟 색조의 heatmap은 칸들이 서로 무관한 여덟 가지라고 말하는 셈입니다.

## Props

<PropsTable name="PlHeatmapChart" />

series 하나가 격자의 한 행이거나 treemap의 한 묶음이고, datum 하나가 칸 또는 타일입니다. `null`은 칸을 척도의 바닥으로 칠하지 않고 표면 그대로 둡니다. "아무 일도 없었다"와 "가장 적다"는 다른 이야기이기 때문입니다.

사다리는 행마다가 아니라 차트 전체에 하나입니다. 칸의 색은 어디에 있든 같은 숫자를 뜻해야 하고, 그것이 heatmap이 하는 약속의 전부입니다.

## Examples

### shape

<Demo src="heatmap-chart/treemap" :min-height="360">

::: fw react

<<< @/.vitepress/demos/heatmap-chart/treemap.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/heatmap_chart/treemap.dart

:::

</Demo>

treemap은 [파이 차트](./pie-chart)가 담을 수 있는 것보다 조각이 많은 전체의 부분을 위한 것입니다. 같은 컴포넌트인 이유는 데이터의 모양이 같기 때문입니다. heatmap의 한 행과 treemap의 한 묶음은 둘 다 이름 붙은 크기들의 이름 붙은 묶음입니다.

배치는 잘라 나누기가 아니라 **정사각형화**입니다. 잘라 나눈 treemap은 값이 스무 개쯤 되면 폭 1px짜리 조각으로 끝나고, 그런 조각의 _넓이_ 는 아무리 정확해도 읽히지 않습니다. 읽는 사람은 대신 길이를 비교하는데, 그것은 담기로 한 양이 아닙니다.

타일의 넓이가 곧 비중이므로 음수는 가질 넓이가 없습니다. 표에는 남고 그림에서만 빠집니다.

treemap에는 축이 없습니다. 타일이 자기 얼굴에 이름을 지니고, 그것이 상자를 가장자리까지 채우는 대가입니다.

### scale

<Demo src="heatmap-chart/diverging" :min-height="280">

::: fw react

<<< @/.vitepress/demos/heatmap-chart/diverging.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/heatmap_chart/diverging.dart

:::

</Demo>

`sequential`은 옅은 쪽에서 짙은 쪽으로 가는 한 색조이고, 많을수록 그냥 많은 것일 때 맞습니다. `diverging`은 중립을 사이에 둔 두 색조로, **가운데**가 뜻을 지니는 값을 위한 것입니다. 목표 위와 아래, 얻은 것과 잃은 것. 평범한 크기에 갖다 대면 데이터에 없는 경계를 만들어 냅니다.

diverging 척도는 바닥이 아니라 가운데에서부터 읽고, 양쪽 팔은 둘 중 먼 쪽만큼 뻗습니다. 그래서 −2에서 +40까지인 자료가 모든 음수를 가장 짙은 파랑으로 칠하지 않습니다.

### valueLabels

칸이 글자를 좌우 여백까지 담을 만큼 클 때 값을 적습니다. 들어가지 않는 label은 자르지 않고 **지웁니다**. 없는 label은 읽는 사람을 tooltip으로 보내지만, 잘린 label은 아무 데로도 보내지 않습니다.

treemap에서는 이름이 먼저 오고 값은 그 아래 자리가 남을 때만 옵니다. treemap에서는 타일 이름을 말해 주는 것이 달리 없기 때문입니다. 격자에서는 두 좌표가 이미 옆과 아래에 적혀 있으므로 남은 것은 숫자뿐입니다.

## Accessibility

- 그림은 차트의 이름을 지니고, 모든 칸을 글로 넘깁니다. 행마다 칸들이 이름과 값의 쌍으로 나열됩니다.
- React에서 그림은 `role="img"`이자 tab 정거장입니다. 화살표 키로 칸을 옮겨 다니고 <kbd>Escape</kbd>로 읽던 값을 지웁니다. 닿는 칸마다 live region으로 읽힙니다.
- React에서는 같은 숫자가 차트 아래 표에도, 두 벌의 이름과 함께 적힙니다. 행은 옆에, 열은 위에 옵니다.
- 칸 안에 적히는 글자는 라이브러리에서 유일하게 잉크 토큰을 입지 않는 자리입니다. 둘 중 어느 쪽을 입을지는 **사다리 단마다** 정해집니다. 그 단의 밝기를 아는 자리이고, 답이 테마에 따라 뒤집히기 때문입니다.
- 척도 legend는 양 끝에 이름을 붙이고, diverging일 때는 가운데에도 붙입니다.
