import Vue from 'vue/dist/vue.esm'
import LocationMap from '../components/location_map.vue'

Vue.component('location_map', LocationMap)

document.addEventListener('DOMContentLoaded', () => {
  const event = new Vue({
    el: '#company-addresses',
    components: { LocationMap }
  })
})

// https://vuejsdevelopers.com/2017/05/01/vue-js-cant-help-head-body/
// ^^ why Vue won't work on paginated tables (with the way we're doing that now)
