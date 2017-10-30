$(function() {
  'use strict';

  $('body').on('ajax:success', '#users-list a[data-remote]', function (e, data) {
    $('#users-list').html(data);
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
