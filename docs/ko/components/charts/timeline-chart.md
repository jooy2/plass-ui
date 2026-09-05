---
title: PlTimelineChart
order: 9
---

# PlTimelineChart

<p class="plass-lede">시간에 대고 놓은 일입니다. 대상마다 한 행, 그 대상이 붙잡고 있던 구간마다 막대 하나. 두 축은 행의 묶음과 달력입니다.</p>

<Demo src="timeline-chart/hero" :min-height="280" />

::: fw react

```tsx
import { PlTimelineChart } from 'plass-ui';

<PlTimelineChart series={plan} />;
```

:::

::: fw flutter

```dart
import 'package:plass_ui/plass_ui.dart';

PlTimelineChart(series: plan);
```

:::

기준선을 걷어 내고 옆으로 눕힌 [막대 차트](./bar-chart)입니다. 막대마다 0이 아니라 제 데이터가 말하는 자리에서 시작하므로, 이 차트가 말하는 것은 _얼마나_ 가 아니라 _언제_ 입니다.

[`PlTimeline`](../display/timeline)과 혼동하지 마세요. 그쪽은 단계의 목록이고 축을 아예 그리지 않습니다. 그쪽은 사건의 차례를, 이쪽은 각 사건이 걸린 시간을 말합니다.

## Props

<PropsTable name="PlTimelineChart" />

한 행은 series입니다. 대상 하나, 이름 하나, 색 하나. 다만 데이터가 값이 아니라 구간이라서 보통의 series 타입 대신 `PlassTimelineSeries`를 받습니다. `legend`도 `hidden`도 없습니다. **행이 곧 category 축이고** 이미 옆에 이름이 적혀 있으니, 그것을 스무 줄로 되풀이하는 legend는 아무도 원하지 않는 필터입니다.

시간 축은 달력이 눈금을 두는 자리에 눈금을 둡니다. 값 축을 반올림하는 1-2-5 계열은 순간에는 맞지 않습니다. 밀리초에 대고 돌리면 200,000,000ms마다 눈금이 생기고, 그것은 아무 화요일의 14:53:20에 떨어집니다.

## Examples

### 겹치는 구간

<Demo src="timeline-chart/lanes" :min-height="240">

::: fw react

<<< @/.vitepress/demos/timeline-chart/lanes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/timeline_chart/lanes.dart

:::

</Demo>

한 행이 동시에 두 가지를 하고 있는 것은 흔한 경우이고, 두 번째 막대를 첫 번째 위에 그리면 두 사실이 한 얼룩이 됩니다. 겹치는 구간은 자기 lane으로 옮깁니다. 모든 스케줄러가 쓰는 탐욕적 배치입니다. 시작 순서로 구간을 훑으며 앞 구간이 끝난 첫 lane에 넣습니다.

겹치지 않는 행은 lane 하나에 남으므로 평범한 행의 두께는 그대로입니다. lane은 **시작** 순서로 정해지지만 구간의 원래 자리에 기록됩니다. 데이터를 적은 순서가 화살표 키가 도는 순서이고, 배치를 정하는 일이 그것을 뒤섞으면 안 되기 때문입니다.

### min과 max

<Demo src="timeline-chart/window" :min-height="200">

::: fw react

<<< @/.vitepress/demos/timeline-chart/window.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/timeline_chart/window.dart

:::

</Demo>

구간은 데이터가 아니라 plot에 맞춰 잘립니다. 축을 이번 분기로 못 박은 사람에게도 지난 분기에 시작한 일이 있고, 가장자리에서 멈춘 막대는 옆으로 더 이어진다고 말하지만 가장자리를 넘어간 막대는 축이 틀렸다고 말합니다.

폭이 0인 구간도 머리카락 굵기는 남깁니다. 이정표도 행 위의 무언가여야 하니까요.

### rounded

[막대 차트](./bar-chart)와 달리 양쪽 끝을 다 깎습니다. 구간은 무에서 자라납니다. 어느 쪽 끝도 0이 아니고, 따라서 읽는 사람이 재기 시작하는 끝이라는 것도 없습니다.

## Accessibility

- 그림은 차트의 이름을 지니고, 모든 구간을 글로 넘깁니다. 행마다 구간이 오가는 두 시각으로 나열됩니다.
- React에서 그림은 `role="img"`이자 tab 정거장이고, 화살표 키가 데이터를 적은 순서대로 구간을 돕니다.
- React에서는 같은 내용이 차트 아래 표에도 적힙니다. 다른 차트가 쓰는 격자가 아니라 **구간마다 한 행**입니다. Gantt의 두 행에는 공통된 열이 없습니다. 한 행의 세 번째 것과 다른 행의 세 번째 것은 서로 무관하고, 나란히 두면 없는 관계를 만들어 냅니다.
- 이름이 있는 구간은 읽어 주는 값에서 그 이름으로 불리고, 행 이름은 첫 줄을 되풀이하는 대신 둘째 줄로 갑니다.
