import { PlButton, PlHeader, type PlassSize } from 'plass-ui';

export default function HeaderSizes() {
  return (
    <div className="flex w-full flex-col gap-4">
      {(['xs', 'sm', 'md', 'lg', 'xl'] as PlassSize[]).map((size) => (
        <PlHeader
          key={size}
          position="static"
          size={size}
          brand={<span className="font-semibold">{size}</span>}
          actions={<PlButton size={size}>Sign in</PlButton>}
        />
      ))}
    </div>
  );
}
