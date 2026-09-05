---
title: 말 번역하기
order: 3
---

# 말 번역하기

<p class="plass-lede">스물몇 개의 컴포넌트가 스스로 말을 합니다. 닫기 버튼의 이름, 페이저의 랜드마크, 목록이 비었을 때 나오는 한 줄. 그 말들은 번역된 묶음으로 함께 배포되고, 설정 하나가 전부를 한 번에 뒤집습니다.</p>

<Demo src="provider/labels" :min-height="360">

::: fw react

<<< @/.vitepress/demos/provider/labels.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/provider/labels.dart

:::

</Demo>

## 설정 둘, 역할 둘

`locale`과 `labels`는 둘 다 필요하고, 어느 쪽도 다른 쪽을 대신하지 않습니다.

::: fw react

`locale`은 `Intl`이 형식을 맞추는 BCP 47 태그입니다. 날짜가 `9/4/2026`이 아니라 `2026. 9. 4.`로 읽히는지, 7월을 뭐라고 부르는지, 천 단위 구분이 어디에 들어가는지를 정합니다. 전부 플랫폼의 몫이라 라이브러리는 달 이름을 하나도 싣지 않습니다.

`labels`는 `Intl`이 아무 의견도 갖지 않는 일흔다섯 개의 문자열입니다. "닫기"는 날짜도 숫자도 아니고, 플랫폼의 어느 부분도 그 말을 모릅니다.

:::

::: fw flutter

`labels`는 위젯이 스스로에 대해 말하는 일흔일곱 개의 문자열입니다. React 쪽보다 둘 많고, 이유는 [`PlDataTable`](../components/display/data-table) 페이지에 있습니다. `aria-sort`가 나르는 뜻을 여기서는 말로 해야 합니다. 프레임워크에 `Intl`이 없으니 날짜는 별도 객체입니다. `PlDateNames`가 달 이름과 요일 약자를 들고 있고, 지정하는 방법은 같습니다. [기본값 정하기](defaults)를 보세요.

:::

## 묶음

일곱 개 언어가 함께 배포되고, 각각이 완전한 한 벌입니다.

::: fw react

```tsx
import { PlassProvider } from 'plass-ui';
import { ko } from 'plass-ui/locales';

<PlassProvider locale="ko-KR" labels={ko}>
  <App />
</PlassProvider>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/locales.dart';
import 'package:plass_ui/plass_ui.dart';

PlassTheme.merge(
  defaults: const PlassDefaults(labels: ko),
  child: const MyApp(),
);
```

묶음은 `plass_ui.dart`와 따로 가져오는 **독립된 라이브러리**입니다. 자기 말을 직접 쓰는 애플리케이션은 이 파일들을 컴파일할 일이 없습니다.

:::

| 이름     | 언어        | 함께 쓰는 태그 |
| -------- | ----------- | -------------- |
| `de`     | 독일어      | `de-DE`        |
| `en`     | 영어        | `en-US`        |
| `es`     | 스페인어    | `es-ES`        |
| `fr`     | 프랑스어    | `fr-FR`        |
| `ja`     | 일본어      | `ja-JP`        |
| `ko`     | 한국어      | `ko-KR`        |
| `zhHans` | 중국어 간체 | `zh-Hans-CN`   |

목록이 짧은 것은 의도입니다. 묶음은 그 언어를 읽는 사람이 읽어 본 뒤에야 실을 값이 있으므로, 이것은 기계가 만들 수 있는 목록이 아니라 사람이 읽은 목록입니다.

## 조회표가 아니라 import인 이유

::: fw react

`locales['ko']` 같은 표가 API로는 더 짧고, 그래서 틀립니다. 표에서 키를 찾으려면 표가 번들에 들어 있어야 하므로, 프랑스어 애플리케이션이 한국어와 일본어를 비롯한 나머지 전부를 함께 싣게 됩니다. import는 하나만 싣습니다.

대가는 실행 중에 문자열로 언어를 고를 수 없다는 것입니다. 정말로 실행 중에 언어를 바꾸는 애플리케이션은 자기가 제공하는 묶음만 가져와 고르면 됩니다. 자기 문구를 다룰 때 이미 쓰고 있는 코드와 같은 모양입니다.

```tsx
import { de, en, ko } from 'plass-ui/locales';

const packs = { de, en, ko };

<PlassProvider locale={tag} labels={packs[language]}>
  <App />
</PlassProvider>;
```

라이브러리에 일곱 개가 있어서 일곱 개가 아니라, 애플리케이션이 셋을 제공하니까 셋이 번들에 들어갑니다.

:::

::: fw flutter

Dart의 트리 셰이킹은 표에서 참조되지 않은 묶음을 알아서 걷어내므로 여기서의 이유는 더 작습니다. `plass_ui.dart`는 애플리케이션의 모든 파일이 이미 가져오는 import이고, 그 뒤에 번역 일곱 벌을 놓으면 그 모든 파일이 분석 단계에서 번역을 짊어집니다. 라이브러리를 하나 더 두면 어휘가 어휘를 쓰는 자리에만 남습니다.

:::

## 한 단어씩

묶음은 출발점이지 천장이 아닙니다. 말을 하는 컴포넌트는 그 말을 프로퍼티로 받고, 프로퍼티가 이깁니다.

