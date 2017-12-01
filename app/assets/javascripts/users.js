$(function() {
  'use strict';

  $('body').on('ajax:success', '.users_pagination', function (e, data) {
    $('#users_list').html(data);
    $('[data-toggle="tooltip"]').tooltip();
  });

  $('#userStatusForm').on('ajax:success', function (e, data) {
    $('#userMemberStatus').html(data);
    $('[data-toggle="tooltip"]').tooltip();
  });

  $('#editUserStatusSubmit').click(function() {
    $('#editStatusModal').modal('hide');
  });
});
