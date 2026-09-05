---
title: PlAnimateSplit
order: 17
---

# PlAnimateSplit

<p class="plass-lede">한 줄의 글이 조각별로 차례로 도착합니다. 다른 효과들은 자식들에 걸쳐 스스로를 나눠 재생하는데, 글 한 줄에는 자식이 없습니다. 그래서 이것이 자식을 만듭니다.</p>

<Demo src="animate-split/hero" :min-height="200" />

::: fw react

```tsx
import { PlAnimateSplit } from 'plass-ui';

<PlAnimateSplit effect="slide" stagger={60}>
  One design language, two libraries
</PlAnimateSplit>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlAnimateSplit(text: 'One design language, two libraries');
```

:::

## Props

<PropsTable name="PlAnimateSplit" />

## `character`는 모든 문자 체계에서 안전하지 않습니다

쓰기 전에 알아야 할 한 가지입니다.

글자 단위로 자르면 글자 사이의 shaping이 끊깁니다. **아랍 문자가 이어지지 않고**, 데바나가리 결합자가 흩어지고, 여러 코드 포인트로 만들어진 이모지가 조각납니다. 한 단어였던 것이 서로 무관한 글리프의 나열이 됩니다.

`word`에는 그런 문제가 없고, 기본값이며, 어차피 제목이 원하는 것입니다. 도착하는 단어는 눈으로 따라갈 수 있고, 도착하는 글자는 장식입니다.

## 틈은 조각이 아닙니다

공백은 공백으로 남고 자기 등장을 받지 않습니다. 두 단어 사이의 공간을 움직이는 것은 아무것도 도착하지 않는 것입니다. 그리고 stagger의 한 칸도 가져가지 않습니다. 두 번째 단어는 첫 번째보다 두 칸이 아니라 한 칸 뒤에 시작합니다.

::: fw react

각 조각은 `inline-block`입니다. transform은 대체되지 않은 인라인 요소에 적용되지 않으므로, 그것이 없으면 slide가 사라졌다 나타나기만 하고 움직이지는 않습니다.

:::

## 등장을 적는 방법

::: fw react

`effect`가 일곱 keyframe 중 하나를 고르고, `stagger`와 `durationStep`과 `reverse`는 `<li>` 목록을 감싼 [`PlAnimateFade`](./animate-fade)에서와 정확히 같은 뜻입니다. 이 컴포넌트는 **자르는 일**이고 그 이상이 아닙니다.

:::

::: fw flutter

등장은 방향과 거리와 fade로 적습니다. 이미 자식들에 걸쳐 하나의 등장을 나눠 재생하는 위젯인 `PlAnimateAppear`가 적는 방식 그대로입니다.

React 쪽은 대신 CSS keyframe의 이름을 적는데, 그 차이는 일관성의 문제가 아닙니다. 저쪽에서는 효과가 스타일시트가 아는 **이름 붙은 것**이고, 여기서는 모든 효과가 위젯으로 만들어집니다. split은 옆에 있는 위젯이 받는 것을 받습니다.

:::

## Accessibility

- **스크린 리더는 줄을 한 번 듣습니다.** 조각들은 접근성 트리에서 감추고 줄 전체가 그 옆에 있습니다. 쪼개진 제목이 한 단어씩, 혹은 한 글자씩 읽히는 것을 막아 주는 것이 그것입니다. 이 패턴이 그것 없이 등장하는 모든 곳에서 알려진 결함입니다.
- 선택과 복사는 여전히 틈을 포함한 줄 전체를 줍니다.
- 동작을 줄여 달라고 한 사람에게는 아무것도 재생되지 않고 줄이 그냥 거기 있습니다.
