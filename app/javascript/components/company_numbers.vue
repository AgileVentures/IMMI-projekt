<template>
  <input
    v-bind:value='value'
    v-on:input="$emit('input', $event.target.value)"
    v-on:change="handle_change"
  />
</template>

<script>
export default {
  props: ['value'],
  methods: {
    handle_change: function (event, data) {
      alert('Value: ' + event.target.value)
      alert('Data: ' + data)
      "$emit('change', 'inhandler')"
    }
  }
}
</script>

<style scoped> {
  font-size: 2em;
  text-align: center;
}
</style>
