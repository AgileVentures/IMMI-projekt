import Vue from 'vue/dist/vue.esm'

document.addEventListener('DOMContentLoaded', () => {
  let initial_data = document.getElementById('initial_data')
  let company_numbers = initial_data.dataset.companynumbers || ''

  const company_numbers_input = new Vue({
    el: '#company-number-entry',
    data: {
      company_numbers: company_numbers
    },
    methods: {
      company_created: function (event) {

        // Get company number of new company in modal input field
        // Add that to any existing value(s) in input field in application form

        var modal_num = document.getElementById('company_company_number').value;
        var form_nums = document.getElementById('shf_application_company_number').value;

        var company_numbers = (form_nums.length > 0 ? form_nums + ', ' + modal_num : modal_num);

        // Update data attribute of input field
        this.company_numbers = company_numbers;
      }
    }
  })
})
