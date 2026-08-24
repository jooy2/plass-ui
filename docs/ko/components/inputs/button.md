---
title: PlButton
order: 1
---

# PlButton

<p class="plass-lede">액션을 실행하는 컨트롤입니다. 사용자가 의도적으로 일으키는 모든 것에 씁니다 — 폼 제출, 저장, 삭제.</p>

<Demo src="button/hero" />

```tsx
import { PlButton } from 'plass-ui';

<PlButton onClick={save}>Save</PlButton>;
```

## Props

<PropsTable name="PlButton" />

네이티브 `<button>` 속성은 그대로 전달됩니다. 예외는 `color` 하나로, 위 표의 `color`와 이름이 겹쳐서 제외했습니다.

공통 축(`variant` `size` `color` `density` `elevation`)이 라이브러리 전체에서 뜻하는 것은 [prop 규칙](../../design/prop-conventions)에 있습니다.

## 예제

### variant

`solid`는 색이 들어간 유리판이자 주요 액션입니다. `glass`는 hairline을 두른 맑은 시트로, 보조 액션에 씁니다. `ghost`는 포인터가 올라오기 전까지 표면이 없어서 툴바나 행에 어울립니다. 화면당 `solid`는 하나로 유지하세요.

`glass` 버튼은 색 계열을 **글자**에 두르므로, `color="secondary"`가 네 번째 variant가 아니라 조용한 중립 버튼이 됩니다.

셋 다 interaction light를 가집니다. 포인터를 따라 컨트롤 위를 옮겨 다니는 부드러운 빛과, 누를 때 한 단계 밝게 터진 뒤 약 700ms에 걸쳐 빠져나가는 flash입니다. 터치 화면에서는 버튼 위를 끄는 손가락을 따라갑니다. 빛은 `solid`에서는 흰색이고, 나머지 둘에서는 그 계열의 tint입니다.

<Demo src="button/variants">

<<< @/.vitepress/demos/button/variants.tsx

</Demo>

### color

여섯 가지 역할 색만 받습니다. 임의 색상값은 받지 않습니다. `solid`에서는 계열이 그러데이션과 그 아래 그림자이고, `glass`와 `ghost`에서는 라벨입니다.

<Demo src="button/colors" :min-height="100">

<<< @/.vitepress/demos/button/colors.tsx

</Demo>

### size

높이와 타입 스케일을 함께 정합니다. `xs` 24px · `sm` 32px · `md` 40px · `lg` 48px · `xl` 56px. `md`가 데스크톱 기본값이고, `lg`와 `xl`은 모두 모바일 터치 타깃 44px을 넘깁니다.

<Demo src="button/sizes">

<<< @/.vitepress/demos/button/sizes.tsx

</Demo>

### density

`density`는 좌우 여백만 바꿉니다. 같은 `size`의 두 버튼은 density와 무관하게 높이가 같아서, 섞어 놓은 줄도 기준선을 유지합니다.

<Demo src="button/density">

<<< @/.vitepress/demos/button/density.tsx

</Demo>

### startIcon과 endIcon

아이콘은 `1.2em`으로 그려져 라벨을 따라가므로 따로 크기를 줄 필요가 없습니다. 아이콘만 있고 `children`이 없으면 버튼은 정사각형이 되고, 그때는 `aria-label`이 필요합니다.

<Demo src="button/icons">

<<< @/.vitepress/demos/button/icons.tsx

</Demo>

### loading · readOnly · disabled

| prop       | 겉모습                                | Focus | 네이티브 `disabled` |
| ---------- | ------------------------------------- | ----- | ------------------- |
| `loading`  | 그대로. `startIcon` 자리에 스피너     | 유지  | 아니오              |
| `readOnly` | 색은 유지, 평평해지고 채도가 빠짐     | 유지  | 아니오              |
| `disabled` | 빛과 그림자를 잃고 페이지가 비쳐 보임 | 잃음  | 예                  |

셋 다 클릭이 부모로 올라가지 않습니다.

<Demo src="button/states">

<<< @/.vitepress/demos/button/states.tsx

</Demo>

### elevation

그림자 깊이입니다. 기본값은 `0`이 아니라 `1`입니다. 키는 시트 **위에** 놓이기 때문입니다. 호버는 한 단계를 올리고 누르면 한 단계를 내려서, 기본 버튼은 손가락 아래에서 유리에 딱 닿는 데까지 내려갑니다.

`solid` 버튼이 자기 색으로 드리우는 tint된 그림자는 이 사다리의 **일부가 아니며** 함께 커지지도 않습니다. `elevation`은 표면이 페이지에서 얼마나 떠 있는지를 말할 뿐이고, 한 단계 높은 `danger` 버튼이 더 붉은 유리판은 아니기 때문입니다.

<Demo src="button/elevation">

<<< @/.vitepress/demos/button/elevation.tsx

</Demo>

### fullWidth

컨테이너 너비만큼 늘어납니다.

<Demo src="button/full-width">

<<< @/.vitepress/demos/button/full-width.tsx

</Demo>

### render

`<button>` 대신 다른 요소로 렌더링합니다. 이동하는 액션은 `<a href>`여야 합니다. 크롤러가 따라가고, 스크린 리더의 링크 목록에 들어가며, 새 탭으로 열기나 주소 복사 같은 브라우저 자체 동작이 계속 작동합니다. 라우터의 `Link`도 같은 방식으로 넣습니다.

표면과 크기, 눌림의 signature는 그대로입니다. `<a>`에는 `disabled`가 없으므로, 사용 불가 상태가 되어야 하는 버튼은 `<button>`으로 남습니다.

<Demo src="button/render">

<<< @/.vitepress/demos/button/render.tsx

</Demo>

## 접근성

- 기본적으로 네이티브 `<button>`을 렌더링합니다. `type`이 그대로 전달되므로 폼 안에서 `type="submit"`이 동작합니다.
- `render`로 요소를 바꿔도 그 요소의 semantics는 유지됩니다. `<a href>`는 `role="button"`에 덮이지 않고 링크로 남습니다.
- 아이콘만 있는 버튼에는 `aria-label`을 주세요.
- focus ring은 `:focus-visible`에서만 나타나므로 마우스 클릭으로는 그려지지 않습니다.
- `loading`과 `readOnly`는 focus를 유지합니다. tab 순서에서 빠지면 키보드 사용자는 페이지에서 자기 위치를 잃습니다.
- 그러데이션의 두 끝이 모두 그 위의 라벨에 대해 4.5:1을 만족합니다.
- interaction light는 장식입니다. 어떤 상태도 담지 않으며, 무엇에 대해서도 유일한 신호가 아닙니다. `prefers-reduced-motion`에서는 easing이 멈춥니다.
