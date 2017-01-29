var Utility = {

  toggle: function () {
    // Toggles (hide or show) via an anchor element $(this) bound to
    // 'click' event.  The 'href' attribute of the element is the
    // id of the content (table, div, etc.) to be toggled
    var toggle_id = $(this).attr('href');

    if (/Show/.test($(this).text())) {
      $(toggle_id).show(800);
      $(this).text($(this).text().replace('Show', 'Hide'));
    } else {
      $(toggle_id).hide(800);
      $(this).text($(this).text().replace('Hide', 'Show'));
    };

    return(false);
  }
}
