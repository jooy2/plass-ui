---
title: PlConfirmProvider
order: 13
---

# PlConfirmProvider

<p class="plass-lede">dialog 하나를, 그 아래 어디서든 불러 씁니다. <code>await confirm(…)</code>이 답을 돌려주므로, 질문 다음에 오는 분기가 질문한 그 핸들러 안에 남습니다.</p>

<Demo src="confirm/hero" :min-height="220" />

::: fw react

```tsx
import { PlConfirmProvider, usePlConfirm } from 'plass-ui';

// 루트 근처에 한 번
<PlConfirmProvider>
  <App />
</PlConfirmProvider>;

// 그 아래 어디서든
const { confirm } = usePlConfirm();

if (await confirm({ title: 'Delete this project?', color: 'danger' })) {
  await remove(project);
}
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

// 앱 안에서 한 번, 자기 Overlay 아래에
WidgetsApp(
  // …
  builder: (BuildContext context, Widget? child) =>
      Overlay.wrap(child: PlConfirmProvider(child: child!)),
);

// 그 아래 어디서든
if (await PlConfirmProvider.of(context).confirm(
  const PlConfirmOptions(title: Text('Delete this project?'), color: PlassColor.danger),
)) {
  await remove(project);
}
```

provider는 앱을 감싸지 말고 앱 안에 두세요. 앱 바깥에는 아직 `Directionality`가 없습니다. `builder` 안의 provider는 navigator와 그 `Overlay`보다 위에 있으므로 자기 `Overlay`가 따로 있어야 하고, 없으면 `confirm`이 "No Overlay widget found"로 실패합니다. 자세한 내용은 [시작하기](../../guide/getting-started#위쪽에-필요한-provider-하나)에 있습니다.

:::

## Props

<PropsTable name="PlConfirmProvider" />

provider의 prop은 그 아래에서 던지는 모든 질문의 기본값입니다. 호출 하나가 무엇이든 덮어쓸 수 있습니다. 아래 `PlConfirmOptions`를 보세요.

- provider는 루트 근처에 한 번 두고, 그 아래 어느 핸들러에서든 <Fw react="`usePlConfirm`" flutter="`PlConfirmProvider.of(context)`" /> 호출 하나로 닿습니다. [`PlToastProvider`](./toast)와 같은 배치입니다.
- **하나가 열려 있는 동안 던진 질문은 큐에 쌓입니다.** 던진 순서대로이고, 시트가 닫혔다 다시 열리는 대신 dialog의 내용이 바뀌며, focus는 질문마다 그 질문의 `initialFocus`에 따라 놓입니다.
- 답을 기다리는 질문이 남은 채 provider가 unmount되면 **전부 `false`로 답합니다**.
- provider 밖에서는 <Fw react="`usePlConfirm`이 throw합니다" flutter="`PlConfirmProvider.of`가 assert합니다" />. `false`로 답하지 않습니다.
- Escape와 바깥 누름은 **아니오**로 답하고, 절대 예로 답하지 않습니다. Cancel이 없는 `alert`도 둘 중 어느 쪽으로든 닫히며 버튼을 눌렀을 때처럼 완료됩니다.

이 규칙들의 이유는 [prop 규약](../../design/prop-conventions#핸들러에서-묻기)에 있습니다.

### PlConfirmOptions

<PropsTable name="PlConfirmOptions" />

::: fw flutter

hook이 아니라 `PlConfirmProvider.of(context)`입니다. `PlToastProvider`가 내주는 그 조회이고, 프레임워크 자신의 모양입니다.

`initialFocus`는 문자열이 아니라 `PlConfirmFocus`를 받습니다. 시트에 ×는 그려지지 않습니다.

:::

## Examples

### alert

버튼 하나, 답 없음. 메시지가 확인되면 resolve되고, 그래서 어떤 절차 한가운데에서 await할 수 있습니다.

<Demo src="confirm/alert" :min-height="160">

::: fw react

<<< @/.vitepress/demos/confirm/alert.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/confirm/alert.dart

:::

</Demo>

### initialFocus

**기본값은 Cancel이 focus를 쥐는 것**이고, 이것이 말해 둘 만한 결정입니다. confirm dialog는 누군가를 멈춰 세우려고 있는 것인데, Enter가 파괴적인 동작에 떨어지면 그 전부가 무의미해집니다.

yes 쪽이 무해한 질문("닫기 전에 저장할까요?") 에서는 옮기세요. 동의하기 위해 마우스를 잡게 만드는 것도 나름의 무례입니다.

<Demo src="confirm/focus" :min-height="160">

::: fw react

<<< @/.vitepress/demos/confirm/focus.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/confirm/focus.dart

:::

</Demo>

### confirmLabel · cancelLabel · acknowledgeLabel

버튼의 말입니다. provider에 한 번 정해 애플리케이션 전체에 쓰고, 자기 말이 필요한 질문 하나가 그것을 덮어씁니다.

::: fw react

```tsx
<PlConfirmProvider confirmLabel="확인" cancelLabel="취소" acknowledgeLabel="확인">
  <App />
</PlConfirmProvider>
```

:::

::: fw flutter

```dart
PlConfirmProvider(
  confirmLabel: const Text('확인'),
  cancelLabel: const Text('취소'),
  acknowledgeLabel: const Text('확인'),
  child: child!,
);
```

:::

### dismissible

기본으로 켜져 있어서 Escape와 바깥 누름이 아니오로 답합니다. 정말로 답해야만 하는 질문 하나에서만 끄고, 그 버튼들에는 각자 무엇을 하는지 말하는 이름을 주세요.

::: fw react

```tsx
await confirm({
  title: '변경 사항이 저장되지 않았습니다.',
  confirmLabel: '버리기',
  cancelLabel: '돌아가기',
  dismissible: false
});
```

:::

::: fw flutter

```dart
await PlConfirmProvider.of(context).confirm(
  const PlConfirmOptions(
    title: Text('변경 사항이 저장되지 않았습니다.'),
    confirmLabel: Text('버리기'),
    cancelLabel: Text('돌아가기'),
    dismissible: false,
  ),
);
```

:::

## Accessibility

- 진짜 modal dialog입니다. focus는 안에 갇히고, 뒤의 페이지는 inert가 되고, 닫히면 focus가 열었던 것으로 돌아갑니다.
- `title`은 dialog에 이름을 주는 `<h2>`이고 `description`은 accessible description입니다. 그래서 스크린 리더가 두 버튼 어느 쪽보다 먼저 질문과 그 결과를 읽습니다.
- 두 버튼은 각자의 label로 이름 붙습니다. "예"와 "아니오"가 아니라 **무엇을 하는지**로("삭제", "버리기", "저장") 이름 붙이세요. 앞의 둘은 맥락을 잃으면 읽을 수 없는 말이고, 맥락을 잃은 채 읽는 것이 정확히 스크린 리더가 하는 일입니다.
