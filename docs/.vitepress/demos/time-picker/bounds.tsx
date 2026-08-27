import { PlTimePicker } from 'plass-ui';

const day = new Date(2026, 6, 27);

/** A time of day on the reference day. */
function at(hours: number, minutes = 0) {
  return new Date(day.getFullYear(), day.getMonth(), day.getDate(), hours, minutes);
}

export default function TimePickerBounds() {
  return (
    <div className="flex flex-wrap gap-6">
      <PlTimePicker
        label="Between 09:30 and 17:00"
        placeholder="Pick a time"
        referenceDate={day}
        minTime={at(9, 30)}
        maxTime={at(17)}
      />

      <PlTimePicker
        label="On the half hour only"
        placeholder="Pick a time"
        referenceDate={day}
        shouldDisableTime={(value, unit) =>
          unit === 'minute' && value.getMinutes() !== 0 && value.getMinutes() !== 30
        }
      />
    </div>
  );
}
