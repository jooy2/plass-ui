---
title: PlAnchor
order: 9
---

# PlAnchor

<p class="plass-lede">읽는 사람을 따라 페이지를 내려가는 목차입니다. 불이 켜지는 것은 화면에 보이는 제목이 아니라, 읽는 선을 마지막으로 지나간 제목입니다.</p>

<Demo src="anchor/hero" :min-height="340" />

::: fw react

```tsx
import { PlAnchor } from 'plass-ui';

<PlAnchor
  label="On this page"
  offset={64}
  items={[
    { href: '#overview', label: 'Overview' },
    { href: '#install', label: 'Install' },
    { href: '#options', label: 'Options', depth: 1 }
  ]}
/>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlAnchor(
  controller: _scroll,
  label: const Text('On this page'),
  items: <PlAnchorItem>[
    PlAnchorItem(target: _overview, label: const Text('Overview')),
    PlAnchorItem(target: _install, label: const Text('Install')),
    PlAnchorItem(target: _options, label: const Text('Options'), depth: 1),
  ],
);
```

:::

## Props

<PropsTable name="PlAnchor" />

### PlAnchorItem

<PropsTable name="PlAnchorItem" />

라이브러리 전체에서 공유 축이 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## 추적이 곧 컴포넌트입니다

링크 목록이야 누구나 그립니다. 한 번 적어 둘 만한 것은 **어느 것에 불이 켜지는가**이고, 그 규칙은 뻔한 쪽이 아닙니다.

> 불이 켜지는 줄은 읽는 선을 **마지막으로 지나간** 제목입니다.

"보이는 제목"이 아닙니다. 제목 셋이 한 화면에 함께 있을 수 있고, 읽는 사람이 들어와 있는 것은 그중 이미 위로 지나간 가장 아래의 제목입니다. 추적이 `IntersectionObserver`가 아니라 측정인 이유가 그것입니다. observer는 "보이는가"에 답하고, 여기서 묻는 것은 "마지막으로 지나친 것이 무엇인가"입니다.

양 끝은 따로 말해야 하고, 둘 다 직접 만들면 놓치는 부분입니다.

- **첫 제목 위에서는 아무것도 켜지지 않습니다.** 아직 어떤 섹션에도 도달하지 않았고, 도착 전에 첫 줄을 켜는 것은 사용자가 어디에 있는지에 대한 잘못된 주장입니다.
- **맨 아래에서는 측정과 상관없이 마지막 줄이 켜집니다.** 짧은 마지막 섹션은 선까지 올라오지 못하므로, 이것이 없으면 목록은 사용자가 가장 눈여겨보는 자리에서 꺼져 버립니다.

## offset

읽는 선이 뷰포트 위에서 얼마나 내려와 있는지입니다. 페이지 위에 고정된 것의 높이입니다.

이것이 없으면 제목이 sticky 헤더 뒤로 사라진 뒤에도 계속 **다음** 제목으로 세어집니다. 그래서 목록이 막대 높이만큼 사용자보다 한 섹션 뒤에 머뭅니다.

```tsx
<PlAnchor offset={64} items={items} />
```

::: fw react

제목의 `scroll-margin-top`은 같은 숫자의 나머지 절반이고, 페이지가 정할 몫입니다. 브라우저가 제목으로 건너뛸 때 제목이 헤더 밑에 들어가는 것을 막아 줍니다.

```css
:target {
  scroll-margin-top: 64px;
}
```

:::

## 무엇을 받는지, 왜 데이터인지

제목들은 **배열**로 들어옵니다. 이 라이브러리의 다른 대부분과 반대입니다. 목차는 생성되는 것이고 — Markdown 파일에서, CMS에서, 문서 자신의 제목들에서 — 그것을 만드는 쪽은 문서 순서대로 된 평평한 목록에 항목마다 레벨을 붙여 내놓습니다.

**평평한 채로 둡니다.** 중첩 목록을 만들려면 그 평평한 목록에서 만들어야 하는데, 실제 문서는 레벨을 건너뜁니다. 그러면 중첩은 아무도 쓰지 않은 모양에 대한 추측이 됩니다. 깊이는 들여쓰기가 나르고, 읽는 순서는 문서 자신의 것입니다.

::: fw react

항목은 fragment를 가리킵니다. `href: '#install'`이고, 거기 적힌 `id`가 목록이 재는 대상입니다. `id`가 없는 제목은 추적할 수 없고, 예외를 던지는 대신 건너뜁니다.

:::

::: fw flutter

항목은 제목 위젯의 `GlobalKey`를 가리킵니다. Flutter 화면에는 가리킬 URL이 없기 때문입니다. 여기서 추적하는 것은 render object의 위치이고, 그것을 잡는 유일한 손잡이가 key입니다. 줄을 누르면 `Scrollable.ensureVisible`을 부릅니다.

:::

## Examples

### 다른 것이 모는 경우

`active`가 추적을 대신합니다. 섹션이 한 페이지의 부분이 아니라 각각의 페이지인 목록에 씁니다.

```tsx
<PlAnchor items={items} active={route.hash} />
```

### 본문 옆에

흔한 배치입니다. 페이지와 함께 스크롤되지 않는 sticky 칸입니다.

```tsx
<PlFlex spacing={8} alignItems="start">
  <article>…</article>
  <PlAnchor className="sticky top-20 w-56" items={items} offset={64} />
</PlFlex>
```

## Notes

- 한 프레임에 많아야 한 번 측정합니다. 스크롤은 페이지가 그려지는 것보다 훨씬 자주 일어나고, 두 페인트 사이에 답이 바뀔 수는 없습니다.
- 줄은 줄바꿈 대신 잘립니다. 목차는 읽는 것이 아니라 훑는 것이고, 두 줄짜리 항목은 훑기를 가능하게 하는 리듬을 깹니다.

## Accessibility

::: fw react

- 이름이 붙은 `<nav>`입니다. 그래서 페이지의 landmark 목록에 이름 없는 내비게이션이 하나 더 늘지 않습니다. `navLabel`이 그 이름을 정합니다.
- 켜진 줄은 `aria-current="location"`을 답니다. 문서 **안에서** 사용자가 어디 있는지이고, 그 값이 존재하는 이유가 정확히 그것입니다. 여러 페이지 중 현재 페이지를 뜻하는 `page`가 아닙니다.
- 줄은 진짜 fragment를 가진 진짜 링크입니다. 새 탭으로 열 수 있고, 복사할 수 있고, JavaScript가 꺼져 있어도 따라갈 수 있습니다.

:::

::: fw flutter

- 목록은 이름이 붙은 컨테이너이고, 켜진 줄에는 `selected`가 붙습니다. `aria-current="location"`의 Dart 쪽 대응입니다.

:::

- 색이 위치를 나르는 유일한 수단은 아닙니다. 켜진 줄은 앞쪽 모서리의 선과 더 굵은 글자도 함께 가집니다.
