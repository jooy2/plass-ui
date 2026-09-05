---
title: 브레이크포인트
order: 4
---

# 브레이크포인트

<p class="plass-lede">이름 다섯, 너비 넷, 그리고 그것이 적힌 자리 하나. 창의 너비에 따라 달라지는 라이브러리의 모든 것이 같은 사다리를 읽습니다. 여러분의 <code>md:</code> 유틸리티까지 포함해서요. 그게 핵심입니다.</p>

## 사다리

| 칸   | 시작           | 비고                                                                |
| ---- | -------------- | ------------------------------------------------------------------- |
| `xs` | 0              | 모든 것이 이 이상에 있습니다. 바닥이 없어서 경계로 쓰이지 않습니다. |
| `sm` | 40rem · 640px  |                                                                     |
| `md` | 48rem · 768px  |                                                                     |
| `lg` | 64rem · 1024px |                                                                     |
| `xl` | 80rem · 1280px |                                                                     |

`size`와 같은 다섯 이름이고, 의도한 것입니다. 사다리를 한 번 배운 독자가 화면이 모양을 바꾸는 지점을 부르는 두 번째 단어 묶음을 또 배워야 할 이유는 없습니다. 같은 사다리는 아닙니다 — size는 컨트롤이 얼마나 높은지이고 브레이크포인트는 창이 얼마나 넓은지입니다 — 하지만 같은 방향으로 가고 같은 문장에 함께 나옵니다.

::: fw react

너비는 **Tailwind 자신의 것**입니다. 그래야 `md:` 유틸리티가 정하는 레이아웃과 이 라이브러리가 정하는 레이아웃이 같은 순간에 바뀝니다. 한 페이지가 자기 너비에 대해 두 가지 답을 갖고 있으면, 나중에 아무도 원인을 찾지 못하는 몇 픽셀만큼 어긋나기 시작합니다.

:::

## 옮기기

::: fw react

자기 Tailwind 테마에 한 줄이면 됩니다.

```css
@import 'tailwindcss';
@import 'plass-ui/tailwind.css';

@theme {
  --breakpoint-md: 50rem;
}
```

라이브러리의 양쪽 절반이 모두 따라갑니다 — `PlGrid`의 cascade, `PlContainer`의 measure, `PlShow`, `usePlBreakpoint`, 그리고 `PlSidebar`의 `collapseBelow`까지.

**이를 위한 provider prop은 없고, 있을 수도 없습니다.** 미디어 쿼리의 *조건*은 custom property를 읽을 수 없습니다. `@media (width >= var(--x))`는 유효한 CSS가 아니고 앞으로도 아닐 것입니다. 그래서 스타일시트가 결정하는 브레이크포인트는 컴포넌트가 렌더링될 때가 아니라 스타일시트가 컴파일될 때 풀립니다. 라이브러리는 자기 것을 `@variant`로 쓰고, 그것은 Tailwind의 것이고, 그것은 여러분 테마의 것입니다.

JavaScript 쪽은 다른 종류의 질문입니다. 거기서 브레이크포인트는 조건이 아니라 *값*이므로 문서에서 읽어 낼 수 있고, 스타일시트가 바로 그것을 위해 토큰 넷으로 내보냅니다.

```css
--plass-breakpoint-sm: var(--breakpoint-sm, 40rem);
--plass-breakpoint-md: var(--breakpoint-md, 48rem);
--plass-breakpoint-lg: var(--breakpoint-lg, 64rem);
--plass-breakpoint-xl: var(--breakpoint-xl, 80rem);
```

이것들이 아니라 Tailwind 변수를 설정하세요. 이 중 하나를 직접 설정하면 JavaScript 쪽만 움직여서 둘이 어긋납니다. 이 구조가 막으려는 바로 그 실패입니다.

**미리 컴파일된 경로에서는 값이 구워져 있습니다.** `plass-ui/styles.css`를 가져오는 프로젝트는 우리가 컴파일한, 우리 너비가 박힌 스타일시트를 받습니다. 그쪽에는 다시 돌릴 Tailwind가 없습니다. 브레이크포인트를 옮겨야 한다면 `plass-ui/tailwind.css`를 가져오세요.

:::

::: fw flutter

사다리는 `PlassBreakpoint`이고, 그 너비는 React 패키지의 것이며 그것은 Tailwind의 것입니다. 여기에는 스타일시트가 없으므로 컴파일을 걸 대상도 없습니다. 너비는 고정입니다.

:::

## 반응형 값

너비에 따라 달라지는 값은 라이브러리 어디서나 같은 방식으로 씁니다. <Fw react="맨값은 모든 너비에 적용되고, 맵은 각 항목이 자기 브레이크포인트부터 위로 적용됩니다." flutter="base 값은 0부터 위로 적용되고, 각 override는 자기 브레이크포인트부터 위로 적용됩니다." />

::: fw react

```tsx
<PlGridItem span={6} />                    // 모든 너비에서 여섯 칸
<PlGridItem span={{ xs: 12, md: 6 }} />    // 폰에서는 꽉, 48rem부터는 절반
```

`xs` 대체값을 따로 쓸 필요가 없습니다. 항목은 그 위의 너비들로 이어지고, 그것이 반응형 prop을 실제로 이름 붙인 브레이크포인트만큼으로 유지합니다. `{ lg: 3 }`은 칸 하나를 말한 것이지 다섯을 말한 것이 아닙니다.

:::

::: fw flutter

```dart
PlGridItem(span: const PlassResponsive<int>(6));               // 어디서나 여섯
PlGridItem(span: const PlassResponsive<int>(12, md: 6));       // 꽉, 그다음 절반
```

