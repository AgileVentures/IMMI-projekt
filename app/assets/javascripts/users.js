$(function() {
  "use strict";
  var custom_context_id;

  $("body").on("ajax:success", ".users_pagination", function(e, data) {
    $("#users_list").html(data);
    $('[data-toggle="tooltip"]').tooltip();
  });

  $("#userStatusForm").on("ajax:success", function(e, data) {
    $("#userMemberStatus").html(data);
    $('[data-toggle="tooltip"]').tooltip();
  });

  $("#editUserStatusSubmit").click(function() {
    $("#editStatusModal").modal("hide");
  });

  // $(".custom-context").on("contextmenu", e => {
  //   e.preventDefault();
  //   $("div.custom-menu").css({ display: "none" });
  //   $(`#${e.currentTarget.id} .custom-menu`).css({ display: "block" });
  // });
  // $(document).bind("click", () => {
  //   $("div.custom-menu").css({ display: "none" });
  // });
  $(".custom-context").bind("contextmenu", function(event) {
    event.preventDefault();
    custom_context_id = event.currentTarget.id;
    $(".custom-menu").toggle(100).css({
      top: event.pageY + "px",
      left: event.pageX + "px"
    });
  });

  $(document).bind("click", function() {
    $(".custom-menu").hide(100);
  });

  $(".custom-menu li").click(function(e) {
    switch ($(this).attr("data-action")) {
      case "first":
        console.log("first");
        break;
      case "second":
        console.log("second");
        break;
      case "third":
        console.log("third");
        break;
    }
  });
});
