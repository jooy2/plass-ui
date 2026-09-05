---
title: PlAnimateCounter
order: 15
---

# PlAnimateCounter

<p class="plass-lede">지금의 값까지 세어 올라가는 숫자입니다. 여기서 상자가 아니라 내용을 움직이는 유일한 효과이고, 마운트가 아니라 보일 때 시작하는 유일한 효과입니다.</p>

<Demo src="animate-counter/hero" :min-height="200" />

::: fw react

```tsx
import { PlAnimateCounter } from 'plass-ui';

<PlAnimateCounter value={48120} format={{ style: 'currency', currency: 'GBP' }} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlAnimateCounter(
  value: 48120,
  formatValue: (double value) => NumberFormat.simpleCurrency(locale: 'en_GB').format(value),
);
```

:::

## Props

<PropsTable name="PlAnimateCounter" />

## 화면에 들어올 때 시작

**`trigger`의 기본값이 `visible`이고**, 라이브러리에서 마운트에 시작하지 않는 유일한 컴포넌트입니다.

빠뜨린 것이 아니라 의도입니다. 화면 밖에서 재생된 등장도 내용은 이미 전달했습니다. 사용자가 도착했을 때 글자가 거기 있고, fade가 나르던 것은 그것뿐이었습니다. 화면 밖에서 돌아간 카운트가 전달한 것은 **이미 거기 있던** 숫자이고, 그것은 counter가 감당할 수 없는 유일한 결과입니다. 보이는 것이 이 컴포넌트의 존재 이유이기 때문입니다.

## CSS keyframe과의 차이

CSS도 숫자를 움직일 수 있습니다. 등록된 커스텀 속성과 가상 요소의 `counter()`면 충분하고, 그쪽이 더 깔끔한 구현입니다.

다만 **서식**을 입히지 못합니다. 천 단위 구분도, 통화 기호도, 1,200,000을 `1.2M`으로 접는 것도 못 합니다. 서식을 입힐 수 없는 counter는 대시보드에 올릴 수 없는 counter입니다. 그래서 프레임 루프는 어떤 숫자를 그릴지만 정하고, 그것이 어떻게 보일지는 `Intl.NumberFormat`이 정합니다.

::: fw react

`easing`이 CSS 문자열이 아니라 **함수**인 이유도 그것입니다. 돌아가는 CSS 애니메이션이 없으니 문자열을 건넬 곳이 없습니다. 기본은 ease out인데, 도착하는 숫자가 그래야 하는 모양입니다. 세고 있다고 읽힐 만큼 빠르고, 끝에서 툭 끊기지 않고 수치에 내려앉을 만큼 느립니다.

:::

::: fw flutter

`formatValue`가 옵션 객체가 아니라 콜백인 것은 `PlProgressLinear`와 같은 이유입니다. 프레임워크에 `Intl`이 없고, 그것을 주려고 `package:intl`을 끌어오는 것은 소비자를 대신해 의존성을 정하는 일입니다.

:::

## Examples

### 랜딩 페이지의 숫자 한 줄

이 컴포넌트가 존재하는 경우이고, `visible`이 기본값인 이유입니다.

```tsx
<PlStat label="Deploys" value={<PlAnimateCounter value={4812} />} />
```

`PlStat`이 값으로 **노드**를 받는 것이 바로 이것을 넣을 수 있게 하기 위해서입니다.

### 새 숫자까지 세기

`value`가 바뀌면 마지막으로 도착한 자리에서 다시 셉니다. 1분마다 수치가 갱신되는 대시보드에 다시 재생하라고 말할 필요가 없습니다.

```tsx
<PlAnimateCounter value={deploys} />
```

### 0이 아닌 곳에서 시작하기

```tsx
<PlAnimateCounter from={4000} value={4812} duration={800} />
```

## Accessibility

- **스크린 리더는 답을 한 번 듣습니다.** 세어 올라가는 수치는 접근성 트리에서 감추고, 최종 숫자를 그 옆의 잘린 span에 둡니다. 초당 예순 번 바뀌는 숫자는 그 트리에서 침묵이거나 예순 번의 알림이고, 둘 다 수치가 아닙니다.
- 동작을 줄여 달라고 한 사람에게는 카운트가 아예 없습니다. 숫자가 그냥 거기 있고, 애초에 나르던 것이 그것뿐입니다.
- 시작하기 전까지 보이는 수치는 **거기서부터** 셀 숫자입니다. 여기의 모든 keyframe이 자기 첫 프레임에 대해 지키는 규칙과 같고, 그래서 도달하지 않은 값을 주장하지 않습니다.
- 숫자는 `tabular-nums`입니다. 세는 동안 수치가 흔들리지 않습니다.
