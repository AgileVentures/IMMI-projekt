<template>
  <div id="app">
    <br>
    This in the "app" component (child of "hello" component)
    <br>
    <br>
    <p>{{ message }}</p>
    <p>{{ message2 }}</p>
  </div>
</template>

<script>
export default {
  props: ['message2'],
  data: function () {
    return {
      message: "Hello Vue!",
    }
  }
}
</script>

<style scoped>
p {
  font-size: 2em;
  text-align: center;
}
</style>
