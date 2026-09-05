---
title: PlGaugeChart
order: 7
---

# PlGaugeChart

<p class="plass-lede">미리 알려진 척도 위의 숫자 하나를 다이얼로 그립니다. 호로 굽힌 <code>PlMeter</code>이며, 여러 필드가 늘어선 줄이 아니라 타일 하나를 위한 물건입니다.</p>

<Demo src="gauge-chart/hero" :min-height="280" />

::: fw react

```tsx
import { PlGaugeChart } from 'plass-ui';

<PlGaugeChart value={68} caption="of quota" />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlGaugeChart(value: 68, caption: Text('of quota'));
```

:::

`value`, `min`, `max`, `thresholds`는 [meter](../feedback/meter)에서와 똑같은 뜻입니다. 그래서 말하는 내용을 바꾸지 않고도 값을 막대에서 다이얼로 옮길 수 있습니다. 필드가 늘어선 줄에는 막대를, 방 건너편에서도 한눈에 읽혀야 하는 자리에는 이쪽을 쓰세요. 4px 막대는 그러지 못합니다.

**`shape="semi"`인 [파이 차트](./pie-chart)가 아닙니다.** 파이는 전체의 부분이고 조각마다 category입니다. 이것은 척도에 대고 잰 값 하나이며, 채워지지 않은 호는 두 번째 category가 아니라 다이얼의 나머지입니다.

## Props

<PropsTable name="PlGaugeChart" />

`value`가 `null`이면 아무것도 얹지 않은 다이얼을 그립니다. 아무 말도 듣지 못한 계기의 정직한 모습입니다. `legend`도 `tooltip`도 없습니다. 숫자 하나에는 둘 다 필요 없습니다.

라이브러리 전체에서 공유 prop이 뜻하는 바는 [prop 규약](../../design/prop-conventions)에 있습니다.

## Examples

### sweep

<Demo src="gauge-chart/sweep" :min-height="240">

::: fw react

<<< @/.vitepress/demos/gauge-chart/sweep.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/gauge_chart/sweep.dart

:::

</Demo>

열두 시를 기준으로 좌우 대칭으로 열리는 각도입니다. `180`은 대시보드 타일이 원하는 반달, `270`은 계기 모양, `360`은 고리입니다.

다이얼은 원이라고 가정하지 않고 상자에 맞춰 잽니다. 중심 **아래**로 얼마나 내려가는지가 sweep에 따라 다르기 때문입니다. 반달은 중심 높이에서 멈추고 270°는 반지름의 대부분만큼 더 내려갑니다. 넓고 낮은 카드가 위쪽 절반을 비운 채 가느다란 띠만 그리는 일을 막는 것이 이 계산입니다.

### thresholds

<Demo src="gauge-chart/thresholds" :min-height="240">

::: fw react

<<< @/.vitepress/demos/gauge-chart/thresholds.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/gauge_chart/thresholds.dart

:::

</Demo>

값 이하에서 가장 높은 band가 이깁니다. 모든 band 아래라면 `color`가 그대로 남습니다. 목록의 순서는 상관없습니다. band는 훑는 것이 아니라 읽는 것이고, 이는 `PlMeter`가 쓰는 것과 같은 규칙이자 같은 코드입니다.

band는 숫자를 말하는 두 번째 방법일 뿐 유일한 방법이 아닙니다. 호가 어떤 색을 입든 값은 가운데에 적힙니다.

### ticks와 showRange

<Demo src="gauge-chart/ticks" :min-height="280">

::: fw react

<<< @/.vitepress/demos/gauge-chart/ticks.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/gauge_chart/ticks.dart

:::

</Demo>

눈금은 기본으로 꺼져 있습니다. 대시보드의 게이지는 비율로 읽히고, 테두리의 눈금은 거기서 **숫자**를 읽어 가는 계기를 위한 것입니다.

`showRange`는 호의 양 끝에 `min`과 `max`를 적습니다. 330°를 넘으면 값과 무관하게 빠집니다. 그쯤이면 두 끝이 label 하나 너비 안으로 다가와, `0`과 `100`이 겹쳐 찍힌 것은 척도가 아니라 얼룩이기 때문입니다.

### center와 caption

`center`는 구멍 속의 숫자를 대신하고, `caption`은 그 아래에 한 줄을 겁니다. 값을 대신하는 것은 더하기 위한 것이지 빼기 위한 것이 아닙니다. 숫자가 다이얼의 존재 이유니까요.

값은 그림에 그려 넣은 label이 아니라 **진짜 텍스트**입니다. 그래서 선택할 수 있고, 브라우저 검색에 걸리며, 차트가 스스로를 설명하지 않아도 읽힙니다. 크기는 고정이 아니라 구멍이 실제로 남긴 공간에 대고 풀어냅니다. `38`과 `10,000%`가 같은 prop이니까요.

## Accessibility

- `label`이 있으면 다이얼은 한 가지를 말하는 이름 붙은 이미지 하나가 됩니다. `"Storage used: 1.36 / 2"`처럼요. 양 끝 label이 떠도는 숫자로 들리는 일을 막아 줍니다.
- 없으면 평범한 상자로 남고, 가운데 값은 이미 텍스트이므로 그대로 읽힙니다.
- 값이 색만으로 전달되는 일은 없습니다. threshold는 계열을 바꾸고, 가운데 숫자가 같은 말을 글로 합니다.
- 호는 새 값으로 튀지 않고 쓸어 갑니다. 그 움직임은 transform이 아니라 길이라서, 다이얼 위에 적힌 숫자가 다시 샘플링되는 일이 없습니다.
