---
title: 색
order: 2
---

# 색

<p class="plass-lede">여섯 개의 의미론적 계열, 계열마다 손으로 고른 값 셋, 그리고 나머지는 전부 계산됩니다. 이 페이지는 토큰이 무엇이고 어떻게 바꾸는지에 대한 것이고, 왜 이런 모양인지는 디자인 언어에 있습니다.</p>

## 여섯 계열

`color`는 값이 아니라 **역할**입니다. `color="#3558ef"`도 `color="blue"`도 없습니다. 컴포넌트는 여섯 이름 중 하나를 받고, 그 이름이 어떤 값이 되는지는 테마가 가진 결정입니다.

| 계열        | 양 끝                 | 어디에 쓰는지                          |
| ----------- | --------------------- | -------------------------------------- |
| `primary`   | `#3f63f2` → `#1b78cb` | 그 화면이 하려는 액션                  |
| `secondary` | `#6b7488` → `#59637a` | 그 옆의 조용한 액션                    |
| `success`   | `#1b8649` → `#12866a` | 잘 됐습니다                            |
| `warning`   | `#f0a63e` → `#d98613` | 안 될 수도 있습니다                    |
| `danger`    | `#d04246` → `#d53c54` | 되돌아오지 않습니다                    |
| `info`      | `#2379bd` → `#157aa9` | 좋지도 나쁘지도 않지만 알아 둘 만한 것 |

두 값은 135° 그러데이션의 양 끝이고, 음영이 아니라 **같은 밝기에서 hue만 도는 것**입니다. 인디고에서 애저로, 초록에서 틸로, 버밀리언에서 로즈로. `warning`만 예외입니다. 앰버는 앰버로 남은 채 방향을 틀 곳이 없어서, 두 끝이 밝기로 갈리는 유일한 계열입니다.

## 손으로 고른 값과 계산된 값

계열마다 네 값을 적습니다. 그중 셋은 두 테마에서 동일합니다.

```css
--plass-primary-solid: #3f63f2; /* 그러데이션의 한쪽 끝이자 정체성 */
--plass-primary-solid-to: #1b78cb; /* 반대쪽 끝 */
--plass-primary-on-solid: #ffffff; /* 두 지점 위의 잉크 */
--plass-primary-accent: #2c49d6; /* 표면 위에서 읽히는 색 — 테마별 */
```

컴포넌트가 실제로 읽는 값은 전부 그 셋에서 파생 블록이 계산합니다.

| 토큰 | 계산 방식 |
| --- | --- |
| `--plass-{c}-fill` | `solid`에서 `solid-to`로 가는 135° 그러데이션 |
| `--plass-{c}-tint` | `solid`을 `--plass-tint-strength`만큼 (라이트 35%, 다크 55%), drop shadow |
| `--plass-{c}-soft` / `-hover` / `-press` | `accent`를 10% / 18% / 26% |
| `--plass-{c}-line` / `-hover` | `accent`를 30% / 48% |
| `--plass-{c}-ring` | 불투명한 `accent`. 두 테마 모두 표면과 3:1 이상의 대비를 냅니다 |

그래서 **색 계열 추가는 다섯 군데를 건드리는 일입니다**. `PlassColor` union의 항목 하나, `:root`에 손으로 고른 세 줄, `styles.css`의 테마 블록 세 곳(라이트 `:root`, `prefers-color-scheme: dark` 블록, 강제 다크 블록)마다 `accent` 하나, 그리고 계열마다 풀어 쓴 파생 선언 여덟 줄입니다. Flutter 패키지에는 짝을 맞출 자기 `PlassColor`와 자기 계열이 따로 있습니다.

## 테마가 바뀌어도 같은 키 색

`--plass-{c}-solid`와 `--plass-{c}-solid-to`, `--plass-{c}-on-solid`는 모든 테마 블록 바깥의 `:root`에 한 번만 선언됩니다. **파란 유리판은 어두운 방에서도 같은 파란 유리판입니다.**

다크 모드가 바꾸는 것은 그 아래 바닥입니다.

| 토큰                     | 라이트                       | 다크                       |
| ------------------------ | ---------------------------- | -------------------------- |
| `--plass-glass`          | `white / 0.62`               | `white / 0.07`             |
| `--plass-glass-line`     | `white / 0.6`                | `white / 0.12`             |
| `--plass-shadow-ambient` | `rgb(20 40 90 / 0.10)`       | `rgb(0 0 0 / 0.42)`        |
| `--plass-tint-strength`  | `35%`                        | `55%`                      |
| `--plass-{c}-accent`     | 흰 배경에서 읽힐 만큼 어둡게 | 시트 위에서 읽힐 만큼 밝게 |

