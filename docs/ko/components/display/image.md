---
title: PlImage
order: 18
---

# PlImage

<p class="plass-lede">사진 하나, 그리고 사진이 일생의 대부분을 보내는 두 상태입니다. 사진이 도착하기 전에 자리를 잡아 두고, 도착하지 않으면 그 실패를 그립니다.</p>

<Demo src="image/hero" :min-height="260" />

::: fw react

```tsx
import { PlImage } from 'plass-ui';

<PlImage src="/cover.jpg" alt="The 2026 team" ratio="16 / 9" rounded />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlImage(
  image: const NetworkImage('https://example.com/cover.jpg'),
  semanticLabel: 'The 2026 team',
  ratio: 16 / 9,
  rounded: true,
);
```

:::

## Props

<PropsTable name="PlImage" />

네이티브 `<img>` 속성은 `srcSet` · `sizes` · `crossOrigin`을 포함해 그대로 통과합니다. `onLoad`와 `onError` 둘만 예외입니다 — 컴포넌트가 그것들을 씁니다. 대신 내주는 것이 `onStatusChange`입니다.

::: fw flutter

`image`는 URL이 아니라 `ImageProvider`입니다. 네트워크 이미지 · 에셋 · 파일 · 메모리 버퍼가 공유하는 모양이 그것이기 때문입니다. `semanticLabel`이 `alt`에 해당하고, `null`은 사진을 장식으로 표시합니다.

**`ratio`가 없으면 위젯은 사진 자신의 intrinsic 크기입니다.** `Image`의 동작이고 일부러 덮어쓰지 않았습니다. 받은 너비를 채우게 만드는 것이 `ratio`이고, 그것이 자리를 잡아 두는 일의 나머지 절반입니다.

:::

## `<img>`에 무엇을 더하는가

`<img>`는 태그 하나이고 그것으로 동작합니다. 그러니 이것이 무엇을 위한 것인지는 가정하지 말고 말해 두는 편이 낫습니다. 세 가지입니다.

1. 사진이 도착하기 전에 **자리를 잡아 둡니다.** 그래서 아래 문단이 도착과 함께 밀려나지 않습니다. 그것이 `ratio`이고, 매번 손을 뻗을 만한 prop입니다 — 그것이 없으면 잡아 둘 자리가 없습니다. 상자는 사진이 얼마나 높은지에 따라 정해지고, 그건 도착하기 전까지 아무도 모릅니다.
2. **실패를 그립니다.** 브라우저의 깨진 이미지 글리프와 아무도 고르지 않은 세리프 폰트의 alt 텍스트로 남기지 않습니다.
3. **둘이 하나의 상태 기계입니다.** 그래서 이미 로드된 사진 뒤에 placeholder가 남아 있지 않고, `src`가 바뀌면 지난번의 성공을 물려받는 대신 다시 시작합니다.
4. **사진은 placeholder 위로 서서히 나타납니다.** 두 프레임 사이에 갈아 끼우지 않습니다. 뚝 끊고 나타나는 사진은 레이아웃이 마음을 바꾼 것처럼 읽히고, placeholder가 존재하는 이유인 느린 연결에서 가장 그렇게 읽힙니다. 이미 디코딩된 사진은 통째로 그립니다. 기다릴 일이 없었던 것에 등장 효과를 붙이는 것은 아무것도 아닌 것에 붙이는 셈입니다.

## Examples

### 두 상태

<Demo src="image/states" :min-height="280">

::: fw react

<<< @/.vitepress/demos/image/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/states.dart

:::

</Demo>

`placeholder`가 skeleton을 대체합니다 — `null`은 아무것도 그리지 않고 잡아 둔 상자를 비워 둡니다. `fallback`이 alt 텍스트를 대체하고, alt가 기본인 이유는 그것이 확실히 존재하고 확실히 없는 것을 설명하는 유일한 것이기 때문입니다.

### filter

사진에 얹는 처리입니다. 여섯 가지에 이름이 있고 — `grayscale`, `sepia`, `saturate`, `desaturate`, `contrast`, `dim` — 그 밖에 넘기는 것은 CSS `filter` 체인이라 쓴 그대로 적용됩니다.

