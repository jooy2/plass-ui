import { PlMockup } from 'plass-ui';

export default function MockupBezel() {
  return (
    <div className="flex w-full flex-wrap items-end justify-center gap-6">
      {(['none', 'thin', 'standard', 'thick'] as const).map((bezel) => (
        <PlMockup key={bezel} device="mobile" bezel={bezel} width={100} />
      ))}
    </div>
  );
}
