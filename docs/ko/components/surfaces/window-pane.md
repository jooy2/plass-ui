---
title: PlWindowPane
order: 13
---

# PlWindowPane

<p class="plass-lede">여덟 가지 시스템 중 하나가 그리는 대로의 창이고, 안에는 무엇이든 넣을 수 있습니다. 진짜 창이 아니고 그런 척도 하지 않습니다. 동작하는 틀입니다.</p>

<Demo src="window-pane/hero" :min-height="340" />

::: fw react

```tsx
import { PlWindowPane } from 'plass-ui';

<PlWindowPane title="Notes">
  <MyApp />
</PlWindowPane>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlWindowPane(title: const Text('Notes'), child: MyApp());
```

:::

바탕화면도, z 순서도, dock도 없습니다. 있는 것은 끌리는 제목 표시줄과 크기가 바뀌는 모서리, 그리고 진짜 이름이 붙은 진짜 button 셋입니다. 그래서 앱의 스크린샷이나 기능 시연, 랜딩 페이지의 한 조각을 그것의 그림이 아니라 그것이 될 물건으로 보여 줄 수 있습니다.

**여기서 변형되는 것은 아무것도 없습니다.** 끌린 창은 위치가 움직이고 크기를 바꾼 창은 너비와 높이가 바뀝니다. 그래서 두 동작 내내 안의 글자가 정수 픽셀에 남습니다. 축소·확대했다면 끄는 동안 창 안의 모든 글자가 다시 샘플링됐을 텐데, 표면을 변형하지 말라는 집안 규칙이 막으려는 것이 바로 그것입니다.

## Props

<PropsTable name="PlWindowPane" />

`minimize`는 창을 어디로 보내지 않고 제목 표시줄까지 말아 올립니다. 페이지에는 보낼 곳이 없기 때문입니다. `maximize`는 창을 담고 있는 것을 가득 채웁니다.

::: fw flutter

Flutter에는 다른 상자를 가리킬 `position`이 없어서, 창을 담고 있는 것은 부모가 창을 배치하는 상자입니다. 스크롤되는 열의 세로 방향처럼 그 상자가 길이를 정해 두지 않은 방향에서는 최대화한 창도 제 크기를 그대로 지킵니다.

:::

**`size`는 chrome만 키웁니다.** 표시줄, button, 제목입니다. 창의 내용은 caller의 것이고 자기 척도로 배치됩니다. 제목 표시줄이 문서를 따라 커지지 않는 진짜 바탕화면에서와 똑같습니다. [`PlBox`](./box), [`PlMockup`](../display/mockup)에 이어 사다리가 컨트롤 높이가 아닌 것을 뜻하는 세 번째 컴포넌트입니다.

## Examples

### os

<Demo src="window-pane/os" :min-height="700">

::: fw react

<<< @/.vitepress/demos/window-pane/os.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/window_pane/os.dart

:::

</Demo>

버전은 *제목 표시줄*이 바뀐 곳마다 따로 들어갑니다. Windows가 다섯이고 나머지가 하나둘인 이유입니다. XP는 표시줄을 Luna 파랑으로 칠하고 창을 그 파랑으로 둘렀고, 7은 그것을 유리로 만들었고, 8은 둘 다 버리고 각진 흰 판으로 갔고, 10은 표시줄과 본문 사이에 선을 그었고, 11은 모서리를 둥글리고 둘을 다시 한 장으로 만들었습니다. `macosx`는 Aqua이고, 그것을 대신한 평평한 `macos`와 나란히 있습니다.

창에 어떤 button이 있는지는 caller가 정하지만, **어떤 순서로 놓이는지는 시스템이 정합니다.** macOS는 close를 맨 앞에, Windows는 맨 뒤에 둡니다. caller가 외우고 있을 일이 아닙니다.

여기 있는 어느 것도 그 시스템들의 복제가 아닙니다. 그려지는 것은 그 시스템이 쓰던 비율의 표시줄과 테두리와 button 셋뿐이고, 남의 마크나 워드마크나 아이콘은 하나도 없습니다.

### accent와 active

<Demo src="window-pane/accent" :min-height="340">

::: fw react

<<< @/.vitepress/demos/window-pane/accent.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/window_pane/accent.dart

:::

</Demo>

앞에 있는 창 뒤의 창은 모양을 지키고 강조를 잃습니다. 색이 빠지고 그림자가 한 단 내려가고 제목이 회색이 됩니다. `opacity`는 쓰지 않습니다. 그러면 chrome과 함께 내용까지 흐려집니다.

React에서는 `active`를 비워 두면 창이 스스로 알아냅니다. 페이지의 다른 창이 눌리거나 focus를 가져갈 때까지 앞에 있습니다. 창들 *주변*의 클릭은 아무것도 바꾸지 않습니다. 문단은 바탕화면이 아니기 때문입니다. Flutter에서는 그냥 값입니다. 귀 기울일 문서가 없고, 트리를 가로질러 다른 창을 찾는 위젯은 바탕화면을 만들어 내는 셈입니다.

