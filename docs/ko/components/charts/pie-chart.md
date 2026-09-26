---
title: PlPieChart
order: 4
---

# PlPieChart

<p class="plass-lede">한눈에 보는 전체의 부분입니다. 라이브러리에서 가장 좁고 가장 잘못 쓰기 쉬운 차트로, 답할 수 있는 질문은 <em>이 중 하나가 대부분인가</em> 하나뿐입니다.</p>

<Demo src="pie-chart/hero" :min-height="360" />

::: fw react

```tsx
import { PlPieChart } from 'plass-ui';

<PlPieChart data={traffic} categories={sources} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlPieChart(data: traffic, categories: sources);
```

:::

각도는 비교하기에 나쁜 재료입니다. 몇 퍼센트 차이 나는 두 조각은 구별되지 않고, 여섯 조각의 순위는 매길 수 없습니다. "이 중 하나가 대부분인가"보다 세밀한 질문이거나 조각이 여섯을 넘으면 [막대 차트](./bar-chart)를 쓰세요.

## Props

<PropsTable name="PlPieChart" />

데이터는 series 목록이 아니라 조각 하나하나의 목록입니다. 파이란 원래 그런 것이기 때문입니다. **여기서 주체는 조각입니다.** 조각마다 팔레트 자리를 하나씩 가져가고, legend도 조각을 나열하며, 색은 크기가 아니라 조각을 따라다닙니다. 그래서 다시 거르거나 다시 정렬해도 category마다 색이 그대로입니다.

`null`과 0은 둘 다 그리지 않습니다. 어느 쪽도 각도가 없고, 폭이 없는 조각은 가리킬 수 없는 조각입니다.

라이브러리 전체에서 공유 prop이 뜻하는 바는 [prop 규약](../../design/prop-conventions)에 있습니다.

## Examples

### shape

<Demo src="pie-chart/shape" :min-height="260">

::: fw react

<<< @/.vitepress/demos/pie-chart/shape.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/pie_chart/shape.dart

:::

</Demo>

`semi`는 반지름으로 높이의 절반이 아니라 **전체**를 씁니다. 위쪽 절반만 그리기 때문입니다. 그래서 중심이 상자 한가운데보다 반지름의 절반만큼 아래에 놓이고, 그 결과 호 자체가 타일 한가운데에 옵니다.

### center

<Demo src="pie-chart/center" :min-height="380">

::: fw react

<<< @/.vitepress/demos/pie-chart/center.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/pie_chart/center.dart

:::

</Demo>

가운데가 빈 도넛은 한 입 베어 문 파이일 뿐입니다. 합계, 또는 이 차트가 전하려는 그 숫자 하나가 고리를 두른 이유입니다. 넣을 구멍이 없는 `pie`에서는 무시됩니다.

### valueLabels

<Demo src="pie-chart/value-labels" :min-height="380">

::: fw react

<<< @/.vitepress/demos/pie-chart/value-labels.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/pie_chart/value_labels.dart

:::

</Demo>

조각에 적히는 숫자는 값이 아니라 **비중**입니다. 파이가 그리는 그림이 비중이고, 값은 hover 한 번 거리에 있습니다. 조각보다 넓은 label은 잘리는 대신 지워지므로, 옆 조각 위에 얹혀 그쪽을 설명하는 일이 생기지 않습니다.

### 구멍과 틈

`shape`가 둘 다 정합니다. `pie`는 아무것도 뚫지 않고, `donut`과 `semi`는 3분의 2에 조금 못 미치게 뚫습니다. `innerRadius`와 `padAngle`은 그 둘을 직접 정합니다. 구멍에 맡길 일이 따로 있거나, 고리가 나뉜 조각으로 읽혀야 할 때 씁니다.

<Demo src="pie-chart/ring" :min-height="260">

::: fw react

<<< @/.vitepress/demos/pie-chart/ring.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/pie_chart/ring.dart

:::

</Demo>

`innerRadius`는 반지름에 대한 비율이라 차트를 어느 크기로 그리든 그대로 유지됩니다. `padAngle`은 각도입니다. 주지 않으면 이 라이브러리가 두 mark 사이에 두는 2px을 테두리에서 각도로 환산해 씁니다. 데이터가 아니라 **화면** 위에서 일정한 값이므로, 작은 원이 큰 원과 같은 틈을 갖지 않습니다. 틈의 두 배보다 좁은 조각은 틈을 아예 받지 않습니다. 1도짜리 조각이 뒤집혀 원 전체를 그리는 일을 막기 위해서입니다.

### startAngle

첫 조각이 시작하는 자리를, 열두 시에서 시계 방향으로 잰 각도로 지정합니다. `semi`는 무시합니다. 그 모양은 어디가 열려 있는지로 정의되기 때문입니다.

## Accessibility

- 그림은 차트의 이름을 지니고, 눈으로 각도를 읽어 얻는 내용을 글로 넘깁니다. 보이는 조각 전부와 그 값, 비중입니다. 값이 0인 조각은 각도가 없으니 읽지도 않습니다. 조각에 자기 `label`이 있으면 값과 비중 대신 그 `label`을 읽고, 조각을 가리키면 뜨는 값에도 `label`을 적습니다.
- 그림은 **tab 정거장**입니다. <kbd>←</kbd>와 <kbd>→</kbd>로 그려진 조각을 하나씩 옮겨 다닙니다. 마지막 조각 다음은 첫 조각이고, 첫 조각 앞은 마지막 조각입니다. <kbd>Escape</kbd>로 읽던 값을 지우는데, 읽고 있는 조각이 있을 때만 차트가 이 키를 가져갑니다. 그 밖에는 차트를 담은 쪽으로 넘어가므로, 차트를 품은 sheet도 그대로 닫힙니다. 닿는 조각마다 이름과 값이 live region으로 읽힙니다. tooltip을 끄면 키는 아무것도 하지 않고 읽히는 것도 없습니다.
- 그림에 포커스가 가면 이름에 이어 조각 전부와 그 비중이 읽힙니다. "Search 40 · 40%, Social 25 · 25%" 같은 모양입니다. React에서 그림은 `role="img"`이고, 같은 숫자를 차트 아래 표에도 적습니다. 화면에서만 잘라낼 뿐 접근성 트리에서 감추지는 않습니다.
- legend는 진짜 button입니다. 하나를 누르면 그 조각이 고리에서 빠지고 각도가 나머지에 다시 나뉩니다.
- 색은 유일한 통로가 아닙니다. 모든 조각은 legend에도, 읽어주는 값에도, 표에도 이름으로 있습니다.
