---
title: PlCarousel
order: 6
---

# PlCarousel

<p class="plass-lede">슬라이드가 늘어선 띠이고, 그중 하나가 보입니다. 밑에 있는 것은 스냅 지점이 붙은 스크롤 컨테이너라서, 스와이프와 드래그는 제스처 핸들러의 흉내가 아니라 플랫폼 자신의 것입니다.</p>

<Demo src="carousel/hero" :min-height="260" />

::: fw react

```tsx
import { PlCarousel } from 'plass-ui';

<PlCarousel label="Places">
  <img src="/harbour.jpg" alt="The harbour at dawn" />
  <img src="/dunes.jpg" alt="Dunes" />
</PlCarousel>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlCarousel(
  label: 'Places',
  value: slide,
  aspectRatio: 16 / 7,
  onChanged: (int next) => setState(() => slide = next),
  children: <Widget>[HarbourPhoto(), DunesPhoto()],
);
```

:::

## Props

<PropsTable name="PlCarousel" />

::: fw react

나머지 `<div>` 속성은 모두 region으로 전달됩니다.

:::

라이브러리 전체에서 공유하는 축이 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## 구성

**스냅 지점이 붙은 스크롤 컨테이너**이고, 이 컴포넌트의 좋은 점은 전부 그 선택 하나에서 따라 나옵니다.

스와이프와 트랙패드 두 손가락 드래그는 플랫폼 자신의 스크롤입니다. 흉내 내는 제스처 핸들러가 아니라서 관성과 고무줄 효과, 스크롤바가 함께 옵니다. RTL에서 띠가 반대로 흐르는 것도 따로 지정할 필요가 없습니다. 스크롤에는 방향이 있고 `translate`에는 없기 때문입니다. **아무것도 변형되지 않으므로** 표면을 움직이지 않는다는 [하우스 규칙](../../design/design-language)도 예외 없이 지켜집니다.

슬라이드도 하위 컴포넌트가 아닙니다. 자식 하나하나가 슬라이드가 되고, 그 감싸개가 스크린 리더에 필요한 의미론을 담당합니다. 사진 한 장에 그것들을 붙이는 걸 호출하는 쪽이 기억해야 할 이유는 없습니다.

::: fw react

`<PlCarousel><img /><img /></PlCarousel>`이 API의 전부입니다. 감싸개가 스냅 지점, 너비, 그리고 `role="group"` / `aria-roledescription="slide"` 쌍을 담당합니다.

:::

::: fw flutter

