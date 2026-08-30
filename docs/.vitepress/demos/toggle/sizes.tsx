import { PlToggle, type PlassSize } from 'plass-ui';

export default function ToggleSizes() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      {(['xs', 'sm', 'md', 'lg', 'xl'] as PlassSize[]).map((size) => (
        <PlToggle key={size} size={size} defaultPressed>
          {size}
        </PlToggle>
      ))}
    </div>
  );
}
