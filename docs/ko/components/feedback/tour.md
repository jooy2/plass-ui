---
title: PlTour
order: 16
---

# PlTour

<p class="plass-lede">이미 있는 화면 위를 함께 걷는 안내입니다. 새로 온 사람에게 한 번만 보여 주면 되는 세 가지를, 그것들이 실제로 있는 자리에서 가리킵니다.</p>

<Demo src="tour/hero" :min-height="320" />

::: fw react

```tsx
import { PlTour } from 'plass-ui';

const filter = useRef<HTMLDivElement>(null);

<PlTour
  open={running}
  onOpenChange={setRunning}
  steps={[
    { target: filter, title: 'Narrow the list', content: 'Type here.' },
    { target: '#export', title: 'Take it with you', side: 'left' },
    { title: 'That is all of it' }
  ]}
/>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlTour(
  open: _running,
  onOpenChanged: (bool next) => setState(() => _running = next),
  steps: <PlTourStep>[
    PlTourStep(target: _filterKey, title: const Text('Narrow the list')),
    PlTourStep(target: _exportKey, title: const Text('Take it with you')),
    const PlTourStep(title: Text('That is all of it')),
  ],
);
```

:::

## 먼저 알아 둘 한 가지

**어둠은 포인터를 받고, 빛은 받지 않습니다.**

가림막은 <Fw react="뷰포트" flutter="화면" /> 전체를 덮는 레이어 하나이고, 대상은 거기서 오려 내집니다. 오려 내는 방식이 칠하기가 아니라 **클립**입니다. 클립으로 잘려 나간 자리는 히트 테스트도 되지 않으므로, 읽는 사람은 가리키고 있는 그 컨트롤만 쓸 수 있고 다른 것은 쓸 수 없습니다. 투어와 "컨트롤 그림이 들어 있는 다이얼로그"를 가르는 지점입니다.

이것은 서로 맞춰야 하는 두 번째 장치가 아니라 도형에서 저절로 나오는 성질이고, 컴포넌트 전체가 그 위에 서 있습니다.

<Demo src="tour/mask" :min-height="280">

::: fw react

<<< @/.vitepress/demos/tour/mask.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tour/mask.dart

:::

</Demo>

같은 클립이 두 번째 것을 사 옵니다. 어둠이 **흐려질** 수 있습니다. 그림자로 그리거나 대상 둘레에 사각형 넷을 두는 방식은 색을 칠할 수만 있는데, 클립된 레이어는 backdrop 필터를 나를 수 있습니다. 그래서 빛 둘레의 페이지는 어두울 뿐 아니라 초점이 나가 있습니다. 회색을 덮어씌운 것이 아니라 이 라이브러리 자신의 재질입니다.

## `PlHowToSteps`를 뒤집은 것

[`PlHowToSteps`](../surfaces/how-to-steps)는 설명을 페이지 **안에** 두고 읽는 사람이 그것을 따라갑니다. `PlTour`는 페이지를 그대로 두고 그 위에 섭니다.

그래서 단계는 무엇을 설명하는 대신 _무엇에 대한 것인지 말합니다._ 투어가 가리키는 것은 이미 화면에 있고, 카드 안의 두 번째 사본은 맞춰 둬야 할 사본이 하나 더 생기는 일입니다. 단계에 `image`나 `example`이 없는 이유이고, 카드가 이만큼 작은 이유이기도 합니다.

읽는 사람이 다시 돌아올 내용이면 단계를, 다시 오지 않을 내용이면 투어를 쓰세요.

## Props

<PropsTable name="PlTour" />

::: fw react

`variant`와 `elevation`은 없습니다. 카드는 [`PlPopover`](popover)가 그리는 그 서리 낀 패널이고, 그림자 사다리의 맨 위를 답니다. 떠 있으라고 만든 것입니다. `solid`로 만든 투어 카드는 컨트롤이고, elevation `0`인 카드는 자기가 올라서 있는 페이지에 납작하게 붙습니다.

