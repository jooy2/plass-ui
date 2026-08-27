---
title: PlTable
order: 1
---

# PlTable

<p class="plass-lede">유리 시트 위에 놓인 데이터 격자입니다. 마크업이 아니라 column과 row를 받기 때문에, 제목 줄과 그 아래 셀이 서로 어긋날 수 없습니다.</p>

<Demo src="table/hero" :min-height="240" />

::: fw react

```tsx
import { PlTable, type PlTableColumn } from 'plass-ui';

const columns: PlTableColumn<Invoice>[] = [
  { key: 'id', header: 'Invoice' },
  { key: 'customer', header: 'Customer' },
  { key: 'total', header: 'Total', align: 'end', render: (row) => `$${row.total}` }
];

<PlTable columns={columns} rows={invoices} caption="Recent invoices" hoverable />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlTable<Invoice>(
  caption: const Text('Recent invoices'),
  hoverable: true,
  rows: invoices,
  columns: <PlTableColumn<Invoice>>[
    PlTableColumn<Invoice>(
      header: const Text('Invoice'),
      cell: (Invoice row, int index) => Text(row.id),
    ),
    PlTableColumn<Invoice>(
      header: const Text('Customer'),
      cell: (Invoice row, int index) => Text(row.customer),
    ),
    PlTableColumn<Invoice>(
      header: const Text('Total'),
      align: PlassAlign.end,
      cell: (Invoice row, int index) => Text(row.total),
    ),
  ],
);
```

:::

## Props

<PropsTable name="PlTable" />

::: fw react

네이티브 `<div>` 속성은 격자가 놓인 시트로 그대로 전달됩니다. `color`는 위 표의 `color`와 충돌해서 제외됩니다.

`PlTable`은 `Row`에 대해 generic이라 `forwardRef`가 아닙니다 — `React.forwardRef`로 감싼 컴포넌트는 타입 파라미터를 잃는데, 이 API의 핵심이 바로 행의 타입입니다. `Row`를 `any`로 넓혀 가며 `ref`를 제공하느니 제공하지 않습니다.

:::

::: fw flutter

표는 행 타입에 대해 제네릭입니다 — `PlTable<Invoice>` — 그리고 그것이 이 API의 핵심입니다. column은 타입이 있는 행을 받아 위젯을 돌려줍니다.

격자는 Flutter 자신의 `Table`이 배치하고, table·row·cell·column header semantics도 거기서 나옵니다. column의 너비는 그 안의 내용에서 측정됩니다 — 브라우저의 자동 표 레이아웃이 재는 방식 그대로라, 같은 데이터가 두 패키지에서 같은 모양으로 나옵니다.

:::

### PlTableColumn

<PropsTable name="PlTableColumn" />

::: fw flutter

`cell`이 필수라는 점이 두 빌드 사이의 유일한 실제 차이입니다. React에서는 column이 `key`로 속성 이름을 말하고 `render`가 없으면 셀이 `row[key]`가 되는데, Dart에는 임의의 타입에 대한 그런 조회가 없습니다. 행의 타입을 `dynamic`으로 넓혀 가며 얻는 것보다, 접근자를 한 줄 쓰는 편이 싼 거래입니다.

:::

