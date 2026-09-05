---
title: PlStat
order: 19
---

# PlStat

<p class="plass-lede">숫자 하나와 그 숫자에 일어난 변화를 함께 보여 줍니다. 숫자만 있으면 지금 어떤지를, 옆에 움직임이 있으면 어디로 가고 있는지를 보여 줍니다.</p>

<Demo src="stat/hero" :min-height="220" />

::: fw react

```tsx
import { PlStat } from 'plass-ui';

<PlStat label="Revenue" value="£48,120" change={12.4} description="vs last month" />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlStat(
  label: const Text('Revenue'),
  value: const Text('₩48,120'),
  change: 12.4,
  description: const Text('vs last month'),
);
```

:::

## Props

<PropsTable name="PlStat" />

네이티브 `<div>` 속성은 그대로 통과합니다. 공유 축이 라이브러리 전체에서 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## improvesWhen

순진한 구현이 틀리는 딱 하나입니다. **움직임의 색은 부호가 아니라 그것이 좋은 변화인지로 정합니다**. 이탈률이 오르는 것은 좋은 소식이 아니고, 거기 붙은 초록 화살표는 누군가에게 잘못된 신호를 주는 대시보드입니다.

기본은 `up`이고 대부분은 그것이 맞습니다. 대시보드의 숫자 중 3분의 1쯤에는 `improvesWhen="down"`을 주세요: 이탈률, 이탈율(bounce rate), p95 지연, 지원 대기열, 비용.

<Demo src="stat/direction" :min-height="200">

::: fw react

<<< @/.vitepress/demos/stat/direction.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/stat/direction.dart

:::

</Demo>

## value는 node를 받습니다

숫자가 아니고, 일부러 그렇습니다. 숫자를 어떻게 적을지(통화, 자릿수 구분, 소수점, 로케일)는 페이지의 결정이고 `Intl.NumberFormat`이 이미 그것을 내립니다. 숫자를 받는 컴포넌트라면 넷 다 짐작해야 합니다.

```tsx
<PlStat
  label="Revenue"
  value={new Intl.NumberFormat('ko-KR', { style: 'currency', currency: 'KRW' }).format(total)}
/>
```

::: fw flutter

같은 이야기이고, 서식은 `package:intl`이 맡습니다. 이 패키지에는 그것을 할 의존성이 없고, 그것이 `value`가 위젯인 나머지 절반의 이유입니다.

```dart
PlStat(
  label: const Text('매출'),
  value: Text(NumberFormat.simpleCurrency(locale: 'ko_KR').format(total)),
);
```

위젯이 직접 쓰는 숫자는 `PlStat.formatChange` 하나뿐입니다. 소수점 한 자리까지, 상승에는 부호. 그보다 특정한 것이 필요하면 `changeLabel`이 그 자리입니다.

:::

## Examples

### changeLabel

비율이 아니라 **개수**로 움직인 숫자를 위한 것입니다.

```tsx
<PlStat label="Sign-ups" value="1,204" change={8.1} changeLabel="이번 주 +94" />
```

화살표와 색은 여전히 `change`가 정하고, `changeLabel`은 말만 정합니다.

### loading

숫자가 올 자리에 skeleton을 그리고, 변화도 함께 붙잡아 둡니다. 아직 아무도 갖지 않은 숫자 옆의 움직임은 아무것도 아닌 것의 움직임입니다.

```tsx
<PlStat label="Revenue" loading={pending} value={total} change={delta} />
```

## Notes

- **표면을 그리지 않습니다.** 숫자는 `PlCard` 안이나 그런 카드들의 줄에 놓이고, 시트 안의 시트는 시트 둘입니다.
- 숫자는 `tabular-nums`입니다. 그래서 타이머로 갱신되는 숫자 줄이 자릿수 폭이 바뀔 때마다 흔들리지 않습니다.

## Accessibility

- 화살표는 `aria-hidden`이고 부호는 **텍스트 안에** 있습니다. "+12.4%"는 그 자체로 올바르게 읽히고, 스크린 리더가 삼각형에 대해 듣지 않습니다.
- 색이 방향을 나르는 유일한 것인 적이 없습니다. 같은 이유로, 부호와 화살표가 둘 다 그것을 나타냅니다.
- role도 heading도 없습니다. 숫자 줄은 페이지가 달리 정하지 않는 한 스크린 리더에게 `<div>` 몇 개입니다. 페이지가 무엇이냐에 따라 리스트에 넣거나 줄에 `<h2>`를 주세요.

::: fw flutter

화살표는 `ExcludeSemantics` 안에 있고 부호는 텍스트 안에 있습니다. 그래서 스크린 리더가 삼각형이 아니라 "+12.4%"를 듣습니다.

:::
