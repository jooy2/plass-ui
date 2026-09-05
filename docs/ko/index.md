---
layout: home

title: Plass
titleTemplate: React와 Flutter를 위한 유리 컴포넌트 라이브러리
description: 색 유리와 그러데이션으로 만든 컴포넌트 127개를, 하나의 디자인 언어로 React와 Flutter에 함께 냅니다. 다크 모드와 접근성, 타입이 이미 들어 있고 채워 넣을 테마 파일도 없습니다.

hero:
  name: Plass
  text: 하나의 디자인 언어를 React와 Flutter로
  tagline: 색 유리와 그러데이션으로 만든 컴포넌트 127개입니다. 다크 모드와 접근성, 타입이 이미 들어 있어 첫 화면을 그리기 전에 설정할 것이 없습니다.
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
  - title: 두 프레임워크, 하나의 라이브러리
    details: React에도 Flutter에도 같은 127개가 같은 이름으로 들어 있습니다. prop도 토큰도 숫자도 같고, 한 페이지가 둘 다 설명합니다.
  - title: 설치하면 그대로 완성
    details: 색과 그림자, 흐림, 모션이 이미 정해져 있고 서로 맞아떨어집니다. 채워 넣을 테마 파일이 없습니다.
    link: /ko/design/design-language
    linkText: 디자인 언어
  - title: 다크 모드 기본 제공
    details: 플랫폼을 따라가고, 원하면 페이지의 어느 부분에서든 한쪽으로 고정할 수 있습니다. 두 번째 팔레트를 쓸 일이 없습니다.
  - title: 익힐 prop은 다섯 개
    details: size, color, variant, density, elevation이 어디서나 같은 뜻입니다. 그래서 열 번째 컴포넌트는 새로 배울 것이 없습니다.
    link: /ko/design/prop-conventions
    linkText: Prop 규칙
---

## 주요 특징

<div class="plass-why">
  <div class="plass-why-card">
    <h3>하나의 재질, 두 가지 답</h3>
    <p>모든 표면은 눌리는 색 유리판이거나, 무언가를 담는 맑은 시트입니다. 이 하나의 구분이 채움과 가장자리, 그림자와 눌림을 모두 정합니다.</p>
  </div>
  <div class="plass-why-card">
    <h3>요철도 하이라이트도 없이</h3>
    <p>hue가 도는 그러데이션이 형태를 만들고, 부드러운 빛이 포인터를 따라 컨트롤 위를 옮겨 다닙니다.</p>
  </div>
  <div class="plass-why-card">
    <h3>기본값이 접근성</h3>
    <p>role과 라벨, 키보드 조작, focus 관리가 컴포넌트 안에 들어 있습니다. 나중에 덧붙이는 것이 아닙니다.</p>
  </div>
  <div class="plass-why-card">
    <h3>측정해서 확보한 가독성</h3>
    <p>그러데이션의 모든 지점이 자기 라벨에 대해 4.5:1을 넘깁니다. 여기서 색을 고르는 일이 나중에 터질 대비 문제가 되지 않습니다.</p>
  </div>
  <div class="plass-why-card">
    <h3>변경할 때마다 테스트</h3>
    <p>모든 컴포넌트에 테스트가 딸려 있습니다. React 패키지는 실제 브라우저에서, Flutter 패키지는 widget test로, 둘 다 세 가지 OS에서 돕니다.</p>
  </div>
  <div class="plass-why-card">
    <h3>기본적으로 가볍게</h3>
    <p>npm 패키지는 ESM이고 tree-shaking이 되므로 import한 것만 번들에 들어갑니다. pub 패키지에는 의존성이 아예 없습니다.</p>
  </div>
  <div class="plass-why-card">
    <h3>설정은 한 줄</h3>
    <p>React는 패키지 하나에 CSS import 한 줄입니다. Flutter는 패키지가 전부여서 스타일시트도 provider도 없습니다.</p>
  </div>
</div>

## 컴포넌트 미리 보기

아래는 이 페이지 안에서 React 빌드로 실제 동작하고 있습니다. 입력해 보고, 저장을 눌러 보세요.

<Demo src="showcase/app" :flutter="false" :min-height="420" />

컴포넌트마다 자기 페이지가 [컴포넌트](./components/)에 있고, 설치와 설정은 [시작하기](./guide/getting-started) 한 페이지면 끝납니다.
