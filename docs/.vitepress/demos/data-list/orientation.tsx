import { PlDataList, PlDataListItem } from 'plass-ui';

export default function DataListOrientation() {
  return (
    <PlDataList className="w-full max-w-xs" orientation="vertical">
      <PlDataListItem label="Endpoint" value="https://api.example.com/v2/projects/9f21/events" />
      <PlDataListItem label="Region" value="eu-west-1" />
    </PlDataList>
  );
}
