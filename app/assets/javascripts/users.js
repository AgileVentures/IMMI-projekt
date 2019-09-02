$(function() {
  "use strict";

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

  $(".custom-context").on("contextmenu", e => {
    e.preventDefault();
    $("div.custom-menu").css({ display: "none" });
    $(`#${e.currentTarget.id} .custom-menu`).css({ display: "block" });
  });
  $(document).bind("click", () => {
    $("div.custom-menu").css({ display: "none" });
  });
});
