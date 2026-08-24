import { PlList, PlListItem } from 'plass-ui';

export default function ListDividers() {
  return (
    <div className="flex w-full max-w-md flex-col gap-5">
      <PlList>
        <PlListItem onClick={() => {}}>Tiles, with space between them</PlListItem>
        <PlListItem onClick={() => {}}>The sheet keeps its padding</PlListItem>
      </PlList>

      <PlList dividers>
        <PlListItem onClick={() => {}}>Ruled lines, edge to edge</PlListItem>
        <PlListItem onClick={() => {}}>The sheet gives its padding up</PlListItem>
      </PlList>
    </div>
  );
}
