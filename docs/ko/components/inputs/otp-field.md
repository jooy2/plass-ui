---
title: PlOtpField
order: 6
---

# PlOtpField

<p class="plass-lede">한 글자짜리 칸이 늘어선 줄입니다 — PIN, 문자로 받은 인증 코드, 초대 키. 칸이 몇 개든 그 뒤에는 값 하나가 있고, 붙여넣기·백스페이스·휴대폰의 자동 완성이 모두 독자가 기대하는 대로 동작합니다.</p>

<Demo src="otp-field/hero" :min-height="180" />

::: fw react

```tsx
import { PlOtpField } from 'plass-ui';

<PlOtpField label="Verification code" groupSize={3} onComplete={verify} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlOtpField(
  label: const Text('Verification code'),
  groupSize: 3,
  onCompleted: verify,
);
```

:::

## Props

<PropsTable name="PlOtpField" />

::: fw react

네이티브 `<div>` 속성은 바깥의 field가 아니라 칸이 늘어선 줄에 그대로 전달됩니다. `color`는 여기서 Plass의 prop이라, `onChange`는 이 컴포넌트가 `onValueChange`로 쓰기 때문에, `children`은 칸들이 곧 children이기 때문에 제외됩니다.

`className`은 label과 control, 그 아래 두 줄을 함께 담는 stack에 붙습니다. 그 안쪽 네 부분에 닿는 것이 `classNames`입니다 — `label`, `control`(칸이 늘어선 줄), `description`, `error`.

:::

::: fw flutter

값은 `PlTextField`에서와 마찬가지로 `TextEditingController`에 있습니다. 그래서 `value`와 `defaultValue`가 매개변수 하나로 합쳐지고, 코드를 지우고 싶은 호출자는 `controller.text`를 설정합니다.

:::

