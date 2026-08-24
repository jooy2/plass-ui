---
title: 시작하기
order: 1
---

# 시작하기

Plass는 React 컴포넌트 라이브러리입니다. 동작과 접근성은 [Base UI](https://base-ui.com) primitive에서, 스타일은 [Tailwind CSS](https://tailwindcss.com) v4에서 옵니다. Tailwind는 이 패키지를 빌드하는 데 쓰일 뿐, 여러분의 프로젝트에 설치될 필요는 없습니다.

> **0.0.1은 미리 보기입니다.** 지금 공개된 컴포넌트는 [Button](../components/inputs/button)과 [TextField](../components/inputs/text-field) 둘뿐입니다. prop 어휘와 토큰, 빌드 구조는 이후 모든 것이 부어질 틀이라서 지금 읽어 둘 값어치가 있지만, 컴포넌트 목록은 아직 제품을 올릴 만한 상태가 아닙니다.

## 설치

```bash
npm install plass-ui
```

`react`와 `react-dom`은 peer dependency입니다 — **React 18 또는 19**. 프로젝트에 이미 있다면 Plass는 그 사본을 씁니다. 없다면 npm 7 이상이 함께 설치해 줍니다. 나머지는 패키지가 가지고 옵니다.

## 스타일시트 연결하기

앱의 CSS 진입점에 한 줄을 추가합니다.

```css
@import 'plass-ui/styles.css';
```

번들러가 CSS를 처리한다면 진입 모듈에서 import해도 똑같이 동작합니다.

```ts
import 'plass-ui/styles.css';
```

`plass-ui/styles.css`는 **컴파일이 끝난 CSS**입니다. 디자인 토큰(색, radius, elevation, motion), `.plass-gloss` 레이어, 컴포넌트가 쓰는 모든 utility 클래스의 실제 규칙, 그리고 작은 reset이 들어 있습니다. 빌드 설정도, PostCSS 플러그인도, `@source`도 필요 없습니다.

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
| `@import 'plass-ui/tailwind.css'` | 디자인 토큰, `.plass-gloss` 레이어, 패키지를 등록하는 `@source` |

이 경로에서도 `@source`를 직접 쓸 필요는 없습니다. Plass 컴포넌트가 쓰는 클래스는 Tailwind utility이므로 Tailwind가 패키지의 컴파일된 파일을 읽어야 하는데, `plass-ui/tailwind.css`가 자기 안에 `@source '.'`를 선언해 그 일을 대신합니다. `@source`는 자신이 쓰인 파일을 기준으로 경로를 풉니다. 여기서는 `node_modules/plass-ui/dist/`, 즉 그 파일들 바로 옆입니다. 명시적으로 등록된 source는 `node_modules` 안이라도 스캔됩니다. 자동 탐지는 그곳을 건너뜁니다.

이 경로에는 reset이 들어 있지 않습니다. Preflight가 이미 reset이기 때문입니다.

## 컴포넌트 아래에 깔릴 페이지

Plass는 컨트롤과 시트를 그립니다. 여러분의 `<body>`는 칠하지 않고, 여기의 어떤 것도 그걸 요구하지 않습니다. 다만 평평한 흰 페이지 위의 유리 시트는 앞에 세울 것이 없어서, 라이브러리의 모든 반투명 표면이 불투명하게 보이게 됩니다.

정확히 이걸 위한 토큰이 둘 있고, 쓰는 법은 규칙 하나입니다.

```css
body {
  background: linear-gradient(160deg, var(--plass-bg-from) 0%, var(--plass-bg-to) 100%);
  background-attachment: fixed;
  color: var(--plass-fg);
}
```

구조가 있는 배경이면 무엇이든 됩니다 — 사진이든, 메시든, 직접 만든 그러데이션이든. 되지 않는 것은 아무것도 없는 배경입니다.

## 사용하기

```tsx
import { Button } from 'plass-ui';

export default function App() {
  return <Button onClick={() => console.log('clicked')}>Save</Button>;
}
```

## 다크 모드

기본값은 `prefers-color-scheme`을 따릅니다. 강제하려면 상위 요소 아무 곳에나 클래스나 `data-theme`을 두면 됩니다.

```text
<html data-theme="dark">   <!-- 또는 --> <html class="dark">
```

라이트는 `data-theme="light"` 또는 `class="light"`입니다. Tailwind의 관례에 맞추기 위해 `.dark`도 함께 지원합니다.

한 가지는 테마를 따라 **바뀌지 않고**, 그건 의도된 것입니다. 바로 키의 색입니다. [색](../design/color#키의-색은-테마를-따라-바뀌지-않습니다)을 보세요.

## 다음

- [모든 컴포넌트](../components/) — 공개된 전부를 한 페이지에
- [Prop 규칙](../design/prop-conventions) — 공통 prop이 뜻하는 것
- [디자인 언어](../design/design-language) — 표면과 색, 모션이 왜 이렇게 생겼는지

## 브라우저 지원

토큰이 `color-mix()`와 `backdrop-filter`를 씁니다. 2023년 이후의 Chrome, Safari, Firefox를 뜻합니다. `backdrop-filter`가 없는 곳에서는 blur만 빠지고 채움과 hairline, gloss는 그대로 동작합니다. 시트가 유리 대신 평평한 반투명 패널로 보일 뿐입니다.
