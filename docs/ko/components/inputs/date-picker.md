---
title: PlDatePicker
order: 12
---

# PlDatePicker

<p class="plass-lede">달력에서 하루를 고릅니다. trigger는 달력 글리프를 단 <code>PlTextField</code>의 껍데기 그대로라, 날짜 field와 그 옆의 field들이 하나의 물건으로 읽힙니다.</p>

<Demo src="date-picker/hero" :min-height="200" />

::: fw react

```tsx
import { PlDatePicker } from 'plass-ui';

<PlDatePicker label="Departure" placeholder="Pick a day" minDate={new Date()} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlDatePicker(
  label: const Text('Departure'),
  placeholder: const Text('Pick a day'),
  minDate: DateTime.now(),
  value: departure,
  onChanged: (DateTime? next) => setState(() => departure = next),
);
```

달력은 트리 밖으로 자기를 들어 올리므로 picker 위에 `Overlay`가 필요합니다 — navigator가 있는 `WidgetsApp`과 `MaterialApp` 둘 다 하나씩 제공합니다.

:::

## Props

<PropsTable name="PlDatePicker" />

::: fw react

나머지 `<div>` 속성은 field 래퍼로 그대로 통과합니다. `color`는 위 표의 `color`와 겹쳐서, `defaultValue`는 DOM 속성이 아니라 값으로 쓰기 때문에, `children`은 달력이 곧 컴포넌트이기 때문에 제외했습니다.

`className`은 label과 control, 그 아래 두 줄을 함께 담는 stack에 붙습니다. 그 안쪽 네 부분에 닿는 것이 `classNames`입니다 — `label`, `control`(트리거), `description`, `error`.

:::

::: fw flutter

picker는 패키지의 다른 모든 입력과 마찬가지로 **controlled**입니다. `value`와 `onChanged`를 함께 주고, `null`은 아무것도 고르지 않은 picker입니다.

React에 대응하는 것이 없는 유일한 파라미터가 `names`이고, 그 이유는 다음 절에 있습니다.

### PlDateNames

<PropsTable name="PlDateNames" />

:::

공유 축(`variant` `size` `color` `density` `elevation`)이 라이브러리 전체에서 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## 날짜 라이브러리도, 번역 파일도 없습니다

picker들은 의존성 트리에 **아무것도** 더하지 않습니다. 하는 일은 열두 줄짜리 `Date` 연산이거나, 플랫폼이 이미 싣고 있고 어떤 번들 테이블보다 더 많은 언어의 월 이름을 아는 `Intl`입니다. `date-fns`를 조용히 끌어오는 — 더 나쁘게는 dayjs / luxon / Temporal 논쟁에서 소비자 대신 편을 드는 — 컴포넌트 라이브러리라면 자기 것이 아닌 결정을 내린 셈입니다.

::: fw react

로캘 이야기도 그게 전부입니다. import하고 등록할 언어별 모듈이 없습니다. `locale`은 BCP 47 태그이고, 거기서부터 `Intl`이 월 이름, 요일 이름, 오전/오후, 한 주가 시작하는 요일, 헤더 두 버튼의 순서, trigger가 날짜를 쓰는 방식을 전부 제공합니다. **열두 언어로 출시하는 프로젝트가 열한 개에 대해 내는 비용이 0입니다.**

:::

::: fw flutter

두 패키지가 진짜로 갈라지는 유일한 지점이기도 합니다. 브라우저는 React에게 7월을 모든 언어로 뭐라 부르는지 이미 아는 `Intl`을 건네주므로 BCP 47 태그 하나면 충분합니다. Flutter 프레임워크는 그런 것을 싣고 있지 않고, 그 공백을 메우려고 `package:intl`을 끌어오는 패키지는 소비자 대신 의존성을 정하는 것입니다 — `PlProgressLinear`의 `formatValue`가 이미 거절한 것과 같은 거래입니다.

그래서 단어들은 `PlDateNames`로 옵니다. 기본값이 영어라 아무 설정 없이도 picker가 작동하고, 이미 `package:intl`에 의존하는 앱이라면 세 줄이면 됩니다.

