var Utility = {

  toggle: function () {
    // Toggles (hide or show) via an anchor element $(this) bound to
    // 'click' event.  The 'href' attribute of the element is the
    // id of the content (table, div, etc.) to be toggled
    //
    // Note that this expects the id to have underscores and not hyphens.
    // This is because I18n.t expects underscores and this function is
    // building the I18n.t string.
    var toggleId = $(this).attr('href');
    var showStr = 'toggle.' + toggleId.replace('#','') + '.show';
    var hideStr = 'toggle.' + toggleId.replace('#','') + '.hide';

    var regex = new RegExp(I18n.t(showStr));

    if (regex.test($(this).text())) {
      $(toggleId).show(600);
      $(this).text($(this).text().replace(I18n.t(showStr),
                                          I18n.t(hideStr)));
    } else {
      $(toggleId).hide(600);
      $(this).text($(this).text().replace(I18n.t(hideStr),
                                          I18n.t(showStr)));
    }
    return(false);
  },

  toggle_accordion_label: function () {
    // Changes the label of a bootstrap accordion element based upon whether
    // the element is open or collapsed.
    // The 'id' attribute of the element is the 2nd level i18N lookup key for
    // the associated label (the first level key is 'accordion_label', and the
    // 3rd level key is either 'show' or 'hide'.
    //
    // Note that this expects the id to have underscores and not hyphens.
    // This is because I18n.t expects underscores and this function is
    // building the I18n.t string.
    var toggleId = $(this).attr('id');

    if ($(this).attr('aria-expanded') === 'true') {
      // We are in the process of collapsing the accordion
      var showStr = 'accordion_label.' + toggleId.replace('#','') + '.show';
      $(this).text(I18n.t(showStr));
    } else {
      // We are in the process of opening the accordion
      var hideStr = 'accordion_label.' + toggleId.replace('#','') + '.hide';
      $(this).text(I18n.t(hideStr));
    }
  }

};