그림자를 키우는 대신 tint 강도를 올립니다. 거의 검은 페이지 위에서 색이 물든 그림자는 앉을 자리가 거의 없기 때문입니다.

## 시트 자신의 선

`--plass-glass-line`은 잘린 모서리에 걸린 흰빛이고, 뒤에 페이지 배경이 있기 때문에 읽힙니다. 그 선을 **안쪽으로** 돌리면 뒤에 있는 것은 더 이상 배경이 아니라 시트이고, 흰 판 위의 흰 선은 아무것도 아닙니다. 안쪽을 향하는 일에는 토큰 세 개가 따로 있으며, 셋 다 빛이 아니라 중립 잉크입니다.

| 토큰              | 라이트                 | 다크            | 하는 일                   |
| ----------------- | ---------------------- | --------------- | ------------------------- |
| `--plass-divider` | `rgb(20 40 90 / 0.10)` | `white / 0.10`  | 행과 행을 나누는 선       |
| `--plass-stripe`  | `rgb(20 40 90 / 0.03)` | `white / 0.035` | 한 줄 걸러 깔리는 옅은 칠 |
| `--plass-track`   | `rgb(20 40 90 / 0.14)` | `white / 0.16`  | thumb이 지나가는 홈       |

`--plass-border`도 같은 무리입니다. 컨트롤이 _자기_ 둘레에 긋는 중립 헤어라인(tick, switch, field, tabs의 레일)이며 이유도 같습니다. 컨트롤은 배경 위가 아니라 흰 카드 위에 놓이는 일이 아주 흔하고, 보이지 않는 컨트롤은 찾을 수 없는 컨트롤이기 때문입니다.

## 대비

모든 그러데이션의 모든 지점이 자기 `on-solid`에 대해 **4.5:1을 넘기고**, 그 전부가 정확히 4.5에서 0.15 이내에 있습니다.

양쪽이 다 중요합니다. 하한은 라벨이 읽히지 않는 것을 막고, 상한은 팔레트가 필요 이상으로 어두워지는 것을 막습니다. 버튼이 전부 한 톤씩 깊게 깔린 팔레트야말로 팔레트가 조용히 어긋나는 가장 흔한 방식입니다.

채움 위 라벨에 대해 측정한 값입니다.

| 계열        | 시작 | 끝   |
| ----------- | ---- | ---- |
| `primary`   | 4.91 | 4.57 |
| `secondary` | 4.69 | 6.02 |
| `success`   | 4.61 | 4.52 |
| `warning`   | 7.10 | 5.12 |
| `danger`    | 4.62 | 4.56 |
| `info`      | 4.62 | 4.79 |

`warning`이 튀는 이유는 잉크가 어둡기 때문입니다. 나머지가 전부 붙어 있는 방향으로 여유가 있습니다. `secondary`는 중립 slate라서 두 번째 끝을 hue가 아니라 밝기에서 가져옵니다. 앰버라 부를 만한 어떤 밝기에서도 흰 글자는 4.5:1에 닿지 않아서, `--plass-warning-on-solid`는 이 세트에서 유일한 짙은 갈색입니다.

각 `accent`는 자신이 읽히는 배경에 대해 4.5:1을 넘깁니다. 라이트 테마에서는 밝은 wash, 다크 테마에서는 어두운 시트입니다.

## 계열 덮어쓰기

::: fw react

테마 root에 값을 설정하면 거기서 파생되는 모든 것이 따라옵니다. `:root`, 그리고 `.dark`나 `.light`, `data-theme`를 단 요소가 테마 root입니다.

```css
:root {
  --plass-primary-solid: #7c3aed;
  --plass-primary-solid-to: #9333c4;
  --plass-primary-accent: #6d28d9;
}

.dark,
[data-theme='dark'] {
  --plass-primary-accent: #c4b5fd;
}
```

:::

::: fw flutter

토큰 세트는 불변이라 덮어쓰기는 곧 복사입니다. 값을 바꿀 세트에서 출발해 여러분 것을 옮긴 다음, 결과를 `PlassTheme.tokens`에 넘기세요.