Dart에는 태그 없는 union이 없으므로 base 값이 첫 위치 인자이고 override가 이름 인자입니다. `PlassResponsive(6)`이 "어디서나 여섯 칸"의 전부입니다.

:::

어떤 prop이 이것을 받는지:

| 컴포넌트 | prop |
| --- | --- |
| [`PlGrid`](../components/layout/grid) | `columns` `spacing` `rowSpacing` `columnSpacing` |
| [`PlGridItem`](../components/layout/grid) | `span` `offset` |
| [`PlContainer`](../components/layout/container) [`PlHeader`](../components/layout/header) [`PlFooter`](../components/layout/footer) | `maxWidth` |
| [`PlPanes`](../components/layout/panes) [`PlTabs`](../components/surfaces/tabs) [`PlScrollZone`](../components/layout/scroll-zone) [`PlTimeline`](../components/display/timeline) [`PlStepper`](../components/navigation/stepper) | `orientation` |
| [`PlStack`](../components/layout/stack) | `direction` |

## 반응형 값이 풀리는 자리

::: fw react

이 부분을 이해하는 것이 값어치가 있습니다. 반응형 prop이 무엇을 치르고 무엇을 할 수 있는지를 정하기 때문입니다.

**스타일만 정하는 값은 CSS에서 풀립니다.** 컴포넌트는 호출자가 이름 붙인 칸마다 `--p-*` custom property를 하나씩 쓰고, 스타일시트가 그것을 위 칸에서 아래로 이어 줍니다. 아무것도 측정하지 않고, 창을 끄는 동안 리렌더가 없으며, 서버가 보내는 첫 페인트가 이미 모든 너비에서 정확합니다. 브라우저가 그것을 푸는 주체이기 때문입니다. `PlGrid`와 `PlContainer`가 이 방식이고, `PlShow`는 같은 발상을 `display`로 한 것입니다.

**구조를 정하는 값은 그럴 수 없습니다.** orientation은 컴포넌트가 만드는 DOM, 주장하는 ARIA, 방향키가 가는 방향을 바꾸는데 어떤 스타일시트도 그것을 할 수 없습니다. 그런 것들은 [`usePlBreakpointValue`](../hooks/use-breakpoint)가 풀고, 그것은 JavaScript입니다. 그래서 서버는 `xs` 항목을 렌더링하고 브라우저가 hydration에서 고칩니다.

라이브러리는 가능한 한 CSS 쪽으로 손을 뻗고, 여러분도 그러시면 좋겠습니다.

:::

::: fw flutter

모든 것이 위젯 안에서 `MediaQuery.sizeOf(context).width`를 상대로 풀리고, 첫 프레임부터 정확합니다. 어긋날 서버 렌더링이 없으므로, React 빌드가 해야 하는 구분이 여기서는 생기지 않습니다. 브레이크포인트는 위젯 자기 상자가 아니라 **창**의 너비입니다. 그것이 미디어 쿼리가 재는 것이고, 나란히 놓인 두 위젯이 각자 얼마나 넓어졌든 같은 칸에 있다고 합의하게 만드는 것입니다.

:::

## 이것 아니면 저것을 보여 주기

[`PlShow`](../components/layout/show)가 게이트입니다. `from`, `until`, 또는 둘을 함께 써서 구간으로.

::: fw react

`display: none`으로 숨기므로 양쪽 모두 문서 안에 있고 어느 쪽도 두 번 읽히지 않습니다. 둘 중 하나만 아예 존재해야 할 때 — fetch를 하거나, 비용이 크거나, 상태를 들고 있을 때 — 는 [`usePlBreakpointValue`](../hooks/use-breakpoint)로 하나만 mount하세요.

:::

## JavaScript에서 묻기

::: fw react

CSS가 내릴 수 없는 결정을 위한 훅 셋입니다 — 항목을 몇 개 fetch할지, 두 컴포넌트 중 무엇을 mount할지, 몇 글자에서 자를지.

- [`usePlBreakpoint()`](../hooks/use-breakpoint) — 창이 어느 칸에 있는지.
- [`usePlBreakpointValue(value)`](../hooks/use-breakpoint) — 반응형 값을 푼 결과. 반응형 prop과 같은 모양, 같은 규칙.
- [`usePlMediaQuery(query)`](../hooks/use-media-query) — 아무 쿼리나.

셋 다 서버에서 **`false` / `xs`** 로 답하고, 이는 우회해야 할 버그가 아닙니다. 서버가 보내는 마크업을 결정적으로 만드는 장치입니다. 첫 프레임에 맞아야 하는 것은 CSS에 있어야 합니다 — Tailwind 변형이든 `PlShow`든. 이 훅들은 그다음을 위한 것입니다.

:::

::: fw flutter

`PlassBreakpoint.of(MediaQuery.sizeOf(context).width)`가 전부이고, `PlassResponsive.resolve(breakpoint)`가 반응형 값을 그것에 대고 읽습니다.

:::

## PlSidebar의 breakpoint

[`PlSidebar`](../components/layout/sidebar)는 `collapseBelow` 아래에서 드로어로 접힙니다. 위의 모든 것이 실제로 쓰인 예로 읽을 만합니다. 결정은 첫 페인트를 위한 CSS 미디어 쿼리 **그리고** 그 이후를 위한 JavaScript `matchMedia` 둘 다입니다. 서버가 보내는 마크업은 열이고, 폰이 그것을 그렸다가 버리면 안 되기 때문입니다.
