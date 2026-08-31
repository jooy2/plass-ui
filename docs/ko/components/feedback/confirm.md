---
title: PlConfirmProvider
order: 12
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

## Props

<PropsTable name="PlConfirmProvider" />

provider의 prop은 그 아래에서 던지는 모든 질문의 기본값입니다. 호출 하나가 무엇이든 덮어쓸 수 있습니다 — 아래 `PlConfirmOptions`를 보세요.

### PlConfirmOptions

<PropsTable name="PlConfirmOptions" />

## 컴포넌트가 아니라 hook인 이유

질문이 필요해진 순간에 호출자가 쥐고 있는 것은 트리 안의 자리가 아니라 **클릭 핸들러**입니다. 이것이 없으면 같은 삭제 버튼 하나에 state 하나, 옆에 마운트해 둔 `<PlModal>` 하나, 그리고 답 다음에 할 일이 콜백을 가로질러 반토막 난 코드가 필요합니다 — 버튼 하나에 확인을 붙이는 데 편집 세 군데이고, 확인이 필요한 버튼마다 되풀이됩니다.

[`PlToastProvider`](./toast)와 같은 배치이고 같은 이유이며 같은 거래입니다. 루트 근처에 컴포넌트 하나, 나머지 전부에서는 hook.

## Examples

### alert

버튼 하나, 답 없음. 메시지가 확인되면 resolve되고, 그래서 어떤 절차 한가운데에서 await할 수 있습니다.

<Demo src="confirm/alert" :min-height="160">

::: fw react

<<< @/.vitepress/demos/confirm/alert.tsx

:::

</Demo>

### initialFocus

**기본값은 Cancel이 focus를 쥐는 것**이고, 이것이 말해 둘 만한 결정입니다. confirm dialog는 누군가를 멈춰 세우려고 있는 것인데, Enter가 파괴적인 동작에 떨어지면 그 전부가 무의미해집니다.

yes 쪽이 무해한 질문 — "닫기 전에 저장할까요?" — 에서는 옮기세요. 동의하기 위해 마우스를 잡게 만드는 것도 나름의 무례입니다.

<Demo src="confirm/focus" :min-height="160">

::: fw react

<<< @/.vitepress/demos/confirm/focus.tsx

:::

</Demo>

### 애플리케이션 전체의 어휘 하나

```tsx
<PlConfirmProvider confirmLabel="확인" cancelLabel="취소" acknowledgeLabel="확인">
  <App />
</PlConfirmProvider>
```

### 반드시 답해야 하는 질문

```tsx
await confirm({
  title: '변경 사항이 저장되지 않았습니다.',
  confirmLabel: '버리기',
  cancelLabel: '돌아가기',
  dismissible: false
});
```

`dismissible`은 기본이 켜짐입니다. Escape는 보편적인 "아니오"이고, 빠져나갈 수 없는 질문은 덫이기 때문입니다. 정말로 답해야만 하는 질문에서만 끄세요 — 그리고 정말로 그럴 때만.

## Notes

- **하나가 열려 있는 동안 던진 질문은 큐에 쌓입니다.** 던진 순서대로이고, 시트가 닫혔다 다시 열리는 대신 dialog의 내용이 바뀝니다. 그러지 않으면 아무도 resolve하지 않는 promise가 남는데, 그것은 보이는 버그가 아니라 멈춰 버린 버튼입니다.
- 답을 기다리는 질문이 남은 채 provider가 unmount되면 **전부 `false`로 resolve합니다.** settle되지 않는 promise는 `finally`가 영영 돌지 않는 핸들러이고, 그러면 라우트 전환 하나가 남은 세션 내내 도는 버튼을 남깁니다.
- provider 밖에서 `usePlConfirm`은 `false`를 돌려주는 대신 **throw합니다.** 조용한 `false`는 아무것도 하지 않는 삭제 버튼이고, 그것은 첫 클릭에서 사실을 말해 주는 없는 provider보다 나쁩니다.
- Escape와 바깥 클릭은 **아니오**입니다. 절대 예가 아닙니다.

## Accessibility

- 진짜 modal dialog입니다. focus는 안에 갇히고, 뒤의 페이지는 inert가 되고, 닫히면 focus가 열었던 것으로 돌아갑니다.
- `title`은 dialog에 이름을 주는 `<h2>`이고 `description`은 accessible description입니다. 그래서 스크린 리더가 두 버튼 어느 쪽보다 먼저 질문과 그 결과를 읽습니다.
- 두 버튼은 각자의 label로 이름 붙습니다. "예"와 "아니오"가 아니라 **무엇을 하는지** 로 — "삭제", "버리기", "저장" — 이름 붙이세요. 앞의 둘은 맥락을 잃으면 읽을 수 없는 말이고, 맥락을 잃은 채 읽는 것이 정확히 스크린 리더가 하는 일입니다.
