import { useState } from 'react';
import { PlTransfer, PlassProvider, type PlTransferItem } from 'plass-ui';
import { ko } from 'plass-ui/locales';

const columns: PlTransferItem[] = [
  { value: 'name', label: '이름' },
  { value: 'email', label: '이메일' },
  { value: 'role', label: '역할' },
  { value: 'team', label: '팀' },
  { value: 'joined', label: '합류일' }
];

export default function ProviderLabels() {
  const [value, setValue] = useState<string[]>(['name']);

  // Nothing here names a word. Both column headings, the tick-everything link,
  // the two move buttons and the empty line all come from the pack.
  return (
    <PlassProvider locale="ko-KR" labels={ko}>
      <PlTransfer className="max-w-2xl" items={columns} value={value} onValueChange={setValue} />
    </PlassProvider>
  );
}
