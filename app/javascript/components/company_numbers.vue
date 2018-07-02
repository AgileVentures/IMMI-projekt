<template>
  <input
    v-bind:value="value"
    v-on:input="$emit('input', $event.target.value)"
  />
</template>

<script>
export default {
  props: ['value'],
  methods: {
    openMap: function () {
      if (this.latitude === null) {
        alert('Coordinates not available')
        return
      }
      var url = 'https://www.google.com/maps/search/?api=1&query=' +
                 this.latitude + ',' + this.longitude
      window.open(url)
    }
  }
}
</script>

<style scoped> {
  font-size: 2em;
  text-align: center;
}
</style>
