---
title: 오른쪽에서 왼쪽으로
order: 5
---

# 오른쪽에서 왼쪽으로

<p class="plass-lede">element 하나에 속성 하나. 모든 컴포넌트가 논리 속성으로 배치돼 있으므로 <code>dir="rtl"</code>이 전부입니다 — 설정할 것도, 방향을 두 번 적을 일도 없습니다.</p>

<Demo src="rtl/direction" :min-height="420" />

::: fw react

```html
<html dir="rtl"></html>
```

여기까지가 배치이고, JavaScript는 한 줄도 필요 없습니다. **JavaScript에서 방향을 읽는 동작이 몇 가지 있습니다** — slider의 화살표 키, ←/→가 탭 목록을 걷는 방향, popup의 `align="start"`가 어느 물리적 가장자리로 풀리는지 — 그리고 그것들은 [`PlassProvider`](../guide/defaults)를 통해 듣습니다. provider는 문서 자신의 방향을 읽습니다. 넘길 것은 없습니다. provider는 배선이지, 답을 다시 적는 자리가 아닙니다.

```tsx
<PlassProvider>
  <App />
</PlassProvider>
```

:::

::: fw flutter

Flutter는 widget 트리에서 `Directionality`를 읽고, `MaterialApp`/`WidgetsApp`이 로케일에서 그것을 설정합니다. 이 패키지도 따로 알려 줄 것이 없습니다.

```dart
Directionality(textDirection: TextDirection.rtl, child: child);
```

:::

## 규칙

**`start`/`end`, 절대 `left`/`right`가 아닙니다.** 라이브러리의 모든 padding · margin · border · radius · inset이 논리 속성으로 적혀 있습니다. 그래서 컴포넌트가 start edge라고 부르는 것이 영어에서는 왼쪽이고 아랍어에서는 오른쪽입니다.

::: fw react

방향을 재서 정하는 것은 아무것도 없습니다 — 브라우저가 합니다.

:::

::: fw flutter

방향을 재서 정하는 것은 아무것도 없습니다. `EdgeInsetsDirectional` · `PositionedDirectional` · `AlignmentDirectional` · `BorderRadiusDirectional` · `BorderDirectional`이 주변의 `Directionality`에 맞춰 스스로 풀립니다. `Row`와 `CrossAxisAlignment.start`, `TextAlign.start`는 이미 그렇습니다.

:::

같은 규칙이 prop 어휘에도 닿습니다. [`PlassAlign`](./prop-conventions)이 `start | center | end`인 이유가 정확히 이것이고, `PlSidebar`는 왼쪽이 아니라 `start` side를 받습니다.

## 무엇이 뒤집히고 무엇이 뒤집히지 않는가

|  |  |
| --- | --- |
| padding · margin · border · radius · inset | **뒤집힙니다.** 논리 속성입니다 |
| 텍스트 정렬, 리스트 마커, 표의 열 | **뒤집힙니다.** 브라우저 자신의 것입니다 |
| 읽는 방향을 가리키는 chevron — breadcrumb, pagination 스테퍼, 서브메뉴 | **뒤집힙니다.** 글리프 하나를 돌립니다 |
| `PlSwitch`의 thumb | **뒤집힙니다.** off는 inline start이고, RTL에서 그것은 오른쪽 끝입니다 — 어느 플랫폼의 스위치든 그렇게 동작합니다 |
| `PlPanes` 핸들, `PlSidebar` 드래그, `PlCarousel`과 `PlScrollZone` 스트립 | **뒤집힙니다.** 화살표 키까지 포함해서 |
| `PlSlider`의 run | **뒤집힙니다.** 최솟값이 inline start에 있으므로 그림과 누른 자리의 해석, 좌우 화살표 키가 한꺼번에 돌아갑니다 |
| `PlChatBubble`의 꼬리 모서리, `PlButtonGroup`의 각진 가장자리, 날짜 range의 시작과 끝 | **뒤집힙니다.** 읽는 사람의 start를 향합니다 |
| `PlAnimateMarquee` | **뒤집힙니다.** 스트립은 읽는 방향의 start를 향해 흐르므로 단어가 읽는 순서대로 도착합니다 |
| `PlassSide` — tooltip의 `side`, drawer의 가장자리 | **일부러 물리적입니다.** 버튼 위의 tooltip은 어느 쓰기 방향에서도 위에 있습니다 |
| `PlColorPicker`의 rail | **뒤집히지 않습니다.** hue rail은 읽는 축이 아니라 색 공간입니다. 0°는 어느 picker에서든 같은 자리에 있고, 뒤집힌 것은 알아볼 수 없습니다 |
| `PlSkeleton`의 sweep | **뒤집히지 않습니다.** 표면을 가로지르는 빛이고, 로케일에 따라 방향이 바뀌는 빛은 다른 재질로 읽힙니다 |
| 방향성 없는 아이콘 — 별, 휴지통, 스피너 | 뒤집히지 않고, 뒤집혀서도 안 됩니다 |
| 숫자 · 날짜 · 시간 | 플랫폼 자신의 것입니다. `locale`을 받는 컴포넌트에 설정하세요 |

## 코드에서 방향을 읽는 자리

거의 아무것도 그럴 필요가 없습니다. 예외는 **재고 있는 대상** 자체가 물리적인 경우이고, 논리 속성을 물리적 측정값과 짝지우는 것이야말로 방향을 깨뜨리는 일입니다.

::: fw react

