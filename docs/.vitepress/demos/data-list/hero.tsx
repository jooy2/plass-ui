import { PlCard, PlChip, PlDataList, PlDataListItem } from 'plass-ui';

export default function DataListHero() {
  return (
    <PlCard className="w-full max-w-md">
      <PlDataList divider>
        <PlDataListItem label="Owner" value="Ada Lovelace" />
        <PlDataListItem label="Plan" value="Team" />
        <PlDataListItem label="Status">
          <PlChip color="success" size="sm">
            Active
          </PlChip>
        </PlDataListItem>
        <PlDataListItem label="Created" value="12 March 2026" />
      </PlDataList>
    </PlCard>
  );
}
