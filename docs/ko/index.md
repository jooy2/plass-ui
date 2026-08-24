---
layout: home

title: Plass
titleTemplate: 플라스틱과 글래스로 만든 React 컴포넌트 라이브러리
description: 두 가지 재질로 만든 React 컴포넌트 라이브러리입니다. 그러데이션으로 성형된 컨트롤이 반투명하게 흐려진 시트 위에 놓입니다. 다크 모드와 TypeScript 타입, 하나의 공통 prop 어휘가 설치 한 번에 따라옵니다.

hero:
  name: Plass
  text: 유리 시트 위에 놓인 플라스틱 키
  tagline: 테마가 아니라 재질을 가진 React 컴포넌트 라이브러리. 다크 모드와 접근성, 타입은 이미 들어 있습니다.
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
    src: /logo.svg
    alt: Plass

features:
  - title: 두 가지 재질, 하나의 언어
    details: 눌리는 그러데이션 키, 그리고 무언가를 담는 흐려진 시트. 모든 컴포넌트는 둘 중 하나이고, 그게 디자인 시스템의 전부입니다.
    link: /ko/design/design-language
    linkText: 디자인 언어
  - title: TypeScript 우선
    details: 타입 정의가 패키지에 함께 들어갑니다. prop 이름과 받을 수 있는 값을 에디터가 먼저 압니다.
  - title: 다크 모드 기본 제공
    details: 상위 요소에 클래스 하나면 모든 컴포넌트가 따라옵니다. 두 번째 테마를 쓸 일도, 색을 다시 선언할 일도 없습니다.
  - title: 하나의 공통 어휘
    details: size, color, variant, density, elevation. md는 모든 컴포넌트에서 같은 뜻입니다.
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
    <h3>주장이 아니라 테스트</h3>
    <p>모든 컴포넌트가 자기 테스트를 함께 가집니다. 변경할 때마다 세 가지 OS와 세 가지 엔진의 실제 브라우저에서 돌아갑니다.</p>
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
    <h3>현대적인 프론트엔드를 위해</h3>
    <p>ESM으로 배포되고 tree-shaking이 됩니다. import한 것만 번들에 들어갑니다. 런타임 의존성은 하나뿐입니다.</p>
  </div>
  <div class="plass-why-card">
    <h3>빌드 설정 없음</h3>
    <p>패키지 하나, CSS import 한 줄. Tailwind는 이 라이브러리를 빌드할 뿐, 여러분의 프로젝트에 설치될 필요는 없습니다.</p>
  </div>
</div>

## 컴포넌트 미리 보기

아래는 이 페이지 안에서 실제로 돌아가고 있습니다. 입력해 보고, 저장을 눌러 보세요.

<Demo src="showcase/app" :min-height="420" />

컴포넌트별 props와 예제는 [컴포넌트](./components/)에 있습니다. 설치와 연결은 한 페이지면 됩니다: [시작하기](./guide/getting-started).
