import { PlCard, PlFieldset, PlRadio, PlRadioGroup, PlTextField } from 'plass-ui';

export default function FieldsetOnASheet() {
  return (
    <PlCard className="w-full max-w-md" title="Delivery">
      <div className="flex flex-col gap-6">
        <PlFieldset legend="Where" size="sm">
          <PlTextField size="sm" label="Street" fullWidth />
        </PlFieldset>

        <PlFieldset legend="How fast" size="sm">
          <PlRadioGroup size="sm" defaultValue="standard">
            <PlRadio value="standard" label="Standard" />
            <PlRadio value="express" label="Express" />
          </PlRadioGroup>
        </PlFieldset>
      </div>
    </PlCard>
  );
}
