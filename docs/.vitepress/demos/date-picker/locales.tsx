import { PlDatePicker } from 'plass-ui';

const value = new Date(2026, 6, 27);

const locales = ['en-US', 'en-GB', 'ko', 'de', 'ar-EG'];

export default function DatePickerLocales() {
  return (
    <div className="flex w-full max-w-xs flex-col gap-4">
      {locales.map((locale) => (
        <PlDatePicker key={locale} fullWidth label={locale} locale={locale} defaultValue={value} />
      ))}
    </div>
  );
}
