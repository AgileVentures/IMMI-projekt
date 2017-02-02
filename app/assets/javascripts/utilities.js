var Utility = {

  toggle: function () {
    // Toggles (hide or show) via an anchor element $(this) bound to
    // 'click' event.  The 'href' attribute of the element is the
    // id of the content (table, div, etc.) to be toggled
    var toggleId = $(this).attr('href');
    var showStr = 'toggle.' + toggleId.replace('#','') + '.show';
    var hideStr = 'toggle.' + toggleId.replace('#','') + '.hide';

    var regex = new RegExp(I18n.t(showStr));

    if (regex.test($(this).text())) {
      $(toggleId).removeClass('hidden');
      $(toggleId).show(600, function() {
        $(toggleId).addClass('show');
      });
      $(this).text($(this).text().replace(I18n.t(showStr),
                                          I18n.t(hideStr)));
    } else {
      $(toggleId).removeClass('show');
      $(toggleId).hide(400, function () {
        $(toggleId).addClass('hidden');
      });
      $(this).text($(this).text().replace(I18n.t(hideStr),
                                          I18n.t(showStr)));
    }
    return(false);
  }
};