:::

::: fw flutter

`variant`와 `elevation`이 없는 이유는 React 빌드와 같습니다.

이 패키지의 다른 레이어가 전부 쓰는 내부 portal 위에 **서 있지 않습니다.** 설계의 전부가 그 이유입니다. 그 헬퍼는 포커스를 자기 안에 가두는데, 모달에는 맞고 여기서는 틀립니다. 가리키고 있는 컨트롤에 읽는 사람이 닿을 수 없는 투어는 그림을 가리킨 것입니다.

위젯은 쓰인 자리에 아무것도 그리지 않으므로 `Overlay` 아래 아무 데나 둘 수 있습니다. navigator가 있는 `WidgetsApp`과 `MaterialApp` 둘 다 하나씩 제공합니다.

:::

### PlTourStep

<PropsTable name="PlTourStep" />

::: fw react

**`target`은 세 가지 형태이고, 손을 뻗을 것은 첫 번째입니다.** **ref**는 컴파일러가 확인해 주고 이름을 바꿔도 살아남습니다. **선택자**는 누군가 클래스 이름을 바꾸는 순간 매칭이 멈출 수 있는 문자열이고, 그러면 투어는 빈 배경 위에 구멍을 뚫은 채로 계속 돕니다. 이 페이지가 렌더링하지 않은 것에 대상이 속할 때 유일하게 동작하는 형태라서 있습니다. **게터**는 찾는 데 질의 하나로 부족한 경우를 위한 것입니다.

:::

::: fw flutter

`target`은 `GlobalKey`이고 그것뿐입니다. 화면의 모든 위젯은 거기에 key를 달 수 있는 사람이 쓴 것이고, key는 컴파일러가 확인합니다. React 빌드가 선택자까지 내놓는 것은 웹 페이지에는 자기가 렌더링하지 않은 요소가 들어 있을 수 있기 때문입니다.

:::

공통 축(`size` `color` `density`)이 라이브러리 전체에서 무엇을 뜻하는지는 [프로퍼티 관례](../../design/prop-conventions)에 있습니다.

## Examples

### 카드가 놓이는 자리

`side`와 `align`이 빛에 대한 카드의 자리를 정하고, 요청한 쪽에 공간이 없으면 반대쪽으로 뒤집힙니다. **대상이 없는** 단계는 카드를 <Fw react="뷰포트" flutter="화면" /> 가운데에 놓고 아무것도 오려 내지 않습니다. 환영하는 단계와 마무리하는 단계가 그런 것입니다.

<Demo src="tour/sides" :min-height="280">

::: fw react

<<< @/.vitepress/demos/tour/sides.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tour/sides.dart

:::

</Demo>

::: fw flutter

뒤집기는 뒤집기이고 **미끄러지기가 아닙니다.** `PlPopover`가 하는 것과 같은 거래입니다. 대상이 가장자리에 가까워질수록 옆으로 기어가는 카드는 더 이상 무언가를 가리키는 것처럼 보이지 않는 카드입니다. 움직이는 것은 교차 축이고, 카드를 화면 안에 두는 데 필요한 만큼만 움직입니다.

:::

### 대상을 따라가기

투어는 살아 있는 페이지 위를 돕니다. 아래쪽에서 무언가 로딩을 끝낼 수 있고, 이미지가 도착할 수 있고, 창 크기가 바뀔 수 있습니다. 그러면 빛은 빈 배경 위에 남습니다.

::: fw react

측정은 스크롤과 리사이즈, 그리고 대상의 크기가 바뀔 때 다시 읽히고, 프레임당 한 번으로 모입니다. 스크롤은 페이지가 그려지는 것보다 훨씬 자주 발생하고, 읽을 때마다 레이아웃이 강제로 계산되기 때문입니다.

투어가 도는 동안 페이지는 **고정되지 않습니다.** 의도한 것입니다. 읽는 사람은 가리키고 있는 것을 쓸 수 있어야 하고, 그러려면 거기까지 스크롤해야 할 때가 있습니다.