```dart
PlDateNames(
  months: List<String>.generate(
    12,
    (int i) => DateFormat.MMMM(locale).format(DateTime(2021, i + 1)),
  ),
  monthsShort: List<String>.generate(
    12,
    (int i) => DateFormat.MMM(locale).format(DateTime(2021, i + 1)),
  ),
  weekdays: List<String>.generate(
    7,
    (int i) => DateFormat.EEEE(locale).format(DateTime(2021, 8, i + 1)),
  ),
  weekdaysShort: List<String>.generate(
    7,
    (int i) => DateFormat.E(locale).format(DateTime(2021, 8, i + 1)),
  ),
)
```

:::

남는 문자열은 picker 자신의 버튼에 적히는 것들 — "Today", "Previous month", "Choose a year" — 뿐입니다. 어느 플랫폼도 그것들에 대해서는 의견이 없기 때문입니다. 영어 기본값을 가진 `labels` 객체 하나입니다.

## 직접 입력할 수 없습니다

의도한 것입니다. 자유 텍스트에서 날짜를 파싱하는 일은 날짜 라이브러리 없이는 정직하게 할 수 없을 만큼 로캘에 의존하고, 어떤 브라우저에서는 `27/7/26`을 알아듣고 다음 브라우저에서는 못 알아듣는 field는 애초에 그런 척하지 않은 field보다 나쁩니다. trigger는 [`PlSelect`](./select)의 것과 똑같이 버튼이고, 답은 달력에서 나옵니다.

## Examples

### 헤더

한 번에 한 달씩만 넘기는 picker는 30년 전 생일을 180번의 클릭 너머에 둡니다. 그래서 월 이름과 연도가 각각 자기 그리드를 여는 **버튼** 입니다 — 열두 달, 그다음 한 번에 열두 해. 화면에 보이는 연도의 어느 달이든 두 번, 어느 해든 세 번입니다.

세 뷰는 너비도 _높이도_ 같아서, 뷰를 바꿔도 그것을 연 포인터 아래에서 팝업 크기가 변하지 않습니다. 날짜 그리드가 언제나 여섯 주인 것도 같은 이유입니다 — 네 줄이면 되는 2월과 여섯 줄이 필요한 3월 사이를 넘길 때마다 모든 칸이 움직일 테니까요.

### precision

생일은 날이고, 카드 만료는 월이고, 연식은 연도입니다. `precision`이 그중 무엇인지를 정하고, 달력은 그 단위의 그리드에서 열립니다 — `month` picker의 월 그리드가 마지막 그리드이고, 그 아래에 날짜 그리드는 아예 없습니다. 2027년 12월 며칠에 카드가 만료되느냐고 묻는 것은 잘못 답해질 질문을 던지는 일입니다.

값은 그대로 `Date`이고, 고른 단위의 시작으로 맞춰집니다 — 그 달의 1일, 또는 1월 1일. `minDate`와 `maxDate`도 같은 정밀도로 읽힙니다. `minDate`가 7월 15일이어도 `month` picker에서 7월은 그대로 고를 수 있고 7월 1일이 돌아옵니다 — 월을 돌려주는 컨트롤의 경계는 월의 경계니까요. `shouldDisableDate`는 일 단위라 아예 참조되지 않습니다.

trigger의 기본 format도 따라가고, 푸터의 지름길도 마찬가지입니다. "Today"가 아니라 "This month", "This year"가 됩니다.

<Demo src="date-picker/precision" :min-height="360">

::: fw react

<<< @/.vitepress/demos/date-picker/precision.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_picker/precision.dart

:::

</Demo>

### 이름과 라벨

::: fw react

`locale`은 BCP 47 태그이고, 월과 요일 이름, 오전/오후, 한 주가 시작하는 요일, 헤더 두 버튼의 순서, trigger 자신의 형식까지 전부 거기서 나옵니다.

:::

::: fw flutter

