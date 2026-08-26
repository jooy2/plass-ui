---
title: PlAlert
order: 1
---

# PlAlert

<p class="plass-lede">일어난 일에 대한 메시지를, 그 일이 벌어진 페이지 안에 놓습니다. 한 줄, 글리프가 붙은 한 줄, 헤드라인과 그 아래 상세 — 세 가지 모양은 서로 다른 자리가 채워진 하나의 컴포넌트입니다.</p>

<Demo src="alert/hero" :min-height="200" />

::: fw react

```tsx
import { PlAlert } from 'plass-ui';

<PlAlert color="success">Your changes are live.</PlAlert>;
<PlAlert color="danger" title="The deploy failed">
  Two of the health checks never came back.
</PlAlert>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlAlert(color: PlassColor.success, child: Text('Your changes are live.'));
const PlAlert(
  color: PlassColor.danger,
  title: Text('The deploy failed'),
  child: Text('Two of the health checks never came back.'),
);
```

:::

## Props

<PropsTable name="PlAlert" />

::: fw react

네이티브 `<div>` 속성은 `role`을 포함해 그대로 전달됩니다 — 아래 live region 항목을 보세요. `color`와 `title`은 둘 다 여기서는 Plass의 prop이라 전달 대상에서 제외됩니다.

:::

::: fw flutter

`icon`은 `Widget?`이고 그 옆에 `showIcon`이 스위치로 있습니다. React는 둘을 세 갈래 prop 하나로 말하는데, Dart에는 그럴 값이 없습니다 — `null`이 있고 위젯이 있을 뿐, "치워라"에 해당하는 값이 없습니다.

:::

라이브러리 전체에서 공유 축(`variant` `size` `color` `density` `elevation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### variant

alert는 색을 입는 **대상 자체**입니다 — 남의 내용을 담는 컨테이너가 아니라 심각도에 대한 알림이므로, `PlCard`와 달리 시트가 틴트를 받습니다.

`solid`는 색 계열의 그러데이션에 같은 계열의 그림자를 깔고, 채워진 `PlButton`이 그렇듯 gloss line은 없습니다. `glass`는 헤어라인과 글리프, 제목에 색 계열을 입습니다. `ghost`는 틴트뿐이며, form 필드들 사이에 놓여 사각형이 하나 더 늘어나면 안 되는 자리에 씁니다.

<Demo src="alert/variants" :min-height="260">

::: fw react

<<< @/.vitepress/demos/alert/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/alert/variants.dart

:::

</Demo>

### color

기본값은 `primary`가 아니라 `info`입니다. `primary`가 거짓말이 되는 유일한 자리입니다 — alert는 무언가의 주요 액션이 아니라 알림이고, 팔레트에는 이미 그것을 가리키는 단어가 있습니다.

각 계열은 자기 색만이 아니라 자기 모양도 그립니다. 빨간색으로만 "잘못됐다"고 말하는 alert는 일부 독자에게만 말하는 alert입니다.

<Demo src="alert/colors" :min-height="240">

::: fw react

<<< @/.vitepress/demos/alert/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/alert/colors.dart

:::

</Demo>

### 세 가지 모양

맨 한 줄이면 <Fw react="icon={false}" flutter="showIcon: false" code />, 글리프가 붙은 한 줄이면 기본값, 헤드라인과 상세면 `title`에 본문. 셋 사이에서 표면은 아무것도 바뀌지 않습니다 — 얼마나 쓰이는지만 다릅니다.

<Demo src="alert/shapes" :min-height="200">

::: fw react

<<< @/.vitepress/demos/alert/shapes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/alert/shapes.dart

:::

</Demo>

### action과 onClose

`action`은 메시지가 옆에서 줄바꿈되는 동안에도 첫 줄에 남습니다. 본문 뒤에 이어 붙이는 대신 자기 자리를 가진 이유입니다.

`onClose`를 주는 것이 닫기 버튼을 나타나게 합니다. 컴포넌트가 스스로 사라지지는 않습니다 — 닫혔을 때 무슨 일이 일어나는지는 호출하는 쪽의 몫이고, 알아서 사라진 alert는 언제 다시 나타나야 하는지 누군가 알려 줘야 합니다.

<Demo src="alert/dismiss" :min-height="160">

::: fw react

<<< @/.vitepress/demos/alert/dismiss.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/alert/dismiss.dart

:::

</Demo>

### size

<Demo src="alert/sizes" :min-height="280">

::: fw react

<<< @/.vitepress/demos/alert/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/alert/sizes.dart

:::

</Demo>

## Accessibility

::: fw react

- alert는 live region이고, 어느 쪽인지는 심각도가 정합니다. `warning`과 `danger`는 `role="alert"`로 스크린리더가 읽고 있던 것을 끊고, 나머지는 `role="status"`로 쉬는 지점을 기다립니다. "실패했다"는 끊을 만하고 "저장됐다"는 그렇지 않습니다.
- 직접 넘긴 `role`이 이깁니다 — props가 기본값 뒤에 펼쳐집니다.
- 글리프는 장식이라 `aria-hidden`입니다. 심각도는 role과 모양, 색이 함께 나르며 색만으로 전달되지 않습니다.
- 글리프는 `1lh`로 메시지의 **첫 줄**에 맞춰 놓입니다. 세 줄짜리 alert도 글리프는 위쪽에 있습니다.
- `action`과 닫기 버튼은 각자 tab stop을 가진 진짜 버튼입니다. action에는 접근 가능한 이름을 주세요. 닫기 버튼은 이미 가지고 있습니다.

:::

::: fw flutter

- 끊을지 말지는 심각도가 정합니다. `warning`과 `danger`는 live region이라 나타나는 순간 알려지고, 나머지는 읽는 사람이 거기 닿았을 때 읽힙니다. "실패했다"는 끊을 만하고 "저장됐다"는 그렇지 않습니다.
- Flutter에는 정중함 단계가 둘이 아니라 live region 하나뿐이라, React 빌드가 `role="alert"`와 `role="status"`로 말하는 것이 여기서는 live region인가 아닌가가 됩니다.
- 글리프는 semantics에서 제외됩니다. 심각도는 모양과 색이 함께 나르며 색만으로 전달되지 않습니다.
- 글리프는 메시지의 **첫 줄**에 맞춰 놓입니다 — 타입 스케일이 무엇이든 그 줄 상자 높이의 상자 안에 — 그래서 세 줄짜리 alert도 글리프는 위쪽에 있습니다.
- `action`과 닫기 버튼은 각자 focus stop을 가집니다. action에는 이름을 주세요. 닫기 버튼은 이미 가지고 있습니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `role="alert"` / `role="status"` | live region이거나 아니거나 | Flutter에는 live region 플래그 하나가 있을 뿐 정중함 단계가 없습니다. 정하는 것은 여전히 심각도이고, 정할 수 있는 폭이 좁습니다. |
| 직접 넘긴 `role`이 이김 | — | 덮어쓸 role이 없습니다. 다른 semantics가 필요한 호출자는 alert를 자기 `Semantics`로 감쌉니다. |
| `icon={false}` | `showIcon: false` | Dart에는 `null`도 위젯도 아닌 값이 없으니, "치워라"가 자기 이름을 갖습니다. |
| `children` | `child` | Flutter의 이름입니다. |
| `className`, `style` | — | 전달할 클래스 목록도 style 속성도 없습니다. |

:::
