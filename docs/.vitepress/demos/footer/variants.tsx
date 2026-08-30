import { PlFooter, type PlassVariant } from 'plass-ui';

export default function FooterVariants() {
  return (
    <div className="flex w-full flex-col gap-4">
      {(['solid', 'glass', 'ghost'] as PlassVariant[]).map((variant) => (
        <PlFooter key={variant} size="sm" variant={variant}>
          <span className="text-sm">The sheet is {variant}.</span>
        </PlFooter>
      ))}
    </div>
  );
}