::: fw react

```tsx
<PlassProvider labels={ko}>
  <PlTransfer sourceLabel="검토 대기" targetLabel="이번 호" items={items} />
</PlassProvider>
```

일부만 담은 객체도 됩니다. 묶음이 있든 없든 마찬가지고, 빠뜨린 것은 영어로 남습니다. `{ ...ko, start: '체크인' }`은 한 단어만 바꾼 묶음이고, `PlDateRangePicker`가 두 날짜 사이에 띄우는 안내처럼 어느 컴포넌트도 프로퍼티로 받지 않는 말에 닿는 방법이기도 합니다.

:::

::: fw flutter

```dart
PlTransfer(items: items, sourceLabel: '검토 대기', targetLabel: '이번 호')
```

한 위젯이 아니라 화면 전체에 닿아야 하는 변경, 또는 `PlDateRangePicker`가 두 날짜 사이에 띄우는 안내처럼 어느 위젯도 매개변수로 받지 않는 말에는 `copyWith`가 그 단어만 바꾼 묶음을 줍니다.

```dart
PlassTheme.merge(
  defaults: PlassDefaults(labels: ko.copyWith(start: '체크인')),
  child: child,
);
```

:::

## 우선순위

**컴포넌트 자신의 프로퍼티 → 가장 가까운 프로바이더의 묶음 → 영어.**

::: fw react

병합은 키 단위입니다. 네 단어만 정한 프로바이더는 나머지 일흔한 개를 영어로 두고, 다른 프로바이더 안에 들어간 프로바이더는 자기가 이름 붙인 것만 바꾸고 나머지는 물려받습니다.

주변 컴포넌트와 줄을 맞춰야 하는 자기 컴포넌트를 위해, 걸려 있는 값을 읽는 방법입니다.

```tsx
import { defaultLabels, usePlassDefaults } from 'plass-ui';

const { labels } = usePlassDefaults();
const close = labels?.close ?? defaultLabels.close;
```

:::

::: fw flutter

`PlassLabels`는 완전한 한 벌입니다. 이름 붙이지 않은 필드는 생성자에서 영어가 되므로, 테마의 labels는 위쪽 것에 병합되지 않고 대체합니다. 안쪽 테마가 바깥 테마의 말을 지키는 방법이 `copyWith`입니다.

걸려 있는 값을 읽는 방법입니다.

```dart
final PlassLabels labels = PlassTheme.labelsOf(context);
```

아무 테마도 정하지 않았으면 `PlassLabels.english`를 돌려줍니다.

:::

## 단어는 뜻이지 컴포넌트가 아닙니다

한 벌은 평평한 목록 하나이고, 키는 그 말을 하는 컴포넌트가 아니라 그 말의 뜻을 따라 이름 붙입니다. `close`는 모달과 드로어와 팝오버와 토스트의 ×이고, 한 번만 번역됩니다. 컴포넌트마다 키를 두는 것은 말이 정말로 다를 때뿐입니다. 페이저의 `paginationNext`는 한 페이지를 움직이고 캐러셀의 `carouselNext`는 한 장을 움직이므로, 그 둘을 구별하는 언어에는 구별을 놓을 자리가 있습니다.

## 언어 추가하기

묶음은 같은 모양의 파일 하나이고, 정직함을 지키는 것은 타입입니다. 빠진 키는 조용히 영어로 남는 말이 아니라 컴파일 오류입니다.

::: fw react

```tsx
// packages/react/src/locales/it.ts
import type { PlassLabels } from '../internal/labels.js';

export const it: PlassLabels = {
  close: 'Chiudi'
  // …그리고 나머지 모든 키.
};
```

`src/locales/index.ts`에서 내보내면, 모든 묶음을 영어와 대조하는 패키지 테스트가 그때부터 이 묶음도 지켜 줍니다.

:::

::: fw flutter

```dart
// packages/flutter/lib/src/locales/it.dart
const PlassLabels it = PlassLabels(close: 'Chiudi');
```

`lib/locales.dart`에서 내보내세요. 여기서는 필드를 빠뜨려도 컴파일됩니다. 생성자가 영어로 채우기 때문입니다. 그러니 한 벌을 다 번역하세요. 묶음의 단어를 영어와 세어 보는 패키지 테스트가 빠뜨린 것을 알려 줍니다.

:::

기다리고 싶지 않은 애플리케이션은 한 벌을 직접 써서 프로바이더에 넘기면 됩니다. 묶음은 편의이지 구조가 아닙니다.

## 메모

- **여기에는 날짜가 없습니다.** 달과 요일과 숫자 형식은 React 쪽에서는 플랫폼이, Flutter 쪽에서는 `PlDateNames`가 정합니다. 묶음에는 달 이름이 하나도 없습니다.
- **읽는 방향은 별개입니다.** 아랍어나 히브리어 인터페이스는 묶음이 아니라 문서에서 뒤집힙니다. [오른쪽에서 왼쪽으로](../design/rtl)를 보세요.
- **React 쪽에서 `PlTable`은 프로바이더를 읽지 않습니다.** 프로바이더를 읽지 않는 유일한 컴포넌트입니다. [기본값 정하기](defaults)의 메모를 보세요.
