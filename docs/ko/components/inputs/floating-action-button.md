---
title: PlFloatingActionButton
order: 2
---

# PlFloatingActionButton

<p class="plass-lede">화면이 다루는 단 하나의 액션이 그 위에 떠 있습니다. 모서리에 놓인 <code>PlButton</code>에 고정, 모양, 그리고 규칙 하나가 더해진 것입니다. 라벨은 그려지든 아니든 언제나 존재합니다.</p>

<Demo src="floating-action-button/hero" :min-height="260" />

::: fw react

```tsx
import { PlFloatingActionButton } from 'plass-ui';

<PlFloatingActionButton icon={<PlusGlyph />} label="New project" onClick={create} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlFloatingActionButton(
  icon: const PlusGlyph(),
  label: 'New project',
  onPressed: create,
);
```

:::

## Props

<PropsTable name="PlFloatingActionButton" />

[`PlButton`](./button)이 받는 것은 전부 받습니다. 세 가지 재질, elevation 사다리, 포인터 빛, `loading`, `readOnly`, `disabled`. 공유 축이 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## label은 선택이 아닙니다

떠 있는 버튼은 열에 아홉이 마크 하나가 든 원판입니다. `extended`가 정하는 것은 **글자도 그릴지**이지 글자가 존재하는지가 아닙니다.

그래서 `label`은 필수이고 언제나 접근성 이름입니다. 이름 없는 아이콘 버튼은 이 패턴이 어디서나 함께 배포하는 가장 흔한 접근성 결함이고, prop을 필수로 만드는 것만이 리뷰를 통과해 살아남는 해법입니다.

<Demo src="floating-action-button/extended" :min-height="180">

::: fw react

<<< @/.vitepress/demos/floating-action-button/extended.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/floating_action_button/extended.dart

:::

</Demo>

처음 온 사람이 글리프만 보고 짐작하지 못할 액션이면 `extended`를 켜고, 짐작할 수 있게 되면 다시 끄십시오.

## 두 가지 모양

아이콘만 있는 쪽은 **원판**입니다. [`PlIconButton`](./icon-button)이 radius 규칙에 두는 의도된 예외입니다. 컨트롤 모서리의 평평한 구간은 글줄이 앉으라고 있는 것이고, 글리프에는 글줄이 없습니다.

글자가 있는 쪽은 바로 그 이유로 **알약이 아닙니다**. 모서리를 따라 글자가 있으므로 다른 모든 라벨 있는 컨트롤처럼 하우스 fillet을 씁니다.

## 화면당 하나

한 모서리의 떠 있는 버튼 둘은 주요 액션 둘이고, 그것은 곧 없는 것입니다.

그리고 주요 액션이 이미 본문의 버튼으로 있는 화면은 그 사본을 모서리에 하나 더 두고 싶어 하지 않습니다. 떠 있는 버튼은 달리 놓일 자리가 없는 액션을 위한 것입니다. 곧 무언가를 더하게 될 목록 화면 같은 곳입니다.

## 예시

### 아래 뒤쪽 모서리가 아닌 자리

`corner`는 넷 중 하나이고 left/right가 아니라 `start`/`end`로 적습니다. 그래서 RTL에서 다른 모든 것과 함께 반대편으로 건너갑니다. `offset`은 맞닿은 두 모서리에서 얼마나 떨어져 서는지입니다.

```tsx
<PlFloatingActionButton corner="bottom-start" offset={16} icon={<PlusGlyph />} label="Add" />
```

### 흐름 안에 놓기

`floating={false}`는 모양과 그림자를 남기고 위치 지정만 뺍니다. 카드 끝이나 툴바에 같은 버튼을 놓을 때 씁니다.

```tsx
<PlFloatingActionButton floating={false} extended icon={<PlusGlyph />} label="New project" />
```

## 참고

- `elevation` 기본값은 사다리 꼭대기인 **3**이고, 라이브러리의 다른 모든 기본값과 달리 타협이 아닙니다. 내용 위에 얹혀 있는 것이 아니라 정말로 떠 있는 유일한 컨트롤입니다.
- `size` 기본값은 `PlButton`보다 한 칸 위인 `lg`입니다. 떠 있는 버튼은 엄지가 겨누는 표적입니다.

::: fw react

- `position: fixed`에 **논리** inset을 인라인으로 씁니다. 호출자의 `offset`은 클래스가 아니라 값이고, 인라인 선언만이 utility를 상대로 확정적으로 이깁니다.
- [`PlBackTop`](../navigation/back-top)과 같은 `z-30`에 놓입니다. 페이지 위, portal된 것 아래입니다.

:::

::: fw flutter

- `floating`인 동안은 `PositionedDirectional`이므로 `Stack` 안에 놓입니다. 무언가 떠 있는 화면의 본문은 보통 이미 `Stack`입니다.

:::

## 접근성

- 이름은 언제나 `label`이고, `extended`가 그렸을 바로 그 글자입니다. 이름 없이 이 버튼을 만들 방법은 없습니다.
- 진짜 버튼일 뿐입니다. 문서 순서대로 포커스를 받고, <kbd>Enter</kbd>와 <kbd>Space</kbd>에 답하며, `loading`과 `disabled`를 `PlButton`과 똑같이 보고합니다.
- **내용을 가립니다.** 모서리에 고정된 버튼은 그 아래 있는 무엇이든 덮으므로, 스크롤되는 목록 끝에는 자리를 남겨 두십시오. 떠 있는 버튼 아래 깔린 마지막 줄은 아무도 누를 수 없는 줄입니다.
