---
title: PlHotKeys
order: 3
---

# PlHotKeys

<p class="plass-lede">키보드 키 하나, 조합, 또는 키보드에 놓인 그대로의 이동 키 네 개입니다. <code>Mod</code>는 Mac에서는 ⌘로, 그 밖에서는 Ctrl로 해석됩니다.</p>

<Demo src="hot-keys/hero" :min-height="140" />

::: fw react

```tsx
import { PlHotKeys } from 'plass-ui';

<PlHotKeys keys="Mod+K" />;
<PlHotKeys cluster={{ up: 'W', left: 'A', down: 'S', right: 'D' }} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

const PlHotKeys(keys: 'Mod+K');
const PlHotKeys(cluster: PlHotKeysCluster(up: 'W', left: 'A', down: 'S', right: 'D'));
```

:::

## Props

<PropsTable name="PlHotKeys" />

::: fw react

네이티브 `<span>` 속성은 그대로 전달됩니다. `color`는 위 표의 `color`와 충돌해서, `children`은 키가 `keys`이기 때문에 제외됩니다.

:::

::: fw flutter

`keys`의 타입은 `Object?`인데, Dart에 없는 union을 쓰는 방법입니다. `+`로 나뉘는 `String`이거나, 키 자체가 `+`인 단축키를 위한 `List<String>`입니다.

:::

### PlKbd

<PropsTable name="PlKbd" />

`PlKbd`는 캡 하나입니다. 이 컴포넌트가 그리지 않는 배치 — 숫자 키패드, 기능키 줄 — 를 단축키 줄과 같은 물건으로 직접 조립할 수 있도록 export합니다.

