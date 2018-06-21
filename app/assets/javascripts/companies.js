$(function() {
  'use strict';

  $('body').on('ajax:success', '.companies_pagination', function (e, data) {
    $('#companies_list').html(data);
    // In case there is tooltip(s) in rendered element:
    $('[data-toggle="tooltip"]').tooltip();
  });

  $('body').on('ajax:success', '.events_pagination', function (e, data) {
    $('#company-events').html(data);
    // In case there is tooltip(s) in rendered element:
    $('[data-toggle="tooltip"]').tooltip();
  });

  $('#brandingStatusForm').on('ajax:success', function (e, data) {
    $('#company-branding-status').html(data);
    $('[data-toggle="tooltip"]').tooltip();
  });

  $('.dinkurs-fetch-events').on('ajax:success', function (e, data) {
    $('#company-events').html(data);
    $('[data-toggle="tooltip"]').tooltip();
  });

  $('#editBrandingStatusSubmit').click(function() {
    $('#edit-branding-modal').modal('hide');
  });

  $('#companyCreateForm').on('ajax:success', function (e, data) {
    var ele = $('#' + data.id);

    if (data.status === 'errors') {
      ele.html(data.value);
    } else {
      
      $('#company-create-modal').on('hidden.bs.modal', function() {
        ele.val( function( index, val ) {
          return (val.length > 0 ? val + ', ' + data.value : data.value);
        });
      }).modal('hide');

      $('#company-create-errors').html('');
    }
  });
});
