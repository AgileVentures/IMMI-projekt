<template>
  <div id="app">
    <p>{{ message }}</p>
    <p>{{ message2 }}</p>
  </div>
</template>

<script>
export default {
  data: function () {
    return {
      message: "Hello Vue!",
      message2: "This is a test"
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
