---
title: 시작하기
order: 1
---

# 시작하기

Plass는 하나의 디자인 언어를 두 프레임워크로 냅니다. 사이드바에서 쓰는 쪽을 고르세요. 미리보기를 포함해 이 사이트 전체가 그 선택을 따라갑니다.

::: fw react

React 패키지의 동작과 접근성은 [Base UI](https://base-ui.com) primitive에서, 스타일은 [Tailwind CSS](https://tailwindcss.com) v4에서 옵니다. Tailwind는 이 패키지를 빌드하는 데 쓰일 뿐, 여러분의 프로젝트에 설치될 필요는 없습니다.

:::

::: fw flutter

Flutter 패키지는 `package:flutter/widgets.dart`만으로 만들어졌습니다. `material.dart`도 `cupertino.dart`도 import하지 않는데, 여기에는 두 가지 뜻이 있습니다. Material 앱이든 Cupertino 앱이든 맨 `WidgetsApp`이든 두 번째 디자인 시스템을 끌고 들어가지 않고 얹힌다는 것, 그리고 그 두 라이브러리가 프레임워크에서 `material_ui`·`cupertino_ui`로 빠져나가도 영향을 받지 않는다는 것입니다. 런타임 의존성은 하나도 없습니다.

:::

> **두 패키지는 같은 라이브러리를 냅니다** — 같은 일흔네 개 컴포넌트, 같은 prop 어휘, 같은 토큰. 버전은 각각 매겨지므로 npm과 pub.dev의 번호가 늘 같지는 않습니다. [모든 컴포넌트](../components/)를 보세요.

## 설치

::: fw react

```bash
npm install plass-ui
```

`react`와 `react-dom`은 peer dependency입니다 — **React 18 또는 19**. 프로젝트에 이미 있다면 Plass는 그 사본을 씁니다. 없다면 npm 7 이상이 함께 설치해 줍니다. 나머지는 패키지가 가지고 옵니다.

:::

::: fw flutter

```bash
flutter pub add plass_ui
```

**Flutter 3.41 이상**(Dart 3.11)이 필요합니다. 그 밖에 설치할 것은 없습니다. 이 패키지에는 의존성도, 애셋도, 플랫폼 채널도 없습니다.

:::

::: fw react

## 스타일시트 연결하기

앱의 CSS 진입점에 한 줄을 추가합니다.

```css
@import 'plass-ui/styles.css';
```

번들러가 CSS를 처리한다면 진입 모듈에서 import해도 똑같이 동작합니다.

```ts
import 'plass-ui/styles.css';
```

`plass-ui/styles.css`는 **컴파일이 끝난 CSS**입니다. 디자인 토큰(색, radius, elevation, motion), `.plass-glow` 레이어, 컴포넌트가 쓰는 모든 utility 클래스의 실제 규칙, 그리고 작은 reset이 들어 있습니다. 빌드 설정도, PostCSS 플러그인도, `@source`도 필요 없습니다.

### reset에 대하여

`plass-ui/styles.css`에는 컴포넌트가 전제하는 전역 reset이 함께 들어 있습니다. Tailwind의 Preflight를 실제로 필요한 만큼만 잘라낸 것으로 `box-sizing`, form control의 폰트 상속, list marker 제거가 전부입니다. 여러분의 문단과 제목, 링크의 타이포그래피는 건드리지 않습니다.

모든 규칙이 `:where()`로 감싸여 있어 **specificity가 0**입니다. `p { margin: 1rem }` 같은 type selector 하나면 import 순서와 무관하게 이깁니다. reset은 컴포넌트 아래에 깔린 바닥이지, 페이지에 대한 주장이 아닙니다.

### 이미 Tailwind를 쓰고 있다면

프로젝트에 Tailwind v4가 이미 있다면 컴파일된 쪽 대신 토큰 시트를 import하세요. 무엇도 두 번 생성되지 않고, 컴포넌트에 넘긴 `className`이 컴포넌트 자신의 클래스와 올바르게 정렬됩니다.

```css
@import 'tailwindcss';
@import 'plass-ui/tailwind.css';
```

| 줄 | 하는 일 |
| --- | --- |
| `@import 'tailwindcss'` | Tailwind 자체 |
| `@import 'plass-ui/tailwind.css'` | 디자인 토큰, `.plass-glow` 레이어, 패키지를 등록하는 `@source` |

이 경로에서도 `@source`를 직접 쓸 필요는 없습니다. Plass 컴포넌트가 쓰는 클래스는 Tailwind utility이므로 Tailwind가 패키지의 컴파일된 파일을 읽어야 하는데, `plass-ui/tailwind.css`가 자기 안에 `@source '.'`를 선언해 그 일을 대신합니다. `@source`는 자신이 쓰인 파일을 기준으로 경로를 풉니다. 여기서는 `node_modules/plass-ui/dist/`, 즉 그 파일들 바로 옆입니다. 명시적으로 등록된 source는 `node_modules` 안이라도 스캔됩니다. 자동 탐지는 그곳을 건너뜁니다.

이 경로에는 reset이 들어 있지 않습니다. Preflight가 이미 reset이기 때문입니다.

#### 쓰는 컴포넌트만 등록하기

`plass-ui/tailwind.css`는 74개 컴포넌트를 한 번에 등록합니다. 기본값으로는 그게 맞지만, 컴포넌트를 하나만 쓰든 전부 쓰든 똑같이 내는 고정비이기도 합니다. Tailwind는 import 그래프가 아니라 **파일**을 스캔합니다. 빌드 어디에도 `import { PlButton }`과 `PlSelect.js`가 적어 둔 클래스를 이어 주는 연결이 없으므로, CSS를 줄이는 방법은 Tailwind에 파일을 덜 주는 것뿐입니다.

패키지는 그 스캔을 조각으로도 배포합니다. `plass-ui/css/base.css`는 토큰과 모든 컴포넌트가 공유하는 클래스이고, `plass-ui/css/<component>.css`는 컴포넌트 하나를 등록하는 한 줄입니다. 이름은 `dist/components` 아래 폴더 이름과 같습니다.

```css
@import 'tailwindcss';
@import 'plass-ui/css/base.css';
@import 'plass-ui/css/button.css';
@import 'plass-ui/css/text-field.css';
```

컴포넌트를 몇 개만 쓰는 프로젝트라면 통짜 import보다 gzip 기준 약 5 kB 작습니다. 그러면서도 Tailwind pass는 여전히 **한 번**이라 utility가 Tailwind 자신의 순서대로 나옵니다. 74개의 컴파일된 스타일시트가 아니라 더 좁은 스캔으로 배포하는 이유가 이것입니다. 컴파일된 파일을 이어 붙이면 공유 utility가 전부 컴포넌트 전용 utility 앞에 놓이는데, 충돌하는 두 utility 중 어느 쪽이 이기는지는 Tailwind의 정렬이 정합니다.

import한 것보다 적게 등록하는 것이 이 방식에서 유일하게 틀릴 수 있는 지점이고, 틀리면 눈에 보이게 틀립니다. 해당 컴포넌트가 스타일 없이 렌더링됩니다. 헷갈리면 `plass-ui/tailwind.css`가 언제나 정답입니다.

:::

::: fw flutter

## 설정이 없습니다

연결할 스타일시트도, 설치할 provider도 없습니다. 컴포넌트는 가장 가까운 `PlassTheme`에서 토큰을 찾고, 트리에 하나도 없으면 플랫폼의 밝기로 넘어갑니다. 그래서 어느 앱에 그냥 놓은 버튼도 이미 맞는 테마이고, 시스템 스위치를 따라갑니다.

즉 `PlassTheme`은 필수가 아니라 **override**입니다. 플랫폼과 무관하게 한 테마여야 하는 화면에서 꺼내 쓰면 됩니다.

```dart
PlassTheme(
  brightness: Brightness.dark,
  child: const PlButton(child: Text('Save')),
)
```

### 위쪽에 하나만은 필요합니다

네 개의 컴포넌트가 자기를 트리 밖으로 들어 올립니다 — `PlModal`, `PlOverlay`, `PlTooltip`, 그리고 `PlSelect`의 목록. 들어 올려진 표면에는 들어갈 `Overlay`가 필요합니다. `MaterialApp`에도, navigator가 있는 `WidgetsApp`에도 하나 있습니다. 둘 다 아닌 앱은 직접 두면 됩니다.

```dart
WidgetsApp(
  // …
  builder: (BuildContext context, Widget? child) => Overlay.wrap(child: child!),
)
```

들어 올리는 것은 구현 세부가 아니라 요점입니다. 쓰인 자리에 그려진 시트는 자르는 첫 조상에서 잘리고, Plass 페이지에서 그것은 모든 카드입니다.

`PlToast`에는 `Overlay`가 필요 없습니다 — `PlToastProvider`가 이미 스택이 덮어야 할 모든 것 위에 있습니다.

:::

## 컴포넌트 아래에 깔릴 페이지

Plass는 컨트롤과 시트를 그립니다. 여러분의 배경은 칠하지 않고, 여기의 어떤 것도 그걸 요구하지 않습니다. 다만 평평한 흰 페이지 위의 유리 시트는 앞에 세울 것이 없어서, 라이브러리의 모든 반투명 표면이 불투명하게 보이게 됩니다.

정확히 이걸 위한 토큰이 둘 있고, 쓰는 법은 규칙 하나입니다.

::: fw react

```css
body {
  background: linear-gradient(160deg, var(--plass-bg-from) 0%, var(--plass-bg-to) 100%);
  background-attachment: fixed;
  color: var(--plass-fg);
}
```

:::

::: fw flutter

```dart
final tokens = PlassTheme.of(context);

DecoratedBox(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[tokens.bgFrom, tokens.bgTo],
    ),
  ),
  child: ...,
)
```

:::

구조가 있는 배경이면 무엇이든 됩니다 — 사진이든, 메시든, 직접 만든 그러데이션이든. 되지 않는 것은 아무것도 없는 배경입니다.

## 사용하기

::: fw react

```tsx
import { PlButton } from 'plass-ui';

export default function App() {
  return <PlButton onClick={() => console.log('clicked')}>Save</PlButton>;
}
```

:::

::: fw flutter

```dart
import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return PlButton(
      onPressed: () => debugPrint('pressed'),
      child: const Text('Save'),
    );
  }
}
```

:::

::: fw react

## Next.js와 server component

거의 모든 컴포넌트에는 `'use client'`가 이미 붙어 있습니다. 따로 추가할 것은 없고, Next.js App Router의 `page.tsx`나 `layout.tsx` 같은 Server Component에서 그대로 import해 쓰면 됩니다.

```tsx
// app/page.tsx — directive 없는 Server Component
import { PlButton, PlCard } from 'plass-ui';

export default function Page() {
  return (
    <PlCard>
      <PlButton>Save</PlButton>
    </PlCard>
  );
}
```

directive가 해결해 주지 않는 것이 하나 있습니다. Server Component에서 컴포넌트에 함수를 넘기는 일입니다. 이건 이 라이브러리의 제약이 아니라 모든 client component에 적용되는 React의 규칙으로, `onClick`, `onValueChange`, `render`는 전부 함수이고 함수는 server 경계를 넘지 못합니다. `'use client'`가 필요한 파일은 그 함수를 넘기는 파일 — 라이브러리 쪽이 아니라 여러분 쪽입니다.

```tsx
'use client';

import { PlButton } from 'plass-ui';

export function SaveButton() {
  return <PlButton onClick={() => save()}>Save</PlButton>;
}
```

스타일시트는 root layout에서 한 번만 import하고, 배경은 그 layout이 이미 불러오고 있는 global 스타일시트에 두면 됩니다.

```tsx
// app/layout.tsx
import 'plass-ui/styles.css';
```

그 밖에 설정할 것은 없습니다. `transpilePackages`도, `next.config` 항목도, provider도 필요 없습니다. `dist/`는 모든 상대 경로 import에 `.js`가 붙은 컴파일된 ESM이고, 이는 bundler와 Node의 resolver, server render가 모두 똑같이 읽는 형태입니다.

`PlTable`은 예외이고, 의도한 예외입니다. **directive가 없어서 Server Component가 통째로 렌더링합니다.** 이 컴포넌트는 모든 컬럼이 `render` 콜백이라, 위의 규칙을 그대로 적용하면 표가 가장 어울리는 페이지 — 자기 행을 직접 가져오는 페이지 — 에서 쓸 수 없게 됩니다. 클라이언트 쪽에서 부를 때 달라지는 것은 없습니다. 최상단에 `'use client'`가 있는 모듈이 `PlTable`을 import하면, 다른 무엇을 import할 때와 똑같이 client component가 됩니다.

```tsx
// app/invoices/page.tsx — 여전히 Server Component
import { PlTable } from 'plass-ui';

export default async function Page() {
  const rows = await db.invoices();

  return (
    <PlTable
      rows={rows}
      columns={[
        { key: 'ref', header: 'Reference' },
        { key: 'total', header: 'Total', align: 'end', render: (row) => money(row.total) }
      ]}
    />
  );
}
```

> **server component가 없는 곳에서 이 directive는 아무 일도 하지 않습니다.** Vite, Remix, React Router, Astro, 그리고 순수한 `tsc` 빌드는 모듈 최상단의 `'use client'`를 무시합니다. 쓰지 않는 프로젝트가 치르는 비용이 없기 때문에, 필요할 가능성이 있으면 붙이는 쪽을 택했습니다 — 감사를 거쳐 하나씩 골라내지 않고요.

:::

## 다크 모드

::: fw react

기본값은 `prefers-color-scheme`을 따릅니다. 강제하려면 상위 요소 아무 곳에나 클래스나 `data-theme`을 두면 됩니다.

```text
<html data-theme="dark">   <!-- 또는 --> <html class="dark">
```

라이트는 `data-theme="light"` 또는 `class="light"`입니다. Tailwind의 관례에 맞추기 위해 `.dark`도 함께 지원합니다.

:::

::: fw flutter

기본값은 `MediaQuery.platformBrightness`를 따릅니다. 강제하려면 해당 서브트리를 `PlassTheme`으로 감싸면 됩니다.

```dart
PlassTheme(brightness: Brightness.dark, child: ...)
```

:::

한 가지는 테마를 따라 **바뀌지 않고**, 그건 의도된 것입니다. 바로 키의 색입니다. [색](../design/color#키의-색은-테마를-따라-바뀌지-않습니다)을 보세요.

## 다음

- [모든 컴포넌트](../components/) — 공개된 전부를 한 페이지에
- [Prop 규칙](../design/prop-conventions) — 공통 prop이 뜻하는 것
- [디자인 언어](../design/design-language) — 표면과 색, 모션이 왜 이렇게 생겼는지

::: fw react

## 브라우저 지원

토큰이 `color-mix()`와 `backdrop-filter`를 씁니다. 2023년 이후의 Chrome, Safari, Firefox를 뜻합니다. `backdrop-filter`가 없는 곳에서는 blur만 빠지고 채움과 hairline, tint된 그림자, 포인터 glow는 그대로 동작합니다. 시트가 유리 대신 평평한 반투명 패널로 보일 뿐입니다.

:::

::: fw flutter

## 플랫폼 지원

Flutter가 지원하는 모든 플랫폼입니다. 플랫폼별 코드는 없습니다. 컴포넌트는 위임하지 않고 직접 그리므로, 한쪽에만 있는 것도 없습니다.

`glass`는 `BackdropFilter`를 쓰는데, 어느 플랫폼에서든 이 라이브러리에서 가장 비싼 연산입니다. 유리 표면이 수십 개 올라간 화면이라면 측정해 볼 값어치가 있고, 몇 개 정도라면 그렇지 않습니다.

:::
