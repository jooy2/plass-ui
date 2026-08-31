---
title: 오른쪽에서 왼쪽으로
order: 4
---

# 오른쪽에서 왼쪽으로

<p class="plass-lede">element 하나에 속성 하나. 모든 컴포넌트가 논리 속성으로 배치돼 있으므로 <code>dir="rtl"</code>이 설정의 전부입니다 — provider도, 플러그인도, 설정할 것도 없습니다.</p>

<Demo src="rtl/direction" :min-height="420" />

::: fw react

```html
<html dir="rtl"></html>
```

:::

::: fw flutter

Flutter는 widget 트리에서 `Directionality`를 읽고, `MaterialApp`/`WidgetsApp`이 로케일에서 그것을 설정합니다. 이 패키지도 따로 알려 줄 것이 없습니다.

```dart
Directionality(textDirection: TextDirection.rtl, child: child);
```

:::

## 규칙

**`start`/`end`, 절대 `left`/`right`가 아닙니다.** 라이브러리의 모든 padding · margin · border · radius · inset이 논리 속성으로 적혀 있습니다. 그래서 컴포넌트가 start edge라고 부르는 것이 영어에서는 왼쪽이고 아랍어에서는 오른쪽입니다. 방향을 재서 정하는 것은 아무것도 없습니다 — 브라우저가 합니다.

같은 규칙이 prop 어휘에도 닿습니다. [`PlassAlign`](./prop-conventions)이 `start | center | end`인 이유가 정확히 이것이고, `PlSidebar`는 `side="left"`가 아니라 `side="start"`를 받습니다.

## 무엇이 뒤집히고 무엇이 뒤집히지 않는가

|  |  |
| --- | --- |
| padding · margin · border · radius · inset | **뒤집힙니다.** 논리 속성입니다 |
| 텍스트 정렬, 리스트 마커, 표의 열 | **뒤집힙니다.** 브라우저 자신의 것입니다 |
| 읽는 방향을 가리키는 chevron — breadcrumb, pagination 스테퍼, 서브메뉴 | **뒤집힙니다.** 글리프 하나를 돌립니다 |
| `PlSwitch`의 thumb | **뒤집힙니다.** off는 inline start이고, RTL에서 그것은 오른쪽 끝입니다 — 어느 플랫폼의 스위치든 그렇게 동작합니다 |
| `PlPanes` 핸들, `PlSidebar` 드래그, `PlCarousel`과 `PlScrollZone` 스트립 | **뒤집힙니다.** 화살표 키까지 포함해서 |
| `PlassSide` — tooltip의 `side`, drawer의 가장자리 | **일부러 물리적입니다.** 버튼 위의 tooltip은 어느 쓰기 방향에서도 위에 있습니다 |
| 방향성 없는 아이콘 — 별, 휴지통, 스피너 | 뒤집히지 않고, 뒤집혀서도 안 됩니다 |
| 숫자 · 날짜 · 시간 | 브라우저와 `Intl`의 것입니다. `locale`을 받는 컴포넌트에 설정하세요 |

## JavaScript에서 방향을 읽는 세 자리

거의 아무것도 그럴 필요가 없습니다 — CSS가 답합니다. 예외는 **재고 있는 대상** 자체가 물리적인 경우이고, 셋 다 짐작하는 대신 `getComputedStyle(…).direction`을 읽습니다.

- 포인터로 끌거나 화살표 키로 미는 **`PlPanes`** 핸들. 포인터의 `clientX`는 어느 방향에서든 오른쪽으로 커지므로 delta를 뒤집어야 합니다.
- 같은 이유로 **`PlSidebar`**의 리사이즈 드래그, 그리고 접힌 사이드바가 `PlDrawer`가 될 때 붙는 가장자리.
- **`PlTabs`** · **`PlSegmentedButton`** · **`PlFloatingBottomNavigation`**의 움직이는 표시자. `offsetLeft`로 놓이는데, 그것은 어느 방향에서든 왼쪽 가장자리로부터의 거리입니다. 이 셋은 일부러 `left`를 유지합니다 — 논리 속성을 물리적 측정값과 짝지우는 것이야말로 방향을 깨뜨리는 일입니다.

## 직접 확인하기

```tsx
<div dir="rtl">{/* 화면 하나 */}</div>
```

`dir`는 어떤 element에나 붙일 수 있으므로 페이지 전체를 옮기지 않고 컴포넌트 하나만 확인할 수 있습니다. 볼 것은 엉뚱한 쪽에 붙은 여백, 돌아야 하는데 돌지 않은 아이콘, 그리고 여전히 반대 가장자리에서 들쭉날쭉한 텍스트입니다.

틀리는 컴포넌트는 버그입니다 — 라이브러리에는 진짜 `dir="rtl"` 문서에서 렌더링하고, 모든 컴포넌트의 소스에서 짧고 문서화된 목록에 없는 물리 utility를 찾아내는 패키지 테스트가 있습니다.

## Notes

- 라이브러리는 번역을 싣지 않습니다. `PlTable`의 `empty`, `PlPagination`의 label들, `PlAlert`의 `closeLabel`, picker들의 `labels`는 전부 평범한 prop이고, `PlassProvider`가 picker 어휘를 한 번에 정합니다. 번역을 싣는 라이브러리는 페이지가 무슨 언어인지 들어야 하는데, 페이지는 이미 알고 있습니다.
- `PlassProvider`의 `locale`은 날짜 · 시간 · 숫자 컴포넌트에 닿습니다. `dir`는 설정하지 않습니다 — 그것은 문서의 것이고, 라이브러리가 `<html>`에 무언가를 쓸 이유는 없습니다.
