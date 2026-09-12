---
title: 브라우저 지원
---

# 브라우저 지원

<p class="plass-lede">패키지마다 가장 오래된 어느 브라우저까지 동작하는지, 그 버전을 무엇이 정하는지, 그보다 오래된 브라우저에서는 무엇이 빠지는지 정리했습니다.</p>

::: fw react

## 최소 버전

| 브라우저           | 전체 지원 | 일부 기능 없이 동작 | 지원하지 않음 |
| ------------------ | --------- | ------------------- | ------------- |
| Chrome, Edge       | 111       | 없음                | 110 이하      |
| Firefox            | 128       | 113~127             | 112 이하      |
| Safari, iOS Safari | 16.4      | 없음                | 16.3 이하     |

**전체 지원**은 모든 컴포넌트가 각 페이지에 적힌 대로 보이고 동작한다는 뜻입니다. **일부 기능 없이 동작**은 컴포넌트가 돌아가고 쓸 수도 있지만, [오래된 브라우저에서 빠지는 것](#오래된-브라우저에서-빠지는-것)에 적힌 기능은 없다는 뜻입니다.

Chrome 111과 Safari 16.4는 2023년 3월에, Firefox 128은 2024년 7월에 나왔습니다. Chromium 기반의 다른 브라우저는 자신의 Chromium 버전을 따릅니다. iOS의 Chrome과 Firefox는 Safari 엔진으로 돌아가므로 Safari 행이 그대로 적용됩니다.

두 스타일시트의 기준선은 같습니다. `plass-ui/styles.css`는 이 버전들에 맞춰 컴파일되어 있고, `plass-ui/tailwind.css`를 쓰는 프로젝트는 자기 Tailwind CSS v4로 컴파일하는데, Tailwind CSS v4도 [같은 세 브라우저를 대상](https://tailwindcss.com/docs/compatibility)으로 합니다.

## 기준선을 정하는 것

기준선은 JavaScript가 아니라 CSS가 정합니다. 새 문법은 번들러가 바꿔 쓸 수 있고 없는 함수는 polyfill로 채울 수 있지만, 브라우저에 없는 CSS 기능은 빌드에서 무엇을 더해도 생기지 않습니다.

| 요구 사항 | Chrome | Firefox | Safari | 쓰는 곳 |
| --- | --- | --- | --- | --- |
| `color-mix()` | 111 | 113 | 16.2 | 모든 색 계열의 focus ring, 옅은 채움, 가장자리, tint된 그림자 |
| Base UI | 111 | 113 | 16.4 | 인터랙티브 컴포넌트의 동작과 접근성 |
| Tailwind CSS v4 | 111 | 128 | 16.4 | 컴파일된 유틸리티와 유틸리티가 읽는 테마 값 |

**넘을 수 없는 선은 `color-mix()`입니다.** 이 함수가 없는 브라우저에서는 해당 토큰을 읽는 속성이 전부 기본값으로 돌아갑니다. focus ring이 hover 채움, 색 있는 가장자리, tint된 그림자와 함께 사라지고, 키보드로 쓰는 사람은 focus가 어디 있는지 알 수 없게 됩니다.

[Base UI](https://base-ui.com/react/overview/about)는 현재 메이저 버전을 낼 때 Baseline Widely Available이던 브라우저를 지원합니다. Safari 16.2와 16.3에는 `color-mix()`를 비롯해 필요한 CSS 기능이 다 있지만 그 범위 밖이어서, Safari에는 일부 기능 없이 동작하는 버전이 없습니다.

Tailwind CSS v4의 대상은 Firefox 128이고, 컴파일된 유틸리티에는 그보다 오래된 Firefox를 위한 대체 규칙이 들어 있습니다. 그래도 Firefox 113~127에서 빠지는 것은 다음 절에 있습니다.

JavaScript는 기준선보다 한참 낮습니다. `dist/`와 Base UI, React의 JavaScript는 Chrome 91, Firefox 79, Safari 14.1보다 새 문법을 쓰지 않습니다.

## 오래된 브라우저에서 빠지는 것

Firefox 113~127에서는 아래 기능 없이 컴포넌트가 동작합니다.

| 기능 | Firefox | 없을 때 |
| --- | --- | --- |
| `:has()` | 121 | `PlTextField`, `PlSelect`, `PlCombobox`, `PlNumberField`, `PlRating`과 picker 필드(`PlDatePicker`, `PlDateRangePicker`, `PlDateTimePicker`, `PlTimePicker`, `PlColorPicker`, `PlTreeSelect`)에 focus ring이 그려지지 않습니다. focus는 그대로 받고 ring만 없습니다. |
| `lh` 단위 | 120 | checkbox의 체크 표시, radio의 점, alert의 아이콘처럼 label 옆에 놓인 아이콘이 label 첫 줄의 가운데보다 조금 위에 놓일 수 있습니다. |
| `Intl.Segmenter` | 125 | [`PlAnimateTyping`](./components/transitions/animate-typing)이 코드 포인트 하나씩 나아가므로, 코드 포인트 여러 개로 된 이모지가 조각으로 나타납니다. |
| `@property` | 128 | [`PlAnimateLighting`](./components/transitions/animate-lighting)의 빛이 가장자리를 따라 돌지 않고 제자리에 있습니다. |

첫 행이 키보드 사용자에게 가장 큰 영향을 줍니다. ring이 사라지는 필드가 바로 그들이 입력하는 필드이기 때문입니다. 키보드로도 문제없이 써야 하는 애플리케이션이라면 Firefox 121을 최소 버전으로 잡으세요.

## 있는 곳에서만 쓰는 새 기능

전체 지원 범위 안의 브라우저에도 없는 기능이 몇 가지 있습니다. 브라우저에 있을 때만 쓰고, 없는 브라우저에서는 마지막 열처럼 동작합니다.

| 기능 | Chrome | Firefox | Safari | 쓰는 곳 | 없을 때 |
| --- | --- | --- | --- | --- | --- |
| `animation-timeline` | 115 | 아직 없음 | 26 | 트랜지션 효과의 `timeline="view"`. 스크롤 위치를 따라갑니다 | `timeline`이 없을 때처럼 `duration`에 맞춰 재생됩니다 |
| `hidden="until-found"` | 102 | 139 | 26.2 | [`PlAccordion`](./components/surfaces/accordion)과 [`PlCollapsible`](./components/surfaces/collapsible)의 `hiddenUntilFound`. 페이지 내 검색이 닫힌 패널을 엽니다 | 닫힌 패널 안의 글은 검색되지 않습니다 |
| `Intl.Locale` 주 정보 | 99 | 153 | 15.4 | 달력이 locale의 한 주 시작 요일로 시작합니다 | 컴포넌트나 [`PlassProvider`](./guide/defaults)에 `weekStartsOn`을 주지 않으면 일요일로 시작합니다 |

Firefox 148 이전과 Safari는 찾은 글이 든 패널을 열지만, 그 글 위치로 제대로 스크롤하지 못합니다.

## 버전을 확인한 방법

pull request마다 Playwright에 포함된 Chromium, Firefox, WebKit으로 Linux, Windows, macOS에서 React 테스트를 돌립니다. 이 빌드들은 최신 릴리스를 따라가므로 오래된 버전은 테스트하지 않습니다.

이 페이지의 버전은 패키지가 실제로 배포하는 것, 즉 컴파일된 스타일시트와 `dist/`의 JavaScript, 의존하는 Base UI 릴리스를 [MDN 브라우저 호환성 데이터](https://github.com/mdn/browser-compat-data)와 대조해 얻었습니다. Base UI와 Tailwind CSS 행은 두 프로젝트가 직접 밝힌 값입니다. 마지막으로 확인한 버전은 `plass-ui` 1.4.0과 `@base-ui/react` 1.8.0입니다.

:::

::: fw flutter

## Flutter 웹

`plass_ui`가 따로 요구하는 브라우저 조건은 없습니다. 모든 컴포넌트를 Flutter 엔진이 그리고 웹 전용 코드도 없으므로, 이 패키지를 쓰는 Flutter 웹 앱은 쓰지 않는 앱과 같은 브라우저에서 돌아갑니다. 그 브라우저는 앱을 빌드한 Flutter SDK가 정하며, 이 패키지에는 3.41 이상이 필요합니다.

이 글을 쓰는 시점에 [Flutter의 지원 플랫폼 페이지](https://docs.flutter.dev/reference/supported-platforms)는 Flutter 3.47 기준으로 다음과 같이 적고 있습니다.

| 브라우저     | 지원         | 지원하지 않음 |
| ------------ | ------------ | ------------- |
| Chrome, Edge | 최신 두 버전 | 95 이하       |
| Firefox      | 최신 두 버전 | 98 이하       |
| Safari       | 15.6 이상    | 15.5 이하     |

두 열 사이의 버전이 동작하는지는 Flutter가 밝히지 않습니다.

`flutter build web`은 JavaScript로 컴파일합니다. `--wasm`을 붙여 빌드하면 WebAssembly 버전이 추가되고 JavaScript 버전도 남습니다. WebAssembly 버전을 실행하지 못하는 브라우저에서는 Flutter가 JavaScript 버전을 씁니다. 지금 어느 브라우저가 WebAssembly 버전을 실행하는지는 [Flutter의 WebAssembly 페이지](https://docs.flutter.dev/platform-integration/web/wasm)에 있습니다.

## 다른 플랫폼

Android, iOS, Linux, macOS, Windows에서도 마찬가지입니다. 패키지는 Flutter 3.41 이상이 돌아가는 곳이면 어디서든 돌아가고, 버전은 지원 플랫폼 페이지에 있습니다.

:::