라이브러리 전체에서 공유 축(`variant` `size` `color` `density` `elevation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### variant

격자 아래의 시트이고, 다른 모든 컨테이너와 같은 세 가지 재질을 쓰며 색이 들어가지 않습니다.

셋 중 어느 것에도 열 이름 뒤에 띠가 없습니다. 헤더는 조금 더 진한 선 위에 놓인 muted semibold 텍스트이고, 그 아래 행들은 중립 divider 잉크로 나뉩니다 — `PlCard`와 `PlList`에 금을 긋는 것과 같은 헤어라인입니다. 격자 맨 위를 칠한 띠는 데이터를 chrome처럼 보이게 만드는 가장 빠른 방법이고, 표의 무게를 하나도 필요 없는 자리에 몰아 줍니다.

예외는 `stickyHeader`인데, 거기서의 칠은 장식이 아닙니다. 고정된 헤더 밑으로 행이 그대로 지나가므로 빛을 막을 것이 필요합니다.

<Demo src="table/variants" :min-height="360">

::: fw react

<<< @/.vitepress/demos/table/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/table/variants.dart

:::

</Demo>

### columns

::: fw react

column은 `key`로 읽어 올 속성을 지정하고, 셀이 문자열이나 숫자가 아니면 `render`가 대신합니다. `width`는 첫 행의 셀이 아니라 `<col>`에 붙습니다 — `<th>`에 준 너비는 브라우저가 나머지 모든 행과 다시 협상하는 너비입니다.

:::

::: fw flutter

column이 말하는 것은 행에서 셀을 어떻게 꺼내는지, 그것뿐입니다. `cell`은 행과 그 위치를 받아 위젯을 돌려줍니다.

너비는 두 가지 형태로 오고, 둘은 서로 다른 질문입니다. `width`는 논리 픽셀 단위의 길이로, 정확히 그만큼이어야 하는 column에 씁니다 — 고정 폭 액션 열, 상태 pill 같은 것. `flex`는 모든 column이 자기 내용만큼 자리를 잡은 뒤 남은 폭을 나눠 갖는 몫이고, React 빌드의 `width: '30%'`가 실제로 뜻하던 것이 바로 이것입니다.

:::

`align`의 기본값은 `start`입니다. 숫자는 자릿수가 세로로 맞도록 보통 `end`가 맞습니다.

<Demo src="table/columns" :min-height="200">

::: fw react

<<< @/.vitepress/demos/table/columns.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/table/columns.dart

:::

</Demo>

### striped와 hoverable

`striped`는 한 행 걸러 하나씩 `--plass-stripe`로 칠합니다. 유리를 한 겹 더 얹는 대신 중립 잉크를 쓰는 것이고, 눈이 가로로 길게 따라가야 하는 넓은 표에서는 도움이 되지만 좁은 표에서는 소음입니다. `hoverable`은 포인터 아래의 행을 색 계열의 soft 틴트로 밝힙니다.

<Demo src="table/striped" :min-height="260">

::: fw react

<<< @/.vitepress/demos/table/striped.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/table/striped.dart

:::

</Demo>

### stickyHeader와 maxHeight

한 아이디어의 두 절반이고, 한쪽만으로는 거의 쓸모가 없습니다.

`maxHeight`는 **격자**의 높이를 제한하고, 그 높이를 넘으면 시트가 늘어나는 대신 시트 안에서 행이 스크롤됩니다. `stickyHeader`는 그 스크롤되는 상자의 맨 위에 열 이름을 고정합니다. 고정 없이 높이만 제한하면 이름이 스크롤되어 사라지고 남는 것은 이름표 없는 숫자 격자이며, 높이 제한 없이 고정만 하면 이름이 붙어 있을 상자가 없어서 아무 일도 일어나지 않습니다.

`caption`은 스크롤되는 것 **위**에 놓입니다. 미끄러져 사라지는 제목은 자기가 이름 붙인 표에서 떨어져 나가기 때문입니다.

고정된 헤더는 격자가 칠을 그리는 유일한 자리입니다. 행이 그 바로 밑을 지나가므로 반투명한 헤더는 행을 그대로 통과시킵니다. 그래서 시트의 가장 짙은 유리를 페이지 자신의 surface 색 위에 얹은 것 — 빛을 막기 위해 쌓아 올린 불투명한 두 겹입니다.

::: fw react

`maxHeight`는 픽셀 숫자이거나 아무 CSS 길이입니다. caption은 `<table>`이 `aria-labelledby`로 가리키는 제목이고, `<caption>`과 똑같이 표의 이름이 되면서 올바른 상자 안에 있습니다.

고정된 헤더 아래의 선은 border가 아니라 inset 그림자인데, 이것은 취향이 아닙니다. `border-collapse: collapse`는 셀의 border를 *표*의 border 격자에 넘기고, 그 격자는 `position: sticky`인 셀을 따라가지 않습니다 — border로 그린 고정 헤더는 자기 밑줄을 스크롤 맨 위에 두고 갑니다.

:::

::: fw flutter

`maxHeight`는 논리 픽셀 단위의 `double`입니다. 스크롤 뷰는 언제나 거기 있으므로, 높이 제한이 있든 없든 표는 자기보다 작은 상자 안에서 넘치는 대신 스크롤됩니다.

고정된 띠는 **두 번째 격자가 아닙니다**. 그것이 요령의 전부이고, 이것이 예전에 Flutter 빌드가 할 수 없는 일로 적혀 있던 이유이기도 합니다. 각자 자기 내용에서 잰 두 격자는 열 너비에 합의할 수 없습니다. 그래서 `Table`은 여전히 하나이고 헤더 행도 예전 그대로 그 안에 있으며, 스크롤 위에 얹힌 띠는 그 행의 *복사본*입니다. 띠의 각 셀은 진짜 헤더 셀이 실제로 배치된 너비의 상자에 담깁니다. 모든 열은 여전히 격자 하나가 정하고, 띠는 그 결정을 되풀이할 뿐입니다. 띠는 말도 하지 않습니다 — 이름은 이미 격자가 열 제목으로 안내하고 있고, 복사본까지 말하면 모든 열이 두 번씩 불립니다.

:::

<Demo src="table/scroll" :min-height="340">

::: fw react

<<< @/.vitepress/demos/table/scroll.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/table/scroll.dart

:::

</Demo>

### <Fw react="onRowClick" flutter="onRowPressed" />

행을 활성화할 수 있게 만들고, hover 처리도 함께 켭니다. 각 행이 focus stop을 갖고 <kbd>Enter</kbd>와 <kbd>Space</kbd>에 반응하므로, 포인터 없이도 행에 닿을 수 있습니다.

::: fw react

셀 **안에서** 눌린 키는 건드리지 않습니다. 셀은 자기 <kbd>Enter</kbd>를 가진 링크나 버튼을 담을 수 있고, 둘 다 실행하면 행을 열면서 동시에 링크를 따라가게 됩니다.

:::

::: fw flutter

행의 focus stop은 그 행의 **첫 번째 셀**에 있습니다. 그럴 수밖에 없습니다 — 여기서 행은 위젯이 아니고, `Table`이 셀들을 배치하며 그 뒤의 띠와 ring을 칠하기 때문에, focus를 쥘 수 있는 것은 셀뿐입니다. 그리고 그 셀이 밝히는 ring은 행 전체입니다.

셀 안의 컨트롤에서 눌린 키는 그 컨트롤의 것입니다. 행의 키는 행의 focus stop 위에 있고, 셀 안의 버튼은 자기 focus stop을 따로 가집니다.

:::

<Demo src="table/rows" :min-height="260">

::: fw react

<<< @/.vitepress/demos/table/rows.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/table/rows.dart

:::

</Demo>

### empty

행이 없는 표도 제목 줄은 그대로 그리고, 문구는 <Fw react="격자를 가로지르는 셀 하나에" flutter="격자 아래 가운데에" /> 놓입니다. 기본 문구는 `No data`이고, `empty`에는 무엇이든 넣을 수 있습니다.

<Demo src="table/empty" :min-height="180">

::: fw react

<<< @/.vitepress/demos/table/empty.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/table/empty.dart

:::

</Demo>

### density

셀 여백만 바꿉니다. 같은 `size`의 두 표는 density가 달라도 타입 스케일이 같습니다.

<Demo src="table/density" :min-height="240">

::: fw react

<<< @/.vitepress/demos/table/density.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/table/density.dart

:::

</Demo>

## Accessibility

::: fw react

- `<thead>`, `<tbody>`, `<th scope="col">`, `<td>`를 갖춘 진짜 `<table>`을 렌더링합니다. 스크린리더가 각 셀과 함께 열 제목, 행의 위치, 전체 행 수를 읽어 줍니다.
- `caption`은 `<caption>`이 되고, 이것이 표의 접근 가능한 이름입니다. 한 페이지에 표가 둘 이상이라면 붙일 만합니다.
- 누를 수 있는 행도 `<tr>`로 남습니다. 행에 붙인 `role="button"`은 따로 떼어 놓고 보면 그럴듯하지만 행이라는 의미를 지워 버려서, 그 안의 모든 셀이 자기가 속한 표에서 떨어져 나갑니다.
- 누를 수 있는 행은 `tabIndex={0}`을 갖고 <kbd>Enter</kbd>와 <kbd>Space</kbd>에 반응합니다. <kbd>Space</kbd>가 페이지를 스크롤하지 않도록 막습니다.
- 행의 focus ring은 안쪽으로 그려집니다. 시트가 자기 둥근 모서리에서 잘리기 때문에, 첫 행이나 마지막 행 바깥으로 그린 outline은 위나 아래가 잘려 나갑니다.
- 셀 여백과 정렬, 배경, 그리고 **테두리**를 inline style로 쓰고, `<table>` 자신의 `display`와 `width`, `margin`, `border-collapse`도 마찬가지입니다. 호스트 스타일시트가 `table`과 `td`, `th`를 태그 이름으로, utility class가 이길 수 없는 specificity로 스타일링하기 때문입니다. prose 스타일시트의 `td { border: 1px solid }`는 디자인이 요청한 적 없는 격자선을 셀마다 그리고, `table { display: block }`은 격자가 시트를 채우지 못하게 하며, `table { margin: 20px 0 }`은 판 모서리에 딱 붙어 있어야 할 표를 통째로 밀어냅니다. 라이브러리에서 이 전부를 우회해야 하는 컴포넌트는 이것 하나뿐입니다.

:::

::: fw flutter

- 격자는 진짜 `Table`이라, 행과 셀이 든 표로 읽히고 스크린리더가 셀 단위로 옮겨 다닐 수 있습니다.
- 제목 칸은 그 열의 header로 읽힙니다. 아래의 모든 숫자 앞에 열 이름이 붙는 것이 이것 덕분입니다.
- `caption`은 시트 맨 위에 그려지고 격자 위의 한 줄로 읽힙니다. 표의 이름이 그려진 것과 달라야 할 때를 위해 `semanticLabel`이 따로 있습니다.
- 누를 수 있는 행도 행이라는 의미를 그대로 지킵니다. tap 액션은 셀에 있고, 행을 버튼이라고 부르는 것은 아무것도 없습니다. 버튼으로 읽히는 행은 그 안의 셀들이 자기가 속한 표에서 떨어져 나간 행입니다.
- 행의 focus stop은 첫 번째 셀에 있고, ring은 행이 직접 칠합니다 — 안쪽으로요. 시트가 자기 둥근 모서리에서 잘리기 때문에, 첫 행이나 마지막 행 바깥에 그린 ring은 위나 아래가 잘려 돌아옵니다.
- 모든 셀은 그 행에서 가장 큰 셀만큼 높습니다. 그래서 행은 가장 긴 글자 줄에서만이 아니라 자기 전부에서 눌립니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `key`가 속성을 가리키고 `render`는 선택 | `cell`이 필수 | Dart에는 임의의 타입에 대한 `row[key]`가 없습니다. 행을 `dynamic`으로 넓히느니 접근자를 쓰는 편이 쌉니다. |
| `width: number \| string` | `width: double`과 `flex: double` | 픽셀은 픽셀 그대로, 퍼센트는 남은 폭의 몫이 됩니다. 자기 폭에 맞아떨어져야 하는 표에서 퍼센트란 원래 그것이었습니다. |
| 시트의 `overflow-x: auto` | — | 격자는 시트만큼 넓습니다. 열에 더 넓은 자리가 필요하면 `SingleChildScrollView`로 감싸세요. *세로* 스크롤은 어느 쪽이든 표가 직접 갖고 있습니다. |
| `getRowKey` | `rowKey` | 같은 일, Flutter의 철자. 돌려주는 것은 `React.Key`가 아니라 `LocalKey`입니다. |
| `onRowClick` | `onRowPressed` | 누름이 부르는 것에 대한 이 패키지의 이름입니다. |
| `maxHeight: number \| string` | `maxHeight: double` | 픽셀은 픽셀 그대로입니다. 받을 CSS 길이가 없습니다. |
| 접근 가능한 이름인 `<caption>` | 그려지는 한 줄과 `semanticLabel` | Flutter는 노드에 문자열로 이름을 붙이고, caption은 위젯입니다. 그 문구는 여전히 먼저 읽힙니다. |
| inline style 우회 | — | `table`, `td`, `th`를 다시 스타일링하려 드는 호스트 스타일시트가 없으니, 우회할 것도 없습니다. |
| `className`, `style` | — | 전달할 클래스 목록도 style 속성도 없습니다. |

:::
