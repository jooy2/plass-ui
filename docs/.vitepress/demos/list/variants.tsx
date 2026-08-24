import { PlList, PlListItem } from 'plass-ui';

export default function ListVariants() {
  return (
    <div className="flex w-full max-w-md flex-col gap-4">
      {(['solid', 'glass', 'ghost'] as const).map((variant) => (
        <PlList key={variant} variant={variant} size="sm">
          <PlListItem onClick={() => {}}>{variant}</PlListItem>
          <PlListItem onClick={() => {}}>A second row</PlListItem>
        </PlList>
      ))}
    </div>
  );
}