밑에 있는 것은 스냅 지점이 붙은 Flutter 자신의 스크롤, [`PageView`](https://api.flutter.dev/flutter/widgets/PageView-class.html)입니다. 그와 함께 React 빌드에는 필요 없는 파라미터 **`aspectRatio`**가 딸려 옵니다. 브라우저의 띠는 안에 든 것만큼 높지만, `PageView`는 모든 페이지를 뷰포트 크기로 배치하므로 높이를 받아야 합니다. `aspectRatio`를 비워 두면 캐러셀은 바깥 레이아웃이 내려 주는 높이를 씁니다.

:::

## Examples

### variant

프레임입니다. 다른 모든 컨테이너와 같은 세 재질이고, 색은 들어가지 않습니다. 캐러셀은 남의 사진을 담습니다. `ghost`에는 프레임이 아예 없고, 사진이 이미 자기 가장자리를 가지고 있을 때 쓰는 것입니다.

<Demo src="carousel/variants" :min-height="380">

::: fw react

<<< @/.vitepress/demos/carousel/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/carousel/variants.dart

:::

</Demo>

### loop

기본은 켜져 있습니다. 화살표가 마지막 슬라이드에서 첫 슬라이드로 감깁니다. 끄면 대신 양 끝에서 반응하지 않게 되는데, 시작과 끝이 있는 묶음에는 그쪽이 정직합니다. 사진 세 장짜리 갤러리에는 시작과 끝이 있고, 도는 배너에는 없습니다.

<Demo src="carousel/loop" :min-height="360">

::: fw react

<<< @/.vitepress/demos/carousel/loop.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/carousel/loop.dart

:::

</Demo>

### autoPlay

**기본은 꺼져 있고, 그것은 의도된 것입니다.** 읽고 있는 동안 움직이는 캐러셀은 가장 많은 불평을 듣는 패턴이고, 아래의 방어 하나하나는 그것이 잘못되는 방식 하나하나 때문에 있습니다.

- 포인터가 위에 있는 동안 멈춥니다.
- 움직임을 줄여 달라고 한 독자에게는 아예 시작하지 않습니다.
- 이동을 알릴 곳이 있어야 합니다. 아무도 듣고 있지 않은 캐러셀에는 넘길 것이 없으므로 시도하지 않습니다.

::: fw react

- **안쪽 어디든** 포커스가 들어오면 멈춥니다. 이쪽이 중요합니다. 슬라이드로 탭해 들어온 키보드 독자는 그것을 읽고 있는 중입니다.
- 탭이 배경에 있는 동안 멈춥니다.
- 현재 슬라이드를 알리는 live region이 그동안 **침묵합니다**. 5초마다 새 슬라이드 이름을 말하는 스크린 리더가 그 페이지를 못 쓰게 만드는 것이기 때문입니다.

:::

<Demo src="carousel/auto-play" :min-height="200">

::: fw react

<<< @/.vitepress/demos/carousel/auto-play.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/carousel/auto_play.dart

:::

</Demo>

### 점들

현재 점은 더 큰 원이 아니라 짧은 **막대**입니다. 자기가 놓인 줄을 따라 길어지므로 줄의 높이는 변하지 않고 양옆의 점들도 움직이지 않습니다. 이동하는 것은 너비와 색 둘뿐이고, 그것이 이 인디케이터를 "아무것도 확대하지 않는다"는 규칙 안에 남겨 둡니다.

점 하나하나는 자기가 가는 슬라이드의 이름이 붙은 진짜 버튼입니다. 이 줄은 읽어 주는 표시가 아니라 이동하는 수단입니다.

## Accessibility

- 캐러셀은 스스로 이름을 밝히고, 슬라이드 하나하나도 자기 이름을 가집니다.
- 화살표와 점은 진짜 이름이 붙은 진짜 버튼입니다. `label`·`previousLabel`·`nextLabel`·`slideLabel`이 그 이름을 정합니다.

::: fw react

- 전체는 `aria-roledescription="carousel"`인 `region`이고, 슬라이드 하나하나는 `aria-roledescription="slide"`인 `group`입니다.
- 화면 밖 슬라이드를 숨기지 않습니다. 슬라이드는 링크나 버튼을 담을 수 있고, 탭 순서에는 남아 있는데 `aria-hidden`인 서브트리는 스크린 리더가 설명하기를 거부하는 자리에 키보드 독자가 도착하는 바로 그 버그의 모양입니다. 띠는 스크롤되므로 그 안의 모든 것에 진짜로 닿을 수 있습니다.
- 독자가 어디 있는지는 polite live region에서 문장으로 안내됩니다. 그리고 `autoPlay`가 켜져 있는 동안에는 절대 말하지 않습니다.
- 띠 자체가 포커스를 받고 방향키로 스크롤됩니다. 스크롤 컨테이너에 대한 브라우저 자신의 키 처리라서 RTL에서도 이미 올바릅니다.

:::

::: fw flutter

- `PageView`는 보이는 페이지와 그 옆 페이지만 만듭니다. 화면 밖 슬라이드는 트리에 있으면서 숨겨진 것이 아니라 아예 없습니다. 거짓말하는 것이 없습니다. 존재하는 페이지는 독자가 지금 닿을 수 있는 페이지이고, 나머지는 스크롤이 만듭니다.

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| `value` / `defaultValue` / `onValueChange` | `value` / `onChanged` | Flutter의 컨트롤은 controlled이고, 이 패키지의 상태 있는 위젯도 전부 그렇습니다. |
| — | `aspectRatio` | 브라우저의 띠는 안에 든 것만큼 높지만, `PageView`는 모든 페이지를 뷰포트 크기로 배치하므로 높이를 받아야 합니다. |
| polite live region | — | Flutter에는 live region이 하나뿐이고 politeness 단계가 없습니다. 슬라이드의 이름은 슬라이드에 있고, 스크린 리더가 읽는 자리가 거기입니다. |
| 배경 탭에서 멈춤 | — | 배경에 놓일 탭이 없습니다. |
| 프레임 안 포커스에서 멈춤 | — | `PageView` 안의 포커스는 DOM `focus` 이벤트처럼 프레임까지 올라오지 않습니다. 포인터 일시정지가 그 역할을 합니다. |
| `className`, `style` | — | 전달할 class 목록도 style 속성도 없습니다. |

:::
