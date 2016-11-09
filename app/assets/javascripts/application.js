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
//= require_tree .

jQuery(document).ready(function() {
    "use strict";

    // Slide mobile navigation from left
    jQuery('#site-navigation .menu-toggle').on('click', function() {
        jQuery(this).toggleClass('active');
        if ( jQuery(this).hasClass('active') ) {
            jQuery('#site-navigation .menu').animate({left:0}, {duration: 225, easing: 'swing'});
            return false;
        } else {
            jQuery('#site-navigation .menu').animate({left:-291}, {duration: 225, easing: 'linear'});
            return false;
        }
    });
});
//Set timeout for flashes
setTimeout("$('.flashes').fadeOut('slow')", 5000)
