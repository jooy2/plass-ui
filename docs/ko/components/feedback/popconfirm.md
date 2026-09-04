---
title: PlPopconfirm
order: 15
---

# PlPopconfirm

<p class="plass-lede">페이지 한가운데가 아니라 물음이 일어난 자리에서 묻습니다. 그 행의 삭제 버튼을, 그 행 옆에서.</p>

<Demo src="popconfirm/hero" :min-height="280" />

::: fw react

```tsx
import { PlPopconfirm } from 'plass-ui';

<PlPopconfirm
  title="Delete this row?"
  description="It cannot be undone."
  confirmLabel="Delete"
  onConfirm={() => remove(row)}
  trigger={<PlButton color="danger">Delete</PlButton>}
/>;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlPopconfirm(
  open: asking,
  onOpenChanged: (bool next) => setState(() => asking = next),
  title: const Text('Delete this row?'),
  confirmLabel: const Text('Delete'),
  onConfirm: () => remove(row),
  trigger: PlButton(
    color: PlassColor.danger,
    onPressed: () => setState(() => asking = true),
    child: const Text('Delete'),
  ),
);
```

:::

## Props

<PropsTable name="PlPopconfirm" />

::: fw flutter

`open`은 이 패키지의 모든 상태와 마찬가지로 **controlled**입니다 — uncontrolled 형태도, `defaultOpen`도 없습니다. `onConfirm`은 `FutureOr<void>`를 돌려주는데, "promise는 기다린다"의 Dart 모양입니다. 평범한 콜백이면 바로 닫히고, `Future`이면 완료될 때까지 질문을 붙잡아 둡니다.

두 버튼은 `Row`가 아니라 `Wrap`에 놓입니다. 그래서 시트에 맞지 않는 번역된 label 쌍은 넘치는 대신 줄바꿈합니다.

:::

## popconfirm인가 confirm dialog인가

차이는 말이 아니라 **얼마나 방해하는가**입니다.

|  |  |
| --- | --- |
| [`PlConfirmProvider`](./confirm) | 페이지를 빼앗습니다. 그럴 만한 질문 — 계정 삭제, 한 시간짜리 작업 버리기 — 을 위한 것입니다 |
| `PlPopconfirm` | 그것이 묻는 대상 옆에 나타납니다. 표의 나머지는 여전히 읽히고, Escape는 사용자를 있던 자리로 정확히 돌려놓습니다 |

판단 기준은 실수로 답했을 때 무슨 일이 생기느냐입니다. **답이 "되돌릴 수 있다"라면 이쪽입니다.**

`color`가 여기서는 `danger`이고 `PlButton`에서는 `primary`인데, 모순이 아닙니다. 저장할지 묻자고 popconfirm에 손을 뻗는 사람은 없습니다.

## Examples

### 시간이 걸리는 confirm

`onConfirm`은 promise를 돌려줄 수 있습니다. 버튼은 그것이 끝날 때까지 loading 상태를 보이고, **resolve될 때만 popup이 닫힙니다** — 실패한 요청은 성공한 척하는 대신 질문을 화면에 남깁니다. 돌고 있는 동안 Escape는 무시됩니다. 진행 중인 요청은 도중에 버릴 것이 아닙니다.

<Demo src="popconfirm/async" :min-height="180">

::: fw react

<<< @/.vitepress/demos/popconfirm/async.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/popconfirm/async.dart

:::

</Demo>

> reject는 잡히고 더 가지 않습니다. 질문을 남겨 두는 것이 이 컴포넌트가 실패에 빚진 전부이고, 그 실패가 _무엇을 뜻하는지_ 는 여러분의 것입니다. `onConfirm`이 그것을 알릴 자리이고, 보통은 toast입니다.

### side와 align

기본은 trigger 위로 열립니다 — 다음 행을 덮을 가능성이 가장 낮은 자리입니다. `side`와 `align`은 [`PlPopover`](./popover) 자신의 것입니다.

```tsx
<PlPopconfirm side="right" align="start" … />
```

## Accessibility

- [`PlPopover`](./popover)입니다. popup은 `title`로 이름 붙고 `description`으로 설명되는 `role="dialog"`이며, focus가 안으로 들어가고 닫히면 trigger로 돌아옵니다.
- **focus는 확인 버튼에 떨어집니다.** `PlConfirmProvider`와 반대이고 일부러 그렇습니다. popconfirm은 그것이 묻고 있는 바로 그 버튼이 연 것이므로, 사용자는 이미 원하는 바를 한 번 말했습니다. modal은 따져 봐야 하는 질문을 위한 것입니다.
- 닫기 버튼이 없습니다 — 두 답이 두 버튼이고, 어느 쪽도 아닌 세 번째 출구는 답이 둘인 질문의 세 번째 답입니다.
- 버튼은 **무엇을 하는지**로 이름 붙이세요. "예"와 "아니오"가 아니라 "삭제"와 "취소"입니다.