라이브러리 전체에서 공유 축(`variant` `size` `color` `density` `elevation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### Mod, 그리고 os

`Mod`는 나머지가 존재하는 이유입니다. 철자만이 아니라 **뜻**이 플랫폼에 따라 달라지는 유일한 토큰으로, 단축키가 기반으로 삼는 modifier입니다 — Mac에서는 Command, 그 밖에서는 Control. `Ctrl+K`라고 쓴 페이지는 모든 Mac 독자에게 틀렸고, `⌘K`라고 쓴 페이지는 나머지 모두에게 틀렸습니다.

`os`의 기본값은 `auto`이고, 플랫폼에 묻습니다. 플랫폼을 명시하는 것은 페이지가 그래야 할 때뿐입니다 — Windows 빌드를 설명하는 지원 문서, 둘을 비교하는 표.

::: fw flutter

`auto`는 `defaultTargetPlatform`을 읽으므로, 테스트나 미리보기의 `debugDefaultTargetPlatformOverride`가 그것을 옮깁니다. Android와 Fuchsia는 Linux 표기로 해석되는데, 둘 중 어느 쪽에 붙는 물리 키보드든 그렇게 인쇄되어 있기 때문입니다.

:::

별칭은 전부 받습니다. `Cmd`, `Command`, `Meta`, `Super`는 한 키가 이미 가지고 있는 이름들이고, 그중 하나만 받는 컴포넌트는 모든 호출자가 매번 찾아봐야 하는 컴포넌트입니다.

<Demo src="hot-keys/os" :min-height="220">

::: fw react

<<< @/.vitepress/demos/hot-keys/os.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/hot_keys/os.dart

:::

</Demo>

### variant

기본값은 `glass`입니다. 헤어라인 상자이고, 인쇄된 매뉴얼에서 키캡이 언제나 그렇게 생겼습니다. 셋 다 아래에 2px 립을 답니다 — 라이브러리에서 표면 바로 아래에 각진 그림자가 붙는 유일한 자리인데, 그것이 "누르는 키"를 뜻하는 표시이기 때문입니다. 키의 *그림*은 키처럼 생겨도 되지만, 컨트롤은 키 그림처럼 생기면 안 됩니다.

<Demo src="hot-keys/variants" :min-height="100">

::: fw react

<<< @/.vitepress/demos/hot-keys/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/hot_keys/variants.dart

:::

</Demo>

### cluster

이동 키 네 개를 뒤집힌 T로 그립니다. `keys`의 레이아웃 옵션이 아니라 자기 prop인 이유는 둘이 서로 다른 물건이기 때문입니다 — 조합은 _함께_ 누르는 키들이고, cluster는 하나씩 누르는 키 넷인데 키보드 위의 배치 자체가 핵심입니다.

<Demo src="hot-keys/cluster" :min-height="160">

::: fw react

<<< @/.vitepress/demos/hot-keys/cluster.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/hot_keys/cluster.dart

:::

</Demo>

### size

캡은 컨트롤 사다리에서 한 단계 내려옵니다 — `md` 캡은 40px이 아니라 32px입니다. 캡은 문장 속 토큰이지, 줄이 기준선을 맞추는 컨트롤이 아닙니다.

<Demo src="hot-keys/sizes" :min-height="100">

::: fw react

<<< @/.vitepress/demos/hot-keys/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/hot_keys/sizes.dart

:::

</Demo>

### 목록 안에서

<Demo src="hot-keys/list" :min-height="280">

::: fw react

<<< @/.vitepress/demos/hot-keys/list.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/hot_keys/list.dart

:::

</Demo>

## Accessibility

::: fw react

- 각 키는 진짜 `<kbd>`입니다. 감싸는 것은 `<span>`입니다 — `<kbd>` 안에 `<kbd>`를 넣는 것도 적법하고 변호할 만하지만, `kbd` 상자를 하나 더 두는 것은 호스트 스타일시트가 손댈 자리를 하나 더 만드는 일이고 얻는 것이 없습니다.
- `⌘`는 단어가 아닙니다. 스크린리더는 이 문자를 "place of interest sign"으로 읽습니다. 글리프로 그려지는 모든 키는 화면에 보이지 않는 상자에 진짜 이름을 함께 실어서, Mac의 `Mod+K`가 "Command K"로 읽힙니다.
- 구분자는 `aria-hidden`이라, 단축키가 "Ctrl plus K"가 아니라 키들로 읽힙니다.
- 플랫폼은 `useSyncExternalStore`로 결정합니다. 서버의 답과 브라우저의 답이 다른 것이 *의도된 일*이라고 React에 말해 줄 수 있는 유일한 API입니다. 서버 렌더링된 페이지는 `Ctrl`로 hydrate하고 Mac에서는 `⌘`로 다시 렌더링되며, hydration mismatch 경고가 남지 않습니다.
- 이 컴포넌트는 단축키를 **보여 줄** 뿐 바인딩하지 않습니다. 키를 눌렀을 때 무슨 일이 일어나는지는 호출하는 쪽의 몫입니다.

:::

::: fw flutter

- `⌘`는 단어가 아닙니다. 스크린리더는 이 문자를 "place of interest sign"으로 읽습니다. 글리프로 그려지는 키는 대신 진짜 이름으로 알려지므로, Mac의 `Mod+K`가 "Command K"로 읽힙니다.
- 구분자는 semantics에서 제외되므로, 단축키가 "Ctrl plus K"가 아니라 키들로 읽힙니다.
- 어긋날 hydration이 없습니다. 플랫폼은 빌드 시점에 알 수 있고, 그려지는 캡은 처음부터 맞는 것 하나뿐입니다.
- 이 컴포넌트는 단축키를 **보여 줄** 뿐 바인딩하지 않습니다. 바인딩은 직접 두는 `Shortcuts` 위젯의 일이고, 키를 눌렀을 때 무슨 일이 일어나는지는 호출하는 쪽의 몫입니다.

:::

::: fw flutter

## React 빌드와 다른 점

| React | Flutter | 이유 |
| --- | --- | --- |
| 진짜 `<kbd>` | 그려진 캡 | Flutter에는 `kbd`가 없습니다. 그 요소가 사 주던 것 — "이 글자들은 키다" — 은 글리프 키가 알리는 이름이 대신 나릅니다. |
| `useSyncExternalStore` | `defaultTargetPlatform` | 맞춰야 할 서버 렌더링이 없습니다. 플랫폼은 첫 프레임 전에 이미 알려져 있습니다. |
| 나머지 전부에 `os="linux"` | Android와 Fuchsia도 | 둘 중 어느 쪽에 붙는 물리 키보드든 Linux처럼 인쇄되어 있습니다. |
| `string \| string[]`인 `keys` | `Object?` | Dart에는 union 타입이 없습니다. `+`로 나누는 형태와 목록 형태는 둘 다 그대로입니다. |
| `className`, `style` | — | 전달할 클래스 목록도 style 속성도 없습니다. |

:::
