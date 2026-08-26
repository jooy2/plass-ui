import { PlBottomNavigation, PlBottomNavigationItem } from 'plass-ui';
import { AccountGlyph, HomeGlyph, SearchGlyph } from './glyphs';

export default function BottomNavigationLinks() {
  return (
    <div className="w-full max-w-sm">
      <PlBottomNavigation position="static" defaultValue="home" safeArea={false}>
        <PlBottomNavigationItem value="home" href="#bottom-navigation" icon={<HomeGlyph />}>
          Home
        </PlBottomNavigationItem>
        <PlBottomNavigationItem value="search" href="#bottom-navigation" icon={<SearchGlyph />}>
          Search
        </PlBottomNavigationItem>
        <PlBottomNavigationItem value="account" disabled icon={<AccountGlyph />}>
          Account
        </PlBottomNavigationItem>
      </PlBottomNavigation>
    </div>
  );
}
