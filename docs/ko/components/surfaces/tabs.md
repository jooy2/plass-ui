---
title: PlTabs
order: 3
---

# PlTabs

<p class="plass-lede">여러 패널 중 하나를 보여 주는 묶음입니다. 인디케이터가 떠난 탭에서 고른 탭으로 미끄러집니다.</p>

<Demo src="tabs/hero" :min-height="200" />

::: fw react

```tsx
import { PlTab, PlTabPanel, PlTabs } from 'plass-ui';

<PlTabs defaultValue="account">
  <PlTab value="account">Account</PlTab>
  <PlTab value="billing">Billing</PlTab>

  <PlTabPanel value="account">Your name and your avatar.</PlTabPanel>
  <PlTabPanel value="billing">Cards and invoices.</PlTabPanel>
</PlTabs>;
```

탭과 패널은 형제로 쓰고, 컴포넌트가 알아서 둘을 갈라 놓습니다. 기억해야 할 `<PlTabList>`도 없고, 서브트리 배열 prop도 없습니다 — 패널은 서브트리이고, 그것을 담을 쓸 만한 모양은 결국 children뿐입니다.

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlTabs<String>(
  value: tab,
  onChanged: (String next) => setState(() => tab = next),
  tabs: <PlTab<String>>[
    PlTab<String>(
      value: 'account',
      label: const Text('Account'),
      panel: const Text('Your name and your avatar.'),
    ),
    PlTab<String>(
      value: 'billing',
      label: const Text('Billing'),
      panel: const Text('Cards and invoices.'),
    ),
  ],
);
```

탭과 그 탭이 여는 패널은 **하나의 설명**입니다. 차이는 사실상 여기서 갈립니다 — 맞춰 줘야 할 `PlTabPanel`도, 짝을 맞춰야 할 세 번째 값도 없고, 고르지 않은 패널은 아예 만들어지지 않습니다.

:::

## Props

<PropsTable name="PlTabs" />

::: fw react

바와 패널이 받는 값은 `string | number`입니다.

:::

::: fw flutter

바는 탭 값 타입에 대해 제네릭입니다 — `PlTabs<String>`, `PlTabs<Section>` — 그래서 `value`와 `onChanged`가 `dynamic`이 아니라 타입을 가지며, 패키지의 다른 컨트롤과 마찬가지로 **controlled**입니다. `value`는 nullable입니다. `null`은 아무것도 고르지 않은 바이고, 그 아래에는 패널도 없습니다.

:::

### PlTab

<PropsTable name="PlTab" />

::: fw react

### PlTabPanel

<PropsTable name="PlTabPanel" />

`variant`, `size`, `density`, `orientation`은 감싸고 있는 `PlTabs`에서 내려받습니다. 이웃과 그중 무엇이든 달라질 수 있는 탭은 구멍 난 탭 바입니다.

:::

::: fw flutter

탭은 위젯이 아니라 **`PlTab`, 즉 설명**입니다. [segment](../inputs/segmented-button)가 그런 것과 같은 이유입니다. 바가 roving focus와 방향키, 그리고 탭 사이를 미끄러지는 인디케이터를 쥐고 있으니, 어느 탭이 골라졌고 각각이 어디 있는지를 알아야 합니다. `panel`이 함께 실려 있는 것은, 그러지 않으면 탭과 그 탭이 여는 것이 같은 사실을 두 번 적는 일이 되기 때문입니다.

`variant`도 `size`도 `density`도 `orientation`도 없고, 있을 수도 없습니다. 이웃과 그중 무엇이든 달라지는 탭은 구멍 난 탭 바입니다.

:::

라이브러리 전체에서 공유 축(`variant` `size` `color` `density` `orientation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Tabs와 segmented button 중 고르기

tabs는 내용 패널 전체를 바꿉니다. [segmented button](../inputs/segmented-button)은 이미 화면에 있는 것을 걸러 냅니다. 여기서 `solid` 타일이 색 계열의 그러데이션이 아니라 **맑은** 유리판인 이유이기도 합니다 — 그러데이션 타일은 segmented button의 것이고, 둘이 한 화면에 있으면 구분이 되어야 합니다.

## Examples

### variant

`glass`는 고전적인 바입니다. 가장자리의 선 위를 인디케이터가 달립니다. `solid`는 홈 안에서 판이 미끄러집니다. `ghost`는 그 선을 뺀 바로, 이미 자기 테두리를 가진 `PlCard` 안의 탭에 씁니다.

<Demo src="tabs/variants" :min-height="420">

::: fw react

