import { PlRadio, PlRadioGroup } from 'plass-ui';

export default function RadioGroupOrientation() {
  return (
    <div className="flex flex-col gap-6">
      <PlRadioGroup label="Vertical" defaultValue="daily">
        <PlRadio value="daily" label="Daily" />
        <PlRadio value="weekly" label="Weekly" />
        <PlRadio value="never" label="Never" />
      </PlRadioGroup>

      <PlRadioGroup label="Horizontal" orientation="horizontal" defaultValue="daily">
        <PlRadio value="daily" label="Daily" />
        <PlRadio value="weekly" label="Weekly" />
        <PlRadio value="never" label="Never" />
      </PlRadioGroup>
    </div>
  );
}
