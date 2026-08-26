---
title: PlModal
order: 2
---

# PlModal

<p class="plass-lede">답할 때까지 페이지를 가져가는 시트입니다. 헤더와 액션은 자리를 지키고 본문만 스크롤됩니다.</p>

<Demo src="modal/hero" :min-height="120" />

::: fw react

```tsx
import { PlButton, PlModal, PlModalClose } from 'plass-ui';

<PlModal
  trigger={<PlButton color="danger">Delete project</PlButton>}
  title="Delete “Aurora”?"
  description="Everything in it goes with it."
  actions={<PlModalClose render={<PlButton color="danger">Delete</PlButton>} />}
>
  <PlTextField label="Type the project name to confirm" />
</PlModal>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlModal(
  open: deleting,
  onOpenChanged: (bool next) => setState(() => deleting = next),
  title: const Text('Delete “Aurora”?'),
  description: const Text('Everything in it goes with it.'),
  actions: <Widget>[
    PlButton(color: PlassColor.danger, onPressed: destroy, child: const Text('Delete')),
  ],
  child: PlTextField(
    controller: name,
    label: const Text('Type the project name to confirm'),
  ),
);
```

modal은 자기를 트리 밖으로 들어 올리므로 위쪽에 `Overlay`가 필요합니다 — navigator가 있는 `WidgetsApp`과 `MaterialApp`이 둘 다 제공합니다. *어디에 쓰였는지*는 중요하지 않고, 그 자리에서는 아무 공간도 차지하지 않습니다.

:::

## Props

<PropsTable name="PlModal" />

::: fw react

네이티브 `<div>` 속성은 시트로 그대로 전달됩니다. `color`, `title`, `children`은 셋 다 여기서는 Plass의 prop이라 제외됩니다.

:::

::: fw flutter

패키지의 다른 모든 상태 있는 것들과 마찬가지로 **controlled**입니다. ×도 바깥 누름도 스스로 modal을 닫지 않고 `onOpenChanged`를 부릅니다. `trigger`도 `PlModalClose`도 없습니다 — 열림 상태가 이미 호출하는 쪽의 손에 있으니, modal을 닫는 버튼이란 그것을 `false`로 두는 버튼입니다.

`actions`는 위젯 하나가 아니라 `List<Widget>`이라, 버튼 두 개에 따로 Row를 씌울 필요가 없습니다.

:::

`variant`는 없습니다. 세 재질은 "이 표면이 주변 페이지에 대해 얼마나 자기를 주장하는가"에 대한 답인데, modal은 이미 페이지를 가져갔습니다. `elevation`도 없습니다 — 페이지에 납작하게 눕힐 수 있는 modal은 modal이기를 그만두라고 할 수 있는 modal이므로, 그림자는 사다리 꼭대기에 고정됩니다.

::: fw react

### PlModalClose

`PlModalClose`는 자기가 속한 modal을 닫습니다. uncontrolled modal에는 Cancel 버튼이 호출할 `setOpen`이 없고, 대안 — 모든 modal을 controlled로 만드는 것 — 은 버튼 하나에 답하려고 modal마다 상태를 하나씩 두는 일이기 때문에 존재합니다.

```tsx
<PlModalClose render={<PlButton variant="ghost">Cancel</PlButton>} />
```

:::

