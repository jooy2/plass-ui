---
title: PlBottomNavigation
order: 1
---

# PlBottomNavigation

<p class="plass-lede">창의 아래 가장자리에 붙어 있는 목적지 한 줄입니다. 진짜 링크나 버튼으로 된 <code>&lt;nav&gt;</code>이지, 탭 목록이 아닙니다. 한 페이지의 어느 패널을 보여 주는가가 아니라 페이지 <em>자체</em>를 바꾸기 때문입니다.</p>

<Demo src="bottom-navigation/hero" :min-height="220" />

::: fw react

```tsx
import { PlBottomNavigation, PlBottomNavigationItem } from 'plass-ui';

<PlBottomNavigation value={where} onValueChange={setWhere} label="Main">
  <PlBottomNavigationItem value="home" icon={<HomeIcon />} href="/">
    Home
  </PlBottomNavigationItem>
  <PlBottomNavigationItem value="search" icon={<SearchIcon />} href="/search">
    Search
  </PlBottomNavigationItem>
</PlBottomNavigation>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlBottomNavigation<String>(
  value: where,
  onChanged: (String next) => setState(() => where = next),
  label: 'Main',
  items: const <PlBottomNavigationItem<String>>[
    PlBottomNavigationItem<String>(value: 'home', label: 'Home', icon: HomeIcon()),
    PlBottomNavigationItem<String>(value: 'search', label: 'Search', icon: SearchIcon()),
  ],
);
```

:::

## Props

<PropsTable name="PlBottomNavigation" />

### PlBottomNavigationItem

<PropsTable name="PlBottomNavigationItem" />

::: fw react

바에는 네이티브 `<nav>` 속성이, 항목에는 네이티브 `<button>` 속성이 그대로 전달됩니다. `color`는 여기서 Plass의 prop이라, `onChange`는 바가 `onValueChange`로 쓰기 때문에 제외됩니다.

:::

::: fw flutter

바는 목적지 타입에 대해 제네릭입니다. 그래서 `value`와 `onChanged`가 `dynamic`이 아니라 타입 검사를 받고, **controlled**입니다. 값을 받고 그것을 대체해야 할 값을 보고합니다. 이 패키지의 다른 모든 입력이 그렇게 동작합니다.

항목은 위젯이 아니라 **설명**입니다. `PlAccordion`과 `PlTable`이 이미 쓰는 관용구이고, 바가 어느 목적지가 현재이고 몇 개가 있는지를 알아야 하는데 `Widget`은 불투명하기 때문입니다.

:::

항목은 자기 `size`도 `color`도 `variant`도 갖지 않습니다. 셋 다 **집합**의 것입니다. 한 번 정하면 모든 목적지에 같은 뜻이 되는 유일한 자리이고, `PlTabs`와 `PlSegmentedButton`이 쓰는 것과 같은 방식입니다. 라이브러리 전체에서 공유 축이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### 링크와 landmark

탭 목록은 키보드 사용자에게 집합 전체에 대한 탭 정지 하나와 그 안의 화살표 키를 빚지고, 스크린 리더에게는 탭마다 패널 하나를 빚집니다. 하단 내비게이션은 그중 어느 것도 하지 않습니다. *페이지*를 바꿉니다. 동작 없이 role만 선언하는 것은 아예 주장하지 않는 것보다 키보드 사용자에게 나쁩니다.

대신 선언하는 것은 `aria-current`이고, 그것이 정직한 진술입니다. 지금 있는 목적지는 여기입니다. `aria-pressed`는 절대 아닙니다. 그것은 토글로 만들어 버립니다.

### 놓이는 자리

::: fw react

`position`의 기본값은 레이아웃 컴포넌트가 쓸 `static`이 아니라 `fixed`입니다. 하단 내비게이션이란 바로 그것이기 때문입니다. 페이지가 무엇을 하든 창의 아래 가장자리에 붙들려 있는 것. `sticky`는 스크롤되는 패널 안에서의 같은 것이고, `static`은 흐름 안에 놓습니다. 이 페이지의 미리보기가 `static`을 쓰는 이유는, `fixed` 바는 페이지를 떠나 브라우저 창에 붙어 버리기 때문입니다.

창의 가장자리를 가로지르는 바에는 모서리 뒤에 아무것도 없습니다. 그래서 흐름 안에 있는 것만이 모서리가 붙은 시트입니다.

:::

::: fw flutter

`position`은 없습니다. Flutter 화면에는 위젯이 빠져나올 페이지 스크롤이 없기 때문입니다. 바는 앱의 스캐폴드가 하단 슬롯이라 부르는 자리에, 또는 `Stack`의 바닥에 놓입니다. 어느 쪽이든 정하는 것은 바가 아니라 앱입니다.

모서리는 React 빌드와 같은 이유로 각져 있습니다. 화면 가장자리를 가로지르는 바에는 깎을 모서리가 뒤에 없습니다.

:::

### labels

`all`은 모든 목적지에 이름을 붙이고, 앱을 처음 쓰는 사람에게 통하는 유일한 설정입니다. `selected`는 현재 것에만 이름을 붙입니다. `none`은 이름을 하나도 그리지 않습니다.

어느 설정에서도 바의 높이는 그대로입니다. 이름이 붙은 항목이 언제나 가장 높기 때문이고, 바뀌는 것은 줄에서 글자가 차지하는 비율입니다.

