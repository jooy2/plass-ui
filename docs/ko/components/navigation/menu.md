---
title: PlMenu
order: 3
---

# PlMenu

<p class="plass-lede">무언가를 눌렀을 때 나타나는 동작 목록입니다. roving 포커스, 타이프어헤드, 안전 삼각형이 딸린 서브메뉴, 그리고 그 모든 것이 스크린 리더에게 뜻을 갖게 하는 role까지.</p>

<Demo src="menu/hero" :min-height="200" />

::: fw react

```tsx
import { PlButton, PlMenu, PlMenuItem, PlMenuSeparator } from 'plass-ui';

<PlMenu trigger={<PlButton variant="glass">Actions</PlButton>}>
  <PlMenuItem shortcut="⌘X">Cut</PlMenuItem>
  <PlMenuItem shortcut="⌘C">Copy</PlMenuItem>
  <PlMenuSeparator />
  <PlMenuItem color="danger">Delete</PlMenuItem>
</PlMenu>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlMenu(
  items: <PlMenuEntry>[
    PlMenuItem(label: 'Cut', shortcut: '⌘X', onPressed: cut),
    PlMenuItem(label: 'Copy', shortcut: '⌘C', onPressed: copy),
    const PlMenuSeparator(),
    PlMenuItem(label: 'Delete', color: PlassColor.danger, onPressed: remove),
  ],
  trigger: (BuildContext context, VoidCallback open, bool isOpen) =>
      PlButton(onPressed: open, variant: PlassVariant.glass, child: const Text('Actions')),
);
```

:::

## Props

<PropsTable name="PlMenu" />

### PlMenuItem

<PropsTable name="PlMenuItem" />

### PlMenuCheckboxItem과 PlMenuRadioItem

<PropsTable name="PlMenuCheckboxItem" />

### PlMenuSubmenu

<PropsTable name="PlMenuSubmenu" />

### PlContextMenu

<PropsTable name="PlContextMenu" />

`variant`은 없습니다. `PlModal`에 없는 것과 같은 이유입니다 — 세 재질은 "이 표면이 페이지에 대해 얼마나 자기를 주장하는가"에 답하는데, 포인터를 가져간 팝업은 이미 그 질문에 답했습니다. `elevation`도 없습니다. 메뉴는 진짜로 떠 있고, 그것이 사다리가 존재하는 유일한 경우라서 맨 윗단에 고정되어 있습니다. 라이브러리 전체에서 공유 축이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### items 배열

::: fw react

**데이터가 아니라 조합입니다** — [`PlSelect`](../inputs/select)의 정반대이고, 의도한 것입니다.

select의 옵션은 호출자가 이미 가진 목록에서 나온 값이라 데이터입니다. 메뉴의 행은 **코드**입니다 — 각각 다른 핸들러, 다른 아이콘, 때로는 링크, 때로는 서브메뉴. 데이터로 넘기면 행이 취할 수 있는 모양마다 변형을 둔 `items` 타입이 되는데, 그것은 판별 유니온으로 쓴 컴포넌트 트리입니다.

:::

::: fw flutter

**조합이 아니라 설명입니다** — 두 패키지가 컴포넌트의 모양에 대해 의견이 갈리는 유일한 자리입니다.

강제된 것입니다. React가 조합할 수 있는 이유는 Base UI가 행이 쓰인 DOM을 읽기 때문입니다. 누가 목록을 건네주지 않아도 행을 찾고, 세고, roving 강조를 옮기고, 타이프어헤드를 맞춰 봅니다. 여기에는 걸어 다닐 트리가 없어서 메뉴에게 말해 주어야 합니다 — `PlAccordion`, `PlTabs`, `PlSelect`가 모두 설명을 받는 것과 같은 이유입니다.

`PlMenuEntry`는 판별자를 단 클래스 하나가 아니라 **sealed** 계층입니다. 그래야 행이 서로 다른 *종류*의 것이 되고, 그 위의 switch가 검사를 받습니다.

:::

<Demo src="menu/rows" :min-height="200">

::: fw react

<<< @/.vitepress/demos/menu/rows.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/menu/rows.dart

:::

</Demo>

### 행의 color

행은 자기 색 가족을 부를 수 있습니다 — 삭제하는 행에 `danger`. 그리고 슬롯을 행에서 다시 선언하기 때문에, 색조 · 얇은 선 · 글자가 하나만 파랗게 남는 일 없이 한꺼번에 넘어갑니다.

