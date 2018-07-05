<template>
  <input
    v-bind:value='value'
    v-on:input="$emit('input', $event.target.value)"
    v-on:company-created='company_created'
  />
</template>

<script>
export default {
  props: ['value'],
  methods: {
    company_created: function (event) {
      alert('In company_created handler');
      alert('Event target = ' + event.target);
      alert('Event type = ' + event.type);

      // Get company number of new company in modal input field
      // Add that to any existing value(s) in input field in application form

      var modal_num = document.getElementById('company_company_number').value;
      var form_ele = document.getElementById('shf_application_company_number');
      // var form_nums = document.getElementById('shf_application_company_number').value;
      var form_nums = form_ele.value;

      // form_ele.value = (form_nums.length > 0 ? form_nums + ', ' + modal_num : form_nums);

      var company_numbers = (form_nums.length > 0 ? form_nums + ', ' + modal_num : form_nums);
      alert('New numbers = ' + company_numbers);

      // form_ele.value = company_numbers;

      // Cannot get the emit-event-to-parent-vue-instance to work ???
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
