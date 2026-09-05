---
title: PlGallery
order: 23
---

# PlGallery

<p class="plass-lede">배치된 사진 묶음입니다. 네 가지 배치 — 콘택트 시트, 메이슨리, 정렬된 라이브러리, 퀼트 — 에 캡션과 포인터 반응, 그리고 선택적인 라이트박스가 모두 얹힙니다.</p>

<Demo src="gallery/hero" :min-height="420" />

::: fw react

```tsx
import { PlGallery } from 'plass-ui';

<PlGallery
  items={[
    { src: '/harbour.jpg', alt: 'A harbour at dusk', ratio: 4 / 3 },
    { src: '/bridge.jpg', alt: 'A bridge over a river', ratio: 3 / 2 }
  ]}
  layout="masonry"
  preview
/>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlGallery(
  items: <PlGalleryItem>[
    PlGalleryItem(
      image: const NetworkImage('/harbour.jpg'),
      semanticLabel: 'A harbour at dusk',
      ratio: 4 / 3,
    ),
  ],
  layout: PlGalleryLayout.masonry,
  preview: true,
);
```

viewer는 트리 밖으로 떠오르므로 `preview`를 켠 갤러리 위에는 `Overlay`가 필요합니다. navigator가 있는 `WidgetsApp`과 `MaterialApp`이 모두 제공합니다.

:::

네 가지 배치가 곧 이 컴포넌트입니다. 나머지 — 캡션, 포인터 반응, viewer — 는 넷 모두에서 같고, 그중 무엇을 쓸지는 컴포넌트 넷이 아니라 prop 하나입니다.

## Props

<PropsTable name="PlGallery" />

### PlGalleryItem

<PropsTable name="PlGalleryItem" />

::: fw react

native `<ul>` 속성은 그대로 전달됩니다. `children`은 사진이 `items`이기 때문에, `onSelect`는 이 컴포넌트의 것이 `onItemSelect`이고 event가 아니라 item을 넘기기 때문에 제외됩니다.

`className`은 목록에 붙습니다. `classNames`는 그 안의 다섯 부분 — `item`, `image`, `caption`, `title`, `description` — 에 닿습니다.

:::

라이브러리 전체에서 공유 축이 뜻하는 바는 [prop 규약](../../design/prop-conventions)에 있습니다.

## Examples

### layout

`grid`는 콘택트 시트입니다. 파일이 어떤 모양이든 모든 타일이 같은 모양이 됩니다. `masonry`는 사진마다 자기 비율을 지키며 열을 쌓습니다. `justified`는 비율을 지키면서 **동시에** 모든 줄을 가장자리까지 채웁니다. 사진 라이브러리가 쓰는 배치이고, 아무것도 잘리지 않으면서 남는 공간도 없는 유일한 배치입니다. `quilted`는 타일이 한 칸 이상을 차지할 수 있는 격자입니다.

<Demo src="gallery/layouts" :min-height="460">

::: fw react

<<< @/.vitepress/demos/gallery/layouts.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/gallery/layouts.dart

:::

</Demo>

메이슨리는 **아래로 내려가기 전에 옆으로 갑니다.** CSS `columns`는 첫 열을 위에서 아래까지 채우고 나서 둘째 열을 시작하므로, 1부터 12까지 번호가 매겨진 묶음은 왼쪽 가장자리를 따라 읽히고 처음 만나는 세 장이 세로로 포개집니다. 이렇게 나누면 첫 줄이 1, 2, 3이고, 그것이 주어진 순서입니다.

### ratio

모든 배치는 측정한 값이 아니라 item 자신의 `ratio`로 이루어집니다. 사진 마흔 장의 벽이 첫 프레임부터 제자리에 있고 파일이 도착하는 동안 다시 흐르지 않는 이유입니다. `ratio`가 없는 묶음은 갤러리의 `ratio`로 떨어지고, 메이슨리의 옷을 입은 정사각형 격자가 됩니다.

```tsx
{ src: '/dunes.jpg', alt: 'Dunes at first light', ratio: 2 }
{ src: '/terrace.jpg', alt: 'A stepped terrace', ratio: '2 / 3' }
```

::: fw react

숫자든 CSS가 쓰는 방식이든 됩니다. `2`도 `'2 / 3'`도 동작하는데, 비율은 원래 그렇게 쓰이고 이 라이브러리는 호출자에게 번역을 시키지 않기 때문입니다.

:::

::: fw flutter

`double`이고, 너비 나누기 높이입니다. 문자열 형태는 없습니다. Dart에는 맞춰야 할 CSS가 없기 때문입니다.

