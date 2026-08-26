/**
 * What every row of a `PlMenu` inherits from the popup around it.
 *
 * A context rather than props threaded down, and a file of its own rather than
 * something exported from the component, for one reason: `PlMenu` and
 * `PlContextMenu` are two triggers onto the same surface, and a row written
 * inside either has to come out identical. A context declared in one of them
 * would make the other import from it.
 *
 * `size`, `color` and `density` belong to the *set*. A menu whose third row is
 * a size out is not a menu.
 */

import * as React from 'react';
import type { PlassColor, PlassDensity, PlassSize } from '../types';

export interface PlassMenuContextValue {
  size: PlassSize;
  color: PlassColor;
  density: PlassDensity;
}

export const MenuContext = React.createContext<PlassMenuContextValue>({
  size: 'md',
  color: 'primary',
  density: 'default'
});
