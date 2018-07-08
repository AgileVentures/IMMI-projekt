import Vue from 'vue/dist/vue.esm'

document.addEventListener('DOMContentLoaded', () => {
  let initial_data = document.getElementById('initial_data')
  let dinkurs_key = initial_data.dataset.dinkurskey || ''

  const dinkurs_key_input = new Vue({
    el: '#dinkurs-company-id',
    data: {
      dinkurs_key: dinkurs_key
    }
  })
})

// This should be pulled in from a separate directive file - need to figure
// out how to do that ....
Vue.directive('tooltip', function(el, binding){
  $(el).tooltip({
    title: binding.value,
    placement: binding.arg,
    trigger: 'hover'
  })
})
