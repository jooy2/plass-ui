---
title: PlModal
order: 2
---

# PlModal

<p class="plass-lede">답할 때까지 페이지를 가져가는 시트입니다. 헤더와 액션은 자리를 지키고 본문만 스크롤됩니다.</p>

<Demo src="modal/hero" :min-height="120" />

```tsx
import { PlButton, PlModal, PlModalClose } from 'plass-ui';

<PlModal
  trigger={<PlButton color="danger">Delete project</PlButton>}
  title="Delete “Aurora”?"
  description="Everything in it goes with it."
  actions={<PlModalClose render={<PlButton color="danger">Delete</PlButton>} />}
>
  <PlTextField label="Type the project name to confirm" />
</PlModal>;
```

## Props

<PropsTable name="PlModal" />

네이티브 `<div>` 속성은 시트로 그대로 전달됩니다. `color`, `title`, `children`은 셋 다 여기서는 Plass의 prop이라 제외됩니다.

`variant`는 없습니다. 세 재질은 "이 표면이 주변 페이지에 대해 얼마나 자기를 주장하는가"에 대한 답인데, modal은 이미 페이지를 가져갔습니다. `elevation`도 없습니다 — 페이지에 납작하게 눕힐 수 있는 modal은 modal이기를 그만두라고 할 수 있는 modal이므로, 그림자는 사다리 꼭대기에 고정됩니다.

### PlModalClose

`PlModalClose`는 자기가 속한 modal을 닫습니다. uncontrolled modal에는 Cancel 버튼이 호출할 `setOpen`이 없고, 대안 — 모든 modal을 controlled로 만드는 것 — 은 버튼 하나에 답하려고 modal마다 상태를 하나씩 두는 일이기 때문에 존재합니다.

```tsx
<PlModalClose render={<PlButton variant="ghost">Cancel</PlButton>} />
```

라이브러리 전체에서 공유 축(`size` `color` `density`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### size

너비와 타입 스케일이 함께 움직입니다. 단계가 컨트롤 사다리보다 넓은 이유는 답하는 질문이 다르기 때문입니다 — 이것이 얼마나 큰가가 아니라, 안에서 한 줄이 얼마나 길어야 읽기 편한가. `width`는 내용이 너비를 정하는 modal — 넓은 표, 좁은 확인창 — 을 위한 탈출구입니다.

<Demo src="modal/sizes" :min-height="120">

<<< @/.vitepress/demos/modal/sizes.tsx

</Demo>

### dividers

기본은 꺼져 있습니다. 본문이 스크롤되기 시작하는 순간 켜세요 — 헤더가 내용과 함께 흘러가지 않고 자리를 지켰다고 말해 주는 것이 그 헤어라인입니다.

<Demo src="modal/dividers" :min-height="120">

<<< @/.vitepress/demos/modal/dividers.tsx

</Demo>

### Controlled

trigger가 아닌 다른 것이 modal을 열어야 하거나, 액션이 닫히기 전에 할 일이 있을 때 `open`과 `onOpenChange`를 함께 넘기세요.

<Demo src="modal/controlled" :min-height="120">

<<< @/.vitepress/demos/modal/controlled.tsx

</Demo>

### dismissible

끄면 <kbd>Esc</kbd>와 바깥 클릭 둘 다 modal을 닫지 않습니다. `showClose={false}`와 함께 쓰는 것은 액션이 정말로 답이 될 때뿐입니다 — 아니면 나갈 길이 아예 없어집니다.

<Demo src="modal/dismissible" :min-height="120">

<<< @/.vitepress/demos/modal/dismissible.tsx

</Demo>

## Accessibility

- 어려운 부분은 전부 Base UI의 것입니다. focus trap, 스크롤 잠금, 닫힐 때 trigger로 focus 되돌리기, 뒤 페이지를 inert로 만들기.
- `title`은 dialog의 이름이 되는 `<h2>`가 되고 `description`은 접근 가능한 설명이 됩니다. 둘 다 Base UI가 엮어 주므로 `aria-labelledby`가 필요 없습니다.
- `dismissible`이 꺼져 있지 않으면 <kbd>Esc</kbd>로 닫힙니다. `modal="trap-focus"`는 뒤 페이지를 스크롤 가능하게 두면서 focus만 가둡니다.
- ×는 기본으로 켜져 있습니다. 라이브러리의 다른 boolean들과 반대인데, modal은 답할 때까지 페이지를 가져가므로 나가는 길이 기억에 의존하면 안 되기 때문입니다.
- 시트는 뷰포트를 넘어 자라는 대신 자기 높이를 제한하고 본문을 스크롤합니다. 키가 큰 modal의 윗부분이 화면 위로 밀려 나가 아무도 닿을 수 없게 되는 일이 없습니다.
- 열고 닫힐 때는 opacity만 움직입니다. 크기가 변하거나 미끄러지는 modal은 자기 글자를 화면 위로 끌고 다니는 것이고, 컨트롤과 달리 이것은 글자로 가득 차 있습니다.
