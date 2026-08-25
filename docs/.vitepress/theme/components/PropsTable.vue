<script setup>
import { computed } from 'vue';
import { useData } from 'vitepress';
import { localeOf, t, tf } from '../../data/i18n';
import { FRAMEWORKS } from '../../data/frameworks';
import { propTables } from '../../data/props';
import { flutterPropTables } from '../../data/props-flutter';

/**
 * One component's props, once per framework.
 *
 * `<PropsTable name="PlButton" />`
 *
 * Every framework's table is rendered and CSS displays one of them, for the
 * reasons in `styles/framework.css`. A framework the component has not reached
 * yet gets a note instead of an empty table — the absence is information, and a
 * table with no rows in it reads as a bug.
 */
const props = defineProps({
  name: { type: String, required: true }
});

const { lang } = useData();
const locale = computed(() => localeOf(lang.value));

/** Which table each framework reads. One entry per id in `frameworks.ts`. */
const tables = { react: propTables, flutter: flutterPropTables };

const perFramework = computed(() =>
  FRAMEWORKS.map((framework) => ({
    id: framework.id,
    label: framework.label,
    rows: tables[framework.id]?.[props.name] ?? []
  }))
);
</script>

<template>
  <div
    v-for="framework in perFramework"
    :key="framework.id"
    class="plass-props plass-fw"
    :data-fw="framework.id"
  >
    <p v-if="!framework.rows.length" class="plass-fw-missing">
      {{ tf(locale, 'propsMissing', { component: name, framework: framework.label }) }}
    </p>
    <table v-else>
      <thead>
        <tr>
          <th>{{ t(locale, 'propColumn') }}</th>
          <th>{{ t(locale, 'typeColumn') }}</th>
          <th>{{ t(locale, 'defaultColumn') }}</th>
          <th>{{ t(locale, 'descriptionColumn') }}</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="row in framework.rows" :key="row.name">
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
