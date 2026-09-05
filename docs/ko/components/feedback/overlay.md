---
title: PlOverlay
order: 3
---

# PlOverlay

<p class="plass-lede">페이지 전체를 덮어 쓸 수 없게 만드는 판입니다. scrim 하나에, 호출하는 쪽이 그 위에 올려놓는 것이 더해집니다. 대개는 spinner와 무엇을 기다리는지 적은 한 줄입니다.</p>

<Demo src="overlay/hero" :min-height="120" />

::: fw react

```tsx
import { PlOverlay } from 'plass-ui';

<PlOverlay open={saving} label="Saving your changes">
  <Spinner />
</PlOverlay>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlOverlay(
  open: saving,
  label: 'Saving your changes',
  child: const Spinner(),
);
```

오버레이는 자기를 트리 밖으로 들어 올리므로 위쪽에 `Overlay`가 필요합니다. navigator가 있는 `WidgetsApp`과 `MaterialApp`이 둘 다 제공합니다. *어디에 쓰였는지*는 중요하지 않고, 그 자리에서는 아무 공간도 차지하지 않습니다.

:::

## Props

<PropsTable name="PlOverlay" />

::: fw react

네이티브 `<div>` 속성은 popup에 그대로 전달됩니다. `color`와 `children`은 둘 다 여기서는 Plass의 prop이라 전달 대상에서 제외됩니다.

`className`도 함께 popup에 붙습니다. 그 아래 scrim에 닿는 것이 `classNames.backdrop`입니다.

:::

::: fw flutter

**Controlled**입니다. 오버레이를 움직이는 방법은 `open`과 `onOpenChanged`이고 uncontrolled 모드는 없습니다. `onOpenChanged`는 `dismissible`이 켜져 있을 때만 불립니다. 그 외에는 물어볼 주체가 없기 때문입니다.

`color`도 없습니다. React 빌드에서 색 계열이 닿던 유일한 것은 내용이 읽던 슬롯이었고, Flutter에서 내용은 자기 색을 가지고 옵니다.

:::

`variant`는 없습니다. 세 가지 재질은 "이 표면이 페이지에 대해 얼마나 자기를 선언하는가"에 답하는데, 오버레이는 이미 페이지를 가져갔습니다. 실제로 답해야 하는 질문은 `tone`입니다. `elevation`도 없습니다. 오버레이는 나머지 전부가 그 위에 떠 있는 **평면 자체**이고, 그림자를 드리우는 scrim은 가장자리가 있는 scrim입니다.

