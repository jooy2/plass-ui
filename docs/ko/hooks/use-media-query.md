---
title: usePlMediaQuery
order: 1
---

# usePlMediaQuery

<p class="plass-lede">창이 CSS media query에 맞는지를 boolean으로 알려 주고, 답이 바뀌면 다시 렌더링합니다. 라이브러리가 줄곧 갖고 있던 것이며, 공개하는 이유는 직접 쓰면 세 줄이고 그 세 줄이 거의 언제나 한 렌더 늦게 구독되기 때문입니다.</p>

<Demo src="hooks/media-query" :min-height="200" />

::: fw react

```tsx
import { usePlMediaQuery } from 'plass-ui';

const coarse = usePlMediaQuery('(pointer: coarse)');
```

:::

::: fw flutter

hook은 React 전용입니다. Flutter는 같은 질문을 `MediaQuery`에 하고, 그것은 이미 inherited widget이며 이미 rebuild합니다.

```dart
final wide = MediaQuery.sizeOf(context).width >= 768;
```

:::

## Signature

```ts
function usePlMediaQuery(query: string): boolean;
```

|         |                                                   |
| ------- | ------------------------------------------------- |
| `query` | 어떤 CSS media query든, 스타일시트에 쓰듯 그대로. |
| 반환    | 창이 맞는 동안 `true`.                            |

barrel 없이 hook만 쓰고 싶다면 `plass-ui/hooks`에서도 가져올 수 있습니다.

## 첫 답

HTML을 만드는 동안에는 잴 창이 없으므로, 서버에서도 **그것을 hydrate하는 렌더에서도** `false`를 돌려줍니다. 진짜 답은 그다음 렌더에 옵니다.

우회할 한계가 아니라 `useSyncExternalStore`가 보장하는 것이고, 라이브러리 자신의 컴포넌트가 이 hook을 CSS 클래스로 **대체**하지 않고 **짝지어** 쓰는 이유입니다. `PlSidebar`는 마크업에 칼럼을 실어 보내고 breakpoint 아래에서는 Tailwind variant로 숨깁니다. 그래서 휴대폰이 전체 너비 사이드바를 그리는 일이 없습니다. hook이 정하는 것은, 물어볼 창이 생긴 뒤에 drawer가 존재해야 하는지뿐입니다.

> **첫** 프레임에서 맞아야 하는 것은 CSS에 있어야 합니다. 이 hook은 CSS가 내릴 수 없는 결정 — 컴포넌트를 마운트할지, 몇 행을 가져올지, 핸들러가 둘 중 어느 쪽으로 갈지 — 을 위한 것입니다.

## Examples

### 디자인 시스템에 없는 query

breakpoint 사다리는 너비를 다룹니다. 페이지가 알고 싶어 할 나머지 — 포인터, color scheme, 사용자의 모션 설정, 고밀도 디스플레이인지 — 는 전부 query일 뿐입니다.

```tsx
const coarse = usePlMediaQuery('(pointer: coarse)');
const dark = usePlMediaQuery('(prefers-color-scheme: dark)');
const dense = usePlMediaQuery('(resolution >= 2dppx)');
```

### 숨기는 대신 마운트하기

CSS가 정말로 답할 수 없는 경우입니다. `display: none`은 서브트리를 여전히 만들고, effect를 여전히 실행하고, 가져올 것을 여전히 가져옵니다.

```tsx
const wide = usePlMediaQuery('(width >= 64rem)');

return wide ? <PlTable columns={columns} rows={rows} /> : <PlList>{…}</PlList>;
```

## Notes

- query 문자열 하나당 `MediaQueryList` 하나를 두고 그것을 묻는 모든 컴포넌트가 나눠 씁니다. 반응형 컴포넌트가 스무 개 있는 페이지가 리스너를 스무 개가 아니라 하나 답니다.
- query는 스타일시트를 읽는 그 엔진이 읽습니다. 그래서 여기의 `(width >= 48rem)`과 클래스의 `md:`가 같은 순간에 바뀝니다 — 사용자가 root font size를 바꿔 둔 경우까지 포함해서. `innerWidth`를 재는 방식은 그것을 틀립니다.
- `matchMedia`가 없는 브라우저에서는 던지지 않고 `false`를 답합니다.
