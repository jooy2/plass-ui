---
title: PlDataTable
order: 21
---

# PlDataTable

<p class="plass-lede">자기 행을 스스로 들고 있는 표입니다. 정렬하고, 입력한 것으로 좁히고, 한 페이지씩 나눠 주고, 어느 행이 체크됐는지 기억합니다. 그리는 격자는 <code>PlTable</code>이 그리는 바로 그 격자입니다. 둘 다 한 곳에서 꺼내 쓰기 때문입니다.</p>

<Demo src="data-table/hero" :min-height="440" />

::: fw react

```tsx
import { PlDataTable, type PlDataTableColumn } from 'plass-ui';

const columns: PlDataTableColumn<Invoice>[] = [
  { key: 'id', header: 'Invoice', sortable: true },
  { key: 'customer', header: 'Customer', sortable: true },
  { key: 'total', header: 'Total', align: 'end', sortable: true }
];

<PlDataTable
  columns={columns}
  rows={invoices}
  getRowKey={(row) => row.id}
  searchable
  selection="multiple"
/>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlDataTable<Invoice>(
  rows: invoices,
  rowKey: (Invoice row, int index) => row.id,
  searchable: true,
  selection: PlDataTableSelection.multiple,
  columns: <PlDataTableColumn<Invoice>>[
    PlDataTableColumn<Invoice>(
      key: 'customer',
      header: const Text('Customer'),
      sortable: true,
      value: (Invoice row) => row.customer,
      cell: (Invoice row, int index) => Text(row.customer),
    ),
  ],
);
```

:::

## PlTable과 PlDataTable 중 고르기

[`PlTable`](table)은 건네받은 격자를 그립니다. 행이 이미 있어야 할 순서로 도착했을 때(요약, 영수증, 비교표, 읽는 사람이 파고들 일이 없는 표) 쓰는 쪽입니다. 서버에서 렌더링되고, 이쪽은 그러지 못합니다.

`PlDataTable`은 읽는 사람이 작업하는 표를 위한 것입니다. 정렬하고 검색하고 체크하고 페이지를 넘기는 표. 그 하나하나가 렌더 사이에 기억해야 하는 결정이고, 그래서 이쪽은 클라이언트 컴포넌트이고 `PlTable`은 아닙니다.

column 아래는 **같은 격자**입니다. 측정된 열 너비도, hover 밴드도, 행 사이의 선도, 고정된 헤더도. 둘 다 하나의 내부 모듈에서 그려지므로, 한 페이지에 놓인 정렬되는 표와 평범한 표가 한 톤 어긋날 수 없습니다.

## Props

<PropsTable name="PlDataTable" />

::: fw react

네이티브 `<div>` 속성은 시트로 그대로 전달됩니다. `color`와 `onSelect`는 위 표의 프로퍼티와 이름이 겹쳐 제외됩니다.

`Row`에 대해 제네릭이므로 `forwardRef`가 아닙니다. `PlTable`과 같은 이유입니다. `React.forwardRef`로 감싼 컴포넌트는 타입 매개변수를 잃고, 행 타입이야말로 이 API의 전부입니다.

:::

::: fw flutter

행 타입에 대해 제네릭입니다(`PlDataTable<Invoice>`). 그래서 column은 타입이 붙은 행을 받고 위젯을 돌려줍니다.

제어하지 않을 때의 출발값은 `default…`가 아니라 `initialSort` · `initialSearch` · `initialSelected` · `initialPage`입니다. Flutter 자신의 관례이고, 이 패키지의 다른 위젯이 전부 따르는 이름입니다.

:::

### PlDataTableColumn

<PropsTable name="PlDataTableColumn" />

::: fw flutter

`cell`이 필수인 것은 `PlTableColumn`과 같은 이유입니다. Dart에는 임의의 타입에 대한 `row[key]`가 없습니다. `value`는 같은 문제의 나머지 반쪽입니다. 정렬과 검색은 위젯을 읽을 수 없으니, 정렬되거나 검색되는 column은 자기가 무엇을 담고 있는지 알려야 합니다.

