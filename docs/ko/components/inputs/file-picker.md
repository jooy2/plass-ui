---
title: PlFilePicker
order: 9
---

# PlFilePicker

<p class="plass-lede">파일을 떨어뜨리거나, 눌러서 파일 대화상자를 여는 상자입니다. 들어온 파일을 <code>accept</code>, <code>maxSize</code>, <code>maxFiles</code>로 검사하고, 돌려보낸 것을 전부 알려 줍니다.</p>

<Demo src="file-picker/hero" :min-height="260" />

```tsx
import { PlFilePicker } from 'plass-ui';

<PlFilePicker label="Attachments" multiple maxFiles={4} value={files} onFilesChange={setFiles} />;
```

## Props

<PropsTable name="PlFilePicker" />

네이티브 `<div>` 속성은 wrapper로 그대로 전달됩니다. `color`, `defaultValue`, `title`, `children`은 넷 다 여기서는 Plass의 prop이라 제외됩니다.

`formatFileSize`도 함께 export되므로, 목록을 직접 그리는 쪽에서도 같은 단위로 크기를 찍을 수 있습니다.

라이브러리 전체에서 공유 축(`variant` `size` `color` `density` `elevation`)이 뜻하는 바는 [prop 규칙](../../design/prop-conventions)에 있습니다.

## Examples

### variant

셋 다 **점선** 테두리를 쓰고, 라이브러리에서 실선이 아닌 선을 긋는 유일한 자리입니다. 장식이 아닙니다 — 점선 사각형은 "여기에 떨어뜨릴 수 있다"는 뜻으로 굳어진 관습이고, `PlCard`처럼 생긴 dropzone은 아무도 떨어뜨려 보지 않는 `PlCard`입니다.

테두리는 쉬고 있을 때 중립색이고, 포인터가 올라온 뒤에야 색 계열을 입습니다 — `glass` `PlButton`과 같은 방식입니다.

<Demo src="file-picker/variants" :min-height="200">

<<< @/.vitepress/demos/file-picker/variants.tsx

</Demo>

### accept · maxSize · maxFiles

`accept`는 input에 붙기도 하고 드롭에도 **적용**됩니다. 브라우저는 이 속성을 자기 대화상자에만 강제하고 그 밖에는 아무 데도 적용하지 않으므로, 속성만 걸어 둔 dropzone은 드래그로 들어오는 순간 무엇이든 받아들입니다.

`maxFiles`는 한 번의 드롭이 아니라 이미 쥐고 있는 것과 합쳐 셉니다. "파일 다섯 개를 떨어뜨릴 수 있다"와 "파일 다섯 개까지 가질 수 있다"의 차이이고, 이 prop이 뜻하는 것은 후자입니다.

거절은 `onReject`로 나갑니다. 이것이 없으면 거절된 파일이 조용히 사라지는데, 그것이 dropzone이 저지르는 가장 나쁜 일입니다.

<Demo src="file-picker/rejections" :min-height="280">

<<< @/.vitepress/demos/file-picker/rejections.tsx

</Demo>

### 한 번에 한 파일

`multiple`이 없으면 상자는 정확히 파일 하나를 쥐고, 새 파일이 들어오면 `count`로 거절되는 대신 그것을 대체합니다. 아바타 선택기가 원하는 동작입니다.

<Demo src="file-picker/single" :min-height="240">

<<< @/.vitepress/demos/file-picker/single.tsx

</Demo>

### size

상자의 여백과 안쪽 글자를 함께 움직입니다. 여백이 시트의 사다리가 아니라 자기 사다리를 쓰는 이유는, dropzone의 크기를 정하는 것이 안에 쓰인 글이 아니라 받아 내야 할 동작이기 때문입니다 — 글자 한 줄 높이의 과녁은 빗나가는 과녁입니다.

<Demo src="file-picker/sizes" :min-height="420">

<<< @/.vitepress/demos/file-picker/sizes.tsx

</Demo>

### disabled · error

<Demo src="file-picker/states" :min-height="220">

<<< @/.vitepress/demos/file-picker/states.tsx

</Demo>

## Accessibility

- 누를 수 있는 영역은 진짜 `<button>`입니다. 포커스 순서에 들어가고 <kbd>Enter</kbd>와 <kbd>Space</kbd>에 반응합니다. 드래그 앤 드롭은 거기에 더해진 것이지 유일한 통로가 아닙니다.
- `<input type="file">`은 `display: none`이 아니라 화면 밖으로 잘려 DOM에 남습니다 — 전자는 일부 브라우저에서 focus를 받을 수 없게 만들고, 네이티브 form 검증에서도 빠지게 합니다.
- `description`과 `error`는 `aria-describedby`로 버튼에 연결되고, error는 `aria-invalid`도 함께 세웁니다.
- 파일 목록은 browse 버튼 바깥의 진짜 `<ul>`입니다. 지우기 버튼을 다른 버튼 안에 넣을 수는 없기 때문입니다.
- 각 지우기 버튼은 지우는 파일 이름을 포함한 접근 가능한 이름을 가집니다. 스크린리더가 "Remove" 세 개가 아니라 서로 다른 버튼 셋을 읽습니다.
- 파일이 위에 있는 동안 영역이 움직이지 않습니다. 색과 테두리만 바뀌고 커지거나 떠오르지 않습니다 — 조준하는 동안 움직이는 과녁은 빗나가는 과녁입니다.
