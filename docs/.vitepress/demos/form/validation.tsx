import { PlButton, PlForm, PlTextField, type PlFormValidationMode } from 'plass-ui';

const modes: PlFormValidationMode[] = ['onSubmit', 'onBlur', 'onChange'];

export default function FormValidation() {
  return (
    <div className="grid w-full gap-6 sm:grid-cols-3">
      {modes.map((mode) => (
        <PlForm key={mode} validationMode={mode} size="sm">
          <PlTextField
            name="email"
            type="email"
            size="sm"
            label={mode}
            placeholder="Type something wrong"
          />
          <PlButton type="submit" size="sm">
            Submit
          </PlButton>
        </PlForm>
      ))}
    </div>
  );
}
