---
title: PlAnimateTyping
order: 10
---

# PlAnimateTyping

<p class="plass-lede">글자가 하나씩 나타납니다. 문자열 전체는 첫 프레임부터 문서에 있어서, 보지 못하는 사람에게는 아무 비용도 들지 않고 보는 사람에게는 아무것도 reflow시키지 않습니다.</p>

<Demo src="animate-typing/hero" :min-height="160" />

::: fw react

```tsx
import { PlAnimateTyping } from 'plass-ui';

<PlAnimateTyping text="npm install plass-ui" speed={14} hold={1600} erase repeat="infinite" />;
```

:::

## Props

<PropsTable name="PlAnimateTyping" />

::: fw react

네이티브 `<div>` 속성은 그대로 통과합니다. 다만 `children`은 예외로, 그것이 텍스트입니다. `render`도 `easing`도 `alternate`도 없습니다. 컴포넌트가 자기 span 두 개를 가지고 있고, 타자기는 곡선을 따라가는 것이 아니라 글자 단위로 나아갑니다.

:::

**텍스트만 타이핑됩니다.** 문자열 하나 또는 여럿을 넘기세요. children 사이의 요소는 자기 텍스트만 보태고 마크업은 아무것도 보태지 않습니다. 링크의 절반을 정직하게 드러낼 방법이 없기 때문입니다.

`duration`은 **문자열 전체**에 걸리는 시간으로 해석되고 `speed`를 덮어씁니다. 여기서 자연스러운 단위는 `speed`입니다. 긴 문단과 짧은 문단은 같은 시간이 아니라 같은 속도로 쳐져야 하니까요. 그래서 기본값이 그쪽입니다.

## Examples

### speed

초당 글자 수입니다. 24 언저리가 사람이 치는 것처럼 읽히고, 10 아래는 기계가 찍는 것, 60 위는 줄이 그냥 나타나는 쪽에 가깝습니다.

<Demo src="animate-typing/speed" :min-height="240">

::: fw react

<<< @/.vitepress/demos/animate-typing/speed.tsx

:::

</Demo>

### erase

`repeat`, `hold`, `erase`가 이것을 순환으로 만듭니다. 치고, 붙들고, 지우고, 다시 칩니다. `erase` 없이는 반복이 한 프레임에 지워지는데, 다시 쓰이는 것이 아니라 **교체되는** 줄에는 그쪽이 맞습니다.

<Demo src="animate-typing/erase" :min-height="160">

::: fw react

<<< @/.vitepress/demos/animate-typing/erase.tsx

:::

</Demo>

## Accessibility

::: fw react

- 문자열 전체는 잘려 있는 상자 안에 있고 스크린리더는 그것을 **한 번** 읽습니다. 애니메이션되는 눈에 보이는 사본은 `aria-hidden`입니다. 아무도 공연을 끝까지 앉아 있을 필요가 없습니다.
- `prefers-reduced-motion`에서는 텍스트가 그냥 거기 있습니다. "아무 일도 일어나지 않음"이 아닙니다. 컴포넌트가 담고 있던 것을 그대로 전달하는 유일한 결과입니다.
- 나아가는 단위는 code point가 아니라 **grapheme**입니다. `👩‍👩‍👧`는 읽는 사람에게 한 글자이고 JavaScript에게 code point 일곱 개이며, code point 단위로 나아가는 타자기는 그것을 아무 뜻도 없는 조각들로 조립하는 데 네 프레임을 씁니다.
- 상자는 도착한 글자들로부터 레이아웃되지 않으므로 주변 텍스트가 매 프레임 reflow하지 않습니다. 다만 컨테이너가 허용하는 만큼 넓어지므로, 줄바꿈이 중요하다면 한 줄짜리 효과에는 `white-space: nowrap`이나 너비를 주세요.

:::