**여기서는 배치 둘이 측정을 하고 React에서는 하나도 하지 않습니다.** CSS는 justified를 `flex-grow`로, 퀼트를 `grid-auto-flow: dense`로 처리합니다. Flutter에는 그런 것이 없으므로 그 둘은 `LayoutBuilder` 안에서 스스로 packing합니다. 결과 배치는 같고, 다른 것은 누가 계산했는가입니다.

:::

### caption

`below`는 두 줄을 사진 아래에 두고, `overlay`는 옅은 사진에서도 글자가 살아남을 만큼 어두운 wash 위에 사진 밑단을 가로질러 씁니다. `hover`는 포인터와 함께 오는 `overlay`입니다.

<Demo src="gallery/captions" :min-height="520">

::: fw react

<<< @/.vitepress/demos/gallery/captions.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/gallery/captions.dart

:::

</Demo>

`title`도 `description`도 없는 타일은 `caption`이 무엇이든 캡션을 그리지 않습니다. 한 줄에 캡션 하나와 빈자리 셋이 있는 편보다 아예 없는 편이 낫습니다.

### hover

`lift`와 `dim`은 깊이와 색이고, 이 라이브러리의 다른 모든 것이 포인터에 답하는 방식입니다. `zoom`만 크기를 바꾸는데, [디자인 언어](../../design/design-language)가 명시한 예외입니다. 움직이는 것은 그대로 있는 프레임 안의 사진이고, 그 위에는 다시 그려질 글자가 없습니다.

### quilted

타일은 격자에서 `cols`개의 열과 `rows`개의 행을 차지합니다. 흐름은 **dense**입니다. 줄에 남은 자리에 비해 너무 넓은 타일은 모두를 아래로 밀지 않고 자기가 들어갈 다음 줄로 내려가며, 뒤의 좁은 타일이 그 구멍을 채웁니다.

<Demo src="gallery/quilted" :min-height="320">

::: fw react

<<< @/.vitepress/demos/gallery/quilted.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/gallery/quilted.dart

:::

</Demo>

격자보다 넓은 span은 거절하지 않고 자릅니다. `cols: 99`라고 쓴 사람이 뜻한 바가 그것입니다.

### preview

사진을 원본 크기로 열고, 나머지는 화살표 키 하나 거리에 둡니다. 캐러셀이 아닙니다. 캐러셀은 누군가에게 순서대로 보여 주는 묶음이고 이것은 다음으로 가는 길이 있는 사진 한 장입니다. 그래서 autoplay도, 순환도 없고, 화살표는 이미 본 사진으로 돌아가는 대신 양 끝에서 멈춥니다.

`full`은 타일이 썸네일일 때 쓸 더 큰 파일입니다. 사진마다 크기가 하나뿐인 묶음은 아무것도 적지 않아도 됩니다.

```tsx
{ src: '/thumb/harbour.jpg', full: '/full/harbour.jpg', alt: 'A harbour at dusk' }
```

::: fw react

viewer는 `React.lazy` 뒤에 있으므로, 아무도 열지 않은 라이트박스에 썸네일 벽이 비용을 치르지 않습니다. [`PlImage`](image)가 같은 prop으로 하는 것과 같은 거래입니다.

:::

## Accessibility

- 이름이 붙은 진짜 `role="list"`이고, 사진 하나당 `role="listitem"` 하나입니다. 메이슨리의 lane은 `<ul>`과 `<li>` 사이의 `<div>`가 아니라 자기 목록을 담은 list item입니다. 그 사이의 `<div>`는 스크린 리더가 아무것도 없는 목록으로 읽는 마크업입니다.
- 타일은 눌렀을 때 무슨 일이 일어날 때만 button입니다. 이름은 **사진 자신의 말에 세트 안의 위치를 더한 것** — "A harbour at dusk — 1 of 6" — 이므로, 썸네일 벽을 tab으로 지나가는 사람은 전체 몇 중 몇 번째에 있는지 듣습니다.
- `itemLabel`은 그 문장을 다른 언어로 쓰는 방법이고, 어순이 다르기 때문에 슬롯이 든 문자열이 아니라 콜백입니다.
- viewer의 화살표 키는 버튼이 아니라 시트에 묶여 있습니다. focus는 읽는 사람이 마지막으로 둔 자리에 있고, 한 곳에서만 동작하는 키는 나머지 모든 곳에서 고장 난 키로 보입니다.
- viewer의 카운터는 live region입니다. 화살표 키가 어디에 닿았는지, 그 사진을 볼 수 없는 사람에게도 말해 줍니다.
