---
title: PlRating
order: 9
---

# PlRating

<p class="plass-lede">별 한 줄로 표현한 5점 만점의 점수입니다. 조작 가능한 rating 아래에는 진짜 라디오 그룹이 있습니다: 탭 정지 하나, 화살표 키, 그리고 폼 전송에 실리는 값.</p>

<Demo src="rating/hero" :min-height="140" />

::: fw react

```tsx
import { PlRating } from 'plass-ui';

<PlRating value={score} onValueChange={setScore} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlRating(
  value: score,
  onChanged: (double next) => setState(() => score = next),
);
```

:::

## Props

<PropsTable name="PlRating" />

::: fw react

네이티브 `<div>` 속성은 그대로 전달됩니다. `color`는 위 표의 `color`와 충돌해서, `onChange`는 이 컴포넌트가 `onValueChange`로 쓰기 때문에 제외됩니다.

:::

::: fw flutter

rating은 **controlled**입니다. `value`를 받고 그것을 대체해야 할 값을 보고합니다. 이 패키지 어디에도 `defaultValue`는 없습니다. Flutter 자체 컨트롤이 그렇게 동작하기 때문입니다.

:::

`variant`도 `elevation`도 없습니다. 별은 페이지 위의 표식이지 표면이 아닙니다. 라이브러리 전체에서 공유 축이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### precision

**고를 수 있는** 가장 작은 단위입니다. 별 하나에 대한 분수로 씁니다. `0.5`는 반 별, `1`은 온 별입니다.

이것은 독자가 고를 수 있는 범위만 정하고 그 외에는 아무것도 하지 않습니다. `value`가 `4.3`이면 어떤 precision에서도 별 넷과 3분의 1로 그려집니다. 평균은 선택이 아니고, 그것을 가장 가까운 반 별로 반올림하는 것은 받은 수와 다른 수를 보고하는 일이기 때문입니다.

<Demo src="rating/precision" :min-height="200">

::: fw react

<<< @/.vitepress/demos/rating/precision.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/rating/precision.dart

:::

</Demo>

### readOnly

상품의 평균 점수, 또는 다른 사람이 남긴 평가입니다.

같은 옷을 입은 다른 컴포넌트입니다. input도 없고, 라디오 그룹도 없고, 점수를 문장으로 들고 있는 <Fw react="role=&quot;img&quot;" flutter="이미지 시맨틱 노드" /> 하나만 있습니다. 포커스 가능한 라디오 스무 개를 그대로 들고 있는 별 표시는, 수 하나를 보고할 뿐인 페이지에 탭 정지를 스무 개 놓는 일입니다.

이것은 라이브러리에서 채도를 빼지 **않는** 유일한 `readOnly`이기도 합니다. 붙들려 있는 컨트롤이 아니라(남은 컨트롤이 없습니다) 회색 별 한 줄은 점수 자체를 쓸 수 없다는 말이 되어 버립니다.

<Demo src="rating/average" :min-height="200">

::: fw react

<<< @/.vitepress/demos/rating/average.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/rating/average.dart

:::

</Demo>

### 분수

채워진 별을 빈 별 **위에** 얹고 너비의 비율만큼 잘라 냅니다. 아무것도 변형하지 않고 어떤 글리프도 축소하지 않아서, 반 별은 바로 옆 별의 정확히 왼쪽 절반입니다. 부분적인 모양이 존재 이유인 컴포넌트에서도 하우스의 no-transform 규칙이 그대로 성립하는 지점입니다.

잘라내는 기준은 시작하는 쪽 가장자리입니다. 그래서 RTL에서는 아무 지시 없이도 오른쪽부터 채워집니다.

### icon과 emptyIcon

둘 다 주거나, 둘 다 주지 않습니다. 두 그림은 하나 위에 하나를 얹고 위쪽을 잘라내므로, 채워진 하트를 외곽선 별 위에 얹으면 안쪽과 맞지 않는 테두리로 보입니다.

<Demo src="rating/icons" :min-height="120">

::: fw react

<<< @/.vitepress/demos/rating/icons.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/rating/icons.dart

:::

</Demo>

### size

독립 글리프 사다리입니다. `PlIcon`이 쓰는 것과 같습니다. 별은 컨트롤이 아니라 내용이기 때문입니다. 자기가 앉은 줄이 아니라 옆에 있는 글자에 대해 재어집니다.

<Demo src="rating/sizes" :min-height="240">

::: fw react

