---
title: Prop 규칙
order: 3
---

# Prop 규칙

<p class="plass-lede">모든 컴포넌트가 공유하는 하나의 어휘. <code>size</code>가 <code>md</code>이면 어디서나 같은 높이이고, 이미 이름이 있는 개념에 두 번째 이름을 붙이지 않습니다.</p>

## 다섯 개의 공통 축

`src/types.ts`에 있고, 스타일을 가진 모든 컴포넌트가 여기서 가져다 씁니다.

| Prop        | 타입                                   | 뜻                              |
| ----------- | -------------------------------------- | ------------------------------- |
| `variant`   | `'solid' \| 'glass' \| 'ghost'`        | 표면이 무엇으로 만들어졌는지    |
| `size`      | `'xs' \| 'sm' \| 'md' \| 'lg' \| 'xl'` | 높이와 타입 스케일, 한 묶음으로 |
| `color`     | 여섯 역할 이름                         | 어떤 의미론적 계열인지          |
| `density`   | `'default' \| 'compact'`               | 여백, 오직 여백                 |
| `elevation` | `0 \| 1 \| 2 \| 3`                     | 페이지에서 얼마나 떠 있는지     |

### `variant`는 재질의 이름입니다

`filled`, `outlined`, `text`가 아니라 `solid`, `glass`, `ghost`입니다. 이 세 단어는 [디자인 언어](./design-language)가 모든 표면에 던지는 질문의 세 가지 답이고, 어떻게 보이는지가 아니라 무엇 _인지_ 로 이름을 붙인 덕분에 애매한 컴포넌트에서도 답이 흔들리지 않습니다.

