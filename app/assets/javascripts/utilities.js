var Utility = {

  toggle: function () {
    // Toggles (hide or show) via an anchor element $(this) bound to
    // 'click' event.  The 'href' attribute of the element is the
    // id of the content (table, div, etc.) to be toggled
    var toggleId = $(this).attr('href');

    var regex = new RegExp(I18n.t('toggle.show'));

    if (regex.test($(this).text())) {
      $(toggleId).show(800);
      $(this).text($(this).text().replace(I18n.t('toggle.show'),
                                          I18n.t('toggle.hide')));
    } else {
      $(toggleId).hide(800);
      $(this).text($(this).text().replace(I18n.t('toggle.hide'),
                                          I18n.t('toggle.show')));
    }
    return(false);
  }
};
