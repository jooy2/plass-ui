import DefaultTheme from 'vitepress/theme';
import Layout from './components/Layout.vue';
import Demo from './components/Demo.vue';
import PropsTable from './components/PropsTable.vue';
import './styles/index.css';
import './custom.css';

export default {
  extends: DefaultTheme,
  // Adds the live hero to the home page; everything else is the default theme.
  Layout,
  enhanceApp({ app }) {
    // Both are used straight from Markdown, so they are registered globally
    // rather than imported page by page.
    app.component('Demo', Demo);
    app.component('PropsTable', PropsTable);
  }
};
