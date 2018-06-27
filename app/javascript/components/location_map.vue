<template>
  <td v-on:click='openMap'>
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
    openMap: function () {
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
