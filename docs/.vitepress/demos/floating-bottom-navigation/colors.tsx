import { PlFloatingBottomNavigation, PlFloatingBottomNavigationItem } from 'plass-ui';
import { HomeGlyph, SavedGlyph, SearchGlyph } from '../bottom-navigation/glyphs';

export default function FloatingBottomNavigationColors() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-2">
      {(['primary', 'success', 'danger'] as const).map((color) => (
        <PlFloatingBottomNavigation
          key={color}
          color={color}
          position="static"
          safeArea={false}
          defaultValue="search"
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
      ))}
    </div>
  );
}
