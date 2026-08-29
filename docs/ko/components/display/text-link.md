---
title: PlTextLink
order: 2
---

# PlTextLink

<p class="plass-lede">문장 안에, 또는 홀로 놓이는 링크입니다. 표면도 높이도 없고, 요청하지 않으면 색도 없습니다. 가진 것은 "여기로 간다"는 뜻으로 이미 모두가 아는 표시 하나입니다.</p>

<Demo src="text-link/hero" :min-height="120" />

::: fw react

```tsx
import { PlTextLink } from 'plass-ui';

<PlTextLink href="/pricing">the colour reference</PlTextLink>;
<PlTextLink href="https://www.w3.org/TR/WCAG22/" newTab>
  WCAG 2.2
</PlTextLink>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlTextLink(onPressed: () => go('/pricing'), child: const Text('the colour reference'));
PlTextLink(onPressed: openWcag, external: true, child: const Text('WCAG 2.2'));
```

:::

## Props

<PropsTable name="PlTextLink" />

::: fw react

네이티브 `<a>` 속성은 그대로 전달됩니다. `color`는 위 표의 `color`와 충돌해서 제외됩니다. `rel`은 호출하는 쪽의 값을 덮어쓰지 않고 **합치는** 유일한 항목입니다 — 아래를 보세요.

:::

::: fw flutter

`href`가 없고, 그것이 진짜 차이입니다. Flutter에는 자체 내비게이션이 없으므로 링크가 _어디로_ 가는지는 앱이 정하고, `onPressed`가 그것을 정하는 자리입니다. 빼면 링크는 아무 일도 하지 않게 되는데, 이미 보고 있는 페이지로 가는 링크가 바로 그래야 합니다.

:::

