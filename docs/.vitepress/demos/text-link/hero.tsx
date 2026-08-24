import { PlTextLink } from 'plass-ui';

export default function TextLinkHero() {
  return (
    <p className="max-w-md text-(--plass-fg)">
      Every gradient stop is measured against its own label — the numbers are in{' '}
      <PlTextLink href="#hero">the colour reference</PlTextLink>, and the reasoning is in{' '}
      <PlTextLink href="https://www.w3.org/TR/WCAG22/" newTab>
        WCAG 2.2
      </PlTextLink>
      .
    </p>
  );
}
