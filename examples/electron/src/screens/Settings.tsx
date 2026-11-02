import { PlCard, PlSegment, PlSegmentedButton, PlSelect, PlSwitch } from 'plass-ui';
import type { Preferences } from '../App';

const languages = [
  { value: 'en-US', label: 'English' },
  { value: 'de-DE', label: 'Deutsch' },
  { value: 'es-ES', label: 'Español' },
  { value: 'fr-FR', label: 'Français' },
  { value: 'ja-JP', label: '日本語' },
  { value: 'ko-KR', label: '한국어' },
  { value: 'zh-CN', label: '简体中文' }
];

/** The choices the whole app reads. */
export function Settings({
  preferences,
  onChange
}: {
  preferences: Preferences;
  onChange: (next: Partial<Preferences>) => void;
}) {
  return (
    <PlCard title="Appearance" className="max-w-xl">
      <div className="flex flex-col gap-4">
        <PlSegmentedButton
          aria-label="Theme"
          value={preferences.scheme}
          onValueChange={(next) => onChange({ scheme: next as Preferences['scheme'] })}
        >
          <PlSegment value="system">System</PlSegment>
          <PlSegment value="light">Light</PlSegment>
          <PlSegment value="dark">Dark</PlSegment>
        </PlSegmentedButton>
        <PlSwitch
          label="Right to left"
          checked={preferences.rtl}
          onCheckedChange={(rtl) => onChange({ rtl })}
        />
        <PlSwitch
          label="Compact"
          checked={preferences.compact}
          onCheckedChange={(compact) => onChange({ compact })}
        />
        <PlSelect
          label="Language of the built-in labels"
          items={languages}
          value={preferences.locale}
          onValueChange={(locale) => onChange({ locale: String(locale) })}
        />
      </div>
    </PlCard>
  );
}