:::

공통 축(`variant` `size` `color` `density` `elevation`)이 라이브러리 전체에서 무엇을 뜻하는지는 [프로퍼티 관례](../../design/prop-conventions)에 있습니다.

## 제어하거나, 하지 않거나

정렬 · 검색 · 선택 · 페이지는 각각 **기본은 비제어이고 하나씩 제어할 수 있습니다.** 값을 넘기면 표는 시키는 대로 그리고, 넘기지 않으면 표가 들고 있습니다.

편의 기능 네 개가 아닙니다. 사람들이 만드는 두 종류의 표를 컴포넌트 하나로 덮는 방법입니다. 평범한 표는 이 페이지 맨 위의 코드이고, 서버가 받쳐 주는 표는 같은 코드에 `manual`과 핸들러가 붙은 것입니다. 그 사이에서 모양이 바뀌는 것은 없습니다.

## Examples

### 정렬

`sortable`인 column의 제목은 컨트롤이 됩니다. 오름차순, 내림차순, 그리고 **행이 도착했던 순서로**. 세 번째 누름은 대부분의 표가 빠뜨리는 부분이고, 중요합니다. 도착 순서는 보통 서버가 고른 순서이고, 되돌릴 수 없는 표는 그것을 버린 표입니다.

표시는 hover할 때 나타나는 대신 모든 정렬 가능한 제목에 옅게 그려져 있습니다. 포인터가 올라가야 누를 수 있어 보이는 제목은 아무도 누르지 않는 제목입니다.

값은 자기 자신으로 비교됩니다. 숫자는 숫자로, 날짜는 그 날짜가 가리키는 순간으로, 그리고 **빈 값은 양쪽 방향 모두에서 마지막입니다.** 빈칸 셋이 섞인 금액 열에서 그 빈칸은 가장 작은 금액이 아니고, 가장 큰 값을 찾으려고 정렬을 뒤집은 사람에게 빈칸을 먼저 건네서는 안 됩니다.

::: fw react

문자는 `localeCompare`로 비교합니다. 그래서 `apple`이 `Banana`보다, `Ösi`가 `Zoe`보다 앞에 옵니다. 코드 포인트로 정렬하면 대문자로 시작하는 단어가 전부 소문자 단어 위로 올라가고, 그건 읽는 사람이 훑을 수 없는 목록입니다.

:::

::: fw flutter

문자는 대소문자를 접어 비교합니다. 그래서 `apple`이 `Banana`보다 앞에 옵니다. **악센트는 접지 않습니다.** `PlTransfer`의 검색이 대는 것과 같은 이유입니다. Dart 코어에는 `String.normalize`가 없고 이 패키지에는 의존성이 없으므로, `Ö`는 자기 코드 포인트가 놓는 자리에 놓입니다. React 빌드는 `localeCompare`로 제대로 처리합니다.

:::

순서가 자기만의 것인 column에는 `compare`가 대신 답합니다. 방향은 그 함수가 돌려준 값에 적용되므로, 직접 쓴 비교 함수도 내장 비교와 똑같이 뒤집힙니다. 어느 방향으로 물어보는 중인지 알 필요가 없습니다.

<Demo src="data-table/sorting" :min-height="320">

::: fw react

<<< @/.vitepress/demos/data-table/sorting.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_table/sorting.dart

:::

</Demo>

### value, 그리고 그려진 셀에 그것이 필요한 이유

`render`는 읽는 사람이 보는 것을 정합니다. `value`는 정렬과 검색이 보는 것을 정합니다. 대부분의 column에는 둘 다 필요 없습니다. 셀이 곧 그 속성이고, 비교되고 매칭되는 것도 그것입니다.