<<< @/.vitepress/demos/tabs/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tabs/variants.dart

:::

</Demo>

### orientation

`vertical`은 탭을 옆으로 세우고 패널을 그 옆에 놓으며, 방향키를 다른 축으로 옮깁니다. <Fw react="Base UI가 하는 일이고" flutter="바가 직접 하는 일이고" />, 세로 탭 바에 닿을 수 있게 만드는 것이 바로 이것입니다.

**반응형입니다.** 그래서 한 집합이 폰에서는 이쪽으로, 노트북에서는 저쪽으로 갈 수 있습니다. <Fw react="서버는 xs 항목을 렌더링하고 브라우저가 hydration에서 고칩니다." flutter="build에서 창 너비를 기준으로 풀리므로 첫 프레임부터 정확합니다." /> [브레이크포인트](../../design/breakpoints) 참고.

<Demo src="tabs/orientation" :min-height="200">

::: fw react

<<< @/.vitepress/demos/tabs/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tabs/orientation.dart

:::

</Demo>

### fullWidth

<Demo src="tabs/full-width" :min-height="160">

::: fw react

<<< @/.vitepress/demos/tabs/full-width.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tabs/full_width.dart

:::

</Demo>

### size

탭은 컨트롤이므로 컨트롤 높이 사다리를 씁니다 — `md` 탭과 `md` `PlButton`은 똑같이 40px이고, 그래서 탭 바가 툴바에서 버튼 옆에 놓여도 줄의 기준선이 유지됩니다.

<Demo src="tabs/sizes" :min-height="380">

::: fw react

<<< @/.vitepress/demos/tabs/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tabs/sizes.dart

:::

</Demo>

### 자리보다 탭이 많은 바

자리보다 탭이 많은 바는 줄바꿈 대신 **스크롤**됩니다. 두 줄이 된 탭 바는 이미 바가 아니고, 인디케이터가 앉을 만한 자리도 없습니다.

그래서 스크롤 중이라는 것을 바가 직접 알려야 하는데, 스크롤바는 그 일을 하지 못합니다. macOS에서는 띠가 움직이는 동안에만 나타나는 오버레이여서, 독자가 더 볼 것이 있는지 판단하는 시간에는 보이지 않습니다. Windows에서는 라벨 줄 아래를 늘 차지하는 15픽셀짜리 가구입니다. 둘 다 감추고, 대신 아직 탭이 남아 있는 쪽 끝을 흐립니다. 남아 있는 쪽만 흐리므로 흐려진 끝은 언제나 더 있다는 뜻입니다.

이 흐림은 위에 덧칠하는 것이 아니라 픽셀을 덜어 내는 것이어서, 바가 무엇 위에 놓여 있든 옳습니다. 컴포넌트는 자기가 페이지 위인지 `PlCard` 위인지 색이 들어간 섹션 위인지 알 수 없고, 틀린 색으로 칠한 그러데이션은 신호가 없는 것보다 나쁩니다. 안의 탭이 focus ring을 그리고 있는 동안에는 흐림을 걷습니다. 탭에 focus가 가면 그 탭은 자기가 온 가장자리에 딱 붙게 스크롤되는데, 거기가 바로 흐림이 가장 진한 자리이기 때문입니다.

바가 넘치는지는 주어진 자리에 달렸으므로 이것은 선언이 아니라 **측정**입니다. 이를 위한 prop은 없습니다.

::: fw react

상태는 탭 리스트에 `data-overflow`로 실려 나갑니다 — `none`, `start`, `end`, `both`이고 독자의 순서를 따릅니다. 페이지가 이를 읽어 스타일을 얹거나 테스트에서 단언할 수 있습니다.

:::

### Controlled

<Demo src="tabs/controlled" :min-height="200">

::: fw react

<<< @/.vitepress/demos/tabs/controlled.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tabs/controlled.dart

:::

</Demo>

## Accessibility

::: fw react

