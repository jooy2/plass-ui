---
title: PlCarousel
order: 6
---

# PlCarousel

<p class="plass-lede">슬라이드가 늘어선 띠이고, 그중 하나가 보입니다. 밑에 있는 것은 스냅 지점을 가진 스크롤 컨테이너라서, 스와이프와 드래그는 제스처 핸들러의 흉내가 아니라 브라우저 자신의 것입니다.</p>

<Demo src="carousel/hero" :flutter="false" :min-height="260" />

::: fw react

```tsx
import { PlCarousel } from 'plass-ui';

<PlCarousel label="Places">
  <img src="/harbour.jpg" alt="The harbour at dawn" />
  <img src="/dunes.jpg" alt="Dunes" />
</PlCarousel>;
```

:::

## Props

<PropsTable name="PlCarousel" />

::: fw react

나머지 `<div>` 속성은 모두 region으로 전달됩니다.

:::

라이브러리 전체에서 공유하는 축이 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## 무엇으로 만들어져 있는가

**스크롤 스냅을 쓰는 스크롤 컨테이너**이고, 이 컴포넌트의 좋은 점은 전부 그 선택 하나에서 따라 나옵니다.

휴대폰의 스와이프도 트랙패드의 두 손가락 드래그도 동작하는 이유는 그것이 플랫폼 자신의 스크롤이고 그것을 흉내 내는 제스처 핸들러가 아니기 때문입니다 — 관성도, 고무줄 효과도, 스크롤바도 함께 옵니다. RTL에서 띠가 반대로 흐르는 것도 따로 말해 줄 필요가 없습니다. 스크롤에는 방향이 있고 `translate`에는 없기 때문입니다. 그리고 **아무것도 변형되지 않아서**, 표면을 움직이지 않는다는 [하우스 규칙](../../design/design-language)이 여기서는 공짜로 지켜집니다. `translate`로 옮기는 트랙이었다면 예외를 주장해야 했을 자리입니다.

슬라이드는 하위 컴포넌트가 아닙니다. 최상위 자식 하나하나가 자기 슬라이드로 감싸이므로 `<PlCarousel><img /><img /></PlCarousel>`이 API의 전부입니다. 그리고 그 감싸개가 스냅 지점, 너비, 그리고 스크린 리더에 필요한 `role="group"` / `aria-roledescription="slide"` 쌍을 담당합니다. 사진 한 장에 그것들을 붙이는 걸 호출하는 쪽이 기억해야 할 이유는 없습니다.

## Examples

### variant

프레임입니다. 다른 모든 컨테이너와 같은 세 재질이고, 색은 들어가지 않습니다 — 캐러셀은 남의 사진을 담습니다. `ghost`에는 프레임이 아예 없고, 사진이 이미 자기 가장자리를 가지고 있을 때 쓰는 것입니다.

<Demo src="carousel/variants" :flutter="false" :min-height="380">

<<< @/.vitepress/demos/carousel/variants.tsx

</Demo>

### loop

기본은 켜져 있습니다. 화살표가 마지막 슬라이드에서 첫 슬라이드로 감깁니다. 끄면 대신 양 끝에서 반응하지 않게 되는데, 시작과 끝이 있는 묶음에는 그쪽이 정직합니다 — 사진 세 장짜리 갤러리에는 시작과 끝이 있고, 도는 배너에는 없습니다.

<Demo src="carousel/loop" :flutter="false" :min-height="360">

<<< @/.vitepress/demos/carousel/loop.tsx

</Demo>

### autoPlay

**기본은 꺼져 있고, 그것은 의도된 것입니다.** 읽고 있는 동안 움직이는 캐러셀은 웹에서 가장 많은 불평을 듣는 패턴이고, 아래의 방어 하나하나는 그것이 잘못되는 방식 하나하나 때문에 있습니다.

- 포인터가 올라오면 멈춥니다.
- **안쪽 어디든** 포커스가 들어오면 멈춥니다. 이쪽이 중요합니다 — 슬라이드로 탭해 들어온 키보드 독자는 그것을 읽고 있는 중입니다.
- 탭이 배경에 있는 동안 멈춥니다.
- 움직임을 줄여 달라고 한 독자에게는 아예 시작하지 않습니다.
- 그리고 현재 슬라이드를 알리는 live region이 그동안 **침묵합니다**. 5초마다 새 슬라이드 이름을 말하는 스크린 리더가 그 페이지를 못 쓰게 만드는 것이기 때문입니다.

<Demo src="carousel/auto-play" :flutter="false" :min-height="200">

<<< @/.vitepress/demos/carousel/auto-play.tsx

</Demo>

### 점들

현재 점은 더 큰 원이 아니라 짧은 **막대**입니다. 자기가 놓인 줄을 따라 길어지므로 줄의 높이는 변하지 않고 양옆의 점들도 움직이지 않습니다 — 이동하는 것은 너비와 색 둘뿐이고, 그것이 이 인디케이터를 "아무것도 확대하지 않는다"는 규칙 안에 남겨 둡니다.

점 하나하나는 자기가 가는 슬라이드의 이름을 가진 진짜 버튼입니다. 이 줄은 읽어 주는 표시가 아니라 이동하는 수단입니다.

## Accessibility

- 전체는 `aria-roledescription="carousel"`인 `region`이고, 슬라이드 하나하나는 `aria-roledescription="slide"`와 자기 이름을 가진 `group`입니다.
- 화면 밖 슬라이드를 숨기지 않습니다. 슬라이드는 링크나 버튼을 담을 수 있고, 탭 순서에는 남아 있는데 `aria-hidden`인 서브트리는 스크린 리더가 설명하기를 거부하는 자리에 키보드 독자가 도착하는 바로 그 버그의 모양입니다. 띠는 스크롤되므로 그 안의 모든 것에 진짜로 닿을 수 있습니다.
- 독자가 어디 있는지는 polite live region에서 문장으로 안내됩니다. 그리고 `autoPlay`가 켜져 있는 동안에는 절대 말하지 않습니다.
- 화살표와 점은 진짜 이름을 가진 진짜 버튼입니다. `label`·`previousLabel`·`nextLabel`·`slideLabel`이 그 이름을 정합니다.

::: fw react

- 띠 자체가 포커스를 받고 방향키로 스크롤됩니다. 스크롤 컨테이너에 대한 브라우저 자신의 키 처리라서 RTL에서도 이미 올바릅니다.

:::
