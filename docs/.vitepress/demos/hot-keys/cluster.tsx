import { PlHotKeys } from 'plass-ui';

export default function HotKeysCluster() {
  return (
    <div className="flex flex-wrap items-end gap-8">
      <PlHotKeys cluster={{ up: 'W', left: 'A', down: 'S', right: 'D' }} />
      <PlHotKeys cluster={{ up: '↑', left: '←', down: '↓', right: '→' }} />
    </div>
  );
}