라이브러리 전체에서 공유 축(`size` `color` `density`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### size

너비와 타입 스케일이 함께 움직입니다. 단계가 컨트롤 사다리보다 넓은 이유는 답하는 질문이 다르기 때문입니다 — 이것이 얼마나 큰가가 아니라, 안에서 한 줄이 얼마나 길어야 읽기 편한가. `width`는 내용이 너비를 정하는 modal — 넓은 표, 좁은 확인창 — 을 위한 탈출구입니다.

<Demo src="modal/sizes" :min-height="120">

::: fw react

<<< @/.vitepress/demos/modal/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/modal/sizes.dart

:::

</Demo>

### dividers

기본은 꺼져 있습니다. 본문이 스크롤되기 시작하는 순간 켜세요 — 헤더가 내용과 함께 흘러가지 않고 자리를 지켰다고 말해 주는 것이 그 헤어라인입니다.

<Demo src="modal/dividers" :min-height="120">

::: fw react

<<< @/.vitepress/demos/modal/dividers.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/modal/dividers.dart

:::

</Demo>

### Controlled

<Fw react="trigger가 아닌 다른 것이 modal을 열어야 하거나, 액션이 닫히기 전에 할 일이 있을 때 `open`과 `onOpenChange`를 함께 넘기세요." flutter="여기서는 이것이 유일한 방식입니다. `open`과 `onOpenChanged`, 그리고 그 덕분에 액션이 시트가 사라지기 전에 자기 일을 끝낼 수 있습니다." />

<Demo src="modal/controlled" :min-height="120">

::: fw react

<<< @/.vitepress/demos/modal/controlled.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/modal/controlled.dart

:::

</Demo>

### dismissible

끄면 <kbd>Esc</kbd>와 바깥 클릭 둘 다 modal을 닫지 않습니다. `showClose={false}`와 함께 쓰는 것은 액션이 정말로 답이 될 때뿐입니다 — 아니면 나갈 길이 아예 없어집니다.

<Demo src="modal/dismissible" :min-height="120">

::: fw react

<<< @/.vitepress/demos/modal/dismissible.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/modal/dismissible.dart

:::

</Demo>

## Accessibility

::: fw react

- 어려운 부분은 전부 Base UI의 것입니다. focus trap, 스크롤 잠금, 닫힐 때 trigger로 focus 되돌리기, 뒤 페이지를 inert로 만들기.
- `title`은 dialog의 이름이 되는 `<h2>`가 되고 `description`은 접근 가능한 설명이 됩니다. 둘 다 Base UI가 엮어 주므로 `aria-labelledby`가 필요 없습니다.
- `dismissible`이 꺼져 있지 않으면 <kbd>Esc</kbd>로 닫힙니다. `modal="trap-focus"`는 뒤 페이지를 스크롤 가능하게 두면서 focus만 가둡니다.
- ×는 기본으로 켜져 있습니다. 라이브러리의 다른 boolean들과 반대인데, modal은 답할 때까지 페이지를 가져가므로 나가는 길이 기억에 의존하면 안 되기 때문입니다.
- 시트는 뷰포트를 넘어 자라는 대신 자기 높이를 제한하고 본문을 스크롤합니다. 키가 큰 modal의 윗부분이 화면 위로 밀려 나가 아무도 닿을 수 없게 되는 일이 없습니다.
- 열고 닫힐 때는 opacity만 움직입니다. 크기가 변하거나 미끄러지는 modal은 자기 글자를 화면 위로 끌고 다니는 것이고, 컨트롤과 달리 이것은 글자로 가득 차 있습니다.

:::

::: fw flutter

- focus는 들어가서 머뭅니다. 시트는 자기 focus scope이고 traversal은 가장 가까운 scope에서 끊기므로 <kbd>Tab</kbd>이 아래 페이지에 내려앉을 수 없습니다. 닫히면 focus는 원래 쥐고 있던 것 — modal을 연 버튼 — 에게 돌아갑니다.
- 레이어는 하나의 route로 명명되고, 그것이 스크린리더가 화면이 바뀌었음을 아는 방법입니다. `title`은 본문의 첫 줄이 아니라 제목으로 읽힙니다.
- `dismissible`이 꺼져 있지 않으면 <kbd>Escape</kbd>로 닫힙니다. `modal: false`는 뒤 페이지를 누를 수 있게 두면서 focus만 가둡니다.
- ×는 기본으로 켜져 있습니다. 라이브러리의 다른 스위치들과 반대인데, modal은 답할 때까지 페이지를 가져가므로 나가는 길이 기억에 의존하면 안 되기 때문입니다.
- 스크롤되는 것은 본문뿐이고, 시트가 화면을 다 쓰면 양보하는 것도 본문뿐입니다 — 흘러가 버린 헤더는 modal의 이름을 가지고 가 버립니다.
- 열고 닫힐 때는 opacity만 움직입니다. 크기가 변하거나 미끄러지는 modal은 자기 글자를 화면 위로 끌고 다니는 것이고, 컨트롤과 달리 이것은 글자로 가득 차 있습니다. OS에서 애니메이션을 끄면 즉시 나타납니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `open` / `defaultOpen` / `onOpenChange` | `open` / `onOpenChanged` | Flutter의 컨트롤은 controlled이고, 콜백 이름도 Flutter의 것입니다. |
| `trigger` | — | 열림 상태가 이미 호출하는 쪽의 손에 있으니, modal을 여는 것은 그것을 `true`로 두는 평범한 버튼입니다. |
| `PlModalClose` | — | React에서 그것이 존재하는 이유는 _uncontrolled_ modal에 닫을 길을 주기 위해서입니다. 여기에는 uncontrolled modal이 없습니다. |
| 노드 하나인 `actions` | `List<Widget>`인 `actions` | Dart에는 fragment가 없고, fragment가 대신하던 것이 결국 목록입니다. |
| `modal={true \| 'trap-focus'}` | `modal: bool` | 두 값이 뜻하던 것은 "포인터가 통과하는가"였습니다. Flutter의 말로는 boolean입니다. |
| `fullScreen` | `fullScreen` | 같습니다. 다만 "뷰포트"란 시트가 들어 올려진 `Overlay`입니다. |
| `width: number \| string` | `width: double` | 논리 픽셀입니다. 받아들일 CSS 길이가 없습니다. |
| `<h2>`인 `title`, `aria-describedby` | 제목과, 이름 붙은 route | Flutter는 상태를 노드 자체에 적습니다. 가리킬 id가 없습니다. |
| 스크롤 잠금, inert 페이지 | barrier | 잠글 document가 없고, 불투명한 barrier 뒤의 페이지에는 포인터가 닿지 않습니다. |
| `children` | `child` | Flutter의 이름입니다. |
| `className`, `style`, 네이티브 속성 | — | 전달할 클래스 목록도 style 속성도 없습니다. |

:::
