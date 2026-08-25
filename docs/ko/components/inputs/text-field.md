---
title: PlTextField
order: 2
---

# PlTextField

<p class="plass-lede">한 줄 또는 여러 줄 텍스트 입력입니다. 라벨과 보조 설명, 오류 메시지가 직접 엮어야 하는 세 요소가 아니라 컴포넌트의 일부입니다.</p>

<Demo src="text-field/hero" :min-height="180" />

```tsx
import { PlTextField } from 'plass-ui';

<PlTextField label="Email" type="email" description="We never share it." />;
```

## Props

<PropsTable name="PlTextField" />

네이티브 `<input>` 속성은 그대로 전달되고, `multiline`일 때는 `<textarea>` 속성이 그대로 전달됩니다. 예외는 위 공통 축과 이름이 겹치는 `color`와 `size`입니다.

공통 축이 라이브러리 전체에서 뜻하는 것은 [prop 규칙](../../design/prop-conventions)에 있습니다.

## 예제

### variant

`glass`가 기본값입니다. hairline을 두른 시트이고, Plass 화면에서 필드란 그런 것입니다. 그 hairline은 `--plass-border`, tick과 switch와 tabs의 레일이 긋는 것과 같은 중립 선입니다. 시트 자기 흰 테두리가 아닌 이유는, 필드가 페이지 배경이 아니라 카드 위에 놓이는 일이 아주 흔하고, 흰 카드 위 거의 흰 상자에 흰 선을 두르면 필드의 모양을 볼 수 없기 때문입니다. `solid`는 **우물**입니다 — 가장 불투명한 유리에 라이브러리에서 유일하게 안쪽으로 떨어지는 그림자가 얹힌 형태로, 떠 있기보다 파인 것처럼 보여야 하는 필드에 씁니다. `ghost`는 포인터가 올라오기 전까지 표면이 없어서 테이블 셀 안의 필드에 어울립니다.

`solid` 필드는 의도적으로 색 유리판이 **아닙니다**. 캐럿과 텍스트 선택, placeholder 아래에 깔린 그러데이션은 읽히지 않기 때문에, 색 계열은 대신 hairline과 focus ring, 캐럿에 나타납니다.

<Demo src="text-field/variants" :min-height="240">

<<< @/.vitepress/demos/text-field/variants.tsx

</Demo>

### size

PlButton과 같은 사다리입니다 — `xs` 24px · `sm` 32px · `md` 40px · `lg` 48px · `xl` 56px. 같은 `size`의 필드와 버튼은 한 줄에서 기준선이 맞습니다.

<Demo src="text-field/sizes" :min-height="260">

<<< @/.vitepress/demos/text-field/sizes.tsx

</Demo>

### label, description, error

셋 다 노드이고, 셋 다 Base UI의 `Field`가 컨트롤과 연결해 줍니다. 라벨은 컨트롤을 가리키고, 두 메시지는 모두 컨트롤의 `aria-describedby`에 들어갑니다.

floating label variant는 없습니다. floating label은 입력 중인 대상에 `transform`을 걸어야 하는데, 캐럿 아래에서 움직이는 라벨은 이 라이브러리가 컨트롤에 대해 유일하게 금지하는 효과입니다.

### 유효성

`error`는 메시지를 담는 **동시에** 필드를 invalid로 만들고, 그러면 slot 계열 전체가 `danger`로 넘어갑니다. hairline과 focus ring, 캐럿, 메시지가 한꺼번에 바뀝니다.

폼 라이브러리가 유효성을 가질 때를 위한 탈출구가 둘 있습니다. `invalid`는 메시지 없이 상태만 켜고, `invalid={false}`는 상태 없이 메시지만 보여 줍니다.

<Demo src="text-field/validation" :min-height="120">

<<< @/.vitepress/demos/text-field/validation.tsx

</Demo>

### multiline

`<textarea>`를 렌더링합니다. 나머지 축은 완전히 동일하고, 한 줄짜리 textarea는 같은 `size`의 한 줄 필드와 정확히 같은 높이입니다. 세로 여백이 높이 사다리에서 계산되기 때문에 `density`는 여기에 손대지 않습니다.

`resize`는 사용자가 어느 방향으로 끌 수 있는지를 정합니다. 가로로 늘리면 폼의 열이 깨지므로 기본값은 세로 축만입니다.

<Demo src="text-field/multiline" :min-height="300">

<<< @/.vitepress/demos/text-field/multiline.tsx

</Demo>

### startIcon과 endIcon

`em`으로 그려져 글자를 따라갑니다. 컨트롤 안이 아니라 shell에 붙으며 컨트롤의 focus에 반응합니다 — 필드가 focus되면 adornment가 muted에서 accent 색으로 바뀝니다.

adornment는 컨트롤의 **첫 줄**을 기준으로 가운데 정렬되므로, multiline 필드가 늘어나도 자리를 지킵니다.

<Demo src="text-field/icons" :min-height="220">

<<< @/.vitepress/demos/text-field/icons.tsx

</Demo>

### loading · readOnly · disabled

| prop       | 겉모습                            | 입력              | Focus |
| ---------- | --------------------------------- | ----------------- | ----- |
| `loading`  | `endIcon` 자리에 스피너           | 가능              | 유지  |
| `readOnly` | 색은 유지, 평평해지고 채도가 빠짐 | 불가, 선택은 가능 | 유지  |
| `disabled` | 시트 너머로 페이지가 비쳐 보임    | 불가              | 잃음  |

`loading`이 입력을 계속 허용하는 것은 의도된 것입니다. 필드가 로딩 중인 이유는 대개 거기에 입력된 내용 *때문*입니다.

<Demo src="text-field/states" :min-height="300">

<<< @/.vitepress/demos/text-field/states.tsx

</Demo>

### Controlled

`value`와 `onChange`는 네이티브 input에서와 똑같이 동작합니다. `onChange`는 두 요소를 모두 받도록 타입이 잡혀 있어서 `multiline`에서도 같은 핸들러가 그대로 쓰입니다.

<Demo src="text-field/controlled" :min-height="120">

<<< @/.vitepress/demos/text-field/controlled.tsx

</Demo>

## 접근성

- 네이티브 `<input>`을, `multiline`에서는 `<textarea>`를 렌더링합니다. 둘 다 각자의 요소가 받는 모든 속성을 받습니다.
- `label`은 컨트롤을 가리키는 실제 `<label>`입니다. 라벨이 없다면 `aria-label`을 주거나, placeholder가 유일한 이름이 되지 않게 하세요.
- `description`과 `error`는 모두 `aria-describedby`에 들어가므로, 스크린 리더가 메시지를 필드 뒤가 아니라 필드와 함께 읽습니다.
- `error`와 `invalid`는 `aria-invalid`를 설정합니다.
- focus ring은 컨트롤이 아니라 shell에 그려져서, 안쪽에 떠 있는 사각형이 아니라 유리의 가장자리를 따라갑니다. `:focus-visible`에서만 나타납니다.
- shell의 여백을 클릭하면 네이티브 input 안을 클릭했을 때처럼 캐럿이 필드로 들어갑니다.
