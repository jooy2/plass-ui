---
title: PlScatterChart
order: 5
---

# PlScatterChart

<p class="plass-lede">점 하나에 숫자 둘, 그리고 그 둘이 함께 움직이는지입니다. 두 축이 모두 값을 재기 때문에, 라이브러리에서 category가 없는 유일한 차트입니다.</p>

<Demo src="scatter-chart/hero" :min-height="360" />

::: fw react

```tsx
import { PlScatterChart } from 'plass-ui';

<PlScatterChart series={stores} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlScatterChart(series: stores);
```

:::

점이 속한 열도 없고, 점들을 흐트러뜨릴 순서도 없습니다. `z`가 있는 점은 버블로, 없는 점은 dot으로 그려지므로 산점도와 버블 차트는 같은 데이터를 읽는 같은 컴포넌트입니다. 세 번째 숫자가 있느냐 없느냐일 뿐입니다.

## Props

<PropsTable name="PlScatterChart" />

각 점의 `x`는 숫자나 날짜여야 합니다. 글자는 수직선 위에 놓일 자리가 없고, 이름 붙은 것들을 한 척도에 대고 재는 차트는 [막대 차트](./bar-chart)입니다.

어느 축도 0으로 끌려가지 않습니다. 위치가 담는 것은 자리이므로, 축을 잘라도 모든 점이 같은 만큼 밀릴 뿐 구름의 모양은 살아남습니다. 길이가 곧 값인 막대에서는 그렇지 않습니다.

라이브러리 전체에서 공유 축이 뜻하는 바는 [prop 규약](../../design/prop-conventions)에 있습니다.

## Examples

### 버블

<Demo src="scatter-chart/bubbles" :min-height="380">

::: fw react

<<< @/.vitepress/demos/scatter-chart/bubbles.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/scatter_chart/bubbles.dart

:::

</Demo>

점의 `z`는 반지름이 아니라 **넓이**입니다. 반지름으로 담으면 두 배인 값이 네 배 크기로 그려지는데, 제곱근이 화면에 칠해진 잉크를 그 뒤의 숫자에 비례하게 만듭니다. 척도는 차트 전체에 하나이고 숨긴 series까지 포함해서 잽니다. 그래서 같은 크기의 두 버블은 어디에 있든 같은 숫자를 뜻하고, series를 꺼도 나머지 크기가 바뀌지 않습니다.

버블은 큰 것부터 그립니다. 큰 버블이 위에 얹히면 그 안의 작은 버블은 보이지 않고, 흔한 해결책인 모든 fill을 반투명으로 만들기는 팔레트가 어렵게 확보한 대비를 되돌립니다.

### shape

<Demo src="scatter-chart/shape" :min-height="380">

::: fw react

<<< @/.vitepress/demos/scatter-chart/shape.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/scatter_chart/shape.dart

:::

</Demo>

기본값 `auto`는 색만으로 정체를 나를 수 있는 동안 원을 그리고, 네 번째 series부터 series마다 다른 모양으로 바꿉니다. 이 경계는 고른 것이 아니라 잰 것입니다. 팔레트의 앞 세 자리를 쓰면 deuteranopia에서 가장 가까운 쌍이 밝은 바탕에서 ΔE 64, 어두운 바탕에서 51입니다. 네 번째를 더하면 각각 4.9와 2.8로 떨어집니다. 셋을 넘으면 색은 아무 말도 하지 않고, dot에 남아 있는 통로는 모양뿐입니다.

`color`를 직접 준 series는 이 한도에 세지 않습니다. 한도가 던지는 질문에 caller가 이미 답했기 때문입니다.

`varied`는 조건 없이 모양을 켭니다. 차트를 인쇄하거나 흑백으로 읽을 때 쓰세요. 다섯 모양 중 하나를 지정하면 모든 점이 그 모양이 되며, series가 넷 이상일 때 이는 두 번째 통로를 포기하는 선택입니다.

### pointRadius와 maxRadius

`pointRadius`는 `z`가 없는 점의 반지름입니다. `maxRadius`는 가장 큰 버블이 커질 수 있는 한계이자 plot 주위에 비워 두는 여백입니다. 점은 중심에서부터 그려지므로, 그러지 않으면 가장 큰 `x`의 버블이 가장자리 밖으로 걸칩니다.

## Accessibility

- 그림은 차트의 이름을 지니고, 모든 점을 글로 넘깁니다. series마다 `x, y` 쌍이 나열되고 `z`가 있으면 괄호 안에 붙습니다.
- React에서 그림은 `role="img"`이자 tab 정거장이고, 화살표 키가 **데이터를 준 순서대로** 점을 옮겨 다닙니다. 그리는 순서인 큰 것부터는 읽는 사람이 예상할 수 없는 순서입니다.
- React에서는 같은 숫자가 차트 아래 표에도 적힙니다. 다른 차트가 쓰는 격자가 아니라 점마다 한 행입니다. 둘 다 자기 series의 다섯 번째인 두 점은 서로 아무 관계가 없고, 한 행에 묶으면 없는 관계를 만들어 내기 때문입니다. 열 이름은 축 label에서 따오고, 없으면 `x`, `y`, `z`입니다.
- series가 셋을 넘으면 점은 색뿐 아니라 **모양**으로도 갈리고, legend의 swatch가 그 모양을 보여 줍니다.
