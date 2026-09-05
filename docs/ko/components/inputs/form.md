---
title: PlForm
order: 18
---

# PlForm

<p class="plass-lede">자기 필드 중 무엇이 틀렸는지 아는 <code>&lt;form&gt;</code>입니다. 제출할 때 모든 필드의 유효성을 한 번에 모으고, 처음 실패한 필드로 focus를 옮기고, 서버의 답을 그것이 속한 필드에 되돌려 놓습니다.</p>

<Demo src="form/hero" :min-height="280" />

::: fw react

```tsx
import { PlButton, PlForm, PlTextField } from 'plass-ui';

<PlForm errors={errors} onSubmit={(values) => save(values)}>
  <PlTextField name="email" type="email" label="Email" required />
  <PlButton type="submit">Sign in</PlButton>
</PlForm>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlForm(
  key: formKey,
  errors: errors,
  onSubmit: save,
  children: <Widget>[
    emailField,
    PlButton(onPressed: () => formKey.currentState?.submit(), child: const Text('Sign in')),
  ],
);
```

:::

## Props

<PropsTable name="PlForm" />

::: fw react

네이티브 `<form>` 속성은 모두 그대로 전달됩니다. `onSubmit`은 DOM 이벤트가 아니라 폼의 **값**을 보고하고 네이티브 제출을 막아 아무 데도 이동하지 않기 때문에 제외됩니다.

:::

::: fw flutter

### PlFormScope

<PropsTable name="PlFormScope" />

필드와 제출 버튼이 둘레의 폼에서 읽는 것입니다. internal이 아니라 export되어 있는데, 이유는 아래 차이점에 있습니다. 여기서 필드는 네이티브 form의 일부가 아니므로, 웹에서 자동인 배선을 호출하는 쪽이 닿을 수 있어야 합니다.

:::

공용 축이 라이브러리 전체에서 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## 범위

여기에는 스키마도, resolver도, field array도 없습니다. 그런 것이 필요한 프로젝트는 이미 쓰고 있는 것을 그대로 두고 결과를 `errors`에 넘기면 됩니다. 이 컴포넌트가 그 이음매를 중심으로 지어졌습니다.

이것이 쥐는 것은 필드 하나에 담길 수 없는 부분입니다.

- **제출**이 모든 필드의 유효성을 하나씩이 아니라 한 번에 모읍니다.
- **focus**가 처음 실패한 필드로 갑니다. 빨간 것을 찾아 헤매지 않도록.
- **`errors`**가 브라우저 바깥에서 온 답을 `name`으로 그것이 속한 필드에 되돌려 놓습니다.

표면도 그리지 않습니다. 폼은 컨트롤의 스택이고, 그것이 얹히는 시트는 필요할 때의 [`PlCard`](../surfaces/card)나 [`PlBox`](../surfaces/box)입니다.

## Examples

### validationMode

`onSubmit`이 기본값이고, 셋 중 유일하게 아직 이메일을 치고 있는 사람에게 그것이 틀렸다고 말하지 않는 값입니다. 제출 전까지는 아무것도 검사하지 않고, 그 뒤로는 각 필드가 바뀔 때마다 다시 검사합니다.

`onBlur`는 필드가 focus를 잃을 때 검사합니다. `onChange`는 키를 누를 때마다 검사하는데, 비밀번호 강도 표시 정도가 아니면 값어치가 없습니다.

<Demo src="form/validation" :flutter="false" :min-height="220">

<<< @/.vitepress/demos/form/validation.tsx

</Demo>

### errors

각 오류가 속한 필드의 `name`으로 묶습니다. 메시지는 그 필드에 표시되고 그 필드가 바뀌는 즉시 지워집니다. 이미 사라진 값에 대한 서버의 이의는 소음이기 때문입니다.

스키마의 출력이 여기로 오고, form action의 응답도 여기로 옵니다. 검증을 위해 이미 가진 것은 전부 있던 자리에 그대로 둡니다.

<Demo src="form/errors" :min-height="240">

::: fw react

<<< @/.vitepress/demos/form/errors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/form/errors.dart

:::

</Demo>

### 받지 않은 메시지도 필드가 보여 줍니다

필드 컴포넌트는 `error`를 받았든 아니든 **오류 상자를 그립니다**. 받았으면 메시지는 호출자의 것이고 조건 없이 보입니다. 받지 않았으면 상자는 비워 두어, 실제로 무엇이 실패했는지(브라우저 자신의 제약 메시지든, 이 폼의 `errors` 항목이든)를 Base UI가 채웁니다.

`errors`가 필드마다 메시지를 손으로 꿰지 않고도 동작하는 이유가 그것이고, invalid로 표시된 필드가 아무 말 없이 빨개지지 않는 이유이기도 합니다.

### onSubmit

폼의 값과 함께, 모든 필드가 유효할 때만 호출됩니다. 네이티브 제출은 막히므로 아무 데도 이동하지 않고 페이지도 다시 불러오지 않습니다.

```tsx
<PlForm onSubmit={(values) => save(values)}>
```

값은 필드의 `name`에서 나옵니다. 네이티브 폼과 같은 계약입니다. `name`이 없는 필드는 이 객체에 없고, 네이티브 제출에도 없습니다.

::: fw flutter

## React 빌드와 다른 점

둘 다 같은 사실에서 나옵니다. **여기에는 네이티브 form이 없습니다.** 웹에서는 필드의 `name`이 그것을 제출에 넣고 제약 검증은 브라우저의 것이라, 폼이 스스로 값을 모으고 메시지를 배달할 수 있습니다. Flutter에서 필드는 호출자가 이미 만든 controller를 쥔 위젯입니다.

| React | Flutter | 이유 |
| --- | --- | --- |
| `onSubmit(values)` | `onSubmit()` | controller가 호출자의 것이므로 값도 이미 호출자에게 있습니다. 폼이 말할 수 있는 것은 *폼이 유효하다*는 사실입니다. |
| 자동으로 필드에 배달되는 `errors` | `PlFormScope.errorFor(name)`으로 읽는 `errors` | 여기서는 아무것도 필드의 이름을 모르므로 조회가 명시적입니다. 이 빌드가 요구하는 유일한 배선이 그것입니다. |
| `type="submit"`인 제출 버튼 | `PlFormScope.maybeOf(context)?.submit()` 또는 `GlobalKey<PlFormState>` | 버튼이 촉발할 네이티브 제출이 없습니다. |
| 브라우저에서 오는 유효성 | Flutter 자신의 `FormField`에서 오는 유효성 | `PlTextField`는 `FormField`가 아닙니다. 데모가 하듯 하나로 감싸세요. |
| `validationMode` | 같은 세 이름, `AutovalidateMode`로 옮김 | 한쪽을 배운 독자가 다른 쪽도 배운 것이 되도록 이름을 유지합니다. |
| `className`, `style`, 네이티브 속성 | — | 전달할 class 목록도 style 속성도 없습니다. |

:::

## Accessibility

- 진짜 `<form>`입니다. 텍스트 필드에서 Enter를 누르면 늘 그랬듯 제출됩니다.
- 제출이 실패하면 focus가 처음의 invalid 필드로 옮겨 갑니다. 문제가 있다고 말해 주는 대신 문제로 데려갑니다.
- 각 필드의 메시지는 Base UI의 Field가 그 필드에 연결하므로, 떠 있는 글이 아니라 필드와 함께 읽힙니다.
- `errors`는 메시지를 쓰는 것과 함께 필드를 invalid로 표시하므로, `aria-invalid`와 눈에 보이는 상태가 같은 말을 합니다.
