<template>
  <td v-if="latitude != null" v-on:click='openMap'>
    <a> {{ location }} </a>
  </td>
  <td v-else>
    {{ location }}
  </td>
</template>

<script>
export default {
  props: { loc: String,
           lat: Number,
           long: Number },
  data: function () {
    return {
      location: this.loc,
      latitude: this.lat,
      longitude: this.long
    }
  },
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
