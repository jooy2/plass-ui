---
title: PlBackTop
order: 8
---

# PlBackTop

<p class="plass-lede">긴 페이지의 맨 위로 돌아가는 버튼입니다. 돌아갈 만큼 스크롤되기 전까지는 숨어 있고, 그것이 설계의 전부입니다.</p>

<Demo src="back-top/hero" :min-height="320" />

::: fw react

```tsx
import { PlBackTop } from 'plass-ui';

<PlBackTop />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

Stack(
  children: <Widget>[
    ListView(controller: controller, children: rows),
    Positioned(right: 24, bottom: 24, child: PlBackTop(controller: controller)),
  ],
);
```

:::

## Props

<PropsTable name="PlBackTop" />

네이티브 `<button>` 속성은 그대로 통과하고, 나머지는 전부 [`PlIconButton`](../inputs/icon-button)의 것입니다: 세 재질, elevation 사다리, 포인터 빛.

::: fw flutter

**`floating`이 없고, 그에 해당하는 것도 없습니다.** Flutter에는 `position: fixed`가 없으므로 버튼이 어디에 놓일지는 호출자의 몫입니다. 스크롤 영역 위의 `Stack`과 그 안의 `Positioned`나 `Align`이고, 그것이 Flutter 화면이 무언가를 구석에 고정하는 방법입니다.

`controller`가 `ScrollController`입니다. 생략하면 `PrimaryScrollController`인데, 자체 controller가 없는 `ListView`가 붙는 곳이고 따라서 이 프레임워크의 "창"입니다. `onPressed`는 스크롤 **앞이 아니라 대신** 돕니다. Dart 호출자가 원하는 모양이 그것입니다. `preventDefault`할 이벤트가 없습니다.

**데스크톱과 데스크톱 웹에서는 `controller`가 필요합니다.** 스크롤 뷰가 `PrimaryScrollController`를 스스로 가져가는 것은 Android, iOS, Fuchsia에서뿐이라서, 그 밖의 플랫폼에서는 거기에 붙는 것이 없고 `controller` 없이 둔 버튼은 끝내 나타나지 않습니다. debug 빌드는 첫 프레임이 끝날 때까지 primary controller에 붙은 것이 없으면 assert를 냅니다. `primary: true`로 만든 스크롤 뷰라면 `PrimaryScrollController.of(context)`를 넘깁니다.

:::

## 쓸모 있어질 때까지 숨어 있습니다

첫 페인트부터 모든 페이지 구석에 박혀 있는 버튼은 내용을 가리는 것이 하나 더 있는 것이고, 스크롤이 없을 만큼 짧은 페이지에서는 아무 일도 하지 않는 컨트롤입니다.

사용자가 `visibilityHeight` 픽셀만큼 내려갔을 때 나타납니다. 기본은 400이고, 노트북에서 대략 한 화면입니다. 스크롤해서 올라가는 것이 "그냥 하면 되는 일"이기를 그만두는 지점입니다.

## Examples

### target

기본은 창입니다. 페이지 안에서 스크롤되는 패널(표의 스크롤 상자, 대화 기록, modal의 본문) 에는 ref나 element를 주세요.

```tsx
const panel = useRef<HTMLDivElement>(null);

<div ref={panel} className="overflow-y-auto">
  …
</div>
<PlBackTop target={panel} />
```

### floating

기본은 켜짐입니다. 그것이 이 컴포넌트이기 때문입니다. 버튼을 직접 정한 자리(글의 끝, 툴바)에 두면서 나타나기와 스크롤은 그대로 쓰고 싶다면 끄세요.

```tsx
<PlBackTop floating={false} className="mx-auto mt-8" />
```

::: fw react

고정된 버튼은 아래쪽 end 모서리에서 24px 떨어져 앉고, 거기에 `env(safe-area-inset-bottom)`이 더해집니다. 화면 끝까지 그리는 기기의 홈 인디케이터나 내비게이션 바를 피하기 위해서입니다. 고정은 유틸리티 클래스가 아니라 인라인 `position: fixed`와 논리 inset으로 씁니다. 그래서 직접 넘긴 `style`은 이를 대신하지만 직접 넘긴 클래스는 그러지 못합니다.

:::

### 글리프와 말

```tsx
<PlBackTop icon={<ArrowUpIcon />} label="위로" />
```

`label`은 accessible name입니다. 툴팁을 포함해 화면 어디에도 그려지지 않으니, 누르면 무슨 일이 일어나는지로 이름 붙이세요.

## Notes

- 위치는 스크롤할 때마다는 물론 마운트할 때도 한 번 읽습니다. 그래서 중간에서 복원된 페이지(뒤로 가기, URL의 앵커) 에는 버튼이 이미 있습니다.
- 호출자 자신의 `onClick`이 먼저 돌고, 거기서 `preventDefault()`를 부르면 스크롤이 멈춥니다. 맨 위가 아닌 다른 곳으로 데려가는 방법이 그것입니다.

## Accessibility

- 손이 닿지 않는 동안에는 흐려지기만 하는 것이 아닙니다. <Fw react="`aria-hidden`이 붙고 탭 순서에서 빠지며" flutter="시맨틱 트리와 포커스 순서에서 빠지며" />, 포인터도 받지 않습니다.
- 이름은 `label`이고, 생략하면 라벨 팩의 `backToTop`입니다. 영어로는 "Back to top"입니다.
- 스크롤은 <Fw react="`prefers-reduced-motion`에서는 미끄러지지 않고 건너뛰며" flutter="플랫폼이 움직임을 줄여 달라고 하면 애니메이션 없이 건너뛰며" />, 도착하는 곳은 같습니다.

::: fw react

- 버튼에 포커스가 있는 채로 눌러 스크롤하면, 포커스는 스크롤한 영역의 맨 위에서 처음으로 포커스를 받는 요소로 옮겨 가고, 그런 요소가 없으면 버튼에서 빠집니다. 그래서 다음 Tab이 방금 숨은 버튼에서 시작하지 않습니다.

:::
