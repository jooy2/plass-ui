---
title: usePlBreakpoint
order: 2
---

# usePlBreakpoint

<p class="plass-lede">창이 breakpoint 사다리의 어느 칸에 있는지, 그리고 <code>PlassResponsive</code> 맵이 거기서 어떤 값이 되는지. <code>PlGrid</code>가 쓰고 Tailwind variant가 쓰는 그 다섯 너비를, JavaScript에서 답합니다.</p>

<Demo src="hooks/breakpoint" :min-height="320" />

::: fw react

```tsx
import { usePlBreakpoint, usePlBreakpointValue } from 'plass-ui';

const at = usePlBreakpoint(); // 'xs' | 'sm' | 'md' | 'lg' | 'xl'
const columns = usePlBreakpointValue({ xs: 1, sm: 2, lg: 4 });
```

:::

::: fw flutter

hook은 React 전용입니다. Flutter는 `MediaQuery`에서 너비를 읽어 비교합니다 — 구독이 빠진 같은 산수입니다.

```dart
final width = MediaQuery.sizeOf(context).width;
final columns = width >= 1024 ? 4 : width >= 640 ? 2 : 1;
```

:::

## Signature

```ts
function usePlBreakpoint(): PlassBreakpoint;
function usePlBreakpointValue<T>(value: PlassResponsive<T>): T | undefined;
```

사다리는 Tailwind 자신의 것입니다. 여기서 내린 결정과 클래스 이름에서 내린 결정이 함께 바뀝니다.

| 칸   | 시작  |
| ---- | ----- |
| `xs` | 0     |
| `sm` | 40rem |
| `md` | 48rem |
| `lg` | 64rem |
| `xl` | 80rem |

## Examples

### usePlBreakpointValue

`PlGrid`의 반응형 prop과 같은 모양, 같은 규칙입니다. 맨값은 어디에나 적용되고, 맵은 각 항목을 **자기 breakpoint부터 위로** 적용합니다. 보통 두 항목이면 레이아웃 하나가 설명됩니다.

```tsx
usePlBreakpointValue(3); // 어느 너비에서나 3
usePlBreakpointValue({ xs: 1, md: 3 }); // 휴대폰에서 1, 48rem부터 3
```

항목은 위 칸으로 이어지므로 `{ xs: 1, md: 3 }`은 `lg`와 `xl`에서 둘 다 쓰지 않고도 `3`입니다.

### 맵이 적은 칸보다 아래일 때

추측이 아니라 `undefined`입니다.

```tsx
usePlBreakpointValue({ lg: 3 }); // xs, sm, md에서 undefined
```

호출자가 적지 않은 값을 만들어 주는 쪽이 더 나쁩니다. 어디에나 답이 있어야 한다면 맵에 `xs` 항목을 주세요.

### CSS가 내릴 수 없는 결정

몇 개를 가져올지, 몇 글자에서 자를지, 둘 중 어느 컴포넌트를 마운트할지.

```tsx
const perPage = usePlBreakpointValue({ xs: 10, md: 25, xl: 50 }) ?? 10;
```

## Notes

- **`xs`가 서버의 답**이고, 브라우저가 처음 렌더링하는 답입니다. [`usePlMediaQuery`](./use-media-query)가 설명하는 그 규칙이며 이유도 같습니다. 안전한 쪽이기도 합니다 — `xs`는 좁은 레이아웃입니다.
- `innerWidth` 한 번이 아니라 media query 네 개입니다. JavaScript에서 잰 너비는 픽셀 수와 비교해야 하는데 사다리는 `rem`으로 적혀 있습니다. 기본 글꼴을 키워 둔 사용자에게는 스타일시트와 어긋나는 칸이 나옵니다.
- **객체는 맵으로 읽습니다.** 반응형 prop에서와 똑같습니다. 값 자체가 객체라면 감싸야 합니다 — `{ xs: { … } }`.
- `usePlBreakpointValue`는 `usePlBreakpoint`를 부르고, 그것은 media query 네 개를 부릅니다. 리스너는 페이지 전체에서 query당 하나로 공유되므로 hook 자체는 쌉니다. 다만 값은 렌더마다 다시 계산되므로, 맵이 크다면 렌더 본문 밖에 두세요.
