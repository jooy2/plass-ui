import { PlTextLink } from 'plass-ui';

export default function TextLinkIcons() {
  return (
    <div className="flex flex-col gap-2 text-(--plass-fg)">
      <p>
        <PlTextLink href="https://base-ui.com" newTab>
          Base UI
        </PlTextLink>{' '}
        — the arrow arrives with <code>newTab</code>.
      </p>
      <p>
        <PlTextLink href="#icons" icon>
          The chain
        </PlTextLink>{' '}
        — <code>icon</code> on its own, for a link that stays here.
      </p>
      <p>
        <PlTextLink href="https://base-ui.com" newTab icon={false}>
          No mark at all
        </PlTextLink>{' '}
        — still announced as a new tab.
      </p>
    </div>
  );
}
