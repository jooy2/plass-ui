import { describe, expect, it, vi } from 'vitest';
import { cachedSearchText, searchText } from '../../src/internal/search.js';

describe('cachedSearchText', () => {
  it('folds the way `searchText` folds', () => {
    const fold = cachedSearchText((item: { label: unknown }) => item.label);

    expect(fold({ label: 'Café' })).toBe(searchText('Café'));
    expect(fold({ label: 42 })).toBe('42');
    expect(fold({ label: null })).toBe('');
  });

  it('reads an item every time and folds it once', () => {
    const read = vi.fn((item: { label: string }) => item.label);
    const fold = cachedSearchText(read);
    const item = { label: 'José' };
    const normalize = vi.spyOn(String.prototype, 'normalize');

    try {
      expect([fold(item), fold(item), fold(item)]).toEqual(['jose', 'jose', 'jose']);
      expect(read).toHaveBeenCalledTimes(3);
      expect(normalize).toHaveBeenCalledTimes(1);
    } finally {
      normalize.mockRestore();
    }
  });

  it('folds an item again once its text has changed', () => {
    const fold = cachedSearchText((item: { label: string }) => item.label);
    const item = { label: 'Seoul' };

    expect(fold(item)).toBe('seoul');

    item.label = 'Busan';

    expect(fold(item)).toBe('busan');
  });
});
