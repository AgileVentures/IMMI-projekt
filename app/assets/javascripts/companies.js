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
});

$(document).ready(function () {

    $('.dinkurs-fetch').on('ajax:before',  function(event, data) {
        // show some sort of spinner or message to let them know the fetch is happening...
    });

    $('.dinkurs-fetch').on('ajax:complete',  function(event, data) {
        // hide the spinner or message to let them know the fetch is happening...
    });

    $('.dinkurs-fetch').on('ajax:success',  function(event, data) {
        $('#dinkurs-events').html(data);
    });

});
