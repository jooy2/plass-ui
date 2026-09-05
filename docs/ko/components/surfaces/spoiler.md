---
title: PlSpoiler
order: 9
---

# PlSpoiler

<p class="plass-lede">누군가 요청할 때까지 덮여 있는 내용입니다. 결말, 정답, 아직 아무도 보겠다고 하지 않은 사진.</p>

<Demo src="spoiler/hero" :min-height="180" />

::: fw react

```tsx
import { PlSpoiler } from 'plass-ui';

<PlSpoiler reversible>
  <p>Rosebud was the name painted on the sled he had as a child.</p>
</PlSpoiler>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlSpoiler(
  reversible: true,
  child: const Text('Rosebud was the name painted on the sled he had as a child.'),
);
```

:::

## Props

<PropsTable name="PlSpoiler" />

::: fw react

나머지 `<div>` 속성은 모두 시트로 전달됩니다.

:::

라이브러리 전체에서 공유하는 축이 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## 왜 숨긴 상자가 아니라 블러인가

덮개는 **블러**이고, 그것이 설계의 전부입니다. 독자는 거기 무언가가 있다는 것과 그것이 대략 얼마만큼인지, 그리고 `maxHeight`가 있다면 잘려 있다는 것까지 볼 수 있습니다. 할 수 없는 것은 실수로 읽는 것이고, 스포일러가 막으려는 것이 그것 하나입니다.

다만 블러만으로는 덮개가 되지 않습니다. 문단은 흐트러뜨리지만 색과 리듬은 남고, 10px로 흐린 사진도 여전히 얼굴 사진으로 알아볼 수 있습니다. 그래서 그 위에 **페이지 자신의 surface 색을 섞은 막**을 얹습니다. 그것이 두 가지를 한 번에 정리합니다 — 내용은 자기 색이 번진 물결이 되고, 버튼은 밑에 무엇이 있든 그 위에 떠 있는 대신 딛고 설 자리를 얻습니다.

짧은 스포일러는 내용이 아니라 자기 덮개만큼 높습니다. 둘이 한 칸을 나눠 쓰므로, 한 줄짜리 스포일러가 누르라고 내미는 버튼을 잘라 먹지 않습니다.

## 시트는 높이가 변하지 않습니다

덮고 여는 동안 주변 페이지는 움직이지 않습니다. 높이를 움직일 수 있는 두 가지를 모두 없애는 대신 붙잡아 두기 때문입니다. 커버는 자기 셀을 지키고, `reversible`의 숨기기 줄도 자기 줄을 지킵니다. 둘 중 어느 것도 들어올 때 레이아웃에서 빠졌다가 나갈 때 돌아오지 않습니다.

그중 중요한 쪽은 커버입니다. 보통 둘 중 더 높은 쪽이기 때문입니다. 커버는 설명 한 줄과 버튼이라, 덮인 글이 한 줄일 때 시트를 벌려 두는 것은 커버입니다. 드러날 때 이것을 빼면 시트는 그 한 줄까지 주저앉고 아래 내용이 전부 위로 딸려 올라갑니다. 자리에 두면 크기는 그대로 재어지고 아무것도 움직이지 않습니다.

붙잡아 둔 것에는 닿을 수 없습니다. 숨어 있는 동안 둘 다 `inert`라서 tab으로 갈 수 없고, 스크린 리더가 읽지 않으며, 선택되지도 않습니다. 이미 내용을 연 독자에게 보이지 않는 열기 버튼을 내미는 일은 없습니다.

`maxHeight`는 위에 적은 대로 예외입니다.

## Examples

### variant

세 재질을 *컨테이너*의 방식으로 말합니다. 시트에는 색이 들어가지 않습니다. 스포일러가 담는 것은 사진이고 문단이고 결말이며, 그것들은 자기 색을 가지고 옵니다 — 색 계열은 버튼과 얇은 선까지만 닿고 멈춥니다.

`ghost`는 상자를 아예 그리지 않습니다. 흐르는 산문 속의 스포일러가 대개 원하는 것이 그것입니다.

<Demo src="spoiler/variants" :min-height="360">

::: fw react

<<< @/.vitepress/demos/spoiler/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/spoiler/variants.dart

:::

</Demo>

### maxHeight

비워 두면 상자는 담고 있는 것만큼 정확히 높습니다. 문단이나 사진에는 그게 맞는 기본값입니다. 흐릿한 내용이 한 페이지를 채우면 아무것도 없는 페이지가 되어 버릴 만큼 긴 것에는 지정하세요.

