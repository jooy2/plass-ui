/**
 * The frameworks Plass ships for, and the one axis of this site that is not a
 * language.
 *
 * A component page says the same things about `PlButton` whichever package a
 * reader installs — the same variants, the same sizes, the same reasons — and
 * only the code, the prop names and the install line differ. So the two are not
 * two sites and not two folders: they are one page with the parts that differ
 * marked up, and this file is what marks them.
 *
 * Adding a framework is an entry here plus the `::: fw <id>` blocks on whatever
 * pages have something to say about it. Nothing else reads the list.
 */

export interface FrameworkInfo {
  id: string;
  /** What the sidebar's select shows. */
  label: string;
  /** The package name in that ecosystem's registry. */
  pkg: string;
  /** The fence language its code samples are written in. */
  lang: string;
}

export const FRAMEWORKS: FrameworkInfo[] = [
  { id: 'react', label: 'React', pkg: 'plass-ui', lang: 'tsx' },
  { id: 'flutter', label: 'Flutter', pkg: 'plass_ui', lang: 'dart' }
];

export type Framework = string;

export const FRAMEWORK_IDS: string[] = FRAMEWORKS.map((framework) => framework.id);

export const DEFAULT_FRAMEWORK: Framework = 'react';

/**
 * Where the choice is remembered.
 *
 * It is deliberately not in the URL. A reader who has picked Flutter has picked
 * it for the whole site, and a query string would have to be carried by every
 * link on every page — including the ones in prose, which are written by hand.
 */
export const FRAMEWORK_STORAGE_KEY = 'plass-framework';

/**
 * The choice, applied to `<html>` before the page paints.
 *
 * This runs as a blocking inline script in `<head>` rather than from the app,
 * for the reason every no-flash theme switch does: the framework decides which
 * half of a page is displayed, and a reader who picked Flutter would otherwise
 * watch the React half render and disappear. Written as a string because it has
 * to be inlined into the document rather than imported.
 */
export const FRAMEWORK_HEAD_SCRIPT = `(function(){var i=${JSON.stringify(
  FRAMEWORK_IDS
)},v;try{v=localStorage.getItem(${JSON.stringify(
  FRAMEWORK_STORAGE_KEY
)})}catch(e){}document.documentElement.dataset.fw=i.indexOf(v)<0?${JSON.stringify(
  DEFAULT_FRAMEWORK
)}:v})()`;
