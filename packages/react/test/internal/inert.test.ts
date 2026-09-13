import { describe, expect, it } from 'vitest';
import { inertProps, inertValueFor } from '../../src/internal/inert';

describe('inertValueFor', () => {
  it('writes a boolean for React 19, which knows the attribute', () => {
    expect(inertValueFor('19.2.8')).toBe(true);
  });

  it('writes an empty string for React 18, which drops a boolean it does not know', () => {
    expect(inertValueFor('18.3.1')).toBe('');
  });
});

describe('inertProps', () => {
  it('leaves the attribute out when the element is not inert', () => {
    expect(inertProps(false)).toEqual({});
  });

  it('sets it for the React the suite runs on', () => {
    expect(inertProps(true)).toEqual({ inert: true });
  });
});