셀이 인쇄되는 대신 _그려지는_ 순간 둘은 갈라집니다. 칩을 그리는 상태 열에는 검색할 글자도 정렬할 순서도 없고, `$1,240.00`을 인쇄하는 합계 열은 문자열로 정렬되어 `$89`가 `$1,240` 뒤로 갑니다. `value`는 column이 실제로 무엇을 담고 있는지 알리는 자리입니다.

::: fw flutter

여기서는 그려지는 column뿐 아니라 정렬되거나 검색되는 column 전부에 `value`가 필요합니다. `cell`은 어느 경우에나 위젯을 돌려주기 때문입니다.

:::

### 선택

`single`은 한 행만 들고 있고, `multiple`은 열 맨 위에 전체 체크 상자를 더합니다. 둘 다 **key**와 **행 자체**를 돌려줍니다. 화면에 보이는 페이지가 아니라 표가 가진 모든 행에서 골라 오므로, 페이지를 넘겨 가며 만든 선택은 그 과정을 살아남은 행 전부를 돌려줍니다.

페이지 일부만 골랐을 때 헤더 상자는 중간 상태가 됩니다. 절반쯤 찬 페이지 위에 그냥 빈 상자가 있으면 "여기에는 고른 것이 없다"로 읽히고, 그건 사실의 반대입니다.

Shift는 마지막으로 누른 행에서 이번 행까지 선택을 늘립니다. 행이 **지금** 놓인 순서대로 늘어나는데, 정렬된 페이지를 아래로 훑어 내리는 사람이 "이것들"이라고 할 때 뜻하는 것이 그것입니다. `isRowSelectable`은 어떤 행을 선택에서, 그리고 전체 체크에서도 함께 빼냅니다.

::: fw react

고른 행은 틴트와 함께 `aria-selected`를 답니다. 눈에는 칠해져 있는데 조용히 선택되지 않은 행은, 스크린 리더가 화면과 다른 말을 하는 행입니다.

체크박스를 누른 것은 체크박스를 누른 것입니다. 행까지 활성화하지 않으므로 `selection`과 `onRowClick`을 한 표에 둘 수 있습니다.

:::

::: fw flutter

행의 체크박스가 스크린 리더가 읽는 상태를 들고 있고, 틴트는 눈으로 보는 사람이 보는 것입니다. Flutter의 `Table`에는 행 단위로 세울 선택 플래그가 없고, 셀마다 `Semantics(selected: true)`를 붙이면 열 개수만큼 반복해서 알려 줍니다.

Shift는 하드웨어 키보드에서 읽으므로, 범위 제스처는 데스크톱과 웹에서 동작하고 터치 기기에서는 아예 생기지 않습니다.

:::

<Demo src="data-table/selection" :min-height="360">

::: fw react

<<< @/.vitepress/demos/data-table/selection.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_table/selection.dart

:::

</Demo>

### 검색

`searchable`은 격자 위, 시트 안에 필드를 그립니다. 모든 column의 `value`를 대상으로 매칭하고, 행마다 열마다가 아니라 키 입력마다 한 번만 접습니다. `PlTransfer`와 `PlCommandPalette`가 쓰는 그 매처이므로, 제품 한 곳에서 필터가 어떻게 동작하는지 배운 사람은 나머지에 대해서도 배운 것이 됩니다.

`unsearchable`은 column을 거기서 빼냅니다. 아무도 입력하지 않는 식별자 열에 맞습니다. 그런 열에서의 매치는 읽는 사람이 이유를 볼 수 없는 행입니다.

::: fw react

대소문자와 악센트를 모두 접으므로 `jose`가 `José`를 찾습니다.

:::

::: fw flutter

대소문자는 접고 악센트는 접지 않습니다. 정렬 항목에 적은 이유와 같습니다.

:::

### 페이징

`scroll`이 기본이고 모든 행을 내놓습니다. `maxHeight`와 함께 쓰면 시트 안에서 스크롤됩니다.

