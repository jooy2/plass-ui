/**
 * English — the words the components already say with no provider at all.
 *
 * It is here as a file rather than only as `defaultLabels` so that a locale is
 * one shape everywhere: a caller building their own pack starts from this one
 * and a reviewer comparing two languages is comparing two identical files.
 */
import { defaultLabels } from '../internal/labels.js';
import type { PlassLabels } from '../internal/labels.js';

export const en: PlassLabels = defaultLabels;
