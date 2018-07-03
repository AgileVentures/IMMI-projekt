import Vue from 'vue/dist/vue.esm'
import CompanyNumbers from '../components/company_numbers.vue'

Vue.component('company-numbers', CompanyNumbers)

document.addEventListener('DOMContentLoaded', () => {
  const company_numbers = new Vue({
    el: '#company-number-entry',
    data: { company_numbers: '' },
    components: { CompanyNumbers }
  })
})
