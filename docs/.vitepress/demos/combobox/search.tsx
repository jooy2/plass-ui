import { useEffect, useState } from 'react';
import { PlCombobox, type PlComboboxOption } from 'plass-ui';

const cities = [
  { value: 'munich', label: 'München', names: ['munich'] },
  { value: 'vienna', label: 'Wien', names: ['vienna'] },
  { value: 'lisbon', label: 'Lisboa', names: ['lisbon'] },
  { value: 'cologne', label: 'Köln', names: ['cologne'] },
  { value: 'prague', label: 'Praha', names: ['prague'] },
  { value: 'warsaw', label: 'Warszawa', names: ['warsaw'] },
  { value: 'florence', label: 'Firenze', names: ['florence'] }
];

const nothing: PlComboboxOption[] = [];

/** Stands in for a server, which also knows each city by its English name. */
function search(query: string): PlComboboxOption[] {
  const needle = query.trim().toLowerCase();

  return cities
    .filter((city) =>
      [city.label.toLowerCase(), ...city.names].some((name) => name.includes(needle))
    )
    .map(({ value, label }) => ({ value, label }));
}

export default function ComboboxSearch() {
  const [query, setQuery] = useState('');
  const [answer, setAnswer] = useState({ query: '', items: search('') });

  // Asked once the reader has stopped typing for a moment.
  useEffect(() => {
    const timer = setTimeout(() => setAnswer({ query, items: search(query) }), 400);

    return () => clearTimeout(timer);
  }, [query]);

  const answered = answer.query === query;

  return (
    <PlCombobox
      className="w-full max-w-sm"
      fullWidth
      multiple
      label="Cities"
      description="Try munich, vienna or prague."
      placeholder="Search in any language…"
      items={answered ? answer.items : nothing}
      filter={null}
      autoHighlight="always"
      allowCustom={false}
      emptyMessage={answered ? 'No city goes by that name' : 'Searching…'}
      onInputValueChange={setQuery}
    />
  );
}