:::

::: fw flutter

빛은 단계가 바뀔 때와 창 크기가 바뀔 때 측정됩니다. 스크롤되는 화면이라면 대상이 들어 있는 `ScrollController`를 투어에 건네세요. 투어는 `Overlay`로 들려 올라가 있어서 아래쪽의 스크롤 알림을 볼 수 없으므로, 스스로 알아낼 수 없는 그 하나를 받습니다. [`PlAnchor`](../navigation/anchor)가 받는 그 매개변수이고, 이유도 같습니다.

:::

`scrollIntoView`는 투어가 닿을 때마다 대상을 화면 안으로 데려오고, 기본으로 켜져 있습니다. 대상이 전부 이미 보이는 투어라면 끄세요. 아무것도 움직이지 않는 부드러운 스크롤은 아무것도 아닌 데 쓰는 한 프레임입니다.

### 제어하거나, 하지 않거나

`open`과 `step`은 각각 따로 제어할 수 있습니다. 첫 방문에 한 번 도는 투어는 `defaultOpen` 하나면 되고, 진행 상황을 어딘가에 저장하는 투어는 `step`과 `onStepChange`를 넘깁니다.

`onFinish`는 마지막 단계의 버튼을 누를 때, 투어가 닫히기 **전에** 불립니다. "이 사람은 이걸 봤다"를 기록하는 자리입니다.

## Accessibility

::: fw react

- 카드는 dialog이고, 단계의 `title`이 이름을, `content`가 설명을 줍니다.
- 어둠에는 `aria-hidden`이 붙습니다. 그림이고, 그것이 말하는 것은 이미 카드에 있습니다.
- `dismissible`이 `false`가 아니면 <kbd>Escape</kbd>가 투어를 끝냅니다. 카드 **바깥**을 누르는 것은 끝내지 않고, 포커스가 빠져나가는 것도 끝내지 않습니다. 페이지를 쓰는 것이야말로 투어가 있는 이유이므로, 나가는 길은 Escape와 ×와 Skip과 Done뿐입니다.
- 카운터는 문장이 아니라 숫자 둘입니다. "7 중 3"은 번역해야 하는 문자열이고 언어마다 어순이 다릅니다. 숫자 자체는 그렇지 않습니다.
- 버튼은 [어휘 묶음](../../guide/locales)에서 말을 가져오므로, 번역된 애플리케이션의 투어도 함께 번역됩니다.

:::

::: fw flutter

- 카드는 자기 자신으로 알려지고, 그 아래의 화면은 여전히 닿을 수 있는 자리에 있습니다. 일부러 route를 가져가지 않습니다. 가져가는 투어는 모달이고, 읽는 사람은 투어가 알려 주는 그 컨트롤에 갈 수 없게 됩니다.
- `dismissible`이 `false`가 아니면 <kbd>Escape</kbd>가 투어를 끝냅니다.
- 카운터가 숫자 둘인 이유는 React 빌드와 같습니다.
- 카드의 버튼은 가장자리로 넘치는 대신 둘째 줄로 넘어갑니다. 영어보다 단어가 긴 번역은 카드보다 버튼 세 개만큼 넓기 때문입니다.

:::

## Notes

- **투어는 문서가 아닙니다.** 세 단계는 투어이고, 아홉 단계는 서서 읽을 사람이 없는 설명서입니다. 그 하나하나가 읽는 사람과 그 사람이 제품을 연 이유 사이에 서 있습니다.
- **`mask={false}`는 진짜 선택지입니다.** 낮춰 잡은 버전이 아닙니다. 읽는 사람이 계속 일하고 있어야 하는 페이지 위의 투어 — 채우고 있는 폼 옆의 안내 — 는 어둠이 아예 없는 쪽이 낫습니다.
- **아무것도 기억하지 않습니다.** 이 사람이 투어를 봤는지는 애플리케이션이 저장할 몫이고, `onFinish`가 그것을 저장할 자리입니다.
