Vue.directive('tooltip', function(el, binding){
  $(el).tooltip({
    title: binding.value,
    placement: binding.arg,
    trigger: 'hover'
  })
})
