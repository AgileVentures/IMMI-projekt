// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require turbolinks
//= require i18n/translations
//= require_tree .

document.addEventListener("turbolinks:load", function() {
    "use strict";

    $.each($('.company_search'), function (index, ele) {
      if ($(ele).data('select2') === undefined &&
          $(ele).next().hasClass('select2-container')) {
        $(ele).next().remove();
      }
      $(ele).select2({
        language: $(ele).data('language')
      });
    });
    // Above logic due to problem with using back arrow in browser - see:
    // http://stackoverflow.com/questions/36497723/
    // select2-with-ajax-gets-initialized-several-times-with-rails-turbolinks-events

    // Bind "show/hide" search form toggle switch
    $('#toggle_search_form').click(Utility.toggle);

    // Slide mobile navigation from left
    jQuery('#site-navigation .menu-toggle').on('click', function () {
        jQuery(this).toggleClass('active');
        if (jQuery(this).hasClass('active')) {
            jQuery('#site-navigation .menu').animate({left: 0}, {
                duration: 225,
                easing: 'swing'
            });
            return false;
        } else {
            jQuery('#site-navigation .menu').animate({left: -291}, {
                duration: 225,
                easing: 'linear'
            });
            return false;
        }
    });

    /*------------------
     Main navigation
     ------------------*/
    // Add toggle button for mobile navigation sub menus
    jQuery('.menu-item-has-children > a').after('<span class="toggle-sub-menu"></span>');

    // Mobile nav sub menu toggle button click
    jQuery('#site-navigation .toggle-sub-menu').on('click', function () {
        jQuery(this).toggleClass('toggle-sub-menu-active');
        jQuery(this).next().slideToggle('fast');
    });

    // Add mobile class to menu on load or resize
    if (jQuery('body').width() <= 1200) {
        jQuery('#site-navigation .menu').addClass('mobile-menu');
    }
    jQuery(window).on('resize', function () {
        if (jQuery('body').width() <= 1200) {
            jQuery('#site-navigation .menu').addClass('mobile-menu');
        }
    });

    // Hide sub menus on desktop nav on resize
    jQuery(window).on('resize', function () {
        if (jQuery('body').width() > 1200) {
            jQuery('#site-navigation .sub-menu').removeAttr('style');
            jQuery('#site-navigation .toggle-sub-menu-active').removeClass('toggle-sub-menu-active');
            jQuery('#site-navigation .menu').removeClass('mobile-menu');
        }
    });

    // Add shadow to fixed nav after scroll
    jQuery(window).scroll(function () {
        if (jQuery(window).scrollTop() > 0) {
            jQuery('#site-navigation.fixed-nav').addClass('nav-shadow');
            jQuery('#site-navigation.fixed-nav .sub-menu').addClass('nav-shadow-sub');
            jQuery('#site-navigation.fixed-nav ~ .search-toggle-container').addClass('nav-shadow-sub');
        } else {
            jQuery('#site-navigation.fixed-nav').removeClass('nav-shadow');
            jQuery('#site-navigation.fixed-nav .sub-menu').removeClass('nav-shadow-sub');
            jQuery('#site-navigation.fixed-nav ~ .search-toggle-container').removeClass('nav-shadow-sub');
        }
    });

});
//Set timeout for flashes
setTimeout("$('.flashes').fadeOut('slow')", 5000)