<Demo src="image/filter" :min-height="220">

::: fw react

<<< @/.vitepress/demos/image/filter.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/filter.dart

:::

</Demo>

사진 자체의 fade와 같은 transition을 타므로, hover에서 filter를 바꿔도 fade가 아직 움직이는 중에 툭 튀지 않고 함께 이동합니다. placeholder와 fallback에는 걸리지 않습니다. 회색이 된 skeleton은 `grayscale`이 요청한 것이 아닙니다.

::: fw flutter

탈출구는 `colorFilter`이고, 직접 만든 `ColorFilter`를 받아 이름 붙은 `filter`를 이깁니다. CSS 체인은 여기서 의미가 없고, Flutter에서 같은 생각은 `ColorFilter`입니다. 이름 붙은 것들은 React 빌드가 쓰는 것과 같은 수치로 풀리므로, `sepia`는 두 패키지에서 비슷해 보이는 두 색이 아니라 하나의 색입니다.

:::

### watermark

사진 위에 얹는 표식입니다. 문자열 하나는 아래 모서리에 놓이고, 객체로 주면 위치와 진하기와 각도를 말할 수 있습니다. `placement: 'tile'`은 대신 사진 전체를 덮습니다. 시안이나 미리 보기가 원하는 것이 그쪽입니다. 모서리의 표식은 한 번 자르면 없어집니다.

<Demo src="image/watermark" :min-height="240">

::: fw react

<<< @/.vitepress/demos/image/watermark.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/watermark.dart

:::

</Demo>

타일로 깐 표식은 요소 더미가 아니라 **반복되는 배경 하나**입니다. 사진 한 장에 표식이 마흔 개 쉰 개 들어가는 것이 보통이고, 그만큼의 요소는 배치할 것도, 스크린 리더에서 숨길 것도, 사용자의 CSS가 걸려 넘어질 것도 그만큼입니다. 레이어는 사본마다가 아니라 **레이어 전체가** 한 번 회전합니다. 그래야 이음매가 생기지 않습니다. 반듯한 격자 안에서 타일만 돌리면 격자의 선이 그대로 비칩니다.

사진이 도착한 뒤에만 그려집니다. 아직 오지 않은 파일에 찍는 도장은 주장이 아닙니다. 그리고 `aria-hidden`이며 포인터를 받지 않습니다. 워터마크는 파일에 대한 주장이지 페이지가 독자에게 하는 말이 아니고, 사진이 자기가 무엇인지 말하는 자리는 `alt`입니다. `preview`로도 따라갑니다. 크게 열 때 벗겨지는 표식은 아무도 원하지 않은 사본에 찍힌 것입니다.

### protect

사진을 가볍게 가져가는 네 가지 길을 막습니다. 컨텍스트 메뉴, 페이지 밖으로 드래그, 위로 지나가는 텍스트 선택, 그리고 iOS의 길게 누르기 — 잊기 쉽고 가장 중요한 것이 마지막입니다. iOS에서 길게 누르기가 곧 컨텍스트 메뉴이기 때문입니다.

<Demo src="image/protect" :min-height="220">

::: fw react

<<< @/.vitepress/demos/image/protect.tsx

:::

</Demo>

**자물쇠가 아니라 억지책입니다.** 파일은 여전히 요청 하나 거리에 있습니다. 네트워크 탭에 있고, 캐시에 있고, 화면 캡처는 둘 다 필요 없습니다. 이것이 막는 것은 무심코 하는 우클릭 저장이고, 대부분의 사진에는 그게 원하던 전부입니다. 정말로 복사되면 안 되는 것은 애초에 페이지에 올릴 것이 아닙니다.

직접 넘긴 `onContextMenu`는 그대로 실행되지만 거부를 끄지는 못합니다. 사진을 보호해 달라고 해 놓고 handler를 넘겨서 말없이 보호가 풀리면 곤란하기 때문입니다. `preview`로도 따라갑니다. 크게 여는 순간 벗겨지는 거부는 거부가 아니고, 크게 연 그것이 애초에 누군가 원하던 사본입니다.

