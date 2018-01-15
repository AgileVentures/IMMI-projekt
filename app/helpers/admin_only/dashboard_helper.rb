module AdminOnly
#--------------------------
#
# @class DashboardHelper
#
# @desc Responsibility: Helpers for AdminOnly::Dashboard views
#
#
# @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
# @date   1/1/18
#
# @file dashboard_helper.rb
#
#--------------------------


  module DashboardHelper


    # Can be used to emphasize something (e.g. a total amount) at the start of some text
    #
    # returns HTML to show this amount, followed by the text.  The amount will be
    # surrounded by <span class='total'></span>, and a single space will be placed
    # between the amount and the text.
    #
    # You can specify the CSS class used with the optional 'css_class: parameter
    #
    # Note that all parameters can be anything that responds to '.to_s'
    # (see the styled_item_then_text method for more info)
    #
    # Ex:
    #   styled_total(42, 'All the things')
    # will return
    #  <span class="total">42> All the things
    #
    # Ex:
    #   styled_total(42, 'All the things', css_class: 'super-duper')
    # will return
    #  <span class="super-duper">42> All the things
    #
    #
    def styled_total(amount, text = '', css_class: 'total')
      styled_item_then_text(css_class, amount, text, spacer: ' ')
    end


    # concats a String created with the 'item' surrounded by a span with class = style,
    # then the text. There is a spacer between the item and text.
    # The spacer is a single space (String) by default.
    #
    # Can be used to emphasize something at the start of some text
    #
    # Ex:
    # We want to empahsize the "New!" in "New! 101 Dalmations" so that it is bold and red via the CSS 'important-new' class
    #
    #    styled_item_then_text('New!', 'important-new', '101 Dalmations')
    #
    # will return the String
    #    <span class='important-new'>New!</span> 101 Dalmations
    #
    # Note the spacer (a single space) that has been put before '101 Dalmations'
    #
    #
    # You can change the spacer with the 'spacer:' parameter.
    #
    # Ex:
    #   styled_item_then_text(42, 'very-interesting', 'the answer', spacer: ' -- ')
    # will return the String
    #   <span class='very-interesting'>42</span> -- the answer
    #   Note that the spacer is ' -- ' (a space, 2 dashes, and another space)
    #   Note that 42 is a Number, which will be converted to a String via .to_s
    #
    # Each parameters is converted to a String.
    #   Any object that responds to '.to_s' can be used as a parameter.
    #   Whatever is displays when '.to_s' is sent to it will be displayed.
    #   ("#{item}" will send .to_s to item by definition of the interpolation works)
    #
    # @param [anything that responds to .to_s] css_class - the CSS class that will be put in the <span> tag
    # @param [anything that responds to .to_s] item - the item surrounded by the <span></span> tag
    # @param [anything that responds to .to_s] text - text that comes after the spacer
    # @param [anything that responds to .to_s] spacer - put after the <span></span> tag and before text
    # @return [String] HTML fragment that has item surrounded by a <span> tag with class= css_style,
    #   followed by the spacer, followed by the text
    #
    def styled_item_then_text(css_class = '', item = '', text = '', spacer: ' ')
      content_tag(:span, "#{item}", class: "#{css_class}") + ("#{spacer}#{text}")
    end


  end # DashboardHelper

end # module AdminOnly
