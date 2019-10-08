$(function() {
  "use strict";
  var custom_context_id;
  var tooltipText;

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
    custom_context_id = e.currentTarget.id;
    $(".custom-menu").toggle(100).css({
      top: e.pageY + "px",
      left: e.pageX + "px"
    });
  });

  $(document).on("click", () => {
    $(".custom-menu").hide(100);
  });

  $(".custom-menu li").click(function(e) {
    const data = {
      "company-h-brand": {
        download: ".download_h_mark",
        link: ".link_for_h_brand",
        show: ".preview_h_brand"
      },
      "proof-of-membership": {
        download: ".download_proof_of_membership",
        link: ".link_for_proof_of_membership",
        show: ".preview_proof_of_membership"
      }
    };
    const action = data[custom_context_id][$(this).attr("data-action")];
    $(action)[0].click();
  });

  $(".copy-to-clipboard").mouseover(function() {
    tooltipText = $(this).attr("data-original-title");
    $(this).attr("data-original-title", "");
  });
  $(".copy-to-clipboard").mouseleave(function() {
    $(this).attr("data-original-title", tooltipText);
  });

  $(".copy-to-clipboard").click(function(e) {
    e.preventDefault();
    var $temp = $("<input>");
    $("body").append($temp);
    $temp.val($(this).attr("href")).select();
    document.execCommand("copy");
    $temp.remove();
    $(this).attr("data-original-title", tooltipText);
    $(this).tooltip("show");
  });
});
