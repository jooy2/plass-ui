---
title: usePlReducedMotion
order: 3
---

# usePlReducedMotion

<p class="plass-lede">사용자가 플랫폼에 움직임을 줄여 달라고 해 두었는지 알려 줍니다. 라이브러리는 움직이는 모든 곳에서 이미 이것에 답하고 있고, 이 hook은 애플리케이션이 직접 쓴 움직임을 위한 같은 답입니다.</p>

<Demo src="hooks/reduced-motion" :min-height="260" />

::: fw react

```tsx
import { usePlReducedMotion } from 'plass-ui';

const still = usePlReducedMotion();
```

:::

::: fw flutter

hook은 React 전용입니다. Flutter는 `MediaQuery`에 묻고, 그것이 알아서 rebuild합니다.

```dart
final still = MediaQuery.disableAnimationsOf(context);
```

:::

## Signature

```ts
function usePlReducedMotion(): boolean;
```

플랫폼이 `prefers-reduced-motion: reduce`를 보고하는 동안 `true`입니다. 값이 바뀌면 다시 렌더링하므로, 설정을 켠 사용자가 새로 고침할 필요가 없습니다.

## "줄이기"는 "없애기"가 아닙니다

라이브러리 자신의 컴포넌트들이 여기서 서로 다르게 행동하며, 그 다름이 쓸모 있는 부분입니다.

| 움직임의 종류 | Plass가 하는 일 | 이유 |
| --- | --- | --- |
| 등장, `PlAnimateFade`, `PlAnimateSlide` | 통째로 뺍니다. 내용은 그냥 거기 있습니다 | 재생되지 않은 애니메이션도 실어 나르던 것은 전부 전달했습니다 |
| 로딩 표시, `PlProgressCircular` | 멈추지 않고 **느려집니다** | 멈춘 스피너는 아직 무언가 진행 중인지에 대해 거짓말을 합니다 |
| 장식용 반복, `PlAnimateBlink`, 회전 | 뺍니다 | 말하고 있던 것이 없었습니다 |

이 hook을 쓰기 전에 답할 질문은 "이 효과가 셋 중 무엇인가"입니다. 움직임이 메시지를 나르고 있다면, 움직임을 끄는 대신 메시지를 움직임 밖으로 꺼내세요.

## Examples

### JavaScript로 쓴 움직임

CSS keyframe은 이미 처리돼 있습니다. 스타일시트의 모든 keyframe이 media query 하나로 한꺼번에 꺼집니다. 이것은 끌 규칙이 없는 움직임을 위한 것입니다.

```tsx
const still = usePlReducedMotion();

element.scrollIntoView({ behavior: still ? 'auto' : 'smooth' });
```

### 세어 올라가지 않고 그냥 도착하는 숫자

```tsx
const still = usePlReducedMotion();

return still ? <>{total}</> : <CountUp to={total} />;
```

## Notes

- 서버의 답은 `false`입니다(서버에는 독자가 없고 따라서 선호도 없습니다). 그리고 브라우저의 첫 답도 그렇습니다. 안전한 방향입니다. 선호는 hydration 다음 렌더에 도착하고, 그것은 이 움직임들이 한 프레임도 돌기 전입니다. [`usePlMediaQuery`](./use-media-query)가 설명하는 그 규칙입니다.
- `usePlMediaQuery('(prefers-reduced-motion: reduce)')`에 이름을 붙인 것이며, 그 이름이 핵심입니다. query는 오타 내기 쉽고 그 실수는 조용합니다.
