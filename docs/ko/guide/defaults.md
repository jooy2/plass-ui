---
title: 기본값 정하기
order: 2
---

# 기본값 정하기

<p class="plass-lede"><code>PlassProvider</code>는 그 아래 모든 것의 <code>size</code> · <code>color</code> · <code>density</code>와 날짜 어휘를 정합니다. 선택 사항이고 — 없어도 라이브러리는 완성돼 있습니다 — 이것이 없애는 것은 받아쓰기입니다.</p>

<Demo src="provider/defaults" :min-height="320" />

::: fw react

```tsx
import { PlassProvider } from 'plass-ui';

<PlassProvider size="sm" density="compact" locale="ko-KR">
  <App />
</PlassProvider>;
```

:::

::: fw flutter

Flutter 쪽에는 아직 provider가 없습니다. `PlassTheme`은 subtree의 brightness와 토큰을 고정하고, 스타일 축은 여전히 widget마다 씁니다.

```dart
PlassTheme(brightness: Brightness.dark, child: child);
```

:::

## 무엇을 정하는가

|                |                                                                     |
| -------------- | ------------------------------------------------------------------- |
| `size`         | 모든 컴포넌트가 출발하는 size 사다리의 칸                           |
| `color`        | 출발하는 의미론적 family                                            |
| `density`      | 내용을 얼마나 빽빽하게 담을지                                       |
| `locale`       | 날짜 · 시간 · 숫자 컴포넌트가 서식하고 읽는 기준이 되는 BCP 47 태그 |
| `weekStartsOn` | 주가 시작하는 요일. `Date`가 세는 방식이라 일요일이 `0`             |
| `labels`       | picker가 말하는, `Intl`이 의견을 갖지 않는 문자열들                 |

## 무엇을 정하지 않는가, 그리고 왜

**`variant`와 `elevation`은 일부러 없습니다.** 이것을 갭으로 접수하기 전에 읽어 둘 만한 대목입니다.

`variant`는 표면이 무엇으로 _만들어졌는지_ 를 이름 붙입니다. [디자인 언어](../design/design-language)는 첫 문단을 통째로, 누르는 것과 무언가를 담는 것이 서로 다른 재질이라는 사실에 씁니다. `PlButton`이 `solid`이고 `PlCard`가 `glass`인 것은 그것이 그 배치이기 때문이지, 아무도 설정할 짬이 없어서가 아닙니다. 둘에 하나의 값을 주는 것은 기본값이 아니라 납작하게 만드는 일입니다.

`elevation`도 같은 이유로 컴포넌트별 의미론입니다. 컨트롤은 시트 **위에** 놓여 `1`에서 출발하고, field는 시트 **안으로** 파여 `0`에서 출발합니다. 둘에 하나의 숫자를 주는 것은 사다리가 뜻하는 바의 반대를 말하는 것입니다.

정말로 모든 버튼을 `glass`로 하고 싶은 애플리케이션은 버튼에 씁니다 — `size="sm"`을 되풀이하던 호출 지점보다 버튼 쪽이 훨씬 적습니다.

## 우선순위

네 겹이고, 순서는 누구나 짐작할 그 순서입니다.

**컴포넌트 자신의 prop → 그것이 속한 집합 → 가장 가까운 provider → 컴포넌트 자신의 기본값.**

```tsx
<PlassProvider size="sm">
  <PlButtonGroup size="lg">
    <PlButton>그룹에서 온 lg</PlButton>
    <PlButton size="xs">자기 prop에서 온 xs</PlButton>
  </PlButtonGroup>

  <PlButton>provider에서 온 sm</PlButton>
</PlassProvider>
```

provider는 **중첩되고 병합됩니다**. compact가 아닌 애플리케이션 안의 compact한 구역은 `density`만 말하고, 위쪽 provider의 `locale`과 `size`는 그대로 유지합니다.

## Examples

### locale 하나, picker 다섯

`locale`은 `PlCalendar` · `PlDatePicker` · `PlDateRangePicker` · `PlTimePicker` · `PlDateTimePicker` · `PlNumberField`에 닿습니다. `labels`는 각 컴포넌트 자신의 것 **아래로** 병합되므로, 애플리케이션이 어휘를 한 번 번역해 두고도 picker 하나는 다른 말을 할 수 있습니다 — 나머지가 전부 "시작"이라고 할 때 하나만 "체크인"이라고.

<Demo src="provider/locale" :min-height="200">

::: fw react

<<< @/.vitepress/demos/provider/locale.tsx

:::

</Demo>

### 지금 무엇이 걸려 있는지 읽기

```tsx
import { usePlassDefaults } from 'plass-ui';

const { size, locale } = usePlassDefaults();
```

주변 컴포넌트와 줄을 맞춰야 하는 자체 컴포넌트를 위한 것입니다. 모든 필드가 optional입니다 — provider가 정하기 전까지는 아무것도 정해져 있지 않습니다.

## Notes

- **`PlTable`은 provider를 읽지 않습니다.** 유일한 예외입니다. 이 컴포넌트는 일부러 React Server Component의 client graph 밖에 두었고 — 모든 column이 `render` 콜백인데, server component는 그 경계 너머로 함수를 건넬 수 없습니다 — context를 읽으면 client component가 됩니다. `size`와 `density`는 컴포넌트에 직접 주세요.
- provider는 element를 렌더링하지 않고 아무것도 그리지 않습니다. 컴포넌트당 context read 하나가 비용입니다.
- theme이 아닙니다. 색 · 반경 · blur · 그림자는 CSS custom property이고, 그것을 바꾸는 자리는 [Colour](../design/color#overriding-a-family)입니다 — JavaScript에 그 사본을 하나 더 두면 진실이 둘이 됩니다.
