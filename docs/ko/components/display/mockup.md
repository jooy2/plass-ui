---
title: PlMockup
order: 24
---

# PlMockup

<p class="plass-lede">무엇이든 얹을 수 있는 화면이 달린 기기입니다. 휴대폰, 태블릿, 모니터, 노트북에 각 시스템의 막대까지 그려 넣습니다.</p>

<Demo src="mockup/hero" :min-height="600" />

::: fw react

```tsx
import { PlMockup } from 'plass-ui';

<PlMockup device="mobile">
  <MyScreen />
</PlMockup>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlMockup(device: PlMockupDevice.mobile, child: MyScreen());
```

:::

**화면은 그 기기의 해상도를 가진 진짜 viewport입니다.** `md` 휴대폰은 390×844이고, 그다음에 기기 전체가 주어진 자리에 맞춰 한 번 축소됩니다. 그래서 안의 내용은 페이지가 아니라 _화면_ 에 대고 배치됩니다. 390px 열은 휴대폰에서 줄바꿈하는 자리에서 줄바꿈하고, mockup 자체는 페이지에서 200px 폭이어도 내용은 그것을 모릅니다.

이 축소가 라이브러리에서 유일한 `transform`입니다. 원래의 규칙은 컨트롤에 대한 것입니다. 컨트롤을 축소하면 누르고 있는 손가락 아래의 label이 다시 샘플링되니까요. 여기서는 아무것도 눌리지 않고, 축척은 상호작용으로 바뀌지 않습니다. 남은 자리에서 한 번 정해질 뿐이고, 1440px 데스크톱을 문단 하나 너비에 그리는 방법은 그것뿐입니다.

## Props

<PropsTable name="PlMockup" />

`device`는 기본값이 없는 유일한 prop입니다. 무엇의 mockup인지 말하지 않은 mockup은 아무 말도 하지 않은 것입니다.

**여기서 `size`는 높이도 타입 스케일도 정하지 않습니다.** 화면의 해상도를 정합니다. 기기에서 크기를 매길 수 있는 것은 그것뿐이고, 사다리가 컨트롤 높이가 아닌 것을 뜻하는 두 번째 컴포넌트입니다. 첫 번째는 [`PlBox`](../surfaces/box)입니다.

## Examples

### device와 hardware

<Demo src="mockup/device" :min-height="420">

::: fw react

<<< @/.vitepress/demos/mockup/device.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/mockup/device.dart

:::

</Demo>

데스크톱은 받침대나 키보드가 받쳐 줍니다. 태블릿과 휴대폰은 스스로 서 있으므로 `hardware`를 무시합니다.

`os`가 chrome을 고릅니다. 데스크톱은 `macos`·`windows`·`linux`, 태블릿은 `ipados`·`android`, 휴대폰은 `ios`·`android`를 씁니다. 그 밖의 값은 기기의 기본값으로 돌아가되 하나만 봐줍니다. 태블릿의 `ios`와 휴대폰의 `ipados`는 둘 다 애플 쪽을 뜻하고, 그대로 받습니다.

### finish

<Demo src="mockup/finish" :min-height="320">

::: fw react

<<< @/.vitepress/demos/mockup/finish.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/mockup/finish.dart

:::

</Demo>

테마 토큰이 아니라 고정된 색입니다. 하드웨어는 하드웨어니까요. 흑연색 휴대폰은 어두운 테마로 바꾼 페이지에서도 같은 흑연색이고, 테마를 따라 색이 바뀌는 기기는 기기의 그림이 아니라 테마의 그림으로 읽힙니다.

### bezel

<Demo src="mockup/bezel" :min-height="300">

::: fw react

<<< @/.vitepress/demos/mockup/bezel.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/mockup/bezel.dart

:::

</Demo>

`none`은 더 얇은 테두리가 아니라 **하드웨어가 아예 없는 것**입니다. 모서리만 깎인 화면만 남고, viewport만 원하는 mockup이 부르는 것이 그것입니다. `thick`은 옛날 기기입니다. 옆은 좁고 위아래에 이마와 턱이 있습니다.

### systemUi와 notch

시스템 막대는 내용을 덮지 않고 각자 자리를 차지합니다. mockup에 스크린샷을 넣는 사람은 스크린샷 전부를 원하고, 위를 가린 상태 표시줄은 아무도 부탁하지 않은 잘라내기입니다. `systemUi`를 끄면 그 자리를 돌려줄 뿐 무언가를 드러내지는 않습니다.

카메라 구멍만은 예외입니다. 그것은 정말로 유리에 뚫린 구멍이라서 막대와 무관하게 그려집니다. 기본값은 그 기기가 실제로 가진 것입니다. iOS 휴대폰은 다이내믹 아일랜드, 안드로이드는 펀치 홀, 그 밖에는 없음.

### orientation

가로로 돌리면 화면과 테두리와 구멍이 함께 돕니다. 테두리가 두꺼운 휴대폰의 이마와 턱이 좌우 가장자리가 되고, 아일랜드는 상태 표시줄 아래에서 빠져나옵니다.

데스크톱은 무시합니다. 모니터를 돌리는 사람이 있기는 하지만 그것의 mockup은 다른 그림입니다. 받침대는 움직이지 않고, 그런 척하면 세로 화면 아래에 가로 받침대를 그리게 됩니다.

## Accessibility

- 하드웨어는 장식이고 그렇게 말합니다. 테두리, 받침대, 카메라 구멍, 모든 시스템 막대가 보조 기술에서 감춰집니다. 읽히는 것은 화면에 얹은 내용입니다.
- chrome이 그리는 유일한 글자는 시계이고, 그것은 실제 시각이 아니라 prop입니다. mockup의 시계는 그림의 일부이고, 실제 시각을 읽으면 페이지를 그리는 서버와 hydrate하는 브라우저가 서로 달라집니다.
- React에서 화면은 container(`plass-screen`)입니다. 그래서 안의 내용이 창이 아니라 **기기**의 너비에 container query로 답할 수 있습니다.
