<script setup>
import { computed } from 'vue';
import { useData } from 'vitepress';
import { framework, setFramework } from '../../data/framework';
import { FRAMEWORKS } from '../../data/frameworks';
import { localeOf, t } from '../../data/i18n';

/**
 * The framework switch, at the top of the sidebar.
 *
 * It sits above the menu rather than in the navbar because it is not
 * navigation: it does not take the reader anywhere, it changes what the page
 * they are already on says. The sidebar is where the rest of that scoping
 * lives, and on mobile the drawer carries it along.
 *
 * A real `<select>`, and deliberately: it is one control with two options, the
 * platform already draws a good one on every device, and a custom listbox here
 * would be the one piece of chrome on the site that is not the library's own
 * component and also not the browser's.
 */
const { lang } = useData();
const locale = computed(() => localeOf(lang.value));
</script>

<template>
  <div class="plass-fw-select">
    <label :for="'plass-fw-select'">{{ t(locale, 'frameworkLabel') }}</label>
    <select id="plass-fw-select" :value="framework" @change="setFramework($event.target.value)">
      <option v-for="item in FRAMEWORKS" :key="item.id" :value="item.id">
        {{ item.label }}
      </option>
    </select>
  </div>
</template>
