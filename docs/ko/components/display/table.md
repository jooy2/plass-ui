---
title: PlTable
order: 1
---

# PlTable

<p class="plass-lede">유리 시트 위에 놓인 데이터 격자입니다. 마크업이 아니라 column과 row를 받기 때문에, 제목 줄과 그 아래 셀이 서로 어긋날 수 없습니다.</p>

<Demo src="table/hero" :min-height="240" />

```tsx
import { PlTable, type PlTableColumn } from 'plass-ui';

const columns: PlTableColumn<Invoice>[] = [
  { key: 'id', header: 'Invoice' },
  { key: 'customer', header: 'Customer' },
  { key: 'total', header: 'Total', align: 'end', render: (row) => `$${row.total}` }
];

<PlTable columns={columns} rows={invoices} caption="Recent invoices" hoverable />;
```

## Props

<PropsTable name="PlTable" />

네이티브 `<div>` 속성은 격자가 놓인 시트로 그대로 전달됩니다. `color`는 위 표의 `color`와 충돌해서 제외됩니다.

`PlTable`은 `Row`에 대해 generic이라 `forwardRef`가 아닙니다 — `React.forwardRef`로 감싼 컴포넌트는 타입 파라미터를 잃는데, 이 API의 핵심이 바로 행의 타입입니다. `Row`를 `any`로 넓혀 가며 `ref`를 제공하느니 제공하지 않습니다.

### PlTableColumn

<PropsTable name="PlTableColumn" />

라이브러리 전체에서 공유 축(`variant` `size` `color` `density` `elevation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### variant

격자 아래의 시트이고, 다른 모든 컨테이너와 같은 세 가지 재질을 쓰며 색이 들어가지 않습니다.

셋 중 어느 것에도 열 이름 뒤에 띠가 없습니다. 헤더는 조금 더 진한 선 위에 놓인 muted semibold 텍스트이고, 그 아래 행들은 `--plass-divider`로 나뉩니다 — `PlCard`와 `PlList`에 금을 긋는 것과 같은 헤어라인입니다. 격자 맨 위를 칠한 띠는 데이터를 chrome처럼 보이게 만드는 가장 빠른 방법이고, 표의 무게를 하나도 필요 없는 자리에 몰아 줍니다. 예외는 `stickyHeader`인데, 거기서의 칠은 장식이 아닙니다. 고정된 헤더 밑으로 행이 그대로 지나가므로 빛을 막을 것이 필요합니다.

<Demo src="table/variants" :min-height="360">

<<< @/.vitepress/demos/table/variants.tsx

</Demo>

### columns

column은 `key`로 읽어 올 속성을 지정하고, 셀이 문자열이나 숫자가 아니면 `render`가 대신합니다. `width`는 첫 행의 셀이 아니라 `<col>`에 붙습니다 — `<th>`에 준 너비는 브라우저가 나머지 모든 행과 다시 협상하는 너비입니다.

`align`의 기본값은 `start`입니다. 숫자는 자릿수가 세로로 맞도록 보통 `end`가 맞습니다.

<Demo src="table/columns" :min-height="200">

<<< @/.vitepress/demos/table/columns.tsx

</Demo>

### striped와 hoverable

`striped`는 한 행 걸러 하나씩 `--plass-stripe`로 칠합니다. 유리를 한 겹 더 얹는 대신 중립 잉크를 쓰는 것이고, 눈이 가로로 길게 따라가야 하는 넓은 표에서는 도움이 되지만 좁은 표에서는 소음입니다. `hoverable`은 포인터 아래의 행을 색 계열의 soft 틴트로 밝힙니다.

<Demo src="table/striped" :min-height="260">

<<< @/.vitepress/demos/table/striped.tsx

</Demo>

### onRowClick

행을 활성화할 수 있게 만들고, hover 처리도 함께 켭니다. 각 행이 tab stop을 갖고 <kbd>Enter</kbd>와 <kbd>Space</kbd>에 반응하므로, 포인터 없이도 행에 닿을 수 있습니다.

셀 **안에서** 눌린 키는 건드리지 않습니다. 셀은 자기 <kbd>Enter</kbd>를 가진 링크나 버튼을 담을 수 있고, 둘 다 실행하면 행을 열면서 동시에 링크를 따라가게 됩니다.

<Demo src="table/rows" :min-height="260">

<<< @/.vitepress/demos/table/rows.tsx

</Demo>

### empty

행이 없는 표도 헤더는 그대로 그리고, 그 아래에 격자를 가로지르는 셀 하나가 놓입니다. 기본 문구는 `No data`이고, `empty`에는 무엇이든 넣을 수 있습니다.

<Demo src="table/empty" :min-height="180">

<<< @/.vitepress/demos/table/empty.tsx

</Demo>

### density

셀 여백만 바꿉니다. 같은 `size`의 두 표는 density가 달라도 타입 스케일이 같습니다.

<Demo src="table/density" :min-height="240">

<<< @/.vitepress/demos/table/density.tsx

</Demo>

## Accessibility

- `<thead>`, `<tbody>`, `<th scope="col">`, `<td>`를 갖춘 진짜 `<table>`을 렌더링합니다. 스크린리더가 각 셀과 함께 열 제목, 행의 위치, 전체 행 수를 읽어 줍니다.
- `caption`은 `<caption>`이 되고, 이것이 표의 접근 가능한 이름입니다. 한 페이지에 표가 둘 이상이라면 붙일 만합니다.
- 누를 수 있는 행도 `<tr>`로 남습니다. 행에 붙인 `role="button"`은 따로 떼어 놓고 보면 그럴듯하지만 행이라는 의미를 지워 버려서, 그 안의 모든 셀이 자기가 속한 표에서 떨어져 나갑니다.
- 누를 수 있는 행은 `tabIndex={0}`을 갖고 <kbd>Enter</kbd>와 <kbd>Space</kbd>에 반응합니다. <kbd>Space</kbd>가 페이지를 스크롤하지 않도록 막습니다.
- 행의 focus ring은 안쪽으로 그려집니다. 시트가 자기 둥근 모서리에서 잘리기 때문에, 첫 행이나 마지막 행 바깥으로 그린 outline은 위나 아래가 잘려 나갑니다.
- 셀 여백과 정렬, 배경, 그리고 **테두리**를 inline style로 쓰고, `<table>` 자신의 `display`와 `width`, `margin`, `border-collapse`도 마찬가지입니다. 호스트 스타일시트가 `table`과 `td`, `th`를 태그 이름으로, utility class가 이길 수 없는 specificity로 스타일링하기 때문입니다. prose 스타일시트의 `td { border: 1px solid }`는 디자인이 요청한 적 없는 격자선을 셀마다 그리고, `table { display: block }`은 격자가 시트를 채우지 못하게 하며, `table { margin: 20px 0 }`은 판 모서리에 딱 붙어 있어야 할 표를 통째로 밀어냅니다. 라이브러리에서 이 전부를 우회해야 하는 컴포넌트는 이것 하나뿐입니다.
