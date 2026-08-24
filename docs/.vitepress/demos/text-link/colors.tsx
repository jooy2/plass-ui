import { PlTextLink } from 'plass-ui';

export default function TextLinkColors() {
  return (
    <div className="flex flex-wrap items-center gap-4 text-(--plass-fg)">
      <PlTextLink href="#colors">inherited</PlTextLink>
      {(['primary', 'success', 'warning', 'danger', 'info'] as const).map((color) => (
        <PlTextLink key={color} href="#colors" color={color}>
          {color}
        </PlTextLink>
      ))}
    </div>
  );
}
