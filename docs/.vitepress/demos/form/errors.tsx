import { useState } from 'react';
import { PlButton, PlForm, PlTextField, type PlFormErrors } from 'plass-ui';

export default function FormErrors() {
  const [errors, setErrors] = useState<PlFormErrors>({});

  return (
    <PlForm
      className="w-full max-w-sm"
      errors={errors}
      onSubmit={(values) => {
        // What a server would have answered.
        setErrors(values.username === 'ada' ? { username: 'That name is already taken' } : {});
      }}
    >
      <PlTextField
        name="username"
        label="Username"
        description="Try “ada”, which the server will refuse."
        defaultValue="ada"
        required
      />
      <PlButton type="submit">Create account</PlButton>
    </PlForm>
  );
}