`names`가 그것을 전부 담고, 그중 가장 놓치기 쉬운 것이 `monthBeforeYear`입니다.

:::

한국어에서는 `2026년 7월`, 영어에서는 `July 2026` — 고정된 순서로 찍는 대신 두 버튼이 자리를 바꿉니다. 순서가 틀린 헤더는 그것이 틀린 바로 그 독자에게 고장으로 읽히기 때문입니다.

<Demo src="date-picker/locales" :min-height="280">

::: fw react

<<< @/.vitepress/demos/date-picker/locales.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_picker/locales.dart

:::

</Demo>

### minDate · maxDate · shouldDisableDate

`minDate`와 `maxDate`는 **일 단위** 입니다. 거기 붙은 시각은 무시됩니다 — 그 경계는 어떤 날이 존재하는가에 대한 것이니까요. `shouldDisableDate`는 범위 안이지만 그래도 쓸 수 없는 날들을 위한 것입니다 — 주말, 공휴일, 이미 예약된 방.

막힌 날은 사라지지 않고 그리드에 남고, `disabled` 버튼이 아닙니다. 화살표 경로에서 자기 자리를 지키므로, 한 달을 화살표로 훑는 독자가 막힌 날마다 구멍에 빠지지 않습니다.

<Demo src="date-picker/bounds" :min-height="220">

::: fw react

<<< @/.vitepress/demos/date-picker/bounds.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_picker/bounds.dart

:::

</Demo>

### trigger가 쓰는 방식

::: fw react

`format`은 `Intl.DateTimeFormat`으로 그대로 넘어갑니다. `{ dateStyle: 'full' }`도 `{ year: 'numeric', month: 'long' }`도 됩니다.

:::

::: fw flutter

`formatValue`는 위의 이유로 콜백입니다. 주지 않으면 `names`의 medium 형식으로 씁니다. 칸들이 이미 쓰고 있는 긴 형식은 `PlDateNames.spell`입니다.

:::

무엇이라 쓰든 trigger는 담을 수 있는 가장 긴 날짜의 너비로 붙잡혀 있습니다 — 28일 뒤에 1일을 골라도, 그것을 고른 포인터 아래에서 field가 줄어들지 않습니다.

<Demo src="date-picker/format" :min-height="240">

::: fw react

<<< @/.vitepress/demos/date-picker/format.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_picker/format.dart

:::

</Demo>

### readOnly · disabled · error

`error`는 picker를 invalid로도 만들고, 그러면 색 계열 전체가 `danger`로 옮겨 갑니다 — 테두리와 ring과 메시지가 함께 넘어갑니다. `invalid`는 메시지 없이 같은 일을 합니다.

`readOnly` picker는 값과 포커스를 유지하되 **열리지 않습니다.** 그것이 담고 있는 건 읽을 것이고, 모든 칸이 죽어 있는 달력은 아무것도 없는 메뉴입니다.

<Demo src="date-picker/states" :min-height="280">

::: fw react

<<< @/.vitepress/demos/date-picker/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_picker/states.dart

:::

</Demo>

### Controlled

`value`를 `onValueChange`와 함께 주세요. 값은 로컬 자정의 `Date`이거나, 이미 갖고 있던 시각 그대로의 `Date`입니다. 새 날을 고르면 날짜만 바뀌고 시계는 그대로 남으므로, 시각도 함께 담는 필드에 묶인 picker가 날짜를 고칠 때마다 시각을 조용히 초기화하지 않습니다.

`null`은 controlled picker가 정당하게 가질 수 있는 값입니다. 비워진 picker가 그것입니다.

## Accessibility

- 그리드에는 **roving tab stop이 하나** 라서, <kbd>Tab</kbd>은 칸 마흔둘을 걷는 대신 달력을 빠져나갑니다. ARIA date picker 관행이 설명하는 패턴입니다.

::: fw react