기본값 옆에 클래스를 덧붙이는 대신 분기합니다. 한 요소에 붙은 명시도가 같은 Tailwind 유틸리티 둘은 쓴 순서가 아니라 생성된 스타일시트 안의 순서로 승부가 나므로, 덧붙인 강조색은 어떤 빌드에서는 아무 일도 하지 않고 어떤 빌드에서는 동작했을 것입니다.

### 그룹과 구분선

그룹의 라벨은 행이 아니라 제목입니다. 고를 수 없고, 타이프어헤드에도 잡히지 않으며, Base UI가 그 아래 행들과 연결해 줍니다.

<Demo src="menu/groups" :min-height="200">

::: fw react

<<< @/.vitepress/demos/menu/groups.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/menu/groups.dart

:::

</Demo>

### 체크와 선택

체크 행은 틱으로, 라디오 행은 점으로 표시됩니다. `PlCheckbox`와 `PlRadioGroup`이 다른 모든 곳에서 하는 것과 같은 구분입니다 — 틱은 "그리고", 점은 "대신에".

둘 다 골랐을 때 **열린 채로 남는 것**이 기본입니다. 평범한 행의 기본값 `true`와 반대입니다. 체크할 것들의 목록은 하나보다 많이 체크하는 목록이기 때문입니다.

::: fw flutter

라디오 *그룹*은 없습니다. 이 패키지의 모든 입력이 controlled이므로, `PlMenuRadioItem`은 자기가 고른 것인지를 듣고 눌렸다는 사실을 보고합니다. 값을 쥔 그룹은 라이브러리에서 보고하고 잊지 않는 유일한 것이 되었을 것입니다.

:::

<Demo src="menu/selection" :min-height="240">

::: fw react

<<< @/.vitepress/demos/menu/selection.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/menu/selection.dart

:::

</Demo>

### 서브메뉴

서브메뉴를 여는 행은 다른 모든 항목과 같은 행이고, 셰브런을 하나 달고 있을 뿐입니다. 호버로, <kbd>Enter</kbd>로, 그리고 그쪽을 가리키는 화살표 키로 열립니다. 대각선으로 손을 뻗어도 닫히지 않습니다 — Base UI가 포인터에서 팝업까지의 안전 삼각형을 추적합니다.

중첩에는 제한이 없습니다. 서브메뉴는 자식을 그 자체가 메뉴인 팝업 안에 렌더링하므로, 서브메뉴의 서브메뉴에 다른 컴포넌트가 필요하지 않습니다.

<Demo src="menu/submenu" :min-height="220">

::: fw react

<<< @/.vitepress/demos/menu/submenu.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/menu/submenu.dart

:::

</Demo>

### size와 density

`size`는 팝업의 반경, 타입 스케일, 그리고 행 패딩 사다리를 정합니다. `density`는 패딩만 건드립니다.

행은 시트 트랙이 아니라 자기 패딩 트랙을 씁니다. `PlList`의 행은 다른 무언가가 너비를 정한 시트를 가로지르지만, 메뉴의 행은 가장 긴 라벨만큼만 넓은 팝업 안에 있습니다. 시트 트랙의 `px-5`는 "Cut"이라고 적힌 메뉴에 40px를 더하고, 그렇게 다섯 줄짜리 메뉴가 다이얼로그만큼 넓어집니다.

<Demo src="menu/sizes" :min-height="160">

::: fw react

<<< @/.vitepress/demos/menu/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/menu/sizes.dart

:::

</Demo>

::: fw react

### PlContextMenu

버튼이 아니라 오른쪽 클릭이나 길게 누르기로 열리는 같은 메뉴입니다.

행을 `content`로, 영역을 `children`으로 받습니다. `PlMenu`가 아니라 `PlTooltip`의 모양인데, 여기서 트리거는 넘겨주는 요소 하나가 아니라 페이지의 한 영역이고, 감싸이는 것이 바로 그 영역이기 때문입니다. 팝업은 앵커가 아니라 포인터 위치에 놓이고, 길게 누르기가 있어야 터치 화면에서 닿을 수 있습니다.

<Demo src="menu/context" :min-height="200" :flutter="false">

<<< @/.vitepress/demos/menu/context.tsx

</Demo>

:::

## Accessibility

::: fw react