- 탭 바를 버튼 줄이 아니라 탭 바로 만드는 것은 전부 Base UI의 것입니다. 바 전체가 tab stop 하나가 되는 roving focus, 바가 놓인 축의 방향키, <kbd>Home</kbd>과 <kbd>End</kbd>, `tab` / `tabpanel` role, 그리고 둘을 잇는 `aria-controls`.
- `activateOnFocus`는 기본이 **꺼짐**입니다. 자동 활성화는 모든 패널이 이미 페이지에 있을 때만 친절합니다. 패널 하나라도 fetch를 하는 순간, 탭 네 개를 지나가면 요청이 네 번 나갑니다.
- 안에 focus 가능한 것이 없는 패널은 자기가 focus를 받으므로, 내용에 키보드로 닿을 수 있습니다.
- 탭의 focus ring은 안쪽으로 그려집니다. `solid` 홈 안의 탭에 바깥쪽 ring을 그리면 이웃 위에 덧칠됩니다.
- 인디케이터는 `transform`이 아니라 `left`, `top`, `width`, `height`를 애니메이션합니다. 빈 상자라서 글자가 담긴 것은 아무것도 움직이지 않습니다.
- 자리보다 탭이 많은 바는 줄바꿈 대신 스크롤되고, 아직 탭이 남아 있는 쪽 끝을 흐립니다. 두 줄이 된 탭 바는 이미 바가 아니고, 인디케이터가 앉을 만한 자리도 없습니다.

:::

::: fw flutter

- 바 전체가 focus stop **하나**입니다. 탭 하나만 tab 순서에 있고 나머지는 `ExcludeFocus` 안에 있습니다. 바를 버튼 줄이 아니라 바로 만드는 것이 이것입니다.
- 가로 바에서는 <kbd>←</kbd> <kbd>→</kbd>, 세로 바에서는 <kbd>↑</kbd> <kbd>↓</kbd>가 선택을 옮기며, 양 끝에서 감기고 비활성 탭은 건너뜁니다. <kbd>Enter</kbd>와 <kbd>Space</kbd>는 focus된 탭을 고릅니다.
- 각 탭은 서로 배타적인 묶음의 하나로, 골라졌는지 아닌지와 함께 읽힙니다. 바 자체는 `semanticLabel`을 줄 수 있는 컨테이너입니다 — 꼭 주세요. 바에는 눈에 보이는 이름이 없습니다.
- focus가 움직이면 **선택도 움직입니다**. 고른 패널만 만들어지기 때문이고, focus와 내용이 어긋날 수 있는 바는 하나를 보여 주면서 다른 것을 읽는 바입니다. 패널이 비싸다면 탭이 아니라 `build` 바깥으로 그 일을 빼세요.
- 탭의 focus ring은 **안쪽**으로 돕니다. `solid` 홈 안의 탭에 바깥쪽 ring을 그리면 이웃 위에 덧칠됩니다.
- 인디케이터는 transform이 아니라 자기 **상자** — 위치와 크기 — 를 애니메이션합니다. 빈 사각형이라서 글자가 담긴 것은 아무것도 움직이지 않습니다. OS에서 애니메이션을 끄면 바로 건너뜁니다.
- 자리보다 탭이 많은 바는 줄바꿈 대신 스크롤되고, 아직 탭이 남아 있는 쪽 끝을 흐립니다. 예전에는 자기 탭들만큼 넓어서 상자를 넘쳤고 직접 감싸라는 안내가 붙어 있었는데, 그 방법은 통하지 않습니다. `PlTabs`를 `SingleChildScrollView`로 감싸면 바와 함께 패널까지 스크롤됩니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `<PlTab>`과 `<PlTabPanel>` children | 각자 `panel`을 든 설명 목록인 `tabs` | 바가 roving focus와 방향키, 미끄러지는 인디케이터를 쥐고 있으니 어느 탭이 골라졌고 각각이 어디 있는지 알아야 합니다. 패널을 탭에 붙이면 값을 맞춰야 할 세 번째 자리가 사라집니다. |
| `defaultValue` / `onValueChange` | `value` / `onChanged` | Flutter의 컨트롤은 controlled이고, 콜백 이름도 Flutter의 것입니다. |
| `string \| number` 값 | 제네릭 `T` | Dart에는 제네릭이 있으니 관습이 아니라 타입 검사로 지켜집니다. |
| 모든 패널을 렌더링하고 하나만 보임 | 고른 패널만 만듦 | 열려 있지 않은 탭은 비용이 0입니다. 대신 패널을 떠나면 그 상태도 사라지니, 상태는 바 위에서 쥐세요. |
| `activateOnFocus` | — | 패널이 선택에서 만들어지므로, focus가 움직이면 선택도 언제나 함께 움직입니다. |
| `aria-label` | `semanticLabel` | Flutter의 이름입니다. |
| `tab` / `tabpanel` role, `aria-controls` | 배타적으로 선택된 노드와, 패널 하나 | Flutter는 상태를 노드 자체에 적습니다. 가리킬 id가 없습니다. |
| `className`, `style` | — | 전달할 클래스 목록도 style 속성도 없습니다. |

:::
