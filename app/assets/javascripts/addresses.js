$(function() {

  // This callback handles changes to an address "mail" attribute.
  // In particular, if the address was a mailing address, and this
  // was unset (mail == false) in the controller, then this callback
  // receives data that contains the ID of that address - this is used
  // to uncheck the "mail" checkbox, for that address, in the view.
  // (this callback will do the same function for "bill" attribute in future)
  $('body').on('ajax:success', '.cb_address', function (e, data) {
    var checkboxId = '#cb_address_' + data.address_id;

    $(checkboxId).prop('checked', false);
  });
});
