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
//= require popper
//= require bootstrap
//= require i18n/translations
//= require_tree .
//= require Chart.bundle
//= require chartkick
//= require bootstrap-toggle

$(function() {
    'use strict';

    $.each($('.search_field'), function (index, ele) {
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

    // Bind 'show/hide' search form accordion label switch
    $('#company_search_form').click(Utility.toggle_accordion_label);

    $('#toggle_search_form').click(Utility.toggle);

    $('#toggle_admin_set_password_form').click(Utility.toggle);

    // Enable all Bootstrap tooltips
    $('[data-toggle="tooltip"]').tooltip();

    // CKeditor initialization
    var ready = function() {
      $.each($('.ckeditor'), function (index, ele) {
        CKEDITOR.replace ($(ele).attr('id'));
      })
    };
} );

/*!
 * Bootstrap 4 multi dropdown navbar ( https://bootstrapthemes.co/demo/resource/bootstrap-4-multi-dropdown-navbar/ )
 * Copyright 2017.
 * Licensed under the GPL license
 */


$( document ).ready( function () {
    $( '.dropdown-menu a.dropdown-toggle' ).on( 'click', function ( e ) {
        var $el = $( this );
        var $parent = $( this ).offsetParent( ".dropdown-menu" );
        if ( !$( this ).next().hasClass( 'show' ) ) {
            $( this ).parents( '.dropdown-menu' ).first().find( '.show' ).removeClass( "show" );
        }
        var $subMenu = $( this ).next( ".dropdown-menu" );
        $subMenu.toggleClass( 'show' );

        $( this ).parent( "li" ).toggleClass( 'show' );

        $( this ).parents( 'li.nav-item.dropdown.show' ).on( 'hidden.bs.dropdown', function ( e ) {
            $( '.dropdown-menu .show' ).removeClass( "show" );
        } );

         if ( !$parent.parent().hasClass( 'navbar-nav' ) ) {
            $el.next().css( { "top": $el[0].offsetTop, "left": $parent.outerWidth() - 4 } );
        }

        return false;
    } );
} );
