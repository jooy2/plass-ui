---
title: PlAnimateFloat
order: 13
---

# PlAnimateFloat

<p class="plass-lede">가만히 떠서 흔들릴 뿐 어디로도 가지 않는 내용입니다. 여기서 혼자 다릅니다. 다른 모든 효과는 내용이 도착할 때 한 번 재생되는 등장이고, 이것은 끝나지 않습니다.</p>

<Demo src="animate-float/hero" :min-height="220" />

::: fw react

```tsx
import { PlAnimateFloat } from 'plass-ui';

<PlAnimateFloat>
  <EmptyStateMark />
</PlAnimateFloat>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlAnimateFloat(child: EmptyStateMark());
```

:::

## Props

<PropsTable name="PlAnimateFloat" />

공유 애니메이션 prop이 무엇을 뜻하는지는 다른 [트랜지션](./animate-fade) 어느 페이지에나 있습니다.

## 등장이 아닙니다

이 그룹의 나머지는 "이 내용이 어떻게 도착하는가"에 답합니다. 이것은 "무게가 없다는 것은 어떻게 보이는가"에 답하고, 거기서 셋이 따라 나옵니다.

**끝나지 않습니다.** `repeat`이 기본으로 무한입니다. 한 번 나갔다 돌아오는 것은 툭 건드리는 것이고, 아무도 그것을 요청하지 않습니다.

**효과 union에 들어가지 않습니다.** `mode`와 `stagger`와 공유 효과 맵이 얹혀 있는 `PlassAnimation`은 내용이 _도착하는_ 방식의 집합입니다. 표류는 도착이 아니고, 그 맵을 import하는 모든 컴포넌트는 쓰든 안 쓰든 각 항목의 값을 치릅니다. 다른 무엇도 원할 수 없는 항목은 넣지 않습니다. 대신 자기 keyframe을 돌립니다.

**`mode`가 없습니다.** 표류에는 역방향이 없습니다. 주기가 이미 대칭이라 거꾸로 돌려도 같은 주기입니다.

## 주기가 대칭입니다

제자리, 바깥, 제자리. 몇 번을 돌아도 시작한 곳에서 끝나므로, 주기 중간에 멈춘 float가 위젯을 몇 픽셀 어긋난 자리에 영영 남겨 두지 않습니다. 그런 것은 끝난 효과가 아니라 레이아웃 버그로 읽힙니다.

[`PlAnimateBlink`](./animate-blink)가 같은 모양을 같은 이유로 취합니다.

## easing

기본값이 `ease-in-out`이고, 라이브러리에서 하우스 커브를 쓰지 않는 유일한 컴포넌트입니다.

하우스 커브는 **등장의** 커브입니다. 출발이 빠르고 자리에 닿을 때 느립니다. 표류에 그 커브를 쓰면 주기의 양 끝에서 돌아서지 않고 덜컥거립니다. 출발선이 없기 때문입니다. 대상은 이미 거기 있고 숨만 쉬고 있습니다.

## 예시

### 빈 상태 위의 마크

흔한 쓰임이고, 거의 유일한 쓰임입니다. 주의의 가장자리에서 느껴지라고 있는 장식입니다.

```tsx
<PlEmpty title="No projects yet">
  <PlAnimateFloat>
    <ProjectsMark />
  </PlAnimateFloat>
</PlEmpty>
```

### 옆으로, 더 멀리

```tsx
<PlAnimateFloat orientation="horizontal" distance={16} duration={5000}>
  <Cloud />
</PlAnimateFloat>
```

`distance`의 기본값이 작은 것은 의도입니다. 열두 픽셀쯤을 넘으면 표류가 아니라 페이지 위에서 무언가 움직이는 것이 됩니다.

## 참고

- 아래가 아니라 위입니다. "float"은 어디서든 그 뜻이고, 아래로 가는 기본값은 낙하입니다.
- 여기의 모든 효과가 그렇듯 `transform` 축약형이 아니라 독립 속성인 `translate`로 움직입니다. 그래서 같은 요소에 호출자가 건 transform이 살아남습니다.

## 접근성

- **동작을 줄여 달라고 한 사람에게는 아무것도 보이지 않습니다.** 이 움직임에 무엇도 기대서는 안 되고, 기댈 것도 없습니다. 장식이고 내용은 어느 쪽이든 전달됩니다.
- 읽을 것을 안에 넣지 마십시오. 읽는 동안 떠다니는 글자는 쫓아가야 하는 글자입니다.
- 읽고 있는 페이지 구석에서 멈추지 않고 움직이는 것은 이 라이브러리가 다른 곳에서는 거절하는 유일한 종류의 움직임입니다. 이것은 삽화를 위한 것이지 공지를 위한 것이 아닙니다.