이 제한은 **덮여 있을 때만** 걸립니다. 무언가를 드러내 놓고 스크롤바 달린 상자에 남겨 두는 것은 엉뚱한 질문에 답하는 것입니다.

그래서 `maxHeight`는 아래 규칙의 **유일한 예외**입니다. 두 상태 사이에서 시트 높이를 바꾸는 것은 이것 하나뿐이고, 그렇게 하는 것이 맞습니다.

<Demo src="spoiler/clamped" :min-height="260">

::: fw react

<<< @/.vitepress/demos/spoiler/clamped.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/spoiler/clamped.dart

:::

</Demo>

### reversible

기본은 꺼져 있습니다. 한 번 드러나면 계속 드러나 있습니다. 켜면 내용 아래에 숨기기 버튼이 나타나는데, 스포일러가 여럿 있는 페이지가 원하는 것이 그것입니다 — 잘못 연 독자가 되돌릴 수 있습니다.

그 줄은 열릴 때 생기는 것이 아니라 **처음부터 자리를 잡고** 있고, 필요해질 때까지 커버 아래에서 보이지 않게 있습니다. 드러남과 함께 도착하는 컨트롤은 들어올 때 시트를 키우고 나갈 때 다시 줄이는 버튼 하나만큼의 높이이고, 그것은 누군가 누르고 있는 바로 그 대상 주위에서 페이지를 두 번 움직입니다. 비어 있는 줄은 커버가 그 위를 덮으므로 보이지 않습니다.

### padded와 미디어

가장자리까지 닿아야 하는 것에서는 여백을 끄세요. 덮인 이미지가 이 컴포넌트를 가장 자주 쓰는 경우이고, 거기서 블러는 진짜 일을 합니다. 형태와 색은 보이고, 무엇인지는 보이지 않습니다.

<Demo src="spoiler/media" :min-height="240">

::: fw react

<<< @/.vitepress/demos/spoiler/media.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/spoiler/media.dart

:::

</Demo>

## Accessibility

- 덮여 있는 동안 내용은 포커스 순서에서 빠지고 접근성 트리에서도 빠집니다. 탭해서 들어갈 수 있는 스포일러는 스포일러가 아닙니다.
- `description`은 버튼보다 먼저 읽힙니다. 무엇 때문에 묻고 있는지를 알려 주는 것이 그것입니다. 끄면 아무 말도 하지 않는 덮개가 남는데, 주변 페이지가 이미 그 말을 하고 있을 때만 할 만합니다.

::: fw react

- 그 전부가 속성 하나입니다 — **`inert`**. 내용을 *선택*에서도 빼냅니다. <kbd>Ctrl</kbd>+<kbd>A</kbd>로 뚫리는 스포일러는 스포일러가 아닙니다.
- 드러내기 버튼은 자기가 제어하는 상태를 알리고 자기가 여는 내용을 가리킵니다. 그래서 스크린 리더가 그것을 있는 그대로의 disclosure로 안내합니다.

:::

::: fw flutter

- `ExcludeSemantics`·`ExcludeFocus`·`IgnorePointer` 셋이 그 속성 하나가 하는 말을 합니다. 텍스트 선택에는 네 번째가 필요 없습니다. Flutter의 선택은 opt-in이라, 덮인 문단은 화면이 그것을 `SelectionArea`로 감쌌을 때만 선택 가능하고 — 그렇게 한 화면은 그러지 말았어야 합니다.

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `revealed` / `defaultRevealed` / `onRevealedChange` | `revealed` / `onRevealedChanged` | 이 패키지에서 **uncontrolled**로 두어도 좋은 유일한 위젯입니다. 기억되는 것이 화면이 가진 값이 아니라 독자가 이 상자에 한 행동이기 때문입니다. `revealed`를 비워 두면 스스로 기억합니다. |
| 노드인 `label`·`hideLabel` | `String`인 `label`·`hideLabel` | 버튼의 문구이자 접근 가능한 이름이고, 둘 다일 수 있는 것은 문자열뿐입니다. |
| `description: ReactNode \| false` | `description: Widget?` | Dart에는 이미 "설정하지 않음"을 뜻하는 말이 있습니다. |
| `maxHeight: number \| string` | `maxHeight: double` | 픽셀은 픽셀 그대로입니다. 받을 CSS 길이가 없습니다. |
| `inert` | `ExcludeSemantics` + `ExcludeFocus` + `IgnorePointer` | 같은 세 가지를, 그것을 하는 세 위젯으로 말한 것입니다. |
| `className`, `style` | — | 전달할 class 목록도 style 속성도 없습니다. |

:::
