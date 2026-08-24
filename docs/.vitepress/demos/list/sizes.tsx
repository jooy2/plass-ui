import { PlList, PlListItem } from 'plass-ui';

export default function ListSizes() {
  return (
    <div className="flex w-full max-w-md flex-col gap-4">
      {(['xs', 'sm', 'md', 'lg', 'xl'] as const).map((size) => (
        <PlList key={size} size={size}>
          <PlListItem description="and a description" onClick={() => {}}>
            {size}
          </PlListItem>
        </PlList>
      ))}
    </div>
  );
}
