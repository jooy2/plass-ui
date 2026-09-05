---
title: PlPortal
order: 14
---

# PlPortal

<p class="plass-lede">문서의 다른 자리에 그려지는 자식들입니다. <code>createPortal</code>에 이 라이브러리의 모든 portal 표면이 달고 다니는 클래스와, ref도 받는 container와, 아무것도 아닌 것이 정답인 서버 렌더링을 더한 것입니다.</p>

<Demo src="portal/hero" :min-height="240" :flutter="false" />

::: fw react

```tsx
import { PlPortal } from 'plass-ui';

<PlPortal>
  <div className="fixed inset-x-4 bottom-4 z-(--plass-z-portal)">
    아무것도 이걸 자르지 않습니다.
  </div>
</PlPortal>;
```

:::

::: fw flutter

이 컴포넌트는 React 전용이고, 빠뜨린 것이 아닙니다. 이것이 우회하는 문제는 DOM의 문제입니다. `overflow: hidden`인 조상, 안쪽에서는 빠져나올 수 없는 stacking context의 `z-index` 같은 것들인데 Flutter에는 둘 다 없습니다. 화면 위로 떠야 하는 위젯은 모든 Flutter 앱이 이미 가지고 있는 `Overlay`로 갑니다.

```dart
Overlay.of(context).insert(
  OverlayEntry(builder: (BuildContext context) => const Positioned(bottom: 16, child: Note())),
);
```

:::

## Props

<PropsTable name="PlPortal" />

네이티브 `<div>` 속성은 그대로 통과합니다. 라이브러리 전체에서 공유 축이 무엇을 뜻하는지는 [prop 규약](../../design/prop-conventions)에 있습니다.

## `createPortal`에 더한 것

`createPortal`을 쓰면 세 가지를 직접 기억해야 합니다. 이 컴포넌트가 그 세 가지이고, 첫 번째가 이것이 존재하는 진짜 이유입니다.

### `plass-portal` 클래스

라이브러리가 portal로 내보내는 모든 표면 — [modal](../feedback/modal), [drawer](../feedback/drawer), [menu](../navigation/menu), [popover](../feedback/popover), [tooltip](../feedback/tooltip), [toast](../feedback/toast) — 이 이 클래스를 달고 내려앉습니다. portal된 서브트리는 호스트가 CSS 리셋을 걸어 둔 요소 바깥으로 나가고, 호스트가 그 서브트리를 다시 찾는 방법이 이 클래스입니다. 이 클래스가 없는 호출자의 portal은 페이지에서 리셋이 닿지 않는 유일한 서브트리가 됩니다.

스타일이 아니라 표식입니다. 라이브러리는 이 클래스에 아무것도 선언하지 않습니다.

### 마운트 전에는 아무것도 그리지 않음

서버에는 `document`가 없으므로, 나가는 HTML에는 portal된 서브트리가 들어 있지 않고 hydration하는 렌더링에도 들어 있지 않습니다.

이것은 우회할 한계가 아니라 portal이 **무엇인지** 그 자체입니다. 크롤러를 위해서든, JavaScript 없이 읽는 사람을 위해서든, 첫 페인트를 위해서든 서버의 HTML에 반드시 있어야 하는 것은 portal에 넣지 마십시오.

### `container`는 마운트 뒤에 풀립니다

그래서 **ref**를 받을 수 있습니다. portal이 겨냥하는 요소는 보통 prop을 쓰는 시점에 React가 아직 만들지 않은 요소입니다. ref는 `null`이고 `getElementById`는 아무것도 찾지 못하므로, 렌더링 중에 prop을 읽으면 매번 틀린 답을 얻습니다.

<Demo src="portal/container" :min-height="260" :flutter="false">

::: fw react

<<< @/.vitepress/demos/portal/container.tsx

:::

</Demo>

요소와 `DocumentFragment`는 그대로 쓰고, 함수는 호출하며, 아무것도 아닌 것으로 풀리면 자식을 버리지 않고 `document.body`로 떨어집니다.

