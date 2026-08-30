/**
 * The one thing a `rel` must not lose.
 *
 * `noopener` is what stops a page opened in a new tab reaching back through
 * `window.opener`; `noreferrer` sits beside it for the browsers that still need
 * the pair. The common reason to write a `rel` by hand is `nofollow` or
 * `sponsored`, which is an SEO decision — and spelled as a plain override it
 * would silently take the protection off a link that still opens elsewhere.
 *
 * So the caller's value is **merged** rather than replaced: whatever was asked
 * for is kept, with the two tokens added if they are not already there, and a
 * link that stays in this tab keeps exactly the `rel` it was given.
 *
 * Here rather than in either component that needs it — `PlTextLink` and
 * `PlNavigationMenu` — because two copies of a security default are two copies
 * that can drift, and the one that drifts is the one nobody reads.
 */
export function safeRel(target: string | undefined, rel: string | undefined): string | undefined {
  if (target === undefined || target === '' || target === '_self') {
    return rel;
  }

  return [...new Set([...(rel ?? '').split(/\s+/).filter(Boolean), 'noopener', 'noreferrer'])].join(
    ' '
  );
}