`pages`는 한 조각을 잘라 내고 푸터에 [`PlPagination`](../inputs/pagination)을 놓습니다. 개수는 그 옆에 붙습니다. 전체에서 행이 몇 번째인지가 정보일 때(장부, 감사 로그) 맞고, 행을 한 페이지씩 받아 오는 상황에서는 유일하게 정직한 선택입니다.

정렬하거나 검색하면 **첫 페이지로 돌아갑니다.** 다른 행 묶음의 9페이지는 읽던 사람이 있던 자리가 아닙니다.

<Demo src="data-table/paging" :min-height="440">

::: fw react

<<< @/.vitepress/demos/data-table/paging.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_table/paging.dart

:::

</Demo>

### manual: 서버가 일할 때

`manual`에 단계를 적으면, 도착하는 행이 이미 그 처리를 거쳤다는 뜻입니다. 표는 읽는 사람이 무엇을 요청했는지 알리고 건네받은 것을 그립니다. 이미 정렬된 페이지를 다시 정렬하거나, 전체의 10분의 1인 페이지를 필터링하지 않습니다.

`rowCount`는 `manual` 페이징과 함께 갑니다. 그래야만 합니다. 아흔 행 중 열 행만 들고 있는 표는 페이저가 아홉 페이지를 내놓아야 한다는 것을 알 방법이 없습니다.

<Demo src="data-table/server" :min-height="320">

::: fw react

<<< @/.vitepress/demos/data-table/server.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_table/server.dart

:::

</Demo>

### loading

행 대신 막대를 그리고, 개수는 한 페이지에 들어가는 만큼입니다. 그래야 데이터가 도착할 때 격자 높이가 바뀌지 않습니다. 포인터 밑에서 자라는 표는 누르려던 행이 손 밑에서 빠져나가는 표입니다.

::: fw react

기다리는 동안 격자는 `aria-busy`를 답니다.

:::

<Demo src="data-table/loading" :min-height="260">

::: fw react

<<< @/.vitepress/demos/data-table/loading.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_table/loading.dart

:::

</Demo>

### toolbar와 footer

시트 안, 격자의 위와 아래에 있는 슬롯 둘입니다. caption이 놓이는 그 선 위에 놓입니다. `toolbar`는 필터나 일괄 동작이 검색 필드 옆에 들어가는 자리이고, `footer`는 페이저 줄 앞쪽의 행 개수를 대신합니다.

시트 위아래에 떠 있지 않고 시트 안에 있는 것은 그것들이 표에 속하기 때문입니다. 자기가 무엇에 작용할지 눈에 보이지 않는 "3개 삭제" 버튼은 범위를 읽는 사람이 짐작해야 하는 버튼입니다.

## 다루지 않는 것

**가상화하지 않습니다.** 십만 행을 DOM 하나에 넣으면 어느 컴포넌트가 그리든 느린 페이지이고, 정직한 답은 `paging="pages"`입니다. 행을 받아 오는 상황에서 동작하는 유일한 모양이기도 합니다. 가상화된 본문은 조건이 다른 별개의 컴포넌트입니다. 행 높이가 고정되고 스크롤바의 길이가 실제 데이터와 어긋나는데, 그것을 이 안에 숨기면 모든 표가 그 값을 치릅니다.

**드래그로 열 너비를 바꾸거나 순서를 옮기지 않습니다.** 둘 다 진짜 기능이고, 둘 다 이 위에 애플리케이션이 만드는 표의 몫입니다. 읽는 사람이 드래그한 결과를 어딘가에 저장해야 하는데, mount할 때마다 너비를 잊어버리는 컴포넌트는 읽는 사람에게 장난감을 건넨 것입니다.

**내보내기를 하지 않습니다.** 행을 파일로 바꾸는 것은 애플리케이션의 데이터이고 애플리케이션의 파일 이름입니다. 프로퍼티가 아니라 표 옆의 세 줄입니다. 버튼이 들어갈 자리는 `toolbar`입니다.

