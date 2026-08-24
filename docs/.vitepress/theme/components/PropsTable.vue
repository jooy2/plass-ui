<script setup>
import { computed } from 'vue';
import { useData } from 'vitepress';
import { localeOf, t } from '../../data/i18n';
import { propTables } from '../../data/props';

/**
 * Renders one component's props table from `data/props.ts`.
 *
 * `<PropsTable name="PlButton" />`
 */
const props = defineProps({
  name: { type: String, required: true }
});

const { lang } = useData();
const locale = computed(() => localeOf(lang.value));
const rows = computed(() => propTables[props.name] ?? []);
</script>

<template>
  <div class="plass-props">
    <table>
      <thead>
        <tr>
          <th>{{ t(locale, 'propColumn') }}</th>
          <th>{{ t(locale, 'typeColumn') }}</th>
          <th>{{ t(locale, 'defaultColumn') }}</th>
          <th>{{ t(locale, 'descriptionColumn') }}</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="row in rows" :key="row.name">
          <td>
            <span class="plass-props-name">{{ row.name }}</span>
            <span v-if="row.required" class="plass-props-required" :title="t(locale, 'required')">
              *
            </span>
            <span v-if="row.shared" class="plass-props-shared" :title="t(locale, 'sharedTitle')">
              {{ t(locale, 'sharedTag') }}
            </span>
          </td>
          <td class="plass-props-type">{{ row.type }}</td>
          <td class="plass-props-default">{{ row.default ?? '—' }}</td>
          <td class="plass-props-desc">{{ row.description[locale] }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
