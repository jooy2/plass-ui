import { useState } from 'react';
import { PlButton, PlTab, PlTabPanel, PlTabs } from 'plass-ui';

export default function TabsControlled() {
  const [tab, setTab] = useState<string | number | null>('write');

  return (
    <div className="flex w-full max-w-lg flex-col gap-3">
      <PlTabs value={tab} onValueChange={setTab}>
        <PlTab value="write">Write</PlTab>
        <PlTab value="preview">Preview</PlTab>

        <PlTabPanel value="write">Markdown goes in here.</PlTabPanel>
        <PlTabPanel value="preview">And comes out rendered here.</PlTabPanel>
      </PlTabs>

      <PlButton
        size="sm"
        variant="glass"
        color="secondary"
        onClick={() => setTab(tab === 'write' ? 'preview' : 'write')}
      >
        Toggle from outside
      </PlButton>
    </div>
  );
}