- 그리드는 `gridcell`들로 이루어진 `role="grid"`입니다.
- <kbd>←</kbd> <kbd>→</kbd> <kbd>↑</kbd> <kbd>↓</kbd>는 하루와 한 주씩, <kbd>Home</kbd>과 <kbd>End</kbd>는 그 주의 양 끝으로, <kbd>PageUp</kbd> / <kbd>PageDown</kbd>은 한 달씩 — <kbd>Shift</kbd>와 함께면 한 해씩 — 움직입니다. 가장자리를 벗어나면 멈추는 대신 달력이 넘어갑니다.
- 막힌 날은 `disabled` 속성이 아니라 `aria-disabled`를 답니다. 그래서 화살표 경로에 남고, 사용할 수 없다고 읽힙니다.

:::

::: fw flutter

- 막힌 날도 자기 focus node를 지키고 사용할 수 없다고 읽힙니다. 같은 이유입니다 — 한 달을 화살표로 훑는 독자가 그때마다 구멍에 빠지면 안 됩니다.
- trigger는 고른 날을 label에 접어 넣는 대신 **value** 로 지닌 버튼입니다. `PlSelect`가 이미 하고 있는 것과 같습니다 — label은 field의 이름을 말하고 value는 그 안에 무엇이 있는지를 말합니다.
- 너비를 잡아 주는 샘플들은 `ExcludeSemantics` 뒤에 있어서 더 읽히는 것이 없습니다.

:::

::: fw react

- 모든 칸의 접근성 이름은 숫자 하나가 아니라 **날짜 전체** 입니다 — picker 자신의 로캘로, `Intl`에서 나온 `2026년 7월 27일 월요일`.
- 오늘은 `aria-current="date"`와 링이 아닌 점을 답니다. 링은 포커스 표시의 몫이고, 한 칸 안의 링 둘은 아무 말도 하지 않는 칸이기 때문입니다.
- 요일 헤더는 전체 이름을 라벨로 단 `columnheader`입니다. 눈으로 보는 독자가 "월"을 볼 때 스크린리더는 "월요일"을 듣습니다.
- `name`이 있으면 hidden input이 값을 **로컬** `YYYY-MM-DD`로 담습니다. precision이 짧으면 `YYYY-MM`, `YYYY`이고, 이는 네이티브 `<input type="month">`가 제출하는 형태와 같습니다. `toISOString()`은 절대 아닙니다 — 서울의 picker라면 화면에 보이는 날의 전날을 제출하게 됩니다.
- trigger는 담을 수 있는 가장 긴 날짜의 너비로 붙잡혀 있습니다. 그 샘플들은 `aria-hidden`이고 generated content로 그려지므로, 더 읽히는 것도 페이지 내 검색에 걸리는 것도 없습니다.
- 팝업은 `<body>` 끝으로 portal되고 positioner가 `.plass-portal`을 답니다. CSS 리셋을 subtree에 한정한 호스트가 같은 리셋을 걸 수 있는 자리입니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| BCP 47 태그인 `locale` | `PlDateNames`인 `names` | 프레임워크에 `Intl`이 없고, `package:intl`을 끌어오는 건 소비자 대신 의존성을 정하는 일입니다. 기본값이 영어라 설정 없이도 picker는 작동합니다. |
| `format: Intl.DateTimeFormatOptions` | `formatValue: String Function(DateTime)` | 같은 이유의 같은 거래입니다. |
| `value` / `defaultValue` / `onValueChange` | `value` / `onChanged` | Flutter의 컨트롤은 controlled이고, 콜백 이름도 그쪽 것입니다. |
| hidden input, `name`, `required` | — | 참여할 네이티브 form 제출이 없습니다. |
| 헤더의 컨트롤이 picker의 `size` | 사다리 한 단 아래 | 월 이름은 어떤 언어에서는 `July`이고 다음 언어에서는 `септември`인데, 그 줄은 칸 일곱 개 안에 들어가야 합니다. 두 버튼 다 넘치는 대신 잘립니다. |
| `className`, `style`, 네이티브 속성 | — | 통과시킬 class 목록도 style 속성도 없습니다. |

:::
