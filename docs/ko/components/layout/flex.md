---
title: PlFlex
order: 4
---

# PlFlex

<p class="plass-lede">가로 한 줄 또는 세로 한 칸, 그리고 그 안에 놓인 것들 사이의 간격입니다. 축이 반응형이고 그 결정을 스타일시트가 하므로, 휴대폰에서는 쌓이고 노트북에서는 한 줄로 서는 폼이 prop 하나로 끝나고 다시 렌더링하지 않습니다.</p>

<Demo src="flex/hero" :min-height="200" />

::: fw react

```tsx
import { PlFlex } from 'plass-ui';

<PlFlex direction={{ xs: 'vertical', md: 'horizontal' }} spacing={3} alignItems="center">
  <PlAvatar name="Ada Lovelace" />
  <PlTextField className="flex-1" label="Display name" fullWidth />
  <PlButton>Save</PlButton>
</PlFlex>;
```

:::

::: fw flutter

이 컴포넌트는 React 전용이고, 빠뜨린 것이 아닙니다. `Row`와 `Column`, `Wrap`은 이미 `package:flutter/widgets.dart`에 있고 이미 `spacing`을 받습니다. 이것들을 감싸는 위젯은 Flutter 개발자가 첫 화면부터 알고 있던 세 가지에 네 번째 이름을 붙이는 일입니다.

```dart
Row(
  spacing: 12,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: <Widget>[…],
);
```

Dart에서 가져올 만한 쪽은 반응형 축인데, 그건 위젯이 아니라 `LayoutBuilder`입니다.

```dart
LayoutBuilder(
  builder: (BuildContext context, BoxConstraints constraints) {
    final children = <Widget>[…];

    return constraints.maxWidth >= 768
        ? Row(spacing: 12, children: children)
        : Column(spacing: 12, children: children);
  },
);
```

:::

## Props

<PropsTable name="PlFlex" />

네이티브 `<div>` 속성은 그대로 통과합니다. 라이브러리 전체에서 공유 축이 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## PlFlex, PlStack, PlGrid 중 고르기

자식을 한 줄로 놓는 컴포넌트가 셋 있는데, 서로의 변형이 아닙니다.

|  | 이럴 때 씁니다 |
| --- | --- |
| [`PlFlex`](./flex) | 자식이 각자 자기 크기 그대로일 때. "이것들을 나란히, 사이를 띄워서." |
| [`PlGrid`](./grid) | 자식이 **한 줄의 몫**을 가져갈 때. 12칸 중 `span`, offset, 줄이 맞아 떨어지는 줄바꿈. |
| [`PlStack`](./stack) | 자식이 **겹칠** 때. 아바타 한 줄, 카드 더미. |

`PlFlex`는 셋 중 계산이 없는 쪽입니다. 라이브러리의 어휘를 입힌 flex 상자이고, `className="flex gap-3"`이 주지 못하는 세 가지를 줍니다. Tailwind 없이도 breakpoint에서 축이 바뀌고, `spacing`이 `PlGrid`의 gutter와 같은 눈금이며, `plass-ui/styles.css`만 import하고 Tailwind가 없는 프로젝트에서도 동작합니다.

## direction은 CSS에서 결정됩니다

<code v-pre>direction={{ xs: 'vertical', md: 'horizontal' }}</code>은 48rem 아래에서는 세로, 그 위에서는 가로입니다. 어느 쪽인지는 **스타일시트**가 정합니다. 호출자가 지정한 칸마다 `--p-dir-*` 슬롯이 하나씩 나가고, `PlGrid`의 열이 쓰는 것과 같은 `@variant` 블록이 이를 아래로 흘려보냅니다.

그래서 서버가 보내는 첫 페인트가 모든 너비에서 이미 맞고, 창을 끌어도 다시 렌더링하지 않으며, 리스너도 붙지 않습니다. 라이브러리의 모든 반응형 prop에 [breakpoints](../../design/breakpoints) 문서가 긋는 선이 이것입니다. **스타일**만 정하는 값은 CSS에서 풀고, **구조**를 정하는 값은(어떤 DOM을 만들지와 화살표 키가 어디로 갈지까지 바꾸는 orientation처럼) JavaScript에서 풀며 그 대가를 냅니다.

<Demo src="flex/direction" :min-height="260">

::: fw react

<<< @/.vitepress/demos/flex/direction.tsx

:::

</Demo>

