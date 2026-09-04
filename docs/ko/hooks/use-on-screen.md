---
title: usePlOnScreen
order: 8
---

# usePlOnScreen

<p class="plass-lede">요소가 화면에 있는지 알려 줍니다. <code>IntersectionObserver</code>에 훅이 정해야 하는 세 가지가 붙은 것이고, 흥미로운 것은 한 번 보고 나면 지켜보기를 그만둔다는 점입니다.</p>

<Demo src="hooks/on-screen" :min-height="260" :flutter="false" />

::: fw react

```tsx
import { usePlOnScreen } from 'plass-ui';

const section = useRef<HTMLDivElement>(null);
const seen = usePlOnScreen(section, { rootMargin: '200px' });
```

:::

::: fw flutter

훅은 React 전용이고, 이것의 Flutter 쪽은 필요한 위젯 안에 들어 있습니다. 모든 `PlAnimate*`가 `trigger: PlassAnimateTrigger.visible`을 받고 가장 가까운 `Scrollable`을 상대로 스스로 지켜봅니다.

:::

## 시그니처

```ts
function usePlOnScreen(
  target: RefObject<Element | null>,
  options?: {
    threshold?: number;
    rootMargin?: string;
    root?: RefObject<Element | null>;
    once?: boolean;
  }
): boolean;
```

|              |                                                                  |
| ------------ | ---------------------------------------------------------------- |
| `target`     | 지켜볼 요소를 가리키는 ref.                                      |
| `threshold`  | 얼마나 보여야 세는지, `0`…`1`. 기본은 `0`입니다.                 |
| `rootMargin` | 바깥으로 얼마까지 세는지. `'200px'`이면 한 화면 일찍 시작합니다. |
| `root`       | 무엇을 기준으로 재는지. 주지 않으면 뷰포트입니다.                |
| `once`       | 처음 나타나면 지켜보기를 멈춥니다. **기본이 켜짐입니다.**        |
| returns      | 화면에 들어온 뒤로 `true`.                                       |

## once가 켜져 있습니다

호출자가 거의 언제나 가진 질문은 "**이미 보였는가**"이지 "지금 화면에 있는가"가 아닙니다. 지연 로드하는 그림, 한 번만 재생하는 섹션, 다음 묶음을 가져오는 페이지. 셋 다 첫 번째 답을 원하고, 셋 다 두 번 듣고 싶어 하지 않습니다.

두 번째 질문에 계속 답하는 훅은 지연 로드 그림이 잔뜩 있는 페이지를 사용자가 지나칠 때마다 아무 이유 없이 다시 렌더링합니다.

정말로 계속 바뀌는 답이 필요할 때만 끄십시오. 섹션이 화면을 벗어나면 나타나는 떠 있는 막대, 화면 밖으로 나가면 멈추는 영상 같은 것들입니다.

## 알기 전에 답하는 것

**`false`** — 서버와 첫 렌더링에서. 이 훅이 쓰이는 두 경우 모두에 안전한 답입니다. 필요 없던 것을 가져오지 않고, 볼 수 있기도 전에 재생하지 않습니다.

**`true`** — `IntersectionObserver`가 없는 브라우저에서. 알아낼 방법이 없고, 영영 로드되지 않는 그림이 일찍 로드되는 그림보다 나쁩니다.

## 예시

### 한 화면 일찍 로드하는 그림

```tsx
const frame = useRef<HTMLDivElement>(null);
const near = usePlOnScreen(frame, { rootMargin: '400px' });

<div ref={frame}>{near ? <PlImage src={src} alt={alt} ratio="16 / 9" /> : null}</div>;
```

### 페이지가 아니라 스크롤 패널 안에서

```tsx
const seen = usePlOnScreen(row, { root: panel });
```

## 참고

- 도착할 때 재생되는 **애니메이션**이라면 이것을 직접 엮지 말고 모든 `PlAnimate*`가 이미 받는 `trigger="visible"`을 쓰십시오. 효과가 붙은 같은 observer입니다.
- 언마운트에서 연결을 끊고, `once`일 때는 답을 얻는 즉시 끊습니다.
