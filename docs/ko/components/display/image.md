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

## Props

<PropsTable name="PlImage" />

네이티브 `<img>` 속성은 `srcSet` · `sizes` · `crossOrigin`을 포함해 그대로 통과합니다. `onLoad`와 `onError` 둘만 예외입니다 — 컴포넌트가 그것들을 씁니다. 대신 내주는 것이 `onStatusChange`입니다.

## `<img>`에 무엇을 더하는가

`<img>`는 태그 하나이고 그것으로 동작합니다. 그러니 이것이 무엇을 위한 것인지는 가정하지 말고 말해 두는 편이 낫습니다. 세 가지입니다.

1. 사진이 도착하기 전에 **자리를 잡아 둡니다.** 그래서 아래 문단이 도착과 함께 밀려나지 않습니다. 그것이 `ratio`이고, 매번 손을 뻗을 만한 prop입니다 — 그것이 없으면 잡아 둘 자리가 없습니다. 상자는 사진이 얼마나 높은지에 따라 정해지고, 그건 도착하기 전까지 아무도 모릅니다.
2. **실패를 그립니다.** 브라우저의 깨진 이미지 글리프와 아무도 고르지 않은 세리프 폰트의 alt 텍스트로 남기지 않습니다.
3. **둘이 하나의 상태 기계입니다.** 그래서 이미 로드된 사진 뒤에 placeholder가 남아 있지 않고, `src`가 바뀌면 지난번의 성공을 물려받는 대신 다시 시작합니다.

## Examples

### 두 상태

<Demo src="image/states" :min-height="280">

::: fw react

<<< @/.vitepress/demos/image/states.tsx

:::

</Demo>

`placeholder`가 skeleton을 대체합니다 — `null`은 아무것도 그리지 않고 잡아 둔 상자를 비워 둡니다. `fallback`이 alt 텍스트를 대체하고, alt가 기본인 이유는 그것이 확실히 존재하고 확실히 없는 것을 설명하는 유일한 것이기 때문입니다.

### preview

누르면 사진을 페이지 위로 엽니다. 기본은 꺼짐입니다. 클릭하면 커지는 사진은 볼 것이 더 있다는 약속이고, 페이지의 사진 대부분은 그 약속을 하고 있지 않습니다.

<Demo src="image/preview" :min-height="280">

::: fw react

<<< @/.vitepress/demos/image/preview.tsx

:::

</Demo>

`tone="glass"`의 [`PlOverlay`](../feedback/overlay)이므로 Escape와 바깥 클릭이 닫습니다. 사진이 도착하기 전까지 trigger는 비활성입니다 — 아직 미리 볼 것이 없습니다 — 그리고 "Preview"가 아니라 사진의 이름을 따릅니다. 그러지 않으면 한 페이지의 미리 보기 셋이 같은 이름의 버튼 셋이 됩니다.

### 갤러리

갤러리 컴포넌트도, 미리 보기 안의 이전/다음도 일부러 없습니다. 갤러리는 자체 state를 가진 목록이고, 이미 여기 있는 것들로 조합됩니다.

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