라이브러리 전체에서 공유 축(`size` `color` `align`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### tone

네 단계는 하나의 축입니다. 뒤에 있는 것이 얼마나 읽히는가. 알파만큼이나 흐림 반경으로 조율되어 있는데, 16px쯤을 넘기면 배경이 평평한 색으로 뭉개져서 알파를 아무리 낮춰도 scrim이 불투명하게 읽히기 때문입니다.

`scrim`은 `PlModal`의 뒤판과 정확히 같습니다. 같아야만 합니다. 그러지 않으면 오버레이 위에 열린 모달에서 이음매가 보입니다.

`clear`는 아무것도 그리지 않으면서 화면을 덮습니다. 그것이 이 값을 고르는 이유 전부입니다: 클릭을 받아 내는 보이지 않는 판.

<Demo src="overlay/tones" :min-height="180">

::: fw react

<<< @/.vitepress/demos/overlay/tones.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/overlay/tones.dart

:::

</Demo>

### dismissible

기본은 꺼짐이고, 이것은 `PlModal`과 반대이며 여기서 두 번 읽어 볼 만한 유일한 prop입니다. 모달은 질문을 하고 Escape는 보편적인 "아니오"입니다. 오버레이는 묻는 대신 *기다리라*고 알리며, 스쳐 지나간 클릭 하나로 사라지는 저장은 사용자가 끝났다고 생각하게 될 저장입니다.

무언가의 바깥 클릭을 받아 내는 것이 일인 오버레이에서 켜세요.

<Demo src="overlay/dismissible" :min-height="120">

::: fw react

<<< @/.vitepress/demos/overlay/dismissible.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/overlay/dismissible.dart

:::

</Demo>

### align

<Demo src="overlay/align" :min-height="120">

::: fw react

<<< @/.vitepress/demos/overlay/align.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/overlay/align.dart

:::

</Demo>

## Accessibility

::: fw react

- 어려운 부분은 Base UI의 Dialog가 가집니다. portal, 스크롤 잠금, 안에 붙들린 focus, 뒤 페이지가 inert가 되는 것, 그리고 닫힐 때 focus가 원래 있던 곳으로 돌아가는 것.
- `label`을 비워 두지 않고 기본값을 둔 이유는, 읽을 것이 아무것도 없는 오버레이(맨 spinner, `clear` 판)도 자기가 무엇인지는 알려야 하기 때문입니다.
- `modal="trap-focus"`는 스크롤과 클릭은 남기고 focus만 안에 붙듭니다. `clear` 오버레이가 대개 원하는 것이 그것입니다.
- 오버레이는 불투명도만 애니메이션합니다. 확대되거나 미끄러지는 오버레이는 그 위에 적힌 것을 화면 너머로 끌고 다니게 되는데, 컨트롤과 달리 이쪽은 대개 문장을 싣고 있습니다.
- 답해야 할 질문이 있으면 `PlModal`을 쓰세요. 오버레이에는 제목도, 설명도, 액션도 없어서 스크린리더가 `label` 말고는 다룰 것이 없습니다.

:::

::: fw flutter

- focus는 들어가서 머뭅니다. 이 레이어는 자기 focus scope이고 traversal은 가장 가까운 scope에서 끊기므로, 오버레이 안의 <kbd>Tab</kbd>이 아래 페이지에 내려앉을 수 없습니다. 닫히면 focus는 원래 쥐고 있던 것에게 돌아갑니다.
- `label`을 비워 두지 않고 기본값을 둔 이유는, 읽을 것이 아무것도 없는 오버레이(맨 spinner, `clear` 판)도 자기가 무엇인지는 알려야 하기 때문입니다. 이 이름은 레이어를 하나의 route로 명명하고, 그것이 스크린리더가 화면이 바뀌었음을 아는 방법입니다.
- `modal: false`는 스크롤과 클릭은 남기고 focus만 안에 붙듭니다. `clear` 오버레이가 대개 원하는 것이 그것입니다.
- 오버레이는 불투명도만 애니메이션합니다. 확대되거나 미끄러지는 오버레이는 그 위에 적힌 것을 화면 너머로 끌고 다니게 되는데, 컨트롤과 달리 이쪽은 대개 문장을 싣고 있습니다. OS에서 애니메이션을 끄면 즉시 나타납니다.
- 답해야 할 질문이 있으면 `PlModal`을 쓰세요. 오버레이에는 제목도, 설명도, 액션도 없어서 스크린리더가 `label` 말고는 다룰 것이 없습니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `open` / `defaultOpen` / `onOpenChange` | `open` / `onOpenChanged` | Flutter의 컨트롤은 controlled이고, 콜백 이름도 Flutter의 것입니다. |
| `modal={true \| 'trap-focus'}` | `modal: bool` | 두 값이 뜻하던 것은 "포인터가 통과하는가"였습니다. Flutter의 말로는 boolean입니다. |
| `children` | `child` | Flutter의 이름입니다. |
| `color` | — | 그것이 닿던 유일한 것은 내용이 읽던 슬롯이었고, 여기서 내용은 자기 색을 가지고 옵니다. |
| `document.body`로의 portal | 조상 `Overlay` | Flutter의 portal은 가장 가까운 `Overlay`로 갑니다. navigator가 있는 `WidgetsApp`과 `MaterialApp`이 둘 다 제공합니다. |
| 스크롤 잠금 | — | 잠글 document가 없습니다. barrier가 이미 포인터를 가져가고, 그 뒤의 스크롤에는 닿을 수 없습니다. |
| `className`, `style`, 네이티브 속성 | — | 전달할 클래스 목록도 style 속성도 없습니다. |

:::
