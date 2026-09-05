---
title: PlScrollArea
order: 6
---

# PlScrollArea

<p class="plass-lede">스크롤되는, 크기가 정해진 상자입니다. 안에는 라이브러리 자신의 스크롤바가 들어 있습니다. <code>overflow: auto</code> 대신 이것을 쓰는 이유는 그 막대입니다. 플랫폼 스크롤바는 사라져 버리는 오버레이거나 회색 붙박이 가구이고, 둘 다 반투명 시트 옆에 어울리지 않습니다.</p>

<Demo src="scroll-area/hero" :min-height="260" />

::: fw react

```tsx
import { PlScrollArea } from 'plass-ui';

<PlScrollArea height={200} label="Release notes">
  <ul>…</ul>
</PlScrollArea>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlScrollArea(
  height: 200,
  label: 'Release notes',
  child: Column(children: notes),
);
```

:::

## Props

<PropsTable name="PlScrollArea" />

라이브러리 전체에서 공유 축이 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## 크기를 정해 주지 않으면 스크롤되지 않습니다

세로 스크롤 영역은 **무언가로 크기가 정해져 있어야** 합니다. 그렇지 않으면 내용이 넘칠 대상이 없어서 상자가 그냥 늘어납니다. `height`가 그 무언가이고, 클래스나 감싸는 상자가 아니라 prop인 이유는 이것이 없으면 이 컴포넌트가 아무 일도 하지 않기 때문입니다.

`maxHeight`는 같은 답의 다른 모양입니다. 크기가 아니라 천장이어서, 내용이 짧으면 줄어들고 넘칠 때만 스크롤되는 패널에 씁니다. 가로 영역에는 `width`와 `maxWidth`가 짝입니다.

::: fw react

숫자는 픽셀이고 문자열은 어떤 CSS 길이든 됩니다. `height={200}`도 `height="40vh"`도 동작합니다.

:::

## PlScrollArea와 PlScrollZone

컴포넌트는 둘, 사실은 하나(내용이 상자 끝을 넘어간다) 그리고 답이 둘입니다.

|  |  |
| --- | --- |
| `PlScrollArea` | 막대를 남기고 라이브러리의 것으로 만듭니다. 얼마나 지나왔는지 알고 싶은 **내용 패널**에 씁니다. |
| [`PlScrollZone`](./scroll-zone) | 막대를 없애고, 아직 뒤에 무언가 남은 쪽 끝을 흐리고, 버튼 한 쌍을 답니다. 탭·칩·필터처럼 **한 줄짜리 띠**에 씁니다. 한 줄 라벨 아래 막대는 라벨보다 무겁습니다. |

여기에는 **흐림이 없습니다.** 의도한 것입니다. 흐림은 "더 있다"고 말하고, 막대는 그것과 함께 얼마나 있고 지금 어디인지까지 말합니다. 한 사실에 신호 둘, 그중 하나만 측정된 것이라면 하나가 남습니다.

## 축

`orientation`은 기본이 `vertical`, 한 줄짜리에는 `horizontal`, 두 모서리로 넘치는 격자에는 `both`입니다. `both`는 각 모서리에 레인을 그리고 만나는 자리를 모서리 조각이 채웁니다.

<Demo src="scroll-area/axes" :min-height="260">

::: fw react

<<< @/.vitepress/demos/scroll-area/axes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/scroll_area/axes.dart

:::

</Demo>

::: fw flutter

`both`는 스크롤 가능 영역 둘이 하나 안에 하나로 겹친 것이고, 각 막대는 자기 것에만 답합니다. 페이지를 아래로 굴렸는데 가로 막대가 움직인다면 그것은 틀린 축을 보고하는 위젯입니다.

:::

## scrollbars

`auto`는 포인터가 상자 위에 있거나 내용이 움직이는 동안 레인을 그리고, 그 밖에는 그리지 않습니다. 사용자가 익숙한 쪽이고 기본값입니다.

`always`는 레인을 계속 열어 둡니다. 보기보다 자주 맞는 선택입니다. 아래에 더 있다는 것이 존재 이유인 패널이라면, 마우스를 올려야 나타나는 막대는 화면에서 조금 물러난 사람은 영영 보지 못하는 신호입니다. 어느 쪽이든 내용의 폭은 **줄지 않습니다**. 레인은 배치되는 것이 아니라 위에 겹쳐집니다.

## Examples

### 헤더는 그대로, 본문만 스크롤되는 dialog

흔한 경우입니다. 가운데만 크기를 정하고 양 끝은 그대로 둡니다.

```tsx
<PlModal title="Terms">
  <PlScrollArea maxHeight="60vh" label="Terms of service">
    <div className="pe-3">{terms}</div>
  </PlScrollArea>
</PlModal>
```

### 자기만 스크롤되는 사이드바

```tsx
<PlScrollArea height="100%" label="Projects" size="sm">
  <PlList>…</PlList>
</PlScrollArea>
```

## Notes

- 엄지는 `--plass-track`으로, [slider](../inputs/slider)의 레일과 [progress](../feedback/progress-linear)의 홈을 새긴 것과 같은 중립 잉크입니다. 라이브러리의 모든 채널이 한 재질입니다.
- 레인은 **위에 겹쳐집니다**. 그래서 나타나거나 사라져도 아래 내용이 다시 흐르지 않습니다.
- 상자는 `size` 단계의 하우스 radius로 잘리고, 내용도 거기에 맞춰 잘립니다.

::: fw react

- viewport는 `overscroll-contain`입니다. 패널 바닥에 닿아도 뒤의 페이지가 대신 스크롤되지 않습니다.
- 동작은 Base UI가 가집니다. 오버레이 측정, 엄지의 크기와 위치, 드래그, 그리고 스크롤할 것이 있을 때만 viewport를 tab 대상으로 만드는 일까지.
- `classNames`는 `className`이 닿지 않는 부분에 닿습니다. `viewport`, `scrollbar`, `thumb`.

:::

::: fw flutter

- `package:flutter/widgets.dart`의 `RawScrollbar` 위에 세웠습니다. 프레임워크 자신의 `Scrollbar`는 이 패키지가 import하지 않는 `material.dart`에 있습니다.

:::

## Accessibility

- **안에 포커스 가능한 것이 없으면 스크롤되는 상자 자체가 tab 대상이 됩니다.** 키보드를 쓰는 사람도 스크롤할 수 있어야 하기 때문입니다. 그 처리는 되어 있고, `label`이 중요한 이유가 이것입니다. 이름 없는 도착점은 아무것도 아닌 것으로 읽힙니다.
- `label`이 있으면 상자는 이름 있는 region이 됩니다. 없으면 **landmark를 선언하지 않습니다.** 의도한 것입니다. 이름 없는 region은 스크린 리더가 "region"이라고만 나열하는 것이라 landmark가 없느니만 못합니다.
- 스크롤바만이 움직이는 방법은 아닙니다. 화살표 키, <kbd>Page Down</kbd>, 휠 모두 상자에서 동작합니다.