**한 열로만 정렬합니다.** 키가 셋인 정렬은 질의입니다. 표를 보는 사람은 세 번째 키를 볼 수 없고 두 행이 왜 그 순서인지 알아낼 수도 없습니다. 정말로 필요한 애플리케이션은 `manual`로 정렬을 가져가서 자기 말로 설명하면 됩니다.

## Accessibility

::: fw react

- 진짜 `<table>`을 렌더링합니다. `<thead>` · `<tbody>` · `<th scope="col">` · `<td>`. `PlTable`이 렌더링하는 그 마크업이고, 거기 붙은 모든 인라인 스타일의 이유도 같습니다.
- 정렬 가능한 column은 방향을 **제목 셀의** `aria-sort`로 알립니다. 안쪽 버튼이 아닙니다. 그 열의 셀에 들어갈 때 스크린 리더가 읽는 것은 제목이고, 버튼에 붙인 상태는 마침 버튼에 내려앉은 사람만 듣습니다.
- 정렬 컨트롤은 제목의 타입을 그대로 입은 맨 `<button>`입니다. 여기에 `PlButton`을 쓰면 컨트롤 위의 컨트롤이 됩니다. 아래 선에 딱 붙어 있는 것이 일인 셀에 배경과 라운드와 높이를 들여옵니다.
- 그 포커스 링은 안쪽에 그려집니다. 시트가 둥근 모서리에서 잘라 내므로, 첫 제목 셀 바깥에 그린 링은 위쪽이 잘려 돌아옵니다.
- 고른 행은 `aria-selected`를 답니다. 각 체크박스의 이름은 로케일의 `selectRow`, 헤더의 것은 `selectAll`입니다.
- `loading` 동안 격자는 `aria-busy`를 답니다.
- `caption`은 시트 위에 그려지고 `aria-hidden`이 붙으며, 표 안의 진짜 `<caption>`이 같은 말을 나릅니다. 스크롤되어 사라지는 caption은 표의 접근 가능한 이름을 함께 데려갑니다.

:::

::: fw flutter

- 격자는 진짜 `Table`이고, 행과 셀이 있는 표로 알려집니다. 모든 제목은 그 열의 헤더로 알려집니다.
- **정렬된 제목은 방향을 소리 내어 알립니다.** semantics의 값으로 전합니다. 두 빌드가 철자가 아니라 종류에서 갈라지는 유일한 자리입니다. `aria-sort`는 모든 스크린 리더가 읽는 사람의 언어로 읽어 주는 플랫폼의 기능인데 Flutter의 semantics에는 대응물이 없습니다. 그러니 말을 해야 하고, 말한 것은 번역돼야 합니다. `sortedAscending`과 `sortedDescending`은 여기 [어휘 묶음](../../guide/locales)에 있고 React 쪽에는 없습니다.
- 행의 체크박스가 그 행이 골라졌는지를 나르고, 틴트는 눈으로 보는 사람이 보는 것입니다.
- 고정된 헤더 밴드는 말이 없습니다. 그것이 베낀 행은 말을 하기 때문입니다.
- 행의 포커스 정지는 첫 셀에 있고 링은 행이 그립니다. 시트의 둥근 모서리 때문에 안쪽에 그립니다.

:::

## Notes

- **무엇보다 먼저 `getRowKey`.** 표가 기억하는 모든 것은 _key로_ 기억됩니다. 선택도, 범위의 기준점도, React와 Flutter가 행을 대조하는 정체성도. index를 기본값으로 두는 것은 정적인 표에는 맞고 이 표에는 틀립니다. 정렬이 행을 옮기면 index는 뒤에 남습니다.
- **`onSelectedChange`는 모든 페이지의 행을 돌려줍니다.** 화면에 보이는 페이지가 아닙니다. 세 페이지를 오가며 만든 선택은 세 페이지 분량의 행입니다.
- **검색과 정렬과 페이지는 그 순서로 계산됩니다.** 그래서 한 페이지는 좁혀지고 정렬된 묶음의 한 페이지이지, 원본 행의 한 페이지에 나중에 필터를 씌운 것이 아닙니다.
