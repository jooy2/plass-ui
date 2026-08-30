import { PlFooter, type PlassSize } from 'plass-ui';

export default function FooterSizes() {
  return (
    <div className="flex w-full flex-col gap-4">
      {(['xs', 'sm', 'md', 'lg', 'xl'] as PlassSize[]).map((size) => (
        <PlFooter key={size} size={size}>
          <span className="text-sm">© 2026 Acme — {size}</span>
        </PlFooter>
      ))}
    </div>
  );
}
