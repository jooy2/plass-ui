import { PlWindowPane } from 'plass-ui';

const systems = [
  'macos',
  'macosx',
  'windows11',
  'windows10',
  'windows8',
  'windows7',
  'windowsxp',
  'linux'
] as const;

export default function WindowPaneOs() {
  return (
    <div className="grid w-full gap-6 sm:grid-cols-2">
      {systems.map((os) => (
        <PlWindowPane key={os} os={os} title={os} height={110}>
          <div className="p-4 text-sm text-(--plass-muted-fg)">{os}</div>
        </PlWindowPane>
      ))}
    </div>
  );
}