## 한계

**색 스킴입니다.** 스타일시트는 조상 어딘가의 `.dark`나 `[data-theme]`에 답하는데, `document.body`로 간 portal은 가지고 있던 조상을 전부 떠났습니다. 그래서 한쪽 테마에 고정해 둔 서브트리가 페이지의 테마로 돌아갑니다.

라이브러리 자신의 popup도 마찬가지이고, 해법도 같습니다. `container`에 테마 안쪽에 있는 요소를 주십시오.

```tsx
<div data-theme="dark" ref={host}>
  …<PlPortal container={host}>…</PlPortal>
</div>
```

**그 밖에는 없습니다.** React context는 portal을 건너갑니다. context가 읽히는 트리는 DOM 트리가 아니라 React 트리이기 때문입니다. portal 위의 [`PlassProvider`](../../guide/defaults)는 그 안의 모든 것에 대해 여전히 `size`, `color`, `density`, `locale`을 정합니다.

## Examples

### 자르는 조상에서 빠져나오기

흔한 경우이고 이름을 붙여 둘 만합니다. `overflow: hidden`인 조상, 또는 서브트리를 `position: fixed`의 containing block으로 만들어 버린 `transform`. 둘 다 `z-index`를 아무리 올려도 안쪽에서는 빠져나올 수 없습니다.

```tsx
<div className="overflow-hidden">
  <PlPortal>
    <div className="fixed inset-0 z-(--plass-z-portal)">…</div>
  </PlPortal>
</div>
```

`--plass-z-portal`은 라이브러리의 모든 portal 표면이 그려지는 층이고, 토큰인 이유는 자기 헤더와 쿠키 바와 비디오 플레이어를 가진 앱이 한 줄로 그 층 전체를 옮길 수 있게 하기 위해서입니다. 숫자 대신 이것을 쓰십시오.

### `<div>`가 아닌 요소

`render`는 목적지가 실제로 자식으로 받는 요소로 wrapper를 바꿉니다.

```tsx
<PlPortal container={listRef} render={<li />}>
  Appended to a list
</PlPortal>
```

### 끄기

`disabled`는 제자리에 그립니다. **마운트 시점에 한 번** 정하십시오. React가 보기에 portal된 서브트리와 제자리 서브트리는 서로 다른 자식이므로, 이 값을 뒤집으면 안쪽이 전부 다시 마운트되면서 절반 채운 폼도, 스크롤 위치도, 재생 중이던 영상도 버려집니다. 여기만의 결함이 아니라 재조정의 성질이고, 어떤 portal 구현도 피하지 못합니다.

## Notes

- wrapper는 fragment가 아니라 실제 요소입니다. 클래스를 다는 것도, 호출자가 서브트리의 위치를 잡는 것도 그 요소입니다.
- 포커스를 가두지 않고, 페이지를 막지 않으며, <kbd>Escape</kbd>로 닫히지도 않습니다. 그 셋은 portal되는 대상의 몫이고 — [`PlModal`](../feedback/modal)이 셋 다 가지고 있습니다 — 그런 의견을 가진 portal은 이름을 잘못 지은 dialog입니다.

## Accessibility

- **portal은 픽셀과 읽는 순서를 함께 옮깁니다.** 스크린 리더는 문서를 따라 걷기 때문에, `<body>` 끝으로 간 서브트리는 트리거 바로 옆에 그려져 있어도 페이지의 끝에서 읽힙니다. 사용자가 곧바로 만나야 하는 것 — dialog, menu, 방금 무슨 일이 있었는지 알리는 메시지 — 이라면 포커스를 그 안으로 옮기거나, 트리거에 `aria-controls`와 `aria-expanded`를 주십시오.
- <kbd>Tab</kbd> 키도 마찬가지입니다. 화면이 아니라 문서를 따라갑니다. 버튼 옆에 그려진 portal 패널이라도 무언가 포커스를 옮겨 주지 않으면 페이지의 나머지를 모두 지난 뒤에야 도달합니다.
