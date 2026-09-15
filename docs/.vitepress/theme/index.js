import DefaultTheme from 'vitepress/theme';
import Layout from './components/Layout.vue';
import Demo from './components/Demo.vue';
import Fw from './components/Fw.vue';
import { syncFramework } from '../data/framework';
import './styles/index.css';
import './custom.css';

export default {
  extends: DefaultTheme,
  // Adds the live hero to the home page and the framework switch to the
  // sidebar; everything else is the default theme.
  Layout,
  enhanceApp({ app }) {
    // Both are used straight from Markdown, so they are registered globally
    // rather than imported page by page. The props tables are not here
    // because they are not components: `propsTables` in `config.ts` writes
    // them into the page as it is rendered.
    app.component('Demo', Demo);
    app.component('Fw', Fw);

    // Reads the stored choice into the reactive copy the components use, and
    // writes it back onto `<html>`. No-op during SSR.
    syncFramework();
  }
};