세 자리이고, 셋 다 짐작하는 대신 `getComputedStyle(…).direction`을 읽습니다.

- 포인터로 끌거나 화살표 키로 미는 **`PlPanes`** 핸들. 포인터의 `clientX`는 어느 방향에서든 오른쪽으로 커지므로 delta를 뒤집어야 합니다.
- 같은 이유로 **`PlSidebar`**의 리사이즈 드래그, 그리고 접힌 사이드바가 `PlDrawer`가 될 때 붙는 가장자리.
- **`PlTabs`** · **`PlSegmentedButton`** · **`PlFloatingBottomNavigation`**의 움직이는 표시자. `offsetLeft`로 놓이는데, 그것은 어느 방향에서든 왼쪽 가장자리로부터의 거리입니다.

Base UI 자신의 primitive들은 대신 **React context**에서 방향을 읽고, 페이지가 손을 대야 하는 것은 그 하나뿐입니다. provider가 없으면 `useDirection()`은 문서가 무엇이라고 적혀 있든 `ltr`이라고 답합니다. `PlassProvider`가 그 context를 문서의 방향으로 렌더링하는 이유이고, `dir`만 적고 만 페이지가 보기에는 맞고 동작은 반대인 이유입니다.

CSS가 JavaScript 대신 답하는 자리가 한 곳 있고, 그것이 규칙을 증명하는 예외입니다. 논리 `translate`는 없으므로 `.plass-marquee-track`이 `[dir='rtl']` 아래에서 부호를 뒤집습니다.

:::

::: fw flutter

전부 `Directionality.of(context)`를 읽고, 세 종류로 나뉩니다.

- **물리적인 축을 상대하는 포인터와 화살표 키.** 드래그의 `delta.dx`는 어느 방향에서든 오른쪽으로 커지므로 `PlPanes` · `PlSidebar` · `PlSlider` · `PlScrollZone`이 그것을 뒤집습니다. 좌우 화살표 키도 함께 뒤집힙니다 — "더 오른쪽으로"가 아니라 "선을 따라 더 멀리"라는 뜻이기 때문입니다.
- **풀린 채로 넘겨야 하는 모서리.** `PlButtonGroup`의 각진 가장자리, `PlChatBubble`의 꼬리, 날짜 range의 시작과 끝은 `BorderRadiusDirectional`이 아니라 `BorderRadius`로 적혀 있습니다. 같은 값이 `ClipRRect`와 `BoxDecoration`, 그리고 painter에 닿는데 painter는 풀린 것을 받기 때문입니다.
- **읽는 사람에 맞춰 고르는 `PlassSide`.** `PlassSide`는 화면의 가장자리를 가리키므로, `PlNavigationMenu`는 패널이 날아갈 가장자리를 늘 오른쪽으로 두는 대신 그때그때 고릅니다.

**`PlSlider`**는 따로 짚을 만합니다. 여백 하나보다 많은 것이 함께 돌아가기 때문입니다 — 그림과 누른 자리의 해석, 좌우 화살표 키가 한꺼번에 뒤집히고, 그중 일부만 뒤집히는 컨트롤은 자기 자신과 어긋나 있는 컨트롤입니다.

나머지는 전부 `*Directional` widget이고, 아래의 패키지 테스트가 그 상태를 유지시킵니다.

:::

## 직접 확인하기

::: fw react

```tsx
<div dir="rtl">{/* 화면 하나 */}</div>
```

`dir`는 어떤 element에나 붙일 수 있으므로 페이지 전체를 옮기지 않고 컴포넌트 하나만 확인할 수 있습니다. 주변 페이지와 반대로 흐르는 subtree라면 페이지와 같은 이유로 `PlassProvider direction="rtl"`도 함께 감싸 주세요.

:::

::: fw flutter

```dart
Directionality(textDirection: TextDirection.rtl, child: screen);
```

`Directionality`는 어떤 subtree든 감쌀 수 있으므로 앱 전체를 옮기지 않고 widget 하나만 확인할 수 있습니다.

:::

볼 것은 엉뚱한 쪽에 붙은 여백, 돌아야 하는데 돌지 않은 아이콘, 그리고 여전히 반대 가장자리에서 들쭉날쭉한 텍스트입니다.

틀리는 컴포넌트는 버그입니다. 두 패키지 모두 이를 위한 테스트를 두 갈래로 갖고 있습니다. 하나는 진짜 오른쪽에서 왼쪽으로 흐르는 트리를 돌려서 반드시 뒤집혀야 하는 동작들을 확인하고, 다른 하나는 모든 컴포넌트의 소스를 읽어 짧고 문서화된 목록에 없는 물리 속성을 찾아냅니다. _다음_ 컴포넌트를 잡는 것은 두 번째 갈래입니다.

## Notes

- 라이브러리는 번역을 싣지 않습니다. `PlTable`의 `empty`, `PlPagination`의 label들, `PlAlert`의 `closeLabel`, picker들의 `labels`는 전부 평범한 prop이고, 앱 전역 기본값이 picker 어휘를 한 번에 정합니다. 번역을 싣는 라이브러리는 페이지가 무슨 언어인지 들어야 하는데, 페이지는 이미 알고 있습니다.
- `locale` 기본값은 날짜 · 시간 · 숫자 컴포넌트에 닿습니다. 방향은 설정하지 않습니다 — React에서는 문서의 것이고 Flutter에서는 앱의 것이며, 컴포넌트 라이브러리가 그중 어느 쪽에도 무언가를 쓸 이유는 없습니다.
