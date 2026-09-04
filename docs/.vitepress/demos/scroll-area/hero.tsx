import { PlCard, PlScrollArea } from 'plass-ui';

const notes = [
  'Tags can be renamed from the sidebar.',
  'The export dialog remembers the last format you used.',
  'Keyboard shortcuts work while a dialog is open.',
  'A saved filter can be shared with a link.',
  'Bulk actions ask before they delete anything.',
  'The table remembers its column widths per project.',
  'Comments can be resolved without deleting them.',
  'Search matches inside attachments as well as titles.'
];

export default function ScrollAreaHero() {
  return (
    <PlCard className="w-full max-w-sm">
      <PlScrollArea height={200} label="Release notes">
        <ul className="flex flex-col gap-3 pe-3 text-sm">
          {notes.map((note) => (
            <li key={note}>{note}</li>
          ))}
        </ul>
      </PlScrollArea>
    </PlCard>
  );
}
