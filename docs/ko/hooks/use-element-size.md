---
title: usePlElementSize
order: 7
---

# usePlElementSize

<p class="plass-lede">요소가 얼마나 큰지, 바뀌는 대로 따라갑니다. <code>ResizeObserver</code>에 훅이 더해야 하는 두 가지가 붙은 것입니다. 첫 측정이 언제 일어나는지, 그리고 어느 상자를 보고하는지.</p>

<Demo src="hooks/element-size" :min-height="220" :flutter="false" />

::: fw react

```tsx
import { usePlElementSize } from 'plass-ui';

const box = useRef<HTMLDivElement>(null);
const size = usePlElementSize(box);
```

:::

::: fw flutter

훅은 React 전용입니다. Flutter는 같은 질문을 `LayoutBuilder`에 하고, 그것은 이미 제약이 바뀔 때 다시 빌드합니다.

```dart
LayoutBuilder(
  builder: (BuildContext context, BoxConstraints constraints) => Text('${constraints.maxWidth}'),
);
```

:::

## 시그니처

```ts
function usePlElementSize(
  target: RefObject<HTMLElement | null>
): { width: number; height: number } | null;
```

|          |                                                    |
| -------- | -------------------------------------------------- |
| `target` | 잴 요소를 가리키는 ref.                            |
| returns  | 그 요소의 content box, 또는 잴 것이 없으면 `null`. |

## 첫 측정은 observer의 것이 아닙니다

`ResizeObserver`의 첫 콜백은 **한 프레임이 그려진 뒤에** 옵니다. 그 프레임 동안 `0 × 0`에서 레이아웃을 잡은 컴포넌트는 깜빡이고, 느린 기기에서는 눈에 띄게 깜빡입니다.

그래서 크기를 **layout effect**에서도 읽습니다. 브라우저가 그리기 전에 실행되는 쪽입니다. 그다음부터는 observer가 최신으로 유지합니다.

## content box를 보고합니다

요소 자신의 padding을 뺀, 안에 실제로 남은 공간입니다.

손으로 쓴 버전은 거의 언제나 `getBoundingClientRect()`나 observer의 `borderBoxSize`를 보고하는데, 그것은 다른 숫자입니다. padding과 border를 포함합니다. 누군가 요소를 재게 만든 질문 — 안에 들어갈 것에 얼마나 자리가 있는가 — 에는 틀린 숫자입니다.

## 예시

### 담는 상자에 맞춰 크기 잡기

```tsx
const frame = useRef<HTMLDivElement>(null);
const size = usePlElementSize(frame);

<div ref={frame}>{size ? <Chart width={size.width} height={size.height} /> : null}</div>;
```

여기서 `null`이 중요합니다. 첫 렌더링에서 `0`을 짐작해 주면 호출자가 그것으로 나눌 수 있게 됩니다.

### 창이 아니라 요소를 보고 레이아웃 정하기

[`usePlMediaQuery`](./use-media-query)는 **창**에 대해 묻습니다. 이것은 요소에 대해 묻는데, 사이드바에도 페이지에도 똑같이 놓일 수 있는 컴포넌트에는 그쪽이 맞는 질문입니다.

```tsx
const size = usePlElementSize(panel);
const roomy = (size?.width ?? 0) > 480;
```

## 참고

- 움직인 것이 없으면 같은 객체를 그대로 돌려줍니다. 그래서 페이지 다른 곳의 리사이즈가 모든 호출자를 다시 렌더링하지 않습니다.
- `ResizeObserver`가 없는 브라우저는 측정을 **한 번** 받습니다. 아무것도 움직이기 전까지는 맞는 레이아웃이 영영 틀린 레이아웃보다 낫습니다.
- 서버와 첫 렌더링에서는 `null`입니다. 아직 요소가 없는 곳에서 정직한 답입니다.