같은 단어가 두 가지를 뜻하는 곳은 입력하는 것에 붙은 `solid` 하나뿐입니다. 거기서는 색 유리판이 아니라 **우물**입니다. [PlTextField](../components/inputs/text-field#variant)를 보세요.

### `size`는 하나의 결정입니다

높이와 타입 스케일은 언제나 함께 움직입니다. `size="md" textSize="lg"` 같은 것은 없습니다. 같은 `size`인데 높이가 다른 두 컨트롤은 한 줄에서 영원히 맞지 않을 두 컨트롤이기 때문입니다.

### `color`는 값이 아니라 역할입니다

여섯 이름뿐이고 임의 색상은 없습니다. 여섯에 없는 색이 필요한 컴포넌트는 디자인 토큰을 요구하는 것이고, 그건 prop이 아니라 [색](./color)의 변경입니다.

### `density`는 여백입니다

높이도 타입 스케일도 절대 건드리지 않습니다. 같은 `size`의 compact 컨트롤과 default 컨트롤은 같은 기준선에 앉습니다.

### `elevation`은 기본값이 다르고, 그 기본값이 곧 주장입니다

콘텐츠를 담는 것은 `0`, 눌리는 것은 `1`입니다. 키는 시트 **위에** 놓이고, 필드는 시트 **안으로** 파입니다. 컴포넌트의 기본값이 짐작과 다를 때는 그 props 표가 그렇게 말해 줍니다.

## 이름 규칙

새 컴포넌트를 만들 때 이 목록으로 점검합니다.

- **이미 이름이 있는 개념에 두 번째 이름을 만들지 마세요.** "얼마나 큰지"가 필요하면 `size`입니다. "어떤 의미론적 색인지"가 필요하면 `color`입니다. `scale`이나 `tone`, `intent` prop은 어휘를 둘로 쪼개는 일입니다.
- **boolean prop은 켜는 상태의 이름을 쓰고** 기본값은 `false`입니다: `loading`, `readOnly`, `disabled`, `fullWidth`, `multiline`, `invalid`.
- **slot은 `ReactNode`이고 놓이는 자리의 이름을 씁니다**: `startIcon`, `endIcon`, `label`, `description`, `error`. `renderIcon`도 `iconLeft`도 아닙니다.
- **`left`/`right`가 아니라 `start`/`end`.** RTL에서 뒤집히는 쪽은 논리적 이름이고, 물리적 단어는 뒤집히지 않습니다.
- **duration과 delay는 CSS 문자열이 아니라 밀리초 숫자입니다.** 타입이 `string`인 prop은 `'0.4s'`를 부르고, 그러면 한 화면의 두 컴포넌트가 두 단위로 쓰이게 됩니다.
- **`render`가 탈출구이고** 어디서나 같은 이름입니다. Base UI 자신의 prop을 그대로 전달합니다. 표면을 바꾸지 않고 요소만 바꿉니다.
- **네이티브 속성은 그대로 전달됩니다.** `<input>`을 감싸는 컴포넌트는 위 축과 이름이 겹치는 것(`color`, `size`)을 뺀 모든 `<input>` 속성을 받습니다.

## 키를 묶기

`PlTextField`, `PlNumberField`, `PlOtpField`, `PlCombobox`, `PlSelect`는 **`hotKeys`** map을 받습니다. chord와, 그 chord를 눌렀을 때 일어나는 일입니다.

```tsx
<PlTextField hotKeys={{ 'Mod+Enter': save, Escape: cancel }} />
```

다섯 곳 모두에 세 가지 규칙이 적용됩니다.

- **chord는 키캡을 쓰는 방식으로 씁니다** — [`PlHotKeys`](../components/display/hot-keys)가 그리는 것과 같은 vocabulary입니다. `Mod`는 platform에 따라 정해지고(Mac에서는 ⌘, 그 밖에서는 <kbd>Ctrl</kbd>), `Esc`, `Return`, `Cmd`, `Option`도 키캡과 같은 키로 접힙니다. 컴포넌트가 **보여 주는** 단축키와 **묶는** 단축키가 한 문자열이 아니면, 화면의 키캡은 아무도 확인하지 않은 주장이 됩니다.
- **modifier는 양방향으로 검사합니다.** `Enter`는 <kbd>Shift</kbd>+<kbd>Enter</kbd>에 반응하지 않습니다. Enter로 저장하는 필드가 Enter로 끝나는 모든 chord에서 저장되지는 않는다는 뜻입니다.
- **맞는 chord는 소비됩니다.** handler가 실행되고 키는 더 이상 가지 않습니다 — 컨트롤 자신의 키 처리에도, form에도, 그 위의 dialog에도. 글자가 아니라 chord를 묶으세요. `{ a: … }`인 필드는 `a`를 칠 수 없습니다.

::: fw react

`hotKeys`는 감싸는 stack이 아니라 **control**에 붙습니다. chord에 답하는 건 focus를 쥔 쪽이기 때문입니다. `onKeyDown`을 대체하는 게 아니라 그 위의 편의입니다 — raw handler는 그대로 같은 요소로 전달되고, **먼저** 실행됩니다. 거기서 `preventDefault()`를 부르면 map은 건너뜁니다.

:::

::: fw flutter

map은 위젯 자신의 키 처리보다 focus node에 더 가깝게 묶입니다. 그래서 caller가 컨트롤에서 키를 가져올 수 있습니다. `PlSelect`만은 감싸는 것으로 안 되는데 — `FocusableActionDetector`가 Enter를 필드가 감쌀 수 있는 그 어떤 것보다 가깝게 묶기 때문입니다 — 그래서 map이 Enter를 요구하면 trigger가 **물러납니다**.

이 아래에 `onKeyDown`은 없습니다. chord map보다 세밀한 키 처리가 필요한 위젯은 필드를 자기 `Focus`로 감쌉니다.

:::

## 바깥에서 컴포넌트에 스타일 입히기

::: fw react

채널은 넷이고, 서로 대체되지 않습니다. 이 순서로 손을 뻗으세요.

### 1. `className` — 레이아웃용

`className`은 읽는 사람이 손가락으로 가리키며 "이 컴포넌트"라고 부를 요소 하나에 붙습니다. `PlButton`의 `<button>`, `PlModal`의 시트, field의 stack입니다. 컴포넌트 자신의 class를 대체하지 않고 함께 적용되며, 어느 요소인지는 각 컴포넌트의 Props 절에 적혀 있습니다.

컴포넌트가 어디에 놓이고 얼마나 자리를 차지하는지 — `w-full`, margin, grid 위치 — 에 맞는 채널입니다. 라이브러리가 자기 자신에게 지정하지 않는 속성들이라 다툴 상대가 없습니다.

### 2. `classNames` — `className`이 닿지 않는 부분용

어떤 컴포넌트는 하나보다 많이 그립니다. field는 label과 그 아래 두 줄을 그리고, portal로 뜨는 표면은 뒤에 scrim을 깝니다. `classNames`는 그 부분들에만 닿는 map입니다. 컴포넌트 자신의 표면은 prop 하나만 갖기 때문에, 둘 중 어느 쪽이 이기는지 물을 일이 없습니다.

```tsx
<PlTextField
  label="Email"
  className="w-full"
  classNames={{ control: 'font-mono', error: 'italic' }}
/>
```

키는 어디에 나오든 같은 부분을 뜻합니다. 라벨 있는 컨트롤에서는 `label`, `control`, `description`, `error`이고, portal 표면에서는 `backdrop`입니다.

### 3. 토큰 — 컴포넌트가 이미 칠한 것을 바꿀 때

**항상 통하는 채널이고**, 그 이유는 그냥 믿기보다 알아 두는 편이 낫습니다.

라이브러리는 테두리와 그림자, focus ring, fill을 Tailwind의 _arbitrary property_ — `[box-shadow:var(--p-elev),var(--p-lift)]` 같은 형태 — 로 씁니다. Tailwind는 이런 클래스를 생성된 스타일시트의 **맨 뒤**에 정렬하고, 두 class 중 어느 쪽이 이기는지는 스타일시트가 정합니다. 뒤에 `shadow-none`을 덧붙이면 파일에서는 더 **앞**에 놓이므로 집니다.

그 아래의 custom property는 지지 않습니다. inline `style`은 어떤 class보다도 강하기 때문입니다. [React에서 토큰 지정하기](./color#react에서-토큰-지정하기)를 보세요.

### 그냥 붙인 `className`의 한계

class 속성 안에서의 순서는 아무 의미가 없습니다. 결정하는 것은 생성된 스타일시트 안에서의 순서이고, Tailwind의 정렬은 _이름_ 기준입니다 — 숫자 스케일은 오름차순, 나머지는 알파벳순. 호출자의 의도와는 아무 관계가 없습니다.

| 컴포넌트가 쓰는 것                   | 당신이 쓰는 것 | 이기는 쪽    |
| ------------------------------------ | -------------- | ------------ |
| `text-sm` (`size="sm"`)              | `text-lg`      | **컴포넌트** |
| `bg-transparent` (`variant="ghost"`) | `bg-red-500`   | **컴포넌트** |
| `w-full` (`fullWidth`)               | `w-auto`       | **컴포넌트** |
| `h-10` (`size="md"`)                 | `h-8`          | **컴포넌트** |
| `[box-shadow:…]`                     | `shadow-none`  | **컴포넌트** |
| `h-10`                               | `h-12`         | 당신         |
| `rounded-(--plass-radius-md)`        | `rounded-3xl`  | 당신         |
| `p-4`                                | `px-8`         | 당신         |

확실한 우회로는 둘입니다.

- **토큰.** 바로 위 절에서 설명한 방법입니다. arbitrary property에 닿는 유일한 채널이기도 합니다.
- **`!` 수식자** — `shadow-none!`, `text-lg!`. 라이브러리에는 `!important`가 한 곳도 없으므로 important 유틸리티는 언제나 이깁니다. 선택이 아닌 곳이 하나 있는데, `.plass-link.plass-link` 규칙이 단일 class를 순서와 무관하게 이기는 `PlTextLink`입니다.

### import한 스타일시트

| import | 충돌을 결정하는 것 |
| --- | --- |
| `plass-ui/tailwind.css` 또는 `plass-ui/css/*.css` | 위 표대로 Tailwind의 정렬 — 당신의 class와 컴포넌트의 class가 한 번의 패스에서 생성됩니다 |
| `plass-ui/styles.css` | **`@import` 순서.** 패키지의 CSS는 이미 컴파일된 것이라 당신의 Tailwind 빌드에 참여할 수 없습니다. 당신의 스타일시트보다 _앞에_ import하지 않으면 그 안의 모든 것을 이겨 버립니다 |

### 4. `render` — 요소 자체가 잘못됐을 때

Base UI 자신의 prop이고, 의미가 있는 곳에서 그대로 전달됩니다. `<PlButton render={<a href="/pricing" />}>` 처럼요. 표면을 바꾸지 않고 요소만 바꾸는데, 이건 CSS로는 아무리 해도 못 하는 일입니다.

:::

## 상태 prop의 규칙

상태는 셋이고 각자 자기 축을 가집니다. 그중 하나와 겹치는 네 번째는 스타일이 아니라 API의 버그입니다.

| 상태       | 네이티브 속성   | Focus | 핸들러 실행 |
| ---------- | --------------- | ----- | ----------- |
| `disabled` | 예              | 잃음  | 아니오      |
| `readOnly` | `aria-disabled` | 유지  | 아니오      |
| `loading`  | `aria-disabled` | 유지  | 아니오      |

`loading`과 `readOnly`가 focus를 유지하는 것은 의도된 것입니다. tab 순서에서 빠지면 키보드 사용자는 페이지에서 자기 위치를 잃습니다.
