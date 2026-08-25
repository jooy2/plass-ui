<script setup>
import { computed } from 'vue';
import { useData } from 'vitepress';
import FrameworkMark from './FrameworkMark.vue';
import { framework, setFramework } from '../../data/framework';
import { FRAMEWORKS } from '../../data/frameworks';
import { localeOf, t } from '../../data/i18n';

/**
 * The language switch, at the top of the sidebar.
 *
 * It sits above the menu rather than in the navbar because it is not
 * navigation: it does not take the reader anywhere, it changes what the page
 * they are already on says. The sidebar is where the rest of that scoping
 * lives, and on mobile the drawer carries it along.
 *
 * A segmented control rather than a `<select>`, and the reason is not that a
 * select is ugly. There are exactly two options, both are always worth showing,
 * and the choice colours every page on the site — a control that hides one of
 * its two states behind a click is the wrong shape for a decision that
 * important, and a popup list of two items is a popup for nothing.
 *
 * Built out of real radio inputs, hidden and labelled. That is what buys the
 * arrow keys, the group semantics and the focus behaviour for free; a row of
 * `<button>`s would need a roving tabindex written by hand to be as good, and
 * it would be worse.
 */
const { lang } = useData();
const locale = computed(() => localeOf(lang.value));
</script>

<template>
  <div class="plass-lang">
    <p :id="'plass-lang-label'" class="plass-lang-title">{{ t(locale, 'languageLabel') }}</p>
    <div class="plass-lang-track" role="radiogroup" aria-labelledby="plass-lang-label">
      <label
        v-for="item in FRAMEWORKS"
        :key="item.id"
        class="plass-lang-option"
        :class="{ 'is-active': framework === item.id }"
      >
        <input
          type="radio"
          name="plass-lang"
          :value="item.id"
          :checked="framework === item.id"
          @change="setFramework(item.id)"
        />
        <FrameworkMark :framework="item.id" />
        <span>{{ item.label }}</span>
      </label>
    </div>
  </div>
</template>
