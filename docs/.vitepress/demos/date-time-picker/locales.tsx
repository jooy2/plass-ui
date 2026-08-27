import { PlDateTimePicker } from 'plass-ui';

const value = new Date(2026, 6, 27, 21, 5);

export default function DateTimePickerLocales() {
  return (
    <div className="flex flex-col gap-4">
      {['en-US', 'en-GB', 'ko'].map((locale) => (
        <PlDateTimePicker key={locale} label={locale} locale={locale} defaultValue={value} />
      ))}
    </div>
  );
}
