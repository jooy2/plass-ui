'use client';

import * as React from 'react';
import { DirectionProvider } from '@base-ui/react/direction-provider';
import { DefaultsContext, type PlassDefaults } from '../internal/defaults.js';
import { useDocumentDirection } from '../internal/direction.js';

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
 *
 * **It also carries the reading direction**, and that one is not a default the
 * caller sets — it is read off the document. `dir="rtl"` turns the layout over
 * on its own, but Base UI reads the direction from a React context, so without
 * this the arrow keys, the composite navigation and the popup alignment would
 * all still be running left to right under a right-to-left page. See
 * `internal/direction.ts`.
 */
export function PlassProvider({
  size,
  color,
  density,
  locale,
  weekStartsOn,
  labels,
  direction,
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
      labels: labels ?? outer.labels,
      direction: direction ?? outer.direction
    }),
    [size, color, density, locale, weekStartsOn, labels, direction, outer]
  );

  // The document is the fallback rather than the override: a provider that was
  // told a direction is describing a subtree that runs the other way, and the
  // page around it is not the authority on that.
  const document = useDocumentDirection();

  return (
    <DirectionProvider direction={value.direction ?? document}>
      <DefaultsContext.Provider value={value}>{children}</DefaultsContext.Provider>
    </DirectionProvider>
  );
}