**그리지 않는 것이 말하지 않는 것은 아닙니다.** 글리프 하나만으로는 접근 가능한 이름이 없으므로, 그리지 않는 이름은 픽셀과 함께 버리는 대신 잘라낸 상자 안에 문서로 남겨 둡니다.

<Demo src="bottom-navigation/labels" :min-height="360">

::: fw react

<<< @/.vitepress/demos/bottom-navigation/labels.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/bottom_navigation/labels.dart

:::

</Demo>

### variant와 color

시트는 `PlCard`에서와 마찬가지로 절대 물들지 않습니다. 바는 각자의 아이콘을 들고 오는 목적지들을 담고 있고, 그 아래 판에 색을 넣으면 모든 아이콘이 그것을 기준으로 고르지 않은 배경 위에 놓입니다. 색 가족을 나르는 것은 현재인 항목 하나입니다.

<Demo src="bottom-navigation/variants" :min-height="320">

::: fw react

<<< @/.vitepress/demos/bottom-navigation/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/bottom_navigation/variants.dart

:::

</Demo>

### divider, safeArea, elevation

`divider`는 위쪽 가장자리에 얇은 선을 그리고 기본으로 켜져 있습니다. 스크롤되는 페이지 위에 고정된 바는 언제나 그 아래로 내용이 지나가고 있고, 가장자리를 표시하는 것이 없는 반투명 시트는 그 내용의 일부처럼 읽힙니다.

`safeArea`는 휴대폰의 홈 인디케이터에서 줄을 떼어 놓습니다. **시트**는 여전히 화면 바닥까지 닿습니다(움직이는 것은 항목뿐입니다). 인디케이터 위에서 멈춘 바는 유리 아래로 페이지가 비치는 띠를 남기기 때문입니다.

`elevation`은 `0`이고, 평평한 것이 맞습니다. 이 바는 창 한가운데 위에 떠 있는 것이 아니라 창 가장자리에 붙어 있고, 내용과 갈라 주는 것은 `divider`입니다. 페이지 위에 떠 있는 바는 다른 물건이고, 그것은 [`PlFloatingBottomNavigation`](./floating-bottom-navigation)입니다.

### size

<Demo src="bottom-navigation/sizes" :min-height="320">

::: fw react

<<< @/.vitepress/demos/bottom-navigation/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/bottom_navigation/sizes.dart

:::

</Demo>

::: fw react

### href

`href`가 있으면 항목은 진짜 `<a>`입니다. 길게 눌렀을 때 "새 탭에서 열기"가 뜨게 하고 목적지를 상태 표시줄에 보여 주는 것이 그것인데, `router.push`를 부르는 `<button>`은 둘 다 하지 못합니다. `href`가 없으면 `<button>`입니다. 클릭 핸들러를 단 `<div>`는 키보드에 보이지 않기 때문입니다.

비활성화된 링크는 `aria-disabled` 뒤에 살아 있는 링크를 남기는 대신 `href`를 잃습니다. `disabled`는 `<a>`가 될 수 있는 상태가 아니기 때문입니다.

<Demo src="bottom-navigation/links" :min-height="160">

<<< @/.vitepress/demos/bottom-navigation/links.tsx

</Demo>

:::

## Accessibility

- 스크린 리더가 건너뛰거나 지나칠 수 있는 이름 붙은 그룹입니다: <Fw react="&lt;nav&gt; 랜드마크" flutter="시맨틱 컨테이너" />.
- `labels`가 무엇이든 모든 항목에 접근 가능한 이름이 있습니다. **그리지 않는 것이 말하지 않는 것은 아닙니다.**
- 항목은 문서 순서대로 놓이고 각자 하나의 포커스 정지입니다. 목적지의 집합이라면 그래야 하고, roving tab index는 바로 그것을 빼앗습니다.

::: fw react

- 현재 목적지는 `aria-current="page"`를 답니다. `aria-pressed`는 절대 아닙니다. 그것은 토글로 만들어 버립니다.

:::

::: fw flutter

- 현재 목적지는 **selected**로 표시됩니다. Flutter에서 `aria-current`에 가장 가까운 말이자, 항목을 토글로 알리지 않는 말입니다.
- 각 항목은 이름과 탭 동작을 든 버튼 노드이고, 안의 그림은 제외됩니다. 그래서 글리프가 읽을 것 하나를 더 만들지 않습니다.

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `<PlBottomNavigationItem>` children | `items: List<PlBottomNavigationItem<T>>` | 바가 자기 멤버에 대해 판단해야 하는데 `Widget`은 불투명합니다. `PlAccordion`과 `PlTable`이 이미 쓰는 관용구입니다. |
| 항목의 `children` | `String`인 `label` | 그려지는 이름이자 **동시에** 안내되는 이름입니다. 위젯은 앞의 하나만 될 수 있고, 문자열만 둘 다 될 수 있습니다. |
| `value` / `defaultValue` / `onValueChange` | `value` / `onChanged` | Flutter 자체 컨트롤이 controlled이고, 콜백 이름도 그쪽 이름입니다. |
| `position` | — | Flutter 화면에는 빠져나올 페이지 스크롤이 없습니다. 바가 어디 놓일지는 앱의 스캐폴드가 정합니다. |
| `href` | — | 링크 요소도 없고 Flutter 앱을 크롤링하는 것도 없습니다. 라우터를 부르는 자리는 `onChanged`입니다. |
| `aria-current="page"` | selected 플래그 | Flutter의 시맨틱 트리에는 `current`가 없습니다. |
| `className`, `style` | — | 전달할 클래스 목록도 style 속성도 없습니다. |

:::
