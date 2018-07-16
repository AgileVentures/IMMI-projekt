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
      return;
    }

    $('#company-create-errors').html('');
    $('#company-create-modal').modal('hide');

    // Trigger event to be handled by Vue instance
    var event = document.createEvent('Event');
    event.initEvent('company-created', true, true);
    ele.get(0).dispatchEvent(event);

  });
});
