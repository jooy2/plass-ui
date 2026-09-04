---
title: PlAppLogo
order: 15
---

# PlAppLogo

<p class="plass-lede">제품의 마크와 그 옆의 이름입니다. 이 컴포넌트의 전부는 <strong>틀 잡기</strong>이고, 기본값이 <code>bare</code>인 이유는 자기 배경을 가지고 그려진 아트워크를 판 위에 올리면 안 되기 때문입니다.</p>

<Demo src="app-logo/hero" :min-height="240" />

::: fw react

```tsx
import { PlAppLogo } from 'plass-ui';

<PlAppLogo shape="plate" name="Acme" render={<a href="/" />}>
  <AcmeGlyph />
</PlAppLogo>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlAppLogo(
  shape: PlAppLogoShape.plate,
  name: const Text('Acme'),
  onPressed: goHome,
  child: const AcmeGlyph(),
);
```

:::

## Props

<PropsTable name="PlAppLogo" />

라이브러리 전체에서 공유 축이 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## shape가 곧 컴포넌트입니다

질문 하나 — 이 아트워크를 어떻게 두를 것인가 — 에 대한 답 셋이고, 기본값은 프로젝트마다 틀리는 바로 그것입니다.

|          |                                                                                 |
| -------- | ------------------------------------------------------------------------------- |
| `bare`   | 준 그대로 그립니다. 높이는 `size`가 정하고 너비는 따라옵니다. **기본값입니다.** |
| `plate`  | 아트워크를 안쪽에 넣은 타일. 모서리는 하우스 radius로 잘립니다.                 |
| `circle` | 같은 타일을 둥글게.                                                             |

**`bare`가 기본인 이유는 대부분의 마크가 이미 틀을 가지고 있기 때문입니다.** 자기 배경, 자기 여백, 또는 제품 이름이 들어간 채로 그려진 마크는 이미 완성된 아트워크입니다. 판 위에 올리면 테두리가 둘이 되고, 원으로 자르면 이름이 반토막 납니다. `plate`와 `circle`은 맨 글리프로 그려진 마크에만 쓰십시오. 그런 마크는 테두리를 받기 전에는 다른 것 옆에 설 수 없습니다.

<Demo src="app-logo/shapes" :min-height="220">

::: fw react

<<< @/.vitepress/demos/app-logo/shapes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/app_logo/shapes.dart

:::

</Demo>

`bare`는 **높이**를 정하고 너비를 따라오게 합니다. 워드마크에 필요한 것이 그것이고, 정사각형이 망가뜨리는 것도 그것입니다. 판은 아트워크를 채우지 않고 타일의 70%쯤으로 넣습니다. 그래야 글리프가 앱 아이콘이 늘 가지는 여백을 가집니다.

## PlAvatar가 아닙니다

닮았지만 다른 질문에 답합니다.

[`PlAvatar`](./avatar)는 **사람이나 사물의 사진**입니다. 언제나 원이거나 fillet이고, 사진이 오지 않으면 뒤에 이니셜이 있습니다. 그릴 것이 늘 있기 때문입니다. `PlAppLogo`는 **제품이 소유한** 아트워크입니다. 지어낼 만한 대체물이 없고, 모양은 이미 누군가 내린 결정입니다. 그래서 여기서는 모양이 prop이고 저기서는 하우스 규칙입니다.

## 예시

### 헤더의 brand 슬롯

로고가 놓이는 흔한 자리이고, `render`를 쓸 만한 이유입니다. 로고는 거의 언제나 첫 페이지로 돌아가는 길입니다.

```tsx
<PlHeader
  brand={
    <PlAppLogo shape="plate" name="Acme" render={<a href="/" />}>
      <AcmeGlyph />
    </PlAppLogo>
  }
/>
```

### 어느 사본인지 말하기

`description`은 이름 아래 한 줄입니다. 환경, 테넌트, 요금제. 스테이징처럼 보여서 프로덕션을 고치는 일을 막는 가장 싼 방법입니다.

```tsx
<PlAppLogo shape="plate" name="Acme" description="Staging" color="warning">
  <AcmeGlyph />
</PlAppLogo>
```

### 글리프가 아니라 그림

::: fw react

`src`를 주면 모양이 요구하는 크기로 `<img>`를 대신 그려 줍니다.

```tsx
<PlAppLogo src="/logo.svg" alt="Acme" />
```

:::

::: fw flutter

마크는 위젯이므로 아트워크를 그리는 무엇이든 됩니다. `PlImage`, `Image.asset`, `CustomPaint`.

```dart
PlAppLogo(semanticLabel: 'Acme', child: Image.asset('assets/logo.png'));
```

:::

## 참고

- `variant`와 `color`는 **판이 있을 때만** 읽습니다. 맨 마크는 제품 자신의 아트워크이고 라이브러리는 거기에 색을 입히지 않습니다.
- 마크의 높이는 `size` 사다리입니다. `md`는 32px로, `md` [header](../layout/header)의 64px 바닥 안에 양옆 여유를 두고 앉습니다.
- 이름은 heading이 아니라 `<span>`입니다. 로고는 제품의 이름을 말하고, 페이지의 heading은 페이지의 이름을 말합니다.

## 접근성

- **`name`이 있으면 마크는 장식**이 되어 접근성 트리에서 빠집니다. 옆의 워드마크가 이미 제품 이름을 말하고 있고, 그림이 그것을 또 말하면 스크린 리더가 이름을 두 번 읽습니다.
- `name`이 없으면 마크가 말합니다. React에서는 `alt`, Flutter에서는 `semanticLabel`입니다. 빈 `alt`는 진짜 답이고 기본값입니다. 그림이 글에 없는 것을 나르지 않는다는 뜻입니다.
- 홈으로 가는 로고라면 그렇게 말해야 합니다. `render={<a href="/" />}`는 그림에 클릭 핸들러를 붙이는 대신 목적지가 있는 진짜 링크로 만듭니다.
