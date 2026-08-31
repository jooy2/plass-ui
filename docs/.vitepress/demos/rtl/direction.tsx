import { useState } from 'react';
import {
  PlButton,
  PlCard,
  PlCheckbox,
  PlSegment,
  PlSegmentedButton,
  PlSwitch,
  PlTextField
} from 'plass-ui';

export default function RtlDemo() {
  const [dir, setDir] = useState<'ltr' | 'rtl'>('rtl');

  return (
    <div className="flex w-full flex-col gap-4">
      <PlSegmentedButton
        size="sm"
        aria-label="Direction"
        value={dir}
        onValueChange={(next) => setDir(next as 'ltr' | 'rtl')}
      >
        <PlSegment value="ltr">ltr</PlSegment>
        <PlSegment value="rtl">rtl</PlSegment>
      </PlSegmentedButton>

      {/* One attribute. Nothing below it is told which way it is running. */}
      <div dir={dir}>
        <PlCard
          title="الإعدادات"
          subtitle="كل شيء ينعكس"
          headerAction={<PlButton size="sm">حفظ</PlButton>}
        >
          <div className="flex flex-col gap-4">
            <PlTextField label="البريد الإلكتروني" placeholder="ada@example.com" fullWidth />
            <PlCheckbox label="تذكرني" />
            <PlSwitch label="الإشعارات" defaultChecked />
          </div>
        </PlCard>
      </div>
    </div>
  );
}