<<< @/.vitepress/demos/rating/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/rating/sizes.dart

:::

</Demo>

### color

기본값은 나머지 전부가 쓰는 `primary`가 아니라 `warning`입니다. 별에 기대되는 그 호박색. 라이브러리에서 컴포넌트의 기본 색이 그것이 무엇을 *뜻하는지*가 아니라 그것이 *무엇인지*로 정해지는 유일한 자리입니다.

<Demo src="rating/colors" :min-height="200">

::: fw react

<<< @/.vitepress/demos/rating/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/rating/colors.dart

:::

</Demo>

### clearable과 disabled

이미 고른 점수를 다시 고르면 `0`으로 지워집니다. 한 번 남긴 평가를 되돌리는 유일한 방법입니다. 점수가 필수인 곳에서는 꺼 두세요.

`disabled`는 하우스의 처리 그대로입니다. 줄에서 빛이 꺼지고 페이지가 비쳐 보이며 색 가족은 남습니다. 회색 줄은 같은 상태에 대한 두 번째 어휘가 됩니다.

<Demo src="rating/states" :min-height="200">

::: fw react

<<< @/.vitepress/demos/rating/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/rating/states.dart

:::

</Demo>

## Accessibility

- 조작 가능한 rating은 **라디오 그룹**입니다. 점수는 "이 중 정확히 하나"이기 때문입니다. 줄 전체에 탭 정지 하나, 그 안에서 화살표 키, 선택된 점수의 표시, 그리고 폼 전송에 실리는 값. 버튼 한 줄이었다면 그중 아무것도 없었을 것들입니다.
- 모든 선택지는 그것이 나타내는 점수로 이름이 붙습니다 (`3 out of 5`). 다른 언어는 `valueLabel`에서 자기 문구를 정합니다. 여기서 화면에 그려지는 것은 없습니다.
- 읽기 전용 rating은 라디오를 전부 내려놓고, 점수를 이름으로 가진 이미지 하나가 됩니다.
- 글리프는 장식입니다. 안내되는 것은 그림이 아니라 문장입니다.

::: fw react

- input들은 시각적으로 숨겨진 상자 안의 진짜 `<input type="radio">`이고, 별의 각 분수 아래에 하나씩 있습니다. `name`은 폼과 함께 전송되고, `required`는 별을 고르기 전까지 전송을 막습니다.
- 지우기는 `change`가 아니라 `click`에 실립니다. 이미 체크된 라디오를 클릭하면 클릭만 발생하고 change는 전혀 발생하지 않는데, 바로 그 클릭이 여기서 듣고 있는 동작이기 때문입니다.

:::

::: fw flutter

- 고를 수 있는 모든 분수는 각자의 시맨틱 노드이고, 상호 배타적인 집합의 하나로 표시되며 자기가 나타내는 점수를 이름으로 들고 있습니다. 스크린 리더가 직접 실행할 수 있습니다.
- 줄 전체가 탭 정지 하나이고, 화살표 키가 `precision` 한 단계씩 점수를 옮깁니다. React 빌드가 라디오 그룹에서 공짜로 얻는 것을 여기서는 직접 묶었습니다. <kbd>Home</kbd>은 지우고 <kbd>End</kbd>는 끝까지 올립니다. 화살표는 쓰기 방향을 따르므로 RTL에서는 반대로 움직입니다.
- 단축키는 상속이 아니라 줄에 직접 선언되어 있습니다. 그래서 맨 `WidgetsApp` 안에서도, 위에 앱 위젯이 하나도 없어도 똑같이 동작합니다.

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `value` / `defaultValue` / `onValueChange` | `value` / `onChanged` | Flutter 자체 컨트롤이 controlled이고, 콜백 이름도 그쪽 이름입니다. |
| 숨겨진 `<input>`의 라디오 그룹 | 시맨틱 노드와 탭 정지 하나 | 전송할 폼도, 키보드를 물려받을 네이티브 라디오도 없어서 화살표를 줄에 직접 묶었습니다. |
| `name`, `required` | — | 둘 다 HTML 폼 전송에 관한 것이고, Flutter에는 대응물이 없습니다. |
| 별마다 포커스 링 | 줄 하나에 링 하나 | 여기서는 줄이 포커스 노드 하나라서, 링은 실제로 포커스를 쥔 것을 두릅니다. |
| `className`, `style` | — | 전달할 클래스 목록도 style 속성도 없습니다. |

:::
