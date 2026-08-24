---
title: PlNumberField
order: 11
---

# PlNumberField

<p class="plass-lede">숫자만 담는 field입니다. 껍데기는 <code>PlTextField</code>와 픽셀 단위로 같고, 그 위에 진짜 숫자 컨트롤이 얹힙니다 — 방향키, 스테퍼, 범위 고정, locale을 아는 서식.</p>

<Demo src="number-field/hero" :min-height="260" />

```tsx
import { PlNumberField } from 'plass-ui';

<PlNumberField label="Quantity" min={1} max={12} defaultValue={2} />;
<PlNumberField label="Budget" locale="en-US" format={{ style: 'currency', currency: 'USD' }} />;
```

## Props

<PropsTable name="PlNumberField" />

네이티브 `<div>` 속성은 field를 감싸는 요소에 그대로 전달됩니다. `color`, `defaultValue`, `children`은 셋 다 여기서는 Plass의 prop이라 전달 대상에서 제외됩니다.

라이브러리 전체에서 공유 축(`variant` `size` `color` `density` `elevation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### steppers

`end`는 두 버튼을 뒤쪽 가장자리에 둡니다. spinner가 늘 그래 온 모양입니다. `split`은 빼기를 앞에, 더하기를 뒤에 두고 숫자를 그 사이에 놓습니다 — 타이핑하기보다 툭툭 밀어 올리는 수량을 위한 것입니다. `none`은 버튼을 빼지만 field는 여전히 숫자 field입니다. 방향키도, 범위 고정도, 서식도 그대로입니다.

반높이 chevron을 위아래로 쌓는 형태는 일부러 없습니다. `xs`에서 화살표 하나는 3px도 되지 않고, 그만한 표적은 아무도 맞히지 못합니다.

<Demo src="number-field/steppers" :min-height="300">

<<< @/.vitepress/demos/number-field/steppers.tsx

</Demo>

### format

`Intl.NumberFormat`으로 그대로 넘어갑니다. 그래서 화면에는 `$1,240.00`이나 `18.5%`가 보이고 `value`는 평범한 숫자로 남습니다. 입력된 것도 같은 locale로 되읽히는데, 그것이 쉼표가 소수점이어야 할 곳에서 소수점이 되게 하는 이유입니다.

<Demo src="number-field/format" :min-height="200">

<<< @/.vitepress/demos/number-field/format.tsx

</Demo>

### step, largeStep, smallStep

방향키와 스테퍼는 둘 다 `step`만큼 움직이고, Shift는 `largeStep`을, Alt는 `smallStep`을 씁니다. `snapOnStep`은 한 걸음이 하나만큼 움직이는 대신 배수에 내려앉게 합니다.

<Demo src="number-field/steps" :min-height="240">

<<< @/.vitepress/demos/number-field/steps.tsx

</Demo>

### variant

껍데기는 `PlTextField`와 픽셀 단위로 같습니다. 수량 상자만 주변 상자들과 높이나 모서리가 다른 form은 설계된 것이 아니라 조립된 것처럼 보이는 form입니다 — 그래서 여기서도 `solid`는 색이 들어간 판이 아니라 시트에 파인 우물입니다.

<Demo src="number-field/variants" :min-height="300">

<<< @/.vitepress/demos/number-field/variants.tsx

</Demo>

### 상태

`readOnly`는 숫자를 읽을 수 있게 두고 스테퍼를 없앱니다. 바뀔 수 없는 값에는 누를 것이 없습니다. `error`는 field 자체를 invalid로 만들고, 그것이 색 계열 전체를 `danger`로 돌려세워 가장자리와 ring, 캐럿, 메시지가 함께 넘어가게 합니다.

<Demo src="number-field/states" :min-height="380">

<<< @/.vitepress/demos/number-field/states.tsx

</Demo>

### size

<Demo src="number-field/sizes" :min-height="420">

<<< @/.vitepress/demos/number-field/sizes.tsx

</Demo>

## Accessibility

- 어려운 부분은 Base UI의 NumberField가 가집니다. locale에 맞춰 입력을 해석하는 것, `min`/`max`로 고정하는 것, 스테퍼를 누르고 있을 때의 반복, form과 함께 제출되는 숨은 input.
- 라벨과 설명, 오류는 Base UI의 Field가 컨트롤에 연결하므로 어느 것도 호출하는 쪽의 `id`를 필요로 하지 않습니다.
- 두 스테퍼에는 이미 접근 가능한 이름이 있습니다. `incrementLabel`과 `decrementLabel`이 그것을 바꿉니다.
- 범위 끝에 닿은 스테퍼는 흐려지기만 하는 것이 아니라 진짜로 `disabled`입니다.
- `allowWheelScrub`은 기본적으로 꺼져 있습니다. 포인터 아래에서 스크롤되는 페이지와 값이 바뀌는 field는 같은 동작이고, 의도된 것은 둘 중 하나뿐입니다.
