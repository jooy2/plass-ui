---
title: PlDataList
order: 20
---

# PlDataList

<p class="plass-lede">라벨과 그에 딸린 값의 목록입니다. 모든 상세 화면이 끝나는 자리의 패널이고, 컴포넌트인 이유의 전부는 마크업입니다. "Owner"가 "Ada Lovelace" 옆에 있는 것이 아니라 그것을 <em>가리킨다</em>고 말해 줍니다.</p>

<Demo src="data-list/hero" :min-height="280" />

::: fw react

```tsx
import { PlDataList, PlDataListItem } from 'plass-ui';

<PlDataList divider>
  <PlDataListItem label="Owner" value="Ada Lovelace" />
  <PlDataListItem label="Plan" value="Team" />
</PlDataList>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlDataList(
  divider: true,
  children: const <Widget>[
    PlDataListItem(label: Text('Owner'), value: Text('Ada Lovelace')),
    PlDataListItem(label: Text('Plan'), value: Text('Team')),
  ],
);
```

:::

## Props

<PropsTable name="PlDataList" />

### PlDataListItem

<PropsTable name="PlDataListItem" />

라이브러리 전체에서 공유 축이 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## PlDataList, PlTable, PlList 중 고르기

글줄을 늘어놓는 컴포넌트가 셋 있고, 서로 다른 질문에 답합니다.

|                      |                                                                |
| -------------------- | -------------------------------------------------------------- |
| `PlDataList`         | **하나**와 그 필드들. 프로젝트의 소유자, 요금제, 리전, 생성일. |
| [`PlTable`](./table) | 같은 필드를 가진 **여럿**.                                     |
| [`PlList`](./list)   | 같은 종류의 항목이 이어진 것. 필드는 없습니다.                 |

상세 패널을 두 칸짜리 표로 만드는 것이 흔한 실수이고, 스타일의 문제가 아닙니다. 표는 있지도 않은 행-열 관계를 주장하므로, 셀 단위로 읽어 나가는 사람은 데이터가 두 열 있다고 듣게 됩니다. 실제로는 **이름**의 열과 **값**의 열인데도요.

::: fw react

마크업이 그것을 위한 것입니다. 진짜 `<dl>`에 진짜 `<dt>`와 `<dd>`가 들어가고, 각 쌍은 `<div>`로 묶입니다. HTML 명세가 허용하는 방식이고, 쌍이라는 사실을 포기하지 않으면서 한 줄을 나란히 놓을 수 있게 해 주는 것이 그것입니다.

:::

::: fw flutter

같은 주장의 Dart 쪽은 각 줄을 감싼 `MergeSemantics`입니다. 라벨과 값이 함께 읽힙니다. 라벨만 읽히면 단어이고, 값만 읽히면 어디에 놓을지 알 수 없는 사실입니다.

:::

## orientation

`horizontal`은 라벨을 값 옆에, 자기 열에 둡니다. 상세 패널이 취하는 모양입니다. `vertical`은 위에 둡니다. 좁은 칸이거나, 옆에 라벨이 있으면 값이 갈 데가 없을 만큼 값이 긴 경우입니다.

<Demo src="data-list/orientation" :min-height="200">

::: fw react

<<< @/.vitepress/demos/data-list/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_list/orientation.dart

:::

</Demo>

라벨 열은 가장 긴 라벨의 너비가 아니라 **고정 너비**입니다. 의도한 것입니다. 한 화면의 두 패널이 서로 맞고, 누가 필드 이름을 바꿔도 값이 움직이지 않습니다. `labelWidth`가 그것을 정합니다.

::: fw react

보통은 `'12ch'`가 맞습니다. 라벨 열은 글자 수로 재는 것이고, `rem` 사다리로는 그것을 적을 수 없습니다.

:::

## Examples

### 줄 사이에 선이 필요할 때

`divider`는 줄과 줄 **사이에만** 실선을 긋습니다. 첫 줄 위나 마지막 줄 아래의 선은, 상자가 없는 목록 둘레에 그린 상자입니다.

```tsx
<PlCard>
  <PlDataList divider>…</PlDataList>
</PlCard>
```

### 문자열이 아닌 값

값은 무엇이든 받습니다. 상태에는 칩, 사람에는 아바타, 참조에는 링크.

::: fw react

```tsx
<PlDataListItem label="Status">
  <PlChip color="success">Active</PlChip>
</PlDataListItem>
```

`value`와 `children`은 같은 말입니다. 문자열이면 `value`, 마크업이면 `children`을 쓰십시오.

:::

::: fw flutter

```dart
PlDataListItem(label: const Text('Status'), value: const PlChip(child: Text('Active')));
```

:::

## Notes

- 줄은 [`PlTable`](./table)의 컬럼과 달리 **데이터가 아니라 children**입니다. 상세 패널은 한 번 적히고 적힌 순서대로 읽히며, 값마다 모양이 다릅니다. 데이터 배열로 만들면 `render` 함수의 배열이 됩니다.
- 표면을 그리지 않습니다. 상세 패널은 [`PlCard`](../surfaces/card) 안에 놓이고, 시트 안의 시트는 시트 둘입니다.
- `size`와 `density`는 목록에서 와서 모든 줄에 닿습니다. 그래서 패널은 줄마다가 아니라 한 번의 결정입니다.

## Accessibility

- 라벨과 값은 **한 쌍**으로 읽힙니다. 이 컴포넌트가 존재하는 이유 전부이고, `<div>` 격자가 하지 못하는 일입니다.
- `icon`은 장식이고 스크린 리더에서 감춰집니다. 옆의 라벨이 이미 어떤 필드인지 말합니다.
- 라벨은 heading이 아닙니다. 패널에 이름을 붙이는 것은 페이지의 몫입니다. 위의 `<h2>`이거나, 패널이 놓인 region의 `aria-label`입니다.