```dart
final PlassTokens base = PlassTokens.light();

PlassTheme.tokens(
  tokens: base.withFamily(
    PlassColor.primary,
    base.family(PlassColor.primary).copyWith(
      solid: const Color(0xFF7C3AED),
      solidTo: const Color(0xFF9333C4),
      accent: const Color(0xFF6D28D9),
    ),
  ),
  child: const App(),
)
```

`withFamily`는 계열 하나를 갈아끼우는 짧은 길이고, `PlassTokens.copyWith`은 세트가 들고 있는 나머지를 전부 받습니다. 유리와 차트 팔레트, scrim, 그림자 색조가 거기 있습니다. 다크 테마는 별개의 세트이니 두 테마를 다 쓰는 앱이라면 `PlassTokens.dark()`도 같은 방식으로 만드세요. 계열 값 중 테마에 따라 움직이는 것은 `accent` 하나입니다.

세트는 `build` 안이 아니라 한 번 만들어 들고 계세요. 값이 같은 두 세트는 서로 같다고 비교돼 아무것도 바꾸지 않지만, 매 프레임 새로 만든 세트는 그때마다 계열 여섯 개어치를 비교합니다.

모서리와 움직임도 같은 방법으로 바꿉니다. `radii`는 웹의 `--plass-radius-*`에 해당하는 크기별 모서리 값이고, `motionDuration`과 `motionDurationSlow`, `motionEase`는 `--plass-duration`과 `--plass-duration-slow`, `--plass-ease`입니다. 모든 컴포넌트가 자기 위에서 가장 가까운 세트에서 이 값을 읽으므로, 세트 하나로 화면 전체의 모서리나 속도가 바뀝니다.

```dart
PlassTheme.tokens(
  tokens: PlassTokens.light().copyWith(
    radii: const <PlassSize, double>{
      PlassSize.xs: 4,
      PlassSize.sm: 4,
      PlassSize.md: 6,
      PlassSize.lg: 6,
      PlassSize.xl: 8,
    },
    motionDuration: const Duration(milliseconds: 200),
    motionEase: Curves.easeOutCubic,
  ),
  child: const App(),
)
```

`radii`에는 다섯 크기가 모두 있어야 합니다. `PlassTokens.radius`와 `duration`, `durationSlow`, `ease`는 그대로 남아 세트가 출발하는 기본값을 들고 있지만, 테마를 따라 바뀌지는 않습니다. 라이브러리와 모서리를 맞춰야 하는 위젯을 직접 만든다면 대신 `PlassTheme.of(context).radii`를 읽으세요.

:::

바꿀 때 확인할 것 셋.

1. **두 끝과 잉크의 대비.** 각각 계열의 잉크에 대해 4.5:1을 넘겨야 합니다. 웹에서는 `--plass-primary-on-solid`, Flutter에서는 `onSolid`입니다. 부족하면 잉크가 아니라 그 끝을 어둡게 하세요.
2. **두 끝끼리의 관계.** 밝기가 아니라 *hue*가 달라야 합니다. 그냥 더 어두운 두 번째 끝은 컨트롤을 다시 성형된 키로 만들고, 그건 이 라이브러리가 한 버전을 들여 벗어난 모양입니다.
3. **두 테마 모두에서 accent와 페이지의 대비.** _읽어야_ 하는 값입니다.

### 페이지의 한 부분만 다시 칠하기

::: fw react

그 밖의 요소에 기본 색을 지정하면 기본 색만 바뀝니다. `--plass-primary-fill`과 `--plass-primary-tint`, `--plass-primary-ring`은 기본 색을 섞어 만드는데, 그 섞는 일은 이미 위쪽 테마 root에서 끝났고 거기에는 옛 색이 남아 있습니다. 그래서 버튼은 새 solid를 받고 그러데이션과 포커스 링은 옛 색 그대로입니다.

요소에 `plass-theme`를 붙이면 파생 블록 전체가 그 요소에서 다시 계산됩니다. 재료는 옆에 적어 둔 기본 색입니다.

```html
<div class="plass-theme" style="--plass-primary-solid: #7c3aed; --plass-primary-solid-to: #9333c4">
  <!-- 안쪽의 primary 컨트롤은 그러데이션, tint, 실선, 링까지 보라색입니다. -->
</div>
```

이 클래스는 색만 옮깁니다. `.dark`와 `data-theme`는 아래 서브트리의 테마를 고정하지만, `plass-theme`는 페이지의 라이트/다크를 그대로 둡니다. 범위를 정한 계열이 두 테마에서 똑같이 동작하는 이유가 이것입니다.

