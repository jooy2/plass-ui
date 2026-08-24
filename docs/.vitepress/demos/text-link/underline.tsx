import { PlTextLink } from 'plass-ui';

export default function TextLinkUnderline() {
  return (
    <div className="flex flex-col gap-2 text-(--plass-fg)">
      <p>
        <PlTextLink href="#underline">always</PlTextLink> — the default, and the only mark a reader
        already knows.
      </p>
      <p>
        <PlTextLink href="#underline" underline="hover">
          hover
        </PlTextLink>{' '}
        — for a dense list where every line is a link.
      </p>
      <p>
        <PlTextLink href="#underline" underline="none" color="primary">
          none
        </PlTextLink>{' '}
        — only where the surroundings already say what it is.
      </p>
    </div>
  );
}
