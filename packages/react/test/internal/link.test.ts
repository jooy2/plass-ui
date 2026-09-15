import { describe, expect, it } from 'vitest';
import { safeHref, safeRel } from '../../src/internal/link';

describe('safeRel', () => {
  it('leaves a link that stays in this tab with the rel it was given', () => {
    expect(safeRel(undefined, 'nofollow')).toBe('nofollow');
    expect(safeRel('_self', undefined)).toBeUndefined();
  });

  it('keeps what was asked for and adds the two tokens that protect the opener', () => {
    expect(safeRel('_blank', 'nofollow')).toBe('nofollow noopener noreferrer');
    expect(safeRel('_blank', 'noopener')).toBe('noopener noreferrer');
  });
});

describe('safeHref', () => {
  it('hands back an address a link may go to', () => {
    expect(safeHref('https://example.com/notes')).toBe('https://example.com/notes');
    expect(safeHref('http://example.com')).toBe('http://example.com');
    expect(safeHref('mailto:someone@example.com')).toBe('mailto:someone@example.com');
    expect(safeHref('HTTPS://example.com')).toBe('HTTPS://example.com');
  });

  it('hands back a relative address, which has no scheme to turn down', () => {
    expect(safeHref('/notes')).toBe('/notes');
    expect(safeHref('notes/today')).toBe('notes/today');
    expect(safeHref('#section')).toBe('#section');
    expect(safeHref('//example.com/notes')).toBe('//example.com/notes');
    expect(safeHref('?q=glass')).toBe('?q=glass');
  });

  it('turns down an address that runs code instead of going somewhere', () => {
    expect(safeHref('javascript:alert(1)')).toBeUndefined();
    expect(safeHref('JavaScript:alert(1)')).toBeUndefined();
    expect(safeHref('vbscript:msgbox(1)')).toBeUndefined();
  });

  it('turns it down through the whitespace a browser takes back out', () => {
    expect(safeHref('  javascript:alert(1)')).toBeUndefined();
    expect(safeHref('java\tscript:alert(1)')).toBeUndefined();
    expect(safeHref('java\nscript:alert(1)')).toBeUndefined();
    expect(safeHref('javascript:alert(1)')).toBeUndefined();
  });

  it('turns down the other schemes a card has no business following', () => {
    expect(safeHref('data:text/html,<script>alert(1)</script>')).toBeUndefined();
    expect(safeHref('file:///etc/hosts')).toBeUndefined();
  });

  it('has nothing to say about an address that was not given', () => {
    expect(safeHref(undefined)).toBeUndefined();
  });
});
