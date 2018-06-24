<template>
  <td v-on:click='doSomething'>
    {{ location }}
  </td>
</template>

<script>
export default {
  props: ['loc', 'lat', 'long'],
  data: function () {
    var eleData = {
      location: this.loc,
      latitude: this.lat,
      longitude: this.long
    }
    return eleData;
  },
  methods: {
    doSomething: function () {
      alert('Location: ' + this.location)
      alert('Lat/Long: ' + this.latitude + '/' + this.longitude)
    }
  }
}
</script>

<style scoped> {
  font-size: 2em;
  text-align: center;
}
</style>
