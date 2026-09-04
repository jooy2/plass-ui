/**
 * The library's own vocabulary, translated.
 *
 * Every pack is a whole `PlassLabels`, so a missing key is a type error rather
 * than a word that quietly stays English, and every one of them is a **named
 * export from its own module**. That is the shape rather than a
 * `locales['ko']` lookup, and the reason is the bundle: a lookup table has to
 * be in the build for the key to be found in it, so a French application would
 * ship the Korean one. An import ships one.
 *
 * ```tsx
 * import { PlassProvider } from 'plass-ui';
 * import { ko } from 'plass-ui/locales';
 *
 * <PlassProvider locale="ko-KR" labels={ko}>…</PlassProvider>
 * ```
 *
 * `locale` and `labels` are two different jobs and both are needed. `locale` is
 * the BCP 47 tag `Intl` formats dates and numbers against; `labels` is the
 * words `Intl` has no opinion about.
 *
 * **The set is short on purpose.** A pack is only worth shipping when somebody
 * who reads the language has read it, so this is the list that has been read
 * rather than the list a machine could produce. Adding one is a file of the
 * same shape and a pull request.
 */

export { de } from './de.js';
export { en } from './en.js';
export { es } from './es.js';
export { fr } from './fr.js';
export { ja } from './ja.js';
export { ko } from './ko.js';
export { zhHans } from './zh-Hans.js';
