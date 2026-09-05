---
layout: home

title: Plass
titleTemplate: 유리와 그러데이션으로 만든, React와 Flutter를 위한 컴포넌트 라이브러리
description: 유리와 그러데이션으로 만든 UI 컴포넌트 라이브러리입니다. 매끄러운 색 유리 표면, 자기 색으로 드리우는 그림자, 그리고 포인터를 따라오는 빛. 하나의 디자인 언어를 React와 Flutter로 내며, 다크 모드와 접근성, 타입이 이미 들어 있습니다.

hero:
  name: Plass
  text: 색이 한 번 도는, 매끄러운 유리
  tagline: 하나의 디자인 언어를 React와 Flutter로. 테마가 아니라 재질을 가졌고, 다크 모드와 접근성, 타입은 이미 들어 있습니다.
  actions:
    - theme: brand
      text: 시작하기
      link: /ko/guide/getting-started
    - theme: alt
      text: 모든 컴포넌트
      link: /ko/components/
    - theme: alt
      text: 디자인 언어
      link: /ko/design/design-language
  image:
    src: /logo-32.png
    alt: Plass

features:
  - title: 두 가지 재질, 하나의 언어
    details: 눌리는 색 유리판, 그리고 무언가를 담는 흐려진 시트. 모든 컴포넌트는 둘 중 하나이고, 그게 디자인 시스템의 전부입니다.
    link: /ko/design/design-language
    linkText: 디자인 언어
  - title: 두 프레임워크, 하나의 라이브러리
    details: React에도 Flutter에도 같은 백열네 개가 들어 있습니다. 같은 prop, 같은 토큰, 같은 숫자. 한 페이지가 둘 다 설명합니다.
  - title: 다크 모드 기본 제공
    details: 플랫폼을 따라가고, 원하면 어느 subtree에서든 한쪽으로 고정할 수 있습니다. 두 번째 테마를 쓸 일도, 색을 다시 선언할 일도 없습니다.
  - title: 하나의 공통 어휘
    details: size, color, variant, density, elevation. md는 어느 프레임워크의 어느 컴포넌트에서든 같은 뜻입니다.
    link: /ko/design/prop-conventions
    linkText: Prop 규칙
---

## 왜 Plass인가

<div class="plass-why">
  <div class="plass-why-card">
    <h3>테마 파일이 아니라 재질</h3>
    <p>모든 표면은 하나의 질문에 답합니다. 이건 눌리는 것인가, 무언가를 담는 것인가. 그 답이 채움과 가장자리, 그림자와 눌림을 모두 정합니다.</p>
  </div>
  <div class="plass-why-card">
    <h3>요철도, 래커칠도 없이</h3>
    <p>bevel도 highlight도 없습니다. hue가 도는 그러데이션이 형태를 만들고, 부드러운 빛이 포인터를 따라 컨트롤 위를 옮겨 다닙니다.</p>
  </div>
  <div class="plass-why-card">
    <h3>주장이 아니라 테스트</h3>
    <p>모든 컴포넌트가 자기 테스트를 함께 가지고, 변경할 때마다 돌아갑니다. React 패키지는 세 가지 엔진의 실제 브라우저에서, Flutter 패키지는 widget test로, 둘 다 세 가지 OS에서.</p>
  </div>
  <div class="plass-why-card">
    <h3>기본값이 접근성</h3>
    <p>role과 라벨, 키보드 조작과 focus 관리가 컴포넌트 안에 있습니다. 나중에 덧붙이는 것이 아닙니다.</p>
  </div>
  <div class="plass-why-card">
    <h3>검증된 대비</h3>
    <p>그러데이션의 모든 지점이 자기 라벨에 대해 4.5:1을 넘깁니다. 가장 밝은 모서리까지 포함해서요 — 채움의 밝기를 정한 것이 바로 그 모서리입니다.</p>
  </div>
  <div class="plass-why-card">
    <h3>요청하지 않은 것은 따라오지 않습니다</h3>
    <p>npm 패키지는 ESM으로 배포되고 tree-shaking이 되어 import한 것만 번들에 들어가며, 런타임 의존성은 하나뿐입니다. pub 패키지는 그마저도 없고, 애셋도 플러그인도 없습니다.</p>
  </div>
  <div class="plass-why-card">
    <h3>빌드 설정 없음</h3>
    <p>React는 패키지 하나에 CSS import 한 줄 — Tailwind는 이 라이브러리를 빌드할 뿐, 여러분의 프로젝트에 설치될 필요는 없습니다. Flutter는 패키지가 전부입니다. 스타일시트도 provider도 없습니다.</p>
  </div>
</div>

## 컴포넌트 미리 보기

아래는 이 페이지 안에서 실제로 돌아가고 있습니다 — Flutter 프레임은 하나가 곧 엔진 하나이기 때문에 React 빌드입니다. 입력해 보고, 저장을 눌러 보세요.

<Demo src="showcase/app" :flutter="false" :min-height="420" />

컴포넌트별 props와 예제는 [컴포넌트](./components/)에 있습니다. 설치와 연결은 한 페이지면 됩니다: [시작하기](./guide/getting-started).
