'use client';

import * as React from 'react';
import { DefaultsContext, type PlassDefaults } from '../internal/defaults.js';

export interface PlassProviderProps extends PlassDefaults {
  children?: React.ReactNode;
}

/**
 * The defaults every Plass component under it starts from.
 *
 * Optional, and the library is finished without it — this is not a theme file
 * to fill in before the first screen looks like something. What it removes is
 * transcription: an application whose controls are `sm` says so once instead of
 * at every call site, and a Korean application names its locale once instead of
 * on five pickers.
 *
 * ```tsx
 * <PlassProvider size="sm" density="compact" locale="ko-KR">
 *   <App />
 * </PlassProvider>
 * ```
 *
 * **It sets `size`, `color`, `density` and the date vocabulary, and it
 * deliberately does not set `variant` or `elevation`.** Those two name what a
 * surface is *made of* and how far off the page it sits, and both are decided
 * per component by the design language rather than per application: a button is
 * `solid` and rests on the sheet, a field is cut into it. One value for all of
 * them would not be a default, it would be a flattening. `internal/defaults.ts`
 * has the long version.
 *
 * Providers **nest and merge**, so a section of a page can be compact inside an
 * application that is not, and a component's own prop always wins over both.
 */
export function PlassProvider({
  size,
  color,
  density,
  locale,
  weekStartsOn,
  labels,
  children
}: PlassProviderProps) {
  const outer = React.useContext(DefaultsContext);

  // Merged with whatever is already in scope rather than replacing it, so a
  // nested provider that only says `density` does not silently take the
  // application's `locale` away from everything under it. `undefined` on a prop
  // means "not decided here", which is why each one falls through by name
  // rather than the object being spread over the outer one wholesale.
  const value = React.useMemo<PlassDefaults>(
    () => ({
      size: size ?? outer.size,
      color: color ?? outer.color,
      density: density ?? outer.density,
      locale: locale ?? outer.locale,
      weekStartsOn: weekStartsOn ?? outer.weekStartsOn,
      labels: labels ?? outer.labels
    }),
    [size, color, density, locale, weekStartsOn, labels, outer]
  );

  return <DefaultsContext.Provider value={value}>{children}</DefaultsContext.Provider>;
}
