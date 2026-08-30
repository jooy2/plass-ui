import { PlFieldset, PlTextField, type PlassSize } from 'plass-ui';

export default function FieldsetSizes() {
  return (
    <div className="grid w-full gap-8 sm:grid-cols-3">
      {(['sm', 'md', 'lg'] as PlassSize[]).map((size) => (
        <PlFieldset key={size} size={size} legend={size} description="A group at this step">
          <PlTextField size={size} label="One" fullWidth />
          <PlTextField size={size} label="Two" fullWidth />
        </PlFieldset>
      ))}
    </div>
  );
}
