import { PlFloatingBottomNavigation, PlFloatingBottomNavigationItem, PlTypography } from 'plass-ui';
import { HomeGlyph, SavedGlyph, SearchGlyph } from '../bottom-navigation/glyphs';

export default function FloatingBottomNavigationVariants() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-3">
      {(['glass', 'solid', 'ghost'] as const).map((variant) => (
        <div key={variant} className="flex flex-col gap-1">
          <PlTypography level="caption">{variant}</PlTypography>
          <PlFloatingBottomNavigation
            variant={variant}
            position="static"
            safeArea={false}
            defaultValue="home"
          >
            <PlFloatingBottomNavigationItem value="home" icon={<HomeGlyph />}>
              Home
            </PlFloatingBottomNavigationItem>
            <PlFloatingBottomNavigationItem value="search" icon={<SearchGlyph />}>
              Search
            </PlFloatingBottomNavigationItem>
            <PlFloatingBottomNavigationItem value="saved" icon={<SavedGlyph />}>
              Saved
            </PlFloatingBottomNavigationItem>
          </PlFloatingBottomNavigation>
        </div>
      ))}
    </div>
  );
}
