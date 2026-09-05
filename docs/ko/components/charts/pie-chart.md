---
title: PlPieChart
order: 4
---

# PlPieChart

<p class="plass-lede">한눈에 보는 전체의 부분입니다. 라이브러리에서 가장 좁고 가장 잘못 쓰기 쉬운 차트로, 답할 수 있는 질문은 하나뿐입니다. <em>이 중 하나가 대부분인가?</em></p>

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

데이터는 series 목록이 아니라 조각 하나하나의 목록입니다. 파이란 원래 그런 것이니까요. **여기서 주체는 조각입니다.** 조각마다 팔레트 자리를 하나씩 가져가고, legend도 조각을 나열하며, 색은 크기가 아니라 조각을 따라다닙니다. 그래서 다시 거르거나 다시 정렬해도 category마다 색이 그대로입니다.

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

가운데가 빈 도넛은 한 입 베어 문 파이일 뿐입니다. 합계, 또는 이 차트가 말하려는 그 숫자 하나가 고리를 두른 이유입니다. 넣을 구멍이 없는 `pie`에서는 무시됩니다.

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

### startAngle

첫 조각이 시작하는 자리를, 열두 시에서 시계 방향으로 잰 각도로 지정합니다. `semi`는 무시합니다. 그 모양은 어디가 열려 있는지로 정의되니까요.

## Accessibility

- 그림은 차트의 이름을 지니고, 눈으로 각도를 읽어 얻는 내용을 글로 넘깁니다. 보이는 조각 전부와 그 값, 비중입니다.
- React에서 그림은 `role="img"`이자 **tab 정거장**이고, 화살표 키로 조각을 옮겨 다닙니다. 각 조각이 얼마인지는 focus가 옮겨갈 때 live region으로 읽힙니다.
- React에서는 같은 숫자가 차트 아래 표에도 적힙니다. 화면에서만 잘라낼 뿐 접근성 트리에서 감추지는 않습니다.
- legend는 진짜 button입니다. 하나를 누르면 그 조각이 고리에서 빠지고 각도가 나머지에 다시 나뉩니다.
- 색은 유일한 통로가 아닙니다. 모든 조각은 legend에도, 읽어주는 값에도, 표에도 이름으로 있습니다.
