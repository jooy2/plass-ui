---
title: PlAnimateShake
order: 14
---

# PlAnimateShake

<p class="plass-lede">거절입니다. 이 묶음에서 등장이 아니라 응답인 유일한 효과이고, 그래서 가만히 멈춘 채 시작합니다. "또"라고 말하는 방법이 <code>replay</code>입니다.</p>

<Demo src="animate-shake/hero" :min-height="240" />

::: fw react

```tsx
import { PlAnimateShake } from 'plass-ui';

<PlAnimateShake replay={attempts}>
  <PlTextField label="Password" type="password" error={error} invalid />
</PlAnimateShake>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlAnimateShake(
  replay: attempts,
  child: PlTextField(label: const Text('Password'), error: error, invalid: true),
);
```

:::

## Props

<PropsTable name="PlAnimateShake" />

공유 애니메이션 prop이 무엇을 뜻하는지는 다른 [트랜지션](./animate-fade) 어느 페이지에나 있습니다.

## replay가 존재 이유입니다

거절은 **두 번** 일어날 수 있고, bool인 `play`로는 "또"라고 말할 수 없습니다. 그것으로 다시 재생하려면 껐다 켜야 하는데, 한 사건에 렌더링 두 번이고 되돌려 놓는 것이 유일한 일인 상태가 하나 생깁니다.

값이 바뀌었다는 사실은 React가 가진 사건에 가장 가까운 것이고, 폼이 이미 세고 있는 실패 횟수가 바로 그 값입니다.

```tsx
const [attempts, setAttempts] = useState(0);

<PlAnimateShake replay={attempts}>…</PlAnimateShake>;
```

첫 렌더링에서는 절대 재생하지 않습니다. 마운트에서 스스로 흔들리는 shake는 일어나지도 않은 사건에 답하는 것입니다.

## 등장이 아닙니다

여기 다른 모든 효과는 "이 내용이 어떻게 도착하는가"에 답하고 **마운트**에서 시작합니다. 이것은 사용자가 한 일에 답하므로 **멈춘 채** 시작하고 — `trigger`의 기본값이 `manual`입니다 — 시키는 때에만 재생합니다.

`mode`와 `stagger`가 얹혀 있는 `PlassAnimation`에도 들어가지 않습니다. [`PlAnimateFloat`](./animate-float)과 같은 이유입니다. 그 union은 내용이 도착하는 방식의 집합이고, 응답은 도착이 아닙니다.

## 시작한 자리에 내려앉습니다

제자리 양옆으로 세 번 떨고 아무것도 아닌 상태로 돌아옵니다.

이 묶음의 다른 어느 것보다 여기서 더 중요합니다. 호출자가 **아직 입력 중인** 내용 위에 돌리게 될 유일한 효과이기 때문입니다. 라벨에서 몇 픽셀 어긋난 채 남은 입력란은 그것이 보고하던 오류보다 나쁜 결함입니다.

## 예시

### 잠긴 컨트롤

```tsx
<PlAnimateShake replay={refusals}>
  <PlButton disabled>Delete workspace</PlButton>
</PlAnimateShake>
```

### 더 짧고 더 넓게 떨기

```tsx
<PlAnimateShake replay={attempts} distance={10} duration={300}>
```

## 접근성

- **동작을 줄여 달라고 한 사람에게는 아무것도 보이지 않습니다.** 그래서 흔들림보다 글자가 더 중요합니다. 거절이 말하려는 것은 **글로도** 말해야 합니다. 입력란의 `error`나 live region의 메시지로요. 흔들림은 강조이지 메시지가 아닙니다.
- 입력란을 흔드는 것은 스크린 리더에게 아무 말도 하지 않습니다. 그것을 하는 입력란 자신의 `error`와 `invalid`와 함께 쓰십시오.
- 내용을 감싸는 장식이지 내용이 무엇인지를 바꾸는 wrapper가 아닙니다. 안에 있는 것은 자기 role과 포커스와 이름을 그대로 유지합니다.