라이브러리 전체에서 공유 축(`variant` `size` `color` `density` `elevation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### length

2–12로 잘립니다. 상자 하나짜리는 `PlTextField`이고, 열둘을 넘기면 줄이 휴대폰에 들어가지 않습니다. 이런 코드는 대개 휴대폰에서 입력됩니다.

<Demo src="otp-field/length" :min-height="220">

::: fw react

<<< @/.vitepress/demos/otp-field/length.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/otp_field/length.dart

:::

</Demo>

### charset

입력할 수 있는 문자입니다. 거부된 것은 보여 주지 않고 버리되 `onValueInvalid`로 보고합니다. 키 입력을 조용히 삼키는 칸은 독자가 고장 났다고 여기는 칸입니다.

기본값이 `numeric`인 것은 문자로 오는 코드가 그렇기 때문이고, 휴대폰에 숫자 키패드를 띄우는 것도 그것이기 때문입니다.

<Demo src="otp-field/charset" :min-height="280">

::: fw react

<<< @/.vitepress/demos/otp-field/charset.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/otp_field/charset.dart

:::

</Demo>

### groupSize와 separator

여섯 자리 코드에 `groupSize={3}`이면 익숙한 세 자리 두 덩어리가 됩니다. 구분자는 두 가지를 나누는 경계가 아니라 값 하나 안의 구두점이라서, 스크린 리더에서는 완전히 숨깁니다. 덩어리마다 그것을 읽어 주는 리더는 그 안의 코드가 아니라 상자의 생김새를 읽고 있는 셈입니다.

### variant

`PlTextField`, `PlSelect`와 같은 field 껍데기입니다. 칸은 field 모양의 상자이고, 둘을 함께 담은 폼이 서로 다른 폼 키트를 쌓아 놓은 것처럼 보여서는 안 되기 때문입니다. `solid`는 색이 든 판이 아니라 **웰**입니다 — 가장 불투명한 유리에 그림자가 안쪽으로 떨어지는 것. text field에서와 같은 이유입니다. 캐럿과 선택 영역이 그 위에서 읽혀야 합니다.

<Demo src="otp-field/variants" :min-height="280">

::: fw react

<<< @/.vitepress/demos/otp-field/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/otp_field/variants.dart

:::

</Demo>

### size

칸은 컨트롤 사다리가 아니라 자기 사다리를 씁니다. 체크박스의 틱과 같은 이유입니다. 칸은 컨트롤들 사이의 컨트롤이 아니라 홀로 선 글자 하나이고, `md` `PlButton` 높이의 `md` 칸은 책상 건너에서 코드를 읽기에 너무 작습니다. 모든 단계가 너비보다 높이가 커서, 이 줄이 작은 field의 행렬이 아니라 글자 하나씩의 자리로 읽힙니다.

타입 스케일도 함께 컨트롤 사다리에서 두 단계 위입니다. 인증 코드는 한 손에 든 휴대폰에서 읽어 다른 손으로 입력됩니다. 폼에서 위의 라벨보다 커야 하는 유일한 글입니다.

`density`는 칸 사이 간격만 건드립니다.

<Demo src="otp-field/sizes" :min-height="380">

::: fw react

<<< @/.vitepress/demos/otp-field/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/otp_field/sizes.dart

:::

</Demo>

### mask, readOnly, disabled, error

`error`는 메시지를 담는 **동시에** 필드를 invalid로 바꿉니다. 그러면 칸의 색 가족 전체가 `danger`로 다시 향해서, 가장자리 · 링 · 캐럿 · 메시지가 한꺼번에 넘어갑니다. `invalid`는 유효성을 폼 라이브러리가 쥐고 있을 때의 탈출구입니다.

<Demo src="otp-field/states" :min-height="400">

::: fw react

<<< @/.vitepress/demos/otp-field/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/otp_field/states.dart

:::

</Demo>

## 구성

::: fw react

칸마다 `<input>` 하나씩이고, Base UI가 그 뒤에 값 하나를 유지합니다. 브라우저의 붙여넣기와 자동 완성이 기대하는 모양이 그것이고, 클릭이 포인터 아래의 상자가 아니라 첫 빈 칸에 떨어지게 만드는 것도 그것입니다.

:::

::: fw flutter

**줄 전체 뒤에 편집기 하나**를 두고 칸으로 그립니다. Flutter의 텍스트 입력은 플랫폼과의 단일 연결이고, 그것을 여섯으로 쪼개면 코드 하나를 두고 키보드 여섯이 다투게 됩니다. 그래서 값은 `TextEditingController`에 있고, 상자는 거기서 그려지며, 줄 어디를 눌러도 캐럿은 첫 빈 칸으로 갑니다.

편집기는 화면 밖으로 치우지 않고 줄 위에 불투명도 0으로 배치됩니다. 텍스트 입력이 그 연결을 유지하려면 트리 안에 있고 측정되어야 해서 `Offstage`가 될 수 없습니다. 아무것도 편집기를 직접 건드리지 않고 — 제스처 하나가 모든 누름을 소유합니다 — 독자가 보는 것은 상자입니다.

거부된 글자는 Flutter의 `FilteringTextInputFormatter`가 아니라 컴포넌트 자신의 포매터를 지납니다. 그쪽은 버리기만 하고 아무 말도 하지 않습니다. 조용히 사라지는 거부는 코드 필드가 저지를 수 있는 최악의 일입니다. 독자는 키를 누르고, 아무 일도 일어나지 않는 것을 보고, 필드가 고장 났다고 결론짓습니다.

:::

## Accessibility

::: fw react

- Base UI의 OTP Field 위에 있습니다. 보기보다 어려운 부분을 전부 그쪽이 맡습니다 — 칸이 몇 개든 그 뒤의 값 하나, 캐럿이 있던 자리에서부터 칸에 흩뿌려지는 붙여넣기, 한 칸 뒤로 물러나는 백스페이스, 그리고 포인터 아래가 아니라 첫 빈 칸에 떨어지는 클릭.
- 모든 칸이 `autocomplete="one-time-code"`를 들고 있어서, 휴대폰이 메시지에서 코드를 바로 제안합니다.
- 라벨 · 설명 · 오류는 Base UI의 `Field`가 줄에 연결합니다. `for` 하나, `aria-describedby` 하나, 호출자가 맞춰 두어야 할 id는 없습니다.
- 구분자는 `role="separator"`가 아니라 `aria-hidden`이 붙은 `<span>`입니다. 두 가지 사이의 경계가 아니라 값 하나 안의 구두점입니다.
- 칸의 포커스 링은 `:focus-visible`이 아니라 `:focus`입니다. 라이브러리에서 그 구분을 의도적으로 내려놓는 유일한 자리입니다 — 칸은 타이핑만큼이나 클릭으로 포커스를 받고, 다음 키가 어느 글자에 떨어지는지를 말해 주는 것은 그 링뿐입니다.

:::

::: fw flutter

- 줄 전체가 코드를 값으로 들고 있는 텍스트 필드 시맨틱 노드 하나입니다. 상자는 그 값의 그림이고 시맨틱에서 완전히 빠지므로, 스크린 리더는 빈 사각형을 세는 대신 코드를 읽습니다.
- 편집기가 `AutofillHints.oneTimeCode`를 들고 있어서, 휴대폰이 메시지에서 코드를 바로 제안합니다.
- 링은 다음 키가 떨어질 칸에 그려지고, focus-visible이 아니라 focus를 따릅니다. 다른 패키지에서와 같은 이유입니다.

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| 칸마다 `<input>` 하나 | 줄 뒤에 편집기 하나 | Flutter의 텍스트 입력은 플랫폼과의 단일 연결입니다. 여섯이면 코드 하나를 두고 키보드 여섯이 다툽니다. |
| `value` / `defaultValue` / `onValueChange` | `controller` / `onChanged` | Flutter의 편집 가능한 위젯이 모두 가진 모양이고, `PlTextField`가 이미 쓰는 것입니다. |
| `onValueInvalid` | `onRejected` | 살아남은 값이 아니라 거부된 글자를 건네줍니다. 둘 중 쓸모 있는 쪽입니다. |
| `name`, `required`, `autoSubmit` | — | 셋 다 HTML 폼 전송에 관한 것이고, Flutter에는 대응물이 없습니다. |
| `autoFocus` | `autofocus` | Flutter의 표기입니다. |
| `className`, `style` | — | 전달할 클래스 목록도 style 속성도 없습니다. |

:::