### transparency

<Demo src="window-pane/transparency" :min-height="360">

::: fw react

<<< @/.vitepress/demos/window-pane/transparency.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/window_pane/transparency.dart

:::

</Demo>

제목 표시줄과 본문의 바탕, 테두리에 적용됩니다. **그 위의 내용에는 절대 적용되지 않고**, 내용은 그대로 읽힙니다. React에서는 `0`을 넘기면 blur도 켜지므로 아래 페이지가 그저 비치는 것이 아니라 흐려집니다.

### draggable와 resizable

제목 표시줄이 끌리고 여덟 모서리와 변이 크기를 바꿉니다. 둘 다 기본은 꺼짐입니다. 페이지 속의 창은 대개 창의 그림이고, 스치기만 해도 움직이는 틀은 놀랄 일입니다.

크기는 `minWidth`와 `minHeight`에서 멈추고, 멈춘 크기를 `onResize`가 알립니다. 왼쪽이나 위쪽 변을 끌면 창이 크기와 함께 자리도 옮기므로 그동안 `onOffsetChange`도 함께 부릅니다.

`draggable` 창의 제목 표시줄은 tab 정거장이기도 해서, 창의 button들보다 먼저 focus를 받습니다. 이름은 **Move window**이고 `moveLabel`로 바꿉니다. <kbd>←</kbd> <kbd>→</kbd> <kbd>↑</kbd> <kbd>↓</kbd>를 한 번 누를 때마다 창이 16px, <kbd>Shift</kbd>와 함께면 64px 움직입니다. 쓰기 방향과 상관없이 화살표가 가리키는 쪽으로 가고, 제목 표시줄이 화면 밖으로 나가려는 곳에서 멈춥니다. 표시줄을 끌 수 있으면 이 정거장도 언제나 있습니다.

포인터로 옮기든 키로 옮기든, 모든 이동은 `offset`을 거칩니다. `offset`을 <Fw react="onOffsetChange" flutter="onOffsetChanged" code />와 함께 넘기면 창은 controlled가 됩니다. 가야 할 자리를 알리기만 하고, 새 offset이 돌아올 때까지 그려진 자리에 머뭅니다. 끌기가 전혀 필요 없는 이동도 이렇게 만듭니다. 누를 때마다 앱이 쥔 offset에 한 걸음씩 더하는 button 줄이 그런 예입니다.

## Accessibility

- 창은 제목에서 이름을 가져오는 이름 붙은 group입니다. React에서는 `aria-labelledby`가 붙은 `role="group"`이고, Flutter에서는 `explicitChildNodes`를 켠 semantics container입니다. 제목과 button과 내용의 모든 낱말이 하나의 긴 이름으로 합쳐지는 것을 막는 것이 그것입니다.
- button 셋은 진짜 button이고 자기가 하는 일을 말합니다. 창이 가득 찬 뒤 `maximize`는 **Restore**가 됩니다. 모든 시스템이 그렇게 부릅니다.
- macOS 신호등은 무언가 가리키기 전까지 자기 표시를 감춰 두고, 키보드도 가리키는 것으로 셉니다. focus를 가진 등은 자기 표시를 그리므로 focus ring이 빈 점을 두르는 일이 없습니다.
- 여덟 개의 크기 손잡이 중 하나만 포인터 없이 닿습니다. 두 축을 한 번에 바꾸는 모서리입니다. 창마다 여덟 개의 tab 정거장은 키보드로 읽는 사람에게 나머지 일곱 방향의 값어치보다 비쌉니다. 화살표 키가 그 모서리를 움직입니다. 나머지 일곱은 이름 없이 남기는 대신 접근성 트리에서 감춥니다.
- `draggable` 창은 포인터 없이도 옮길 수 있습니다. 제목 표시줄이 button들보다 앞선 tab 정거장이고, 거기서 화살표 키가 창을 움직입니다. 끌지 않고 포인터 하나로 옮기는 방법은 controlled `offset`으로 직접 더해야 합니다.
- 말아 올린 창의 내용은 **없어지는 것이 아니라 손이 닿지 않게 됩니다.** 트리에는 남되 inert로 표시되므로, 접힌 표시줄 아래의 어떤 것에도 tab으로 들어갈 수 없습니다.
- React에서는 포커스를 가진 창을 닫으면 포커스가 들어온 곳으로 돌아갑니다. 창을 연 버튼 같은 곳입니다. 그 요소가 없어졌거나 닿을 수 없으면 창 뒤의 첫 포커스 가능한 요소로, 없으면 창 앞의 마지막 요소로 갑니다.
