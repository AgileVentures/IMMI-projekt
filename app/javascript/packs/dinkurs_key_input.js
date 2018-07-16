import Vue from 'vue/dist/vue.esm'

require('../directives/tooltip')

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
