---
title: PlSparkline
order: 6
---

# PlSparkline

<p class="plass-lede">모양만 남기고 전부 걷어낸 차트입니다. 축도, 격자도, legend도, tooltip도 없이 문장 안에 들어가 무언가가 어느 쪽으로 가고 있는지만 보여 줍니다.</p>

<Demo src="sparkline/hero" :min-height="200" />

::: fw react

```tsx
import { PlSparkline } from 'plass-ui';

<PlSparkline data={signups} endDot />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlSparkline(data: signups, endDot: true);
```

:::

스파크라인은 차트를 줄여 놓은 것과는 다른 물건입니다. 여기에 붙일 수 있는 숫자는 이미 주변 글에 있고, 그래서 아무것도 붙이지 않습니다. [`PlStat`](../display/stat) 옆이나 표의 칸, 문장 속에 넣으세요.

## Props

<PropsTable name="PlSparkline" />

색은 다른 차트와 달리 직접 받습니다. sparkline에는 series가 하나뿐이고 legend도 없으니 팔레트가 나눠 줄 것이 없습니다.

`tooltip`도 `legend`도 없습니다. 둘 중 하나라도 붙이면 차트가 됩니다. `null`은 여기서도 빈 곳이고, 선은 거기서 끊깁니다.

## Examples

### shape

<Demo src="sparkline/shape" :min-height="220">

::: fw react

<<< @/.vitepress/demos/sparkline/shape.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/sparkline/shape.dart

:::

</Demo>

큰 차트들이 하는 세 문장을, 다른 말은 아무것도 하지 않는 크기에서 그대로 합니다. 추세는 선, 양은 면적, 낱낱의 개수는 막대입니다.

### min과 max

<Demo src="sparkline/scale" :min-height="280">

::: fw react

<<< @/.vitepress/demos/sparkline/scale.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/sparkline/scale.dart

:::

</Demo>

**sparkline은 자기 범위에 맞춰 스스로 늘어나므로 띠가 언제나 꽉 찹니다.** 20px 높이에서도 읽히는 이유이자 함정입니다. 나란히 놓인 둘은 서로 다른 척도로 그려지므로, 가파르게 오르는 띠가 더 작은 숫자일 수 있습니다. 한 줄로 늘어놓을 때 같은 `min`과 `max`를 주면 small multiples 차트가 됩니다.

### baseline

<Demo src="sparkline/baseline" :min-height="160">

::: fw react

<<< @/.vitepress/demos/sparkline/baseline.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/sparkline/baseline.dart

:::

</Demo>

목표치, 예산, 작년 평균. 이만한 띠가 실을 수 있는 맥락은 이것 하나입니다. 데이터 바깥에 있으면 범위 안으로 끌어들이므로 선은 언제나 보입니다.

### endDot

마지막 칸이 아니라 값이 있는 마지막 점에 dot을 찍습니다. 이만한 띠에 들어갈 수 있는 유일한 직접 label이고, series가 어디서 끝났는지를 보여 줍니다. 막대에는 붙지 않습니다. 막대는 이미 끝나는 자리에서 끝나기 때문입니다.

## Accessibility

- `label`이 없으면 띠는 **접근성 트리에서 통째로 빠집니다.** sparkline은 숫자를 이미 가진 글 옆의 장식이고, 이름 없는 이미지를 이미지라고 읽어 주는 것은 소음입니다.
- `label`이 있으면 이름 붙은 `role="img"`가 되고, 값이 옆에 적힙니다. 화면에서만 잘라낼 뿐 트리에서 감추지는 않습니다. sparkline이 갚아야 할 것은 숫자이지, 그 숫자가 만든 모양에 대한 설명이 아닙니다.
- 색이 유일한 통로가 아닌 것도 같습니다. sparkline은 자기가 속한 이름과 숫자 옆에 놓입니다.