- Base UI의 Menu 위에 있습니다. 메뉴를 떠다니는 `<div>` 목록이 아니라 메뉴로 만드는 것 전부를 그쪽이 맡습니다 — `menu`와 `menuitem` role, 화살표 키의 roving 포커스, <kbd>Home</kbd>과 <kbd>End</kbd>, 타이프어헤드, <kbd>Esc</kbd>, 바깥 클릭으로 닫기, 그리고 트리거로 포커스 되돌리기.
- `href`가 있는 행은 진짜 `<a>`입니다. 링크가 아닌 링크들의 메뉴는 새 탭으로 열 수도, 복사할 수도 없고, 스크린 리더에게는 그 하나하나에 대해 틀린 말을 합니다.
- 행에는 포커스 링이 없습니다. Base UI가 강조된 행 자체로 포커스를 옮기므로, 링이 있으면 화살표를 누를 때마다 팝업 안에 사각형이 그려집니다. 색조가 포커스 표시이고, 그래서 마우스가 받는 것과 같은 표시가 됩니다.
- 행에 불이 들어오는 기준은 `:hover`가 아니라 `data-highlighted`입니다. 그래서 키보드와 포인터가 같은 행에 불을 켭니다.
- 비활성 행도 목록에 남고 타이프어헤드에도 잡힙니다. 쓸 수 없을 때 사라지는 행은 길이가 바뀌는 메뉴입니다.
- 팝업은 **불투명도만** 애니메이션합니다. 미끄러져 들어오는 메뉴는 이미 손을 뻗고 있던 행을 옮겨 버리고, 그것이 메뉴가 절대 해서는 안 되는 단 하나입니다.

:::

::: fw flutter

- 팝업이 떠 있는 동안 포커스는 **트리거**에 남습니다. `PlSelect`가 하는 것과 같고 이유도 같습니다 — 행은 오버레이에 그려지고, 함께 들려 올라간 포커스 스코프는 그 키를 어떻게 다룰지 아는 위젯에서 키보드를 빼앗아 갑니다. 화살표 · `Home` · `End` · `Esc` · `Enter` · 타이프어헤드가 모두 거기에 묶여 있습니다.
- 포인터는 화살표 키가 옮기는 것과 같은 강조를 옮깁니다. 그래서 마우스와 키보드가 두 행이 아니라 한 행에 불을 켜고, 바깥 메뉴의 행으로 옮겨 가는 것이 옆에 열려 있던 서브메뉴를 닫습니다.
- 행은 이름과 동작을 든 버튼 노드입니다. 체크된 행은 **checked**로, 고른 행은 **상호 배타적 집합 안에서 selected**로 표시됩니다. 안에 그려진 것은 전부 제외되므로 글리프가 읽을 것 하나를 더 만들지 않습니다.
- 서브메뉴를 여는 화살표는 쓰기 방향을 따릅니다. RTL에서는 반대로 움직입니다.
- 비활성 행도 목록에 남고 타이프어헤드에도 잡힙니다. 쓸 수 없을 때 사라지는 행은 길이가 바뀌는 메뉴입니다.

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| 조합된 행 | `items: List<PlMenuEntry>` | Base UI는 행이 쓰인 DOM을 읽습니다. 여기에는 걸어 다닐 트리가 없어서 메뉴에게 무엇을 들고 있는지 말해 주어야 합니다. |
| 행의 `children` | `String`인 `label` | 그려지고, 안내되고, 타이프어헤드가 맞춰 보는 대상입니다. 셋 다 될 수 있는 것은 문자열뿐입니다. |
| `PlMenuRadioGroup` | `PlMenuRadioItem.selected` | 이 패키지의 모든 입력이 controlled입니다. 값을 쥔 그룹은 그렇지 않은 유일한 것이 되었을 것입니다. |
| 요소인 `trigger` | 빌더인 `trigger` | 메뉴를 여는 콜백과 열려 있는지를 함께 받습니다. 열린 동안 켜져 있는 트리거에 필요한 것이 그것입니다. |
| 행의 `href` | — | 링크 요소도 없고 Flutter 앱을 크롤링하는 것도 없습니다. 라우터를 부르는 자리는 `onPressed`입니다. |
| `modal` | — | 팝업은 화면 위에 덮이는 것이 아니라 앵커에 매달립니다. 바깥에 떨어진 누름이 그것을 닫습니다. |
| `PlContextMenu` | — | 이 패키지가 도는 모든 플랫폼에서 같은 뜻을 갖는 오른쪽 클릭 제스처가 없습니다. 길게 눌러 여는 메뉴는 `onLongPress`와 앱이 직접 여는 `PlMenu`입니다. |
| `className`, `style` | — | 전달할 클래스 목록도 style 속성도 없습니다. |

:::