지정하지 않은 칸은 바로 아래 칸을 물려받습니다. `{ xs: 'horizontal', lg: 'vertical' }`은 64rem 전까지 모든 너비에서 가로입니다. 칸 하나를 지정한다고 나머지가 사라지지도 않습니다. `xs` 항목은 CSS 폴백이 아니라 문서에 적힌 기본값으로 채워집니다.

## reverse는 그리는 순서입니다

자식을 축의 반대 방향으로 놓고 **그 밖에는 아무것도 바꾸지 않습니다**. 스크린 리더가 읽는 순서와 <kbd>Tab</kbd> 키가 걷는 순서는 DOM 순서이고, 둘 다 그대로입니다.

그래서 배치에는 맞고(반대쪽 끝에 붙는 채팅 말풍선, 뒤쪽에 놓이는 푸터의 액션) 순서 자체가 정보인 내용에는 맞지 않습니다. 두 번째 것이 두 번째로 읽혀야 한다면 두 번째에 두십시오.

반응형이 아닌 것은 의도한 것입니다. `direction`이 쓰는 슬롯에 함께 접히므로 커스텀 속성 하나가 답 전체를 나르고, breakpoint에서 축이 바뀔 때 어느 끝에서 시작하는지를 다시 말할 필요가 없습니다.

## Examples

### 줄바꿈하는 툴바

`wrap`은 기본값이 `false`이고, 그것이 flex 상자가 원래 하는 일입니다. 줄바꿈은 결정이지 결정하지 않은 상태가 아닙니다. 반대로 기본값을 잡으면 누군가 딱 맞게 크기를 잡아 둔 툴바가 소리 없이 흐트러집니다.

<Demo src="flex/toolbar" :min-height="200">

::: fw react

<<< @/.vitepress/demos/flex/toolbar.tsx

:::

</Demo>

### 축마다 다른 간격

`spacing`은 둘 다 정합니다. `rowSpacing`과 `columnSpacing`은 하나씩 맡고 없으면 `spacing`으로 돌아가는데, 줄바꿈하는 칩 한 줄이 보통 원하는 모습입니다. 줄 사이는 좁게, 줄을 따라서는 넓게.

```tsx
<PlFlex wrap spacing={3} rowSpacing={1.5}>
```

### inline

`inline`은 상자를 글줄 안에 놓고 자식만큼만 넓게 만듭니다. 따로 블록을 차지하지 않고 문장 안에 토큰을 늘어놓을 때 씁니다.

```tsx
<p>
  Assigned to{' '}
  <PlFlex inline spacing={1} alignItems="center">
    <PlAvatar size="xs" name="Ada" /> Ada
  </PlFlex>{' '}
  since March.
</p>
```

## Notes

- **아무것도 그리지 않습니다.** 표면도 패딩도 없고 `variant`, `color`, `size`, `density`, `elevation`도 받지 않습니다. flex 상자는 그 안에 든 표면들의 배치이고, 이 컴포넌트가 가진 유일한 치수는 자식 **사이**의 공간인 `spacing`입니다.
- `spacing`은 8px 눈금이 아니라 Tailwind의 spacing 눈금입니다. `spacing={4}`는 `1rem`으로, `gap-4`가 뜻하는 값이자 `PlGrid`에서 gutter `4`가 뜻하는 값과 같습니다. 소수도 같은 사다리 위에 있어서 `1.5`는 `0.375rem`입니다.
- `render`는 마크업이 실제로 원하는 요소로 `<div>`를 바꿉니다. `<ul>`, `<nav>`, `<fieldset>` 어느 것이든 레이아웃은 그대로입니다.
- `flex-direction`은 컴포넌트 자신의 클래스에 선언되므로 `className`에 실린 `flex-col`은 집니다. 같은 뜻이면서 반응형이기까지 한 `direction`을 쓰십시오.

## Accessibility

- **순서를 바꾸는 것은 시각적인 일입니다.** `reverse`도, 호출자가 자식에 것은 `order`도 픽셀을 옮길 뿐 문서를 옮기지 않습니다. 읽는 순서가 보이는 순서와 어긋나는 것은 [의미 있는 순서](https://www.w3.org/WAI/WCAG22/Understanding/meaningful-sequence.html)에 대한 명시된 실패이므로, 읽혀야 할 순서대로 내용을 두고 레이아웃이 그것을 따르게 하십시오.
- role이 없고 role을 붙이지도 않습니다. 배치를 스크린 리더에게 목록으로 만들어 주는 것은 `<li>` 자식과 함께 쓰는 `render={<ul />}`이고, 그냥 두면 `<div>` 안의 `<div>`로 보입니다.
