import { PlTransfer, type PlTransferItem } from 'plass-ui';

const people: PlTransferItem[] = [
  { value: 'ada', label: 'Ada Lovelace' },
  { value: 'alan', label: 'Alan Turing' },
  { value: 'grace', label: 'Grace Hopper' },
  { value: 'jose', label: 'José Hernández' },
  { value: 'katherine', label: 'Katherine Johnson' },
  { value: 'linus', label: 'Linus Torvalds' }
];

export default function TransferSearchable() {
  return (
    <PlTransfer
      className="max-w-2xl"
      items={people}
      searchable
      defaultValue={['grace']}
      sourceLabel="Everyone"
      targetLabel="On the channel"
      height={180}
    />
  );
}
