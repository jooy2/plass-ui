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

공백은 공백으로 남습니다. 두 단어 사이의 틈은 자기 등장을 받지 않고 stagger의 한 칸도 가져가지 않으므로, 두 번째 단어는 첫 번째보다 한 칸 뒤에 시작합니다.

줄은 같은 글이 넘어갈 자리에서 넘어갑니다. 글자 단위로 잘라도 한 단어의 글자는 함께 묶여 있어서 줄이 단어 사이에서 넘어가고, 줄 전체보다 긴 단어는 그 안에서 줄을 바꾸며, 중국어, 일본어, 태국어처럼 단어 사이를 띄우지 않는 문자는 여전히 글자 사이에서 줄이 넘어갑니다. 단어 단위로 자르면 공백이 없는 줄은 한 조각이 되고, 그 조각은 자리가 모자라면 다음 줄에서 시작해 글자 사이에서 줄을 바꿉니다.

## Examples

### by

기본값인 `word`가 제목에 맞습니다. 도착하는 단어는 눈으로 따라갈 수 있습니다. `character`는 독자가 한 글자로 세는 단위인 grapheme으로 자르므로 데바나가리 결합자, 국기, 여러 코드 포인트로 만들어진 이모지는 각각 한 조각에 그대로 남습니다.

**`character`는 모든 문자 체계에서 안전하지는 않습니다.** 글자 단위로 자르면 글자 사이의 shaping이 끊겨서 **아랍 문자가 이어지지 않고**, 한 단어였던 것이 서로 무관한 글리프의 나열이 됩니다.

<Demo src="animate-split/by" :min-height="200">

::: fw react

<<< @/.vitepress/demos/animate-split/by.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_split/by.dart

:::

</Demo>

### <Fw react="effect" flutter="from · distance · fade" />

::: fw react

`effect`가 일곱 등장 중 하나를 고르고, 각 조각은 같은 이름의 컴포넌트에 아무것도 주지 않았을 때와 같은 자리에서 출발합니다. `slide` 조각은 자기 높이만큼 아래에서 올라오고, `zoom` 조각은 크기의 0.4에서, `grow` 조각은 0.8에서 커집니다.

:::

::: fw flutter

등장은 방향과 거리와 fade로 적습니다. [`PlAnimateAppear`](./animate-appear)가 적는 방식 그대로입니다. React 쪽은 등장의 이름을 적는데, 저쪽에서는 효과가 스타일시트가 이름으로 아는 keyframe이고 여기서는 모든 효과가 위젯으로 만들어지기 때문입니다.

:::

<Demo src="animate-split/effect" :min-height="320">

::: fw react

<<< @/.vitepress/demos/animate-split/effect.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_split/effect.dart

:::

</Demo>

### stagger

한 조각 다음에 다음 조각이 얼마 뒤에 시작하는지입니다. 이 컴포넌트는 **자르는 일**을 할 뿐입니다.

::: fw react

`stagger`와 `durationStep`과 `reverse`는 `<li>` 목록을 감싼 [`PlAnimateFade`](./animate-fade)에서와 정확히 같은 뜻입니다.

:::

::: fw flutter

`stagger`와 `reverse`는 [`PlAnimateAppear`](./animate-appear)에서와 정확히 같은 뜻입니다.

:::

<Demo src="animate-split/stagger" :min-height="240">

::: fw react

<<< @/.vitepress/demos/animate-split/stagger.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_split/stagger.dart

:::

</Demo>

## Accessibility

- **스크린 리더는 줄을 한 번 듣습니다.** 조각들은 접근성 트리에서 감추고 줄 전체가 그 옆에 있습니다. 쪼개진 제목이 한 단어씩, 혹은 한 글자씩 읽히는 것을 막아 주는 것이 그것입니다. 이 패턴이 그것 없이 등장하는 모든 곳에서 알려진 결함입니다.
- 선택과 복사는 여전히 틈을 포함한 줄 전체를 주고, 한 번만 줍니다. 스크린 리더가 읽는 잘린 사본은 선택에서 빠집니다.
- 동작을 줄여 달라고 한 사람에게는 아무것도 재생되지 않고 줄이 그냥 거기 있습니다.
