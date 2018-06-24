import Vue from 'vue/dist/vue.esm'
import EventLocation from '../components/event_location.vue'

Vue.component('event_location', EventLocation)

document.addEventListener('DOMContentLoaded', () => {
  const event = new Vue({
    el: '#company-events-table',
    components: { EventLocation }
  })
})

// https://vuejsdevelopers.com/2017/05/01/vue-js-cant-help-head-body/
// ^^ why Vue won't work on paginated tables (with the way we're doing that now)