닿지 않는 곳이 하나 있습니다. 메뉴와 툴팁, select의 목록을 비롯한 모든 팝업은 portal을 통해 `<body>` 끝에 그려지므로 색을 감싼 요소 바깥이고, 페이지 본래의 계열로 나옵니다. 팝업까지 맞춰야 한다면 라이브러리가 portal로 띄운 positioner마다 달아 두는 `.plass-portal`에 같은 값을 선언하세요.

:::

::: fw flutter

앱 전체가 아니라 서브트리를 `PlassTheme.tokens`로 감싸면 화면의 그 부분만 다시 칠해집니다. 위젯은 자기 위에서 가장 가까운 세트를 읽기 때문입니다.

```dart
PlassTheme.tokens(
  tokens: branded,
  child: const CheckoutPanel(),
)
```

그 서브트리 안에서 연 레이어도 따라옵니다. 메뉴와 툴팁, select의 목록, modal은 모두 `OverlayPortal`의 자식이라 `Overlay`에 그려지면서도 위젯 트리에서는 자기를 연 위젯 아래에 남습니다. 그래서 앱의 세트가 아니라 둘러싼 세트를 읽습니다.

:::

## React에서 토큰 지정하기

::: fw react

토큰을 꼭 스타일시트에 써야 하는 것은 아닙니다. `--plass-*`는 모두 평범한 custom property이므로 inline `style`로 지정할 수 있고, 이건 보기보다 중요합니다. inline 선언은 어떤 class보다도 강하기 때문입니다.

라이브러리는 테두리와 그림자, focus ring, fill을 Tailwind의 _arbitrary property_(`[box-shadow:var(--p-elev),var(--p-lift)]` 같은 형태)로 씁니다. Tailwind는 이런 클래스를 생성된 스타일시트의 가장 뒤에 정렬하므로, 그 뒤에 덧붙인 `shadow-none`은 내용과 무관하게 순서에서 집니다. 그 아래에 있는 토큰은 지지 않습니다.

```tsx
<PlButton style={{ '--plass-radius-md': '4px' }}>Save</PlButton>
```

그리고 custom property는 cascade되므로, 감싸는 요소에 한 줄이면 그 안 전체가 바뀝니다.

```tsx
<div style={{ '--plass-radius-md': '4px', '--plass-blur': 'blur(10px) saturate(160%)' }}>
  <PlCard>…</PlCard>
  <PlButton>Save</PlButton>
</div>
```

TypeScript도 둘 다 받습니다. React의 `CSSProperties`에는 index signature가 없어서, 패키지를 import하면 `--plass-*` 키를 받도록 넓혀 줍니다. 넓어지는 것은 그것뿐이라 다른 custom property의 오타는 여전히 오타입니다.

한 번 써 두고 여러 곳에 쓰는 override 묶음이라면 `PlassTokens`가 더 엄격한 형태입니다. 토큰이 아닌 이름은 컴파일되지 않습니다.

```tsx
import type { PlassTokens } from 'plass-ui';

const quiet: PlassTokens = {
  '--plass-radius-md': '4px',
  '--plass-shadow-1': 'none'
};

<PlButton style={quiet}>Save</PlButton>;
```

컴포넌트가 _자기 자신에게_ 쓰는 `--p-*`는 여기에 포함되지 않습니다. 그건 라이브러리 자신의 계산값(이 컨트롤이 어떤 계열로 정해졌는지, 이 `elevation`에서 그림자가 얼마인지)이고, 그것을 정하는 것은 `color`, `variant`, `elevation` prop입니다.

:::

## 중립색

| 토큰 | 하는 일 |
| --- | --- |
| `--plass-surface` | 반투명할 수 없는 것을 위한 불투명 시트 |
| `--plass-fg` | 본문 글자 |
| `--plass-muted-fg` | 라벨, 설명, adornment |
| `--plass-border` | 유리 hairline이 어울리지 않는 자리의 중립 hairline |
| `--plass-bg-from` / `-to` | 유리를 튜닝한 기준이 된 페이지 wash, [시작하기](../guide/getting-started#컴포넌트-아래에-깔릴-페이지) 참고 |

`--plass-bg-from`과 `--plass-bg-to`는 라이브러리가 스스로는 절대 쓰지 않는 유일한 두 토큰입니다. 평평한 흰 페이지 위의 유리 시트는 앞에 세울 것이 없는데, 컴포넌트 라이브러리가 남의 `<body>`를 칠할 일은 아니어서, 색의 이름만 알려 주고 칠하는 일은 넘기는 것입니다.