::: fw flutter

여기에는 `protect`가 없고, 할 일도 없습니다. Flutter 앱은 사진을 각자의 요소가 아니라 canvas 위에 그리므로 사진마다 거부할 컨텍스트 메뉴가 없고, 밖으로 끌어낼 것도 선택할 것도 없습니다. Flutter web에서 브라우저 자체 메뉴를 끄는 것은 위젯 하나가 요청할 일이 아니라 앱 전체의 결정입니다 — `package:flutter/services.dart`의 `BrowserContextMenu`입니다.

:::

### preview

누르면 사진을 페이지 위로 엽니다. 기본은 꺼짐입니다. 클릭하면 커지는 사진은 볼 것이 더 있다는 약속이고, 페이지의 사진 대부분은 그 약속을 하고 있지 않습니다.

<Demo src="image/preview" :min-height="280">

::: fw react

<<< @/.vitepress/demos/image/preview.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/preview.dart

:::

</Demo>

`tone="glass"`의 [`PlOverlay`](../feedback/overlay)이므로 Escape와 바깥 클릭이 닫습니다. 사진이 도착하기 전까지 trigger는 비활성입니다 — 아직 미리 볼 것이 없습니다 — 그리고 "Preview"가 아니라 사진의 이름을 따릅니다. 그러지 않으면 한 페이지의 미리 보기 셋이 같은 이름의 버튼 셋이 됩니다.

::: fw react

이 overlay는 `React.lazy`로 부르는 **별도 청크**입니다. 이것을 여는 사진 컴포넌트보다 몇 배 무겁고 `preview`는 기본이 꺼짐이므로, 썸네일만 잔뜩 그리는 페이지가 한 번도 열지 않을 lightbox를 내려받지 않습니다. 켜면 첫 페인트 뒤에 한 번 받아 옵니다. 어느 쪽이든 설정할 것은 없지만, 캐시가 비어 있을 때 첫 누름에서는 overlay가 한 박자 늦게 나타납니다.

:::

### 갤러리

사진 묶음에는 [`PlGallery`](./gallery)를 씁니다. 배치와 캡션, 라이트박스로 여는 동작까지 이 컴포넌트가 담당합니다. 배치나 선택 state를 직접 다뤄야 할 때만 아래처럼 조합하세요. 여기의 `preview`는 사진 한 장을 보여줄 뿐이고, 이전/다음 조작은 없습니다.

```tsx
const [at, setAt] = useState<number | null>(null);

{
  photos.map((photo, index) => (
    <PlImage
      key={photo.id}
      src={photo.thumb}
      alt={photo.alt}
      ratio="1"
      onClick={() => setAt(index)}
    />
  ));
}

<PlOverlay open={at !== null} onOpenChange={() => setAt(null)} tone="glass" dismissible>
  …
</PlOverlay>;
```

## Accessibility

- `alt`는 **필수**이고, `""`는 빠뜨린 것이 아니라 진짜 답입니다. 사진을 장식으로 표시해 accessibility tree에서 빼는데, 텍스처나 배경에는 맞고 사용자가 아쉬워할 무엇에는 틀립니다.
- 실패했을 때 그리는 fallback이 `alt` 텍스트입니다. 그래서 보는 사람과 스크린 리더가 사진이 오지 않았을 때 같은 것을 듣습니다.
- `<img>`는 로드되는 동안 문서에 남아 있습니다. 문서에 없는 `<img>`는 절대 로드되지 않으므로, 그것을 unmount하는 placeholder는 영영 도착하지 않는 사진입니다.
- 기본은 `loading="lazy"`입니다. 화면 위쪽의 사진 하나에는 `loading="eager"`를 주세요 — 지연 로드되는 히어로는 늦게 도착하는 히어로입니다.

::: fw flutter

안쪽 `Image`는 `excludeFromSemantics`입니다. 그래서 사진은 정확히 한 번 — 바깥 wrapper가 — 이름 붙이고, 두 번 읽히지 않습니다.

:::
