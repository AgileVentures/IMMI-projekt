$(function() {
  'use strict';

  $('#brandingStatusForm').on('ajax:success', function (e, data) {
    $('#company-branding-status').html(data);
    $('[data-toggle="tooltip"]').tooltip();
  });

  $('#editBrandingStatusSubmit').click(function() {
    $('#edit-branding-modal').modal('hide');
  });
});
