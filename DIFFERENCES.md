# Differences between the builds

Small differences between the React and the Flutter builds of the same component, found during the audit of both packages from 2026-09-13 to 2026-09-28. Each was recorded rather than fixed, because a reader would not call either build broken: a pixel of size, a colour a step apart, a change that eases in one build and happens at once in the other, or a detail of the keyboard or the semantics that only a close comparison shows.

Line numbers are from the commit that found each difference and drift as the code changes; when one no longer matches, search for the symbol. A difference that is closed later is deleted from this list.

- `PlHeatmapChart`: the Flutter card sits 8px higher than the React one (`pl_heatmap_chart.dart` ~468 and `chart_frame.dart` ~2724, against `chart-frame.tsx` ~715).
- Charts: when the legend lets go, the React `mask` that keeps a faded line out of its markers goes at once while the series' opacity eases back, so the line shows through its markers for about 150ms (`chart-line.tsx`, the band `<g>`).
