---
title: PlToast
order: 5
---

# PlToast

<p class="plass-lede">스스로 나타나 무슨 일이 있었는지 말하고 사라지는 메시지입니다. 앱을 <code>PlToastProvider</code>로 한 번 감싸고, 어디서든 <code>usePlToast</code>로 올립니다.</p>

<Demo src="toast/hero" :min-height="120" />

```tsx
import { PlToastProvider, usePlToast } from 'plass-ui';

<PlToastProvider>
  <App />
</PlToastProvider>;

// 그 아래 어디서든
const toast = usePlToast();

toast.add({ color: 'success', title: 'Saved', description: 'Your changes are live.' });
```

## Props

### PlToastProvider

<PropsTable name="PlToastProvider" />

토스트가 **어떻게 보일지**는 전부 provider에서 정해집니다 — 스택이 놓이는 자리, 너비, 재질, 지속 시간 — 그래서 호출하는 자리는 마땅히 그래야 할 한 가지, 무슨 일이 있었는지만 말합니다.

`elevation`은 없습니다. 토스트는 페이지 위에 떠 있으므로 그림자가 언제나 3단계이고, `PlSelect`의 popup, `PlModal`의 시트, `PlTooltip`의 판과 같습니다.

### usePlToast

<PropsTable name="usePlToast" />

컴포넌트가 아니라 훅인 이유는, 토스트가 필요해지는 순간에 호출하는 쪽이 가진 것은 트리 안의 자리가 아니라 클릭 핸들러이기 때문입니다. 메시지마다 상태를 하나씩 두고 계속 마운트해 두어야 하는 `<PlToast open={…} />`는 이 컴포넌트가 피하려고 존재하는 바로 그 모양입니다.

### PlToastOptions

<PropsTable name="PlToastOptions" />

라이브러리 전체에서 공유 축(`variant` `size` `color` `density`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### position

`side`와 `align` 쌍이 아니라 한 단어인 이유는 둘이 독립적이지 않기 때문입니다. 토스트 스택은 언제나 위나 아래에 고정되지 옆에 붙지 않고, `left`/`right`를 "side"로 내주면 어떤 레이아웃도 살아남지 못하는 화면 한가운데 스택을 부르게 됩니다.

<Demo src="toast/positions" :min-height="200">

<<< @/.vitepress/demos/toast/positions.tsx

</Demo>

### variant와 color

둘 다 provider의 기본값이고 개별 토스트가 덮어씁니다. 그래서 페이지는 하나의 집안 스타일을 가지면서도, 오류 하나만은 오류처럼 보이게 할 수 있습니다.

각 계열은 자기 색만이 아니라 자기 모양도 그립니다 — 빨간색으로만 "잘못됐다"고 말하는 토스트는 일부 독자에게만 말하는 토스트입니다.

<Demo src="toast/variants" :min-height="120">

<<< @/.vitepress/demos/toast/variants.tsx

</Demo>

<Demo src="toast/colors" :min-height="120">

<<< @/.vitepress/demos/toast/colors.tsx

</Demo>

### 액션, 그리고 timeout: 0

`actionLabel`을 넘기는 것이 액션 버튼을 나타나게 합니다. 독자가 무언가 해야 하는 토스트에는 `timeout: 0`도 함께 주세요. 읽히기 전에 사라진 토스트는 아무 말도 하지 않은 것입니다.

### update

id를 다시 쓰면 그 토스트가 제자리에서 갱신되고 타이머가 다시 시작됩니다. "업로드 중… / 업로드됨"이 원하는 것이 그것입니다 — 겹쳐 쌓인 두 개가 아니라, 마음을 바꾼 하나.

<Demo src="toast/update" :min-height="120">

<<< @/.vitepress/demos/toast/update.tsx

</Demo>

### promise

promise를 따라가는 토스트 하나입니다. 진행되는 동안에는 로딩 메시지, 그다음에는 성공이나 오류. loading 상태에는 Base UI가 `timeout: 0`을 적용하므로 느린 요청이 자기 토스트를 지워 버리지 못합니다.

<Demo src="toast/promise" :min-height="120">

<<< @/.vitepress/demos/toast/promise.tsx

</Demo>

## Accessibility

- 어렵고, 잘 동작할 때는 보이지 않는 부분은 Base UI가 가집니다. 타이머와 hover·창 blur에서의 일시정지, limit, 스와이프, F6 focus 단축키, 그리고 난데없이 나타난 메시지가 스크린리더에 닿게 하는 live region.
- `priority`가 어느 live region인지를 고릅니다. `high`는 읽고 있던 것을 끊고 `low`는 쉬는 지점을 기다립니다 — 오류는 끊을 만하고 저장 확인은 그렇지 않습니다.
- ×는 일부러 페이지의 tab 순서에 들어가지 않고 접근성 트리에서도 숨겨집니다. 스크린리더는 **F6**으로 토스트에 닿고 거기서 닫기를 받습니다. 이미 사라졌을지도 모르는 메시지의 버튼이 페이지 어딘가에 떠도는 대신입니다.
- `limit`에 밀려난 토스트는 다시 돌아올 수 있도록 DOM에 남고, 기다리는 동안에는 아무 말도 하지 않습니다.
- 스택은 전체 너비에 걸쳐 `pointer-events-none`입니다. 그래서 페이지 위나 아래를 가로지르는 그 띠가 앱 전체를 가로막는 벽이 되지 않습니다. 이벤트는 토스트 자신이 되찾아 갑니다.
