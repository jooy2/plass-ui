---
title: PlButton
order: 1
---

# PlButton

<p class="plass-lede">액션을 실행하는 컨트롤입니다. 사용자가 의도적으로 일으키는 모든 것에 씁니다 — 폼 제출, 저장, 삭제.</p>

<Demo src="button/hero" />

::: fw react

```tsx
import { PlButton } from 'plass-ui';

<PlButton onClick={save}>Save</PlButton>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlButton(onPressed: save, child: const Text('Save'));
```

:::

## Props

<PropsTable name="PlButton" />

::: fw react

네이티브 `<button>` 속성은 그대로 전달됩니다. 예외는 `color` 하나로, 위 표의 `color`와 이름이 겹쳐서 제외했습니다.

:::

::: fw flutter

`PlButton`은 트리 위쪽에 아무것도 필요하지 않습니다. `PlassTheme`이 없으면 플랫폼의 밝기를 따라가므로, 어느 앱에 그냥 놓아도 이미 맞는 테마입니다. 넘어오지 않는 것들은 [React 빌드와 다른 점](#react-빌드와-다른-점)에 있습니다.

:::

공통 축(`variant` `size` `color` `density` `elevation`)이 라이브러리 전체에서 뜻하는 것은 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### variant

`solid`는 색이 들어간 유리판이자 주요 액션입니다. `glass`는 hairline을 두른 맑은 시트로, 보조 액션에 씁니다. `ghost`는 포인터가 올라오기 전까지 표면이 없어서 툴바나 행에 어울립니다. 화면당 `solid`는 하나로 유지하세요.

`glass` 버튼은 색 계열을 **글자**에 두르므로, <Fw react='color="secondary"' flutter='color: PlassColor.secondary' code />가 네 번째 variant가 아니라 조용한 중립 버튼이 됩니다.

셋 다 interaction light를 가집니다. 포인터를 따라 컨트롤 위를 옮겨 다니는 부드러운 빛과, 누를 때 한 단계 밝게 터진 뒤 약 700ms에 걸쳐 빠져나가는 flash입니다. 터치 화면에서는 버튼 위를 끄는 손가락을 따라갑니다. 빛은 `solid`에서는 흰색이고, 나머지 둘에서는 그 계열의 tint입니다.

<Demo src="button/variants">

::: fw react

<<< @/.vitepress/demos/button/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button/variants.dart

:::

</Demo>

### color

여섯 가지 역할 색만 받습니다. 임의 색상값은 받지 않습니다. `solid`에서는 계열이 그러데이션과 그 아래 그림자이고, `glass`와 `ghost`에서는 라벨입니다.

<Demo src="button/colors" :min-height="100">

::: fw react

<<< @/.vitepress/demos/button/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button/colors.dart

:::

</Demo>

### size

높이와 타입 스케일을 함께 정합니다. `xs` 24px · `sm` 32px · `md` 40px · `lg` 48px · `xl` 56px. `md`가 데스크톱 기본값이고, `lg`와 `xl`은 모두 모바일 터치 타깃 44px을 넘깁니다.

<Demo src="button/sizes">

::: fw react

<<< @/.vitepress/demos/button/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button/sizes.dart

:::

</Demo>

### density

`density`는 좌우 여백만 바꿉니다. 같은 `size`의 두 버튼은 density와 무관하게 높이가 같아서, 섞어 놓은 줄도 기준선을 유지합니다.

::: fw flutter

기본 트랙의 이름은 `PlassDensity.standard`입니다. React 패키지에서는 `'default'`인데, Dart에서 `default`는 예약어입니다. 공통 어휘 중에서 두 패키지가 다르게 부르는 값은 이것 하나뿐입니다.

:::

<Demo src="button/density">

::: fw react

<<< @/.vitepress/demos/button/density.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button/density.dart

:::

</Demo>

### startIcon과 endIcon

아이콘은 `1.2em`으로 그려져 라벨을 따라가므로 따로 크기를 줄 필요가 없습니다. 아이콘만 있고 <Fw react="children" flutter="child" code />가 없으면 버튼은 정사각형이 되고, 그때는 <Fw react="aria-label" flutter="semanticLabel" code />이 필요합니다.

::: fw flutter

크기는 `IconTheme`으로 전달되며 `Icon`은 이것을 알아서 읽습니다. 다른 방식으로 그린 글리프라면 아래 데모처럼 `IconTheme.of(context)`를 읽으면 됩니다.

:::

<Demo src="button/icons">

::: fw react

<<< @/.vitepress/demos/button/icons.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button/icons.dart

:::

</Demo>

### loading · readOnly · disabled

::: fw react

| prop       | 겉모습                                | Focus | 네이티브 `disabled` |
| ---------- | ------------------------------------- | ----- | ------------------- |
| `loading`  | 그대로. `startIcon` 자리에 스피너     | 유지  | 아니오              |
| `readOnly` | 색은 유지, 평평해지고 채도가 빠짐     | 유지  | 아니오              |
| `disabled` | 빛과 그림자를 잃고 페이지가 비쳐 보임 | 잃음  | 예                  |

:::

::: fw flutter

| 파라미터   | 겉모습                                | Focus |
| ---------- | ------------------------------------- | ----- |
| `loading`  | 그대로. `startIcon` 자리에 스피너     | 유지  |
| `readOnly` | 색은 유지, 평평해지고 채도가 빠짐     | 유지  |
| `disabled` | 빛과 그림자를 잃고 페이지가 비쳐 보임 | 잃음  |

셋 다 사용 불가로 읽히고, 포커스 순서에서 빠지는 것은 `disabled`뿐입니다. Flutter에는 `aria-busy`에 해당하는 것이 없어서 스크린 리더는 `loading`과 `readOnly`를 구분하지 못합니다. 화면에서 그 차이가 중요하다면 `semanticLabel`에 담으세요.

`onPressed`를 비워 두면 `disabled: true`와 같습니다. Flutter 개발자가 먼저 손이 가는 쪽이기 때문입니다.

:::

셋 다 탭이 부모로 올라가지 않습니다.

<Demo src="button/states">

::: fw react

<<< @/.vitepress/demos/button/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button/states.dart

:::

</Demo>

### elevation

그림자 깊이입니다. 기본값은 `0`이 아니라 `1`입니다. 키는 시트 **위에** 놓이기 때문입니다. 호버는 한 단계를 올리고 누르면 한 단계를 내려서, 기본 버튼은 손가락 아래에서 유리에 딱 닿는 데까지 내려갑니다.

`solid` 버튼이 자기 색으로 드리우는 tint된 그림자는 이 사다리의 **일부가 아니며** 함께 커지지도 않습니다. `elevation`은 표면이 페이지에서 얼마나 떠 있는지를 말할 뿐이고, 한 단계 높은 `danger` 버튼이 더 붉은 유리판은 아니기 때문입니다.

<Demo src="button/elevation">

::: fw react

<<< @/.vitepress/demos/button/elevation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button/elevation.dart

:::

</Demo>

### fullWidth

컨테이너 너비만큼 늘어납니다.

<Demo src="button/full-width">

::: fw react

<<< @/.vitepress/demos/button/full-width.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button/full_width.dart

:::

</Demo>

::: fw react

### render

`<button>` 대신 다른 요소로 렌더링합니다. 이동하는 액션은 `<a href>`여야 합니다. 크롤러가 따라가고, 스크린 리더의 링크 목록에 들어가며, 새 탭으로 열기나 주소 복사 같은 브라우저 자체 동작이 계속 작동합니다. 라우터의 `Link`도 같은 방식으로 넣습니다.

표면과 크기, 눌림의 signature는 그대로입니다. `<a>`에는 `disabled`가 없으므로, 사용 불가 상태가 되어야 하는 버튼은 `<button>`으로 남습니다.

<Demo src="button/render">

<<< @/.vitepress/demos/button/render.tsx

</Demo>

:::

## Accessibility

::: fw react

- 기본적으로 네이티브 `<button>`을 렌더링합니다. `type`이 그대로 전달되므로 폼 안에서 `type="submit"`이 동작합니다.
- `render`로 요소를 바꿔도 그 요소의 semantics는 유지됩니다. `<a href>`는 `role="button"`에 덮이지 않고 링크로 남습니다.
- 아이콘만 있는 버튼에는 `aria-label`을 주세요.
- focus ring은 `:focus-visible`에서만 나타나므로 마우스 클릭으로는 그려지지 않습니다.
- `loading`과 `readOnly`는 focus를 유지합니다. tab 순서에서 빠지면 키보드 사용자는 페이지에서 자기 위치를 잃습니다.
- 그러데이션의 두 끝이 모두 그 위의 라벨에 대해 4.5:1을 만족합니다.
- interaction light는 장식입니다. 어떤 상태도 담지 않으며, 무엇에 대해서도 유일한 신호가 아닙니다. `prefers-reduced-motion`에서는 easing이 멈춥니다.

:::

::: fw flutter

- 활성 여부와 무관하게 버튼으로 읽히며, 이름은 `child`에서 가져옵니다.
- 아이콘만 있는 버튼에는 `semanticLabel`을 주세요.
- focus ring은 CSS가 `:focus-visible`이라 부르는 경우에만 나타납니다. 키보드로 도달했을 때만이고, 포인터로 클릭했을 때는 그려지지 않습니다. Flutter에서 같은 구분을 하는 것이 `FocusableActionDetector`의 focus highlight입니다.
- <kbd>Enter</kbd>, <kbd>Space</kbd>, 그리고 숫자패드 <kbd>Enter</kbd>로 활성화됩니다. 버튼 자신에 바인딩되어 있어서 위에 앱 위젯이 있든 없든 동작이 같습니다.
- `loading`과 `readOnly`는 focus를 유지합니다. 포커스 순서에서 빠지면 키보드 사용자는 페이지에서 자기 위치를 잃습니다.
- 그러데이션의 두 끝이 모두 그 위의 라벨에 대해 4.5:1을 만족합니다.
- interaction light는 장식입니다. 어떤 상태도 담지 않으며, 무엇에 대해서도 유일한 신호가 아닙니다. 애니메이션을 끈 플랫폼(`MediaQuery.disableAnimations`)에서는 easing이 멈춥니다.

:::

::: fw flutter

## React 빌드와 다른 점

위의 내용은 두 패키지에서 모두 같습니다. 아래는 같지 않은 지점과 그 이유입니다.

| React | Flutter | 이유 |
| --- | --- | --- |
| `render` | — | Flutter에는 다형 엘리먼트가 없습니다. 이동하는 액션은 `onPressed`에서 라우터를 호출하세요. |
| `className`, `style`, 네이티브 속성 | — | 전달할 클래스 목록도 style 속성도 없습니다. 대신 `focusNode`, `autofocus`, `onLongPress`가 있습니다. |
| `onClick` | `onPressed` | Flutter의 이름입니다. `onPressed: null`은 Flutter 어디서나 그렇듯 버튼을 비활성으로 만듭니다. |
| `children` | `child` | Flutter의 이름입니다. |
| `aria-label` | `semanticLabel` | Flutter의 이름입니다. |
| `density="default"` | `PlassDensity.standard` | Dart에서 `default`는 예약어입니다. |
| `prefers-reduced-motion` | `MediaQuery.disableAnimations` | 플랫폼 자신의 신호입니다. |

API는 아니지만 눈에 보이는 차이가 둘 더 있습니다.

- **폰트.** 두 패키지 모두 폰트를 지정하지 않습니다. 버튼은 호스트가 쓰는 폰트를 그대로 물려받고, 폰트를 공급하는 건 양쪽 다 앱의 몫입니다. 이 페이지의 React 미리보기는 문서 사이트의 UI 폰트로, Flutter 미리보기는 갤러리가 싣고 있는 Inter로 그려집니다. 서체가 둘일 뿐 같은 버튼입니다.

  들리는 것보다 중요한 이야기인데, **라벨이 weight 600이고 모든 폰트에 600이 있는 건 아니기 때문입니다.** Flutter 엔진이 들고 다니는 페이스는 Roboto Regular 하나뿐이고 나머지 weight는 획을 굵혀서 합성합니다. Roboto 자체도 400 → 500 → 700이라 600이 없습니다. 그래서 진짜 SemiBold가 없는 폰트를 쓰는 앱에서는 라벨이 위 미리보기보다 두껍고 눈에 띄게 뭉개져 보입니다. Inter·Pretendard·SF·Noto Sans에는 600이 있고, Roboto에는 없습니다.

- **블러.** `glass`는 뒤에 그려진 것을 블러하는데, Flutter에서 그것은 **같은 앱 안**을 뜻합니다. 여기 미리보기는 iframe이므로 갤러리가 페이지의 배경을 직접 그립니다. Flutter 미리보기의 `glass` 버튼 앞에 무언가가 있는 이유가 그것입니다.

나머지는 전부 의도적으로 맞췄습니다. 같은 숫자를 쓰면 오히려 틀렸을 곳까지 포함해서 — 그림자 블러는 CSS의 반지름을 Flutter의 시그마로 변환해 두 그림자의 크기가 같도록 했고, `solid`의 그러데이션은 대각선이 아니라 `linear-gradient(135deg, …)`가 하는 방식으로 끝점을 계산합니다. 가로로 긴 버튼에서는 눈에 띄게 다른 sweep이기 때문입니다.

:::
