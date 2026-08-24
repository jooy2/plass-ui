import { PlRadio, PlRadioGroup } from 'plass-ui';

export default function RadioGroupStates() {
  return (
    <div className="flex flex-wrap gap-8">
      <PlRadioGroup label="One option out" defaultValue="card">
        <PlRadio value="card" label="Card" />
        <PlRadio value="transfer" label="Bank transfer" />
        <PlRadio value="invoice" label="Invoice" disabled description="Team plan only." />
      </PlRadioGroup>

      <PlRadioGroup label="Read-only" defaultValue="card" readOnly>
        <PlRadio value="card" label="Card" />
        <PlRadio value="transfer" label="Bank transfer" />
      </PlRadioGroup>

      <PlRadioGroup label="Delivery" error="Choose how it should arrive.">
        <PlRadio value="standard" label="Standard" />
        <PlRadio value="express" label="Express" />
      </PlRadioGroup>
    </div>
  );
}