라이브러리 전체에서 공유 축(`size` `color`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### underline

기본값이 `always`인 이유는 `color`에 있습니다. 링크는 요청하지 않으면 색 계열을 입지 않으므로, 밑줄까지 끄면 주변 문장과 구분할 것이 아무것도 남지 않습니다.

hover는 **글자** 색은 일부러 건드리지 않고 밑줄만 진하게 합니다. 문단 속 링크가 포인터 아래에서 색이 바뀌면, 읽고 있던 줄에서 눈이 끌려 나갑니다.

밑줄은 쉬는 동안 글자 색의 45%로 놓였다가 포인터 아래에서 전부가 됩니다. 그래서 물려받은 색에서도 강조색에서도 똑같이 동작합니다.

<Demo src="text-link/underline" :min-height="160">

::: fw react

<<< @/.vitepress/demos/text-link/underline.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_link/underline.dart

:::

</Demo>

### color

라이브러리의 다른 모든 컨트롤과 달리 기본값이 **없습니다**. 이미 색이 칠해진 채로 도착하는 컴포넌트는 페이지가 되돌려야 하는 컴포넌트이고, 문단 속 링크는 보통 그 문단의 색에 밑줄만 그은 것입니다.

<Demo src="text-link/colors" :min-height="100">

::: fw react

<<< @/.vitepress/demos/text-link/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_link/colors.dart

:::

</Demo>

### <Fw react="newTab" flutter="external" />

발밑에서 무언가 바뀌는 것은 링크에서 미리 볼 수 없는 유일한 일입니다.

::: fw react

그래서 `newTab`은 세 가지를 함께 합니다 — `target="_blank"`, 새 페이지가 `window.opener`로 되돌아오지 못하게 막는 `rel`, 그리고 표시. 표시는 눈에는 화살표로, 스크린리더에는 라벨 뒤에 붙는 한 마디로 전달됩니다.

`rel`은 덮어쓰지 않고 합칩니다. 직접 `rel`을 쓰는 흔한 이유는 `nofollow`나 `sponsored`인데 그것은 SEO 결정이고, 단순한 덮어쓰기였다면 새 탭으로 열리는 링크에서 보호 장치가 조용히 사라졌을 것입니다.

:::

::: fw flutter

그래서 `external`은 두 가지를 합니다. 상자를 빠져나가는 화살표를 그리고, 스크린리더가 라벨 뒤에 읽는 힌트를 붙입니다. `target`도 `rel`도 없습니다 — 여기서 브라우징 컨텍스트를 여는 것은 아무것도 없으니 막을 opener도 없고, "앱을 떠난다"가 무엇인지는 앱의 몫이며 `onPressed`가 그 자리입니다.

:::

### icon

::: fw react

`true`는 `newTab`일 때 상자를 빠져나가는 화살표를, 아니면 체인을 그립니다. `false`는 아무것도 그리지 않고, 노드를 주면 그것이 글리프를 대신합니다. 생략하면 `newTab`을 따릅니다 — 창을 가져가는 링크는 그렇다고 말해야 하고, 조용한 쪽은 호출하는 쪽이 요청해야 합니다.

:::

::: fw flutter

`showIcon`이 표시를 그릴지를, `icon`이 무엇을 그릴지를 정합니다. 생략하면 `showIcon`은 `external`을 따릅니다 — 독자를 앱 밖으로 데려가는 링크는 그렇다고 말해야 하고, 조용한 쪽은 호출하는 쪽이 요청해야 합니다. `bool`이 아니라 `bool?`인 이유가 그것입니다.

:::

`startIcon`은 나머지 절반이자 의견 없는 쪽입니다. 라벨 **앞**의 표시 — 파비콘, 파일 종류, 자물쇠 — 이고, 넣지 않으면 아무것도 그리지 않습니다. 위의 `icon`과 다른 점이 바로 그것입니다. 그쪽은 링크가 *어디로 가는지*에 대한 것이라 앱을 떠나는 링크에서는 스스로 켜집니다.

글리프는 컨트롤 안의 아이콘이 쓰는 `1.2em`이 아니라 `0.95em`으로 놓입니다. 이것은 문장 안에 앉아 있고, 줄 높이만 한 아이콘은 주변 단어들을 벌려 놓습니다. 두 표시 모두 같은 크기이고 라벨에서 같은 0.25em만큼 떨어지므로, 어느 쪽을 달아도 링크는 여전히 문단 속의 한 단어로 읽힙니다.

<Demo src="text-link/icons" :min-height="160">

::: fw react

<<< @/.vitepress/demos/text-link/icons.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_link/icons.dart

:::

</Demo>

### size

이것도 기본값이 없습니다. 문장 속 링크는 그 문장의 크기입니다. 홀로 서는 링크에만 지정하세요.

<Demo src="text-link/sizes" :min-height="200">

::: fw react

<<< @/.vitepress/demos/text-link/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_link/sizes.dart

:::

</Demo>

::: fw react

### render

밑줄과 표시, focus ring을 그대로 둔 채 라우터의 `Link`를 씁니다. `href`도 함께 전달되므로 한 번만 씁니다.

```tsx
import NextLink from 'next/link';

<PlTextLink href="/pricing" render={<NextLink href="/pricing" />}>
  Pricing
</PlTextLink>;
```

:::

## Accessibility

::: fw react

- 진짜 `<a href>`로 렌더링됩니다. 브라우저의 링크 목록에 들어가고, <kbd>Enter</kbd>로 따라가며, 새 탭으로 열거나 주소를 복사할 수 있습니다.
- `newTab`은 그려지기만 하는 것이 아니라 읽힙니다. 화살표는 볼 수 있는 사람에게, 화면에 보이지 않는 문구는 나머지 모두에게 새 탭이라고 말합니다.
- 주된 신호는 밑줄이고, 색이 유일한 신호였던 적은 없습니다. `underline="none"`은 주변이 이미 무엇인지 말해 주는 링크를 위한 것입니다.
- focus ring은 `:focus-visible`에서 나타나고 작은 모서리 반경을 가지므로, 줄 상자 전체가 아니라 라벨을 따라갑니다.
- 컴포넌트의 클래스는 스타일시트에서 두 번 겹쳐 씁니다(`.plass-link.plass-link`). 호스트 페이지의 `.prose a`나 `.vp-doc a`가 링크에서 색과 밑줄을 빼앗아 가지 못하게 하기 위해서입니다.

:::

::: fw flutter

- 버튼이 아니라 링크로 알려집니다. 스크린리더의 링크 목록에 들어가는 것이 그 차이가 사 주는 것입니다.
- <kbd>Enter</kbd>와 넘패드 <kbd>Enter</kbd>가 링크를 따라갑니다. <kbd>Space</kbd>는 일부러 아닙니다 — 링크는 버튼이 아니고, 스페이스바는 스크롤하는 쪽의 것입니다.
- `external`은 그려지기만 하는 것이 아니라 읽힙니다. 화살표는 볼 수 있는 사람에게, 힌트는 나머지 모두에게 앱을 떠난다고 말합니다.
- 주된 신호는 밑줄이고, 색이 유일한 신호였던 적은 없습니다. `PlTextLinkUnderline.none`은 주변이 이미 무엇인지 말해 주는 링크를 위한 것입니다.
- focus ring은 CSS가 `:focus-visible`이라고 부르는 것 — 키보드가 링크에 닿았을 때에만 나타나고 포인터 클릭에는 절대 나타나지 않습니다 — 이고, 작은 모서리 반경으로 라벨을 따라갑니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `href` | `onPressed` | Flutter에는 자체 내비게이션이 없습니다. 링크가 어디로 가는지는 앱의 몫이고, 여기가 그것을 정하는 자리입니다. |
| `newTab`, `target`, `rel` | `external` | 여기서 브라우징 컨텍스트를 여는 것은 없으니 막을 opener도 없습니다. 남는 것은 독자에게 중요한 부분 — 표시와 알림입니다. |
| 노드이거나 boolean인 `icon` | `icon`과 `showIcon` | Dart에는 `null`도 위젯도 아닌 값이 없으니, "그릴까"와 "무엇을"이 두 개의 질문이 됩니다. |
| `render` | — | Flutter에는 요소를 바꿔 끼우는 수단이 없습니다. 라우터의 내비게이션은 `onPressed`에서 부릅니다. |
| `.plass-link.plass-link` | — | 이겨야 할 호스트 스타일시트가 없습니다. |
| `children` | `child` | Flutter의 이름입니다. |

:::
