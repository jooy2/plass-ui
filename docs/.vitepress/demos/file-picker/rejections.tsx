import { useState } from 'react';
import { PlFilePicker, type PlFileRejection } from 'plass-ui';

const reasons: Record<PlFileRejection['reason'], string> = {
  type: 'that is not an image',
  size: 'that file is over 200 kB',
  count: 'two is the limit'
};

export default function FilePickerRejections() {
  const [message, setMessage] = useState('');

  return (
    <PlFilePicker
      className="max-w-md"
      label="Screenshots"
      accept="image/*"
      multiple
      maxFiles={2}
      maxSize={200_000}
      hint="PNG or JPEG, under 200 kB, two at most"
      error={message}
      onFilesChange={() => setMessage('')}
      onReject={(rejections) =>
        setMessage(`${rejections[0].file.name}: ${reasons[rejections[0].reason]}.`)
      }
    />
  );
}
