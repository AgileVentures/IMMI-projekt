$(function() {
  'use strict';

  $('body').on('ajax:success', '.companies_pagination', function (e, data) {
    $('#companies_list').html(data);
    // In case there is tooltip(s) in rendered element:
    $('[data-toggle="tooltip"]').tooltip();
  });

  $('#brandingStatusForm').on('ajax:success', function (e, data) {
    $('#company-branding-status').html(data);
    $('[data-toggle="tooltip"]').tooltip();
  });

  $('#editBrandingStatusSubmit').click(function() {
    $('#edit-branding-modal').modal('hide');
  });

  $('#companyCreateForm').on('ajax:success', function (e, data) {
    $('#' + data.id).html(data.html);
    if (data.status === 'success') {
      $('#company-create-modal').modal('hide');
      $('#company-create-errors').html('');
    }
  });
});
