<template>
  <input
    v-bind:value='value'
    v-on:input="$emit('input', $event.target.value)"
    v-on:company-created='company_created'
  />
</template>

<script>
export default {
  props: ['initial_value'],
  data: function () {
    return { value: this.initial_value }
  },
  methods: {
    company_created: function (event) {

      // Get company number of new company in modal input field
      // Add that to any existing value(s) in input field in application form

      var modal_num = document.getElementById('company_company_number').value;
      var form_nums = document.getElementById('shf_application_company_number').value;

      var company_numbers = (form_nums.length > 0 ? form_nums + ', ' + modal_num : form_nums);

      // Update "value" attribute of input field
      this.value = company_numbers;

      // Update "company_numbers" var in parent vue instance
      this.$emit('update-company-numbers', company_numbers);

    }
  }
}
</script>

<style scoped> {
  font-size: 2em;
  text-align: center;
}
</style>
