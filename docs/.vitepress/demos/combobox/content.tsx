import { PlAvatar, PlCombobox } from 'plass-ui';

const people = [
  { value: 'mina', name: 'Mina Park', team: 'Design' },
  { value: 'jonas', name: 'Jonas Weber', team: 'Platform' },
  { value: 'amara', name: 'Amara Okafor', team: 'Research' },
  { value: 'leo', name: 'Leo Rossi', team: 'Support' }
];

const assignees = people.map(({ value, name, team }) => ({
  value,
  label: name,
  content: (
    <span className="flex items-center gap-2">
      {/* The name is said beside it, so the picture is not said again. */}
      <span aria-hidden="true">
        <PlAvatar size="xs" name={name} />
      </span>
      <span className="truncate">{name}</span>
      <span className="ms-auto text-(--plass-muted-fg)">{team}</span>
    </span>
  )
}));

export default function ComboboxContent() {
  return (
    <PlCombobox
      className="w-full max-w-sm"
      fullWidth
      label="Assignee"
      placeholder="Search people…"
      allowCustom={false}
      items={assignees}
    />
  );
}
