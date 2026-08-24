import { PlTextLink } from 'plass-ui';

export default function TextLinkSizes() {
  return (
    <div className="flex flex-col items-start gap-2">
      {(['xs', 'sm', 'md', 'lg', 'xl'] as const).map((size) => (
        <PlTextLink key={size} href="#sizes" size={size} color="primary">
          size=&quot;{size}&quot;
        </PlTextLink>
      ))}
    </div>
  );
}
