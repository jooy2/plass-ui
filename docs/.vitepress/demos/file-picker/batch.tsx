import { useState } from 'react';
import { PlFilePicker } from 'plass-ui';

export default function FilePickerBatch() {
  const [message, setMessage] = useState('');

  return (
    <PlFilePicker
      className="max-w-md"
      label="Cover image"
      accept="image/*"
      hint="One image. Drop it with anything else and only the image is kept."
      error={message}
      // An error only when nothing in the batch could be used.
      onAdd={({ kept, rejected }) =>
        setMessage(kept.length === 0 && rejected.length > 0 ? 'None of those is an image.' : '')
      }
    />
  );
}
