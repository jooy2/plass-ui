---
title: PlAnimateScramble
order: 16
---

# PlAnimateScramble

<p class="plass-lede">잡음에서 풀려 나오는 한 줄의 글입니다. 그 잡음은 그 줄 자신의 글자들로 만들어지고, 그래서 라틴 문자가 하나도 없는 문자 체계에서도 동작합니다.</p>

<Demo src="animate-scramble/hero" :min-height="200" />

::: fw react

```tsx
import { PlAnimateScramble } from 'plass-ui';

<PlAnimateScramble>Ship it on Friday</PlAnimateScramble>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlAnimateScramble(text: 'Ship it on Friday');
```

:::

## Props

<PropsTable name="PlAnimateScramble" />

## 잡음은 그 줄 자신의 글자입니다

기본 알파벳을 함께 배포하는 스크램블러는 예외 없이 **영어** 알파벳을 배포합니다. 한국어나 그리스어나 아랍어 제목 위에서 그것은 단어가 풀려 나오는 것이 아닙니다. 단어가 나타날 자리에서 다른 문자 체계가 깜빡이는 것이고, 자기 언어가 남의 언어 사이에서 도착하는 것을 보는 사람은 버그를 보고 있는 것입니다.

그 줄 자신의 글자를 섞는 것은 어느 문자 체계에서나 옳고 값도 들지 않습니다. **색과 너비도 흔들리지 않습니다.** 매 프레임이 완성된 줄을 이루는 바로 그 글자들로 그려지기 때문입니다.

터미널 느낌을 정말로 원하는 호출자를 위해 `characters`가 이것을 덮습니다.

```tsx
<PlAnimateScramble characters="01">Ship it on Friday</PlAnimateScramble>
```

## 왼쪽에서 오른쪽으로 가라앉습니다

무작위가 아닙니다. 도착하는 단어는 눈으로 따라갈 수 있는 것이고, 한눈 팔았다 돌아와도 자리를 잃지 않습니다. 무작위 순서로 가라앉는 글자들은 슬롯머신입니다.

**공백은 절대 섞지 않습니다.** 단어 사이의 틈이 잡음 한 줄을 여전히 문장처럼 보이게 하는 것이고, 공백이 글자로 깜빡이면 매 프레임마다 단어 수가 바뀝니다.

## 문자열을 받습니다

노드가 아닙니다. [`PlAnimateCounter`](./animate-counter)가 숫자를 받는 것과 같은 이유입니다. `<strong>` 안에는 섞을 글자가 없습니다. 안의 글자가 아니라 컴포넌트에 스타일을 주십시오.

counter와 마찬가지로 마운트가 아니라 **보일 때까지 기다립니다.** 화면 밖에서 풀린 줄이 전달한 것은 이미 거기 있던 글입니다.

## Notes

- 다시 그리는 것은 매 프레임이 아니라 `tick`(기본 45ms) 단위입니다. 초당 예순 번 바뀌는 글자 줄은 눈이 아프고, 민감한 사람에게는 절대 건네서는 안 되는 종류의 깜빡임입니다.
- 줄이 바뀌면 잡음에서부터 다시 돕니다.

## Accessibility

- **스크린 리더는 줄을 한 번 듣고**, 잡음은 듣지 않습니다. 가라앉는 글자는 접근성 트리에서 감추고 진짜 줄이 그 옆 잘린 span에 있습니다.
- 동작을 줄여 달라고 한 사람에게는 스크램블이 아예 없습니다. 줄이 그냥 거기 있습니다.
- 시작하기 전까지 그려지는 것은 줄이 아니라 잡음입니다. 여기의 모든 효과가 자기 첫 프레임에 대해 지키는 규칙과 같아서, 의도보다 먼저 조용히 읽히는 일이 없습니다.
