import { useState } from 'react';
import { PlOtpField } from 'plass-ui';

export default function OtpFieldHero() {
  const [code, setCode] = useState('');

  return (
    <PlOtpField
      label="Verification code"
      description={code.length === 6 ? 'Checking…' : 'We texted it to you.'}
      groupSize={3}
      value={code}
      onValueChange={setCode}
    />
  );
}
