require 'rails_helper'

RSpec.describe AdminOnly::DashboardHelper, type: :helper do


  describe "#styled_total(amount, text = '', css_class: 'total')" do

    context 'all arguments are valid: all respond to .to_s' do
      describe 'amount' do

        it "nil is converted to an empty String (nil.to_s = '')" do
          expect(helper.styled_total(nil,
                                     'All the things',
                                     css_class: 'some-css-class')).to eq "<span class=\"some-css-class\"></span> All the things"
        end

        it 'empty string is just an empty string' do
          expect(helper.styled_total('',
                                     'All the things',
                                     css_class: 'some-css-class')).to eq "<span class=\"some-css-class\"></span> All the things"
        end

        it '424242 / 7 / 6  becomes the String representation of the result of that expression' do
          expect(helper.styled_total(424242 / 7 / 6,
                                     'All the things',
                                     css_class: 'some-css-class')).to eq "<span class=\"some-css-class\">10101</span> All the things"
        end

      end

      describe 'text' do

        it "nil is converted to an empty String (nil.to_s = '')" do
          expect(helper.styled_total(42,
                                     nil,
                                     css_class: 'some-css-class')).to eq "<span class=\"some-css-class\">42</span> "
        end

        it 'empty string is just an empty string' do
          expect(helper.styled_total(42,
                                     '',
                                     css_class: 'some-css-class')).to eq "<span class=\"some-css-class\">42</span> "
        end

        it '424242 / 7 / 6  becomes the String representation of the result of that expression' do
          expect(helper.styled_total(42,
                                     424242 / 7 / 6,
                                     css_class: 'some-css-class')).to eq "<span class=\"some-css-class\">42</span> 10101"
        end
      end

      describe 'css_class' do

        it "comes after 'class =' within the <span></span> tag, surrounded by single quote marks" do
          expect(helper.styled_total(42,
                                     'All the things',
                                     css_class: 'blorf'))
            .to match(/<span class=\"(.*)\">42<\/span> All the things/)
        end

        it "nil is converted to an empty String (nil.to_s = '')" do
          expect(helper.styled_total(42,
                                     'All the things',
                                     css_class: nil)).to eq "<span class=\"\">42</span> All the things"
        end

        it 'empty string is just an empty string (which is invalid css and meaningless, but allowed)' do
          expect(helper.styled_total(42,
                                     'All the things',
                                     css_class: '')).to eq "<span class=\"\">42</span> All the things"
        end

        it '424242 / 7 / 6  becomes the String representation of the result of that expression' do
          expect(helper.styled_total(42,
                                     'All the things',
                                     css_class: 424242 / 7 / 6)).to eq "<span class=\"10101\">42</span> All the things"
        end
      end

    end

    context 'invalid arguments will raise exceptions' do
      describe 'amount' do
        it 'does not respond to .to_s raises Exception ' do
          expect { helper.styled_total(this_method_doesnt_exist,
                                       'All the things',
                                       css_class: 'some-css-class') }.to raise_exception NameError
        end
      end


      describe 'text' do
        it 'does not respond to .to_s raises Exception ' do
          expect { helper.styled_total(42,
                                       this_method_doesnt_exist,
                                       css_class: 'some-css-class') }.to raise_exception NameError
        end
      end

      describe 'css_class' do
        it 'does not respond to .to_s raises Exception ' do
          expect { helper.styled_total(42,
                                       'All the things',
                                       css_class: this_method_doesnt_exist) }.to raise_exception NameError
        end
      end

    end

  end


  describe '#styled_item_then_text( css_class, item, text, spacer: )' do

    context 'all arguments are valid: all respond to .to_s' do

      describe "css_class" do

        it "comes after 'class =' within the <span></span> tag, surrounded by single quote marks" do
          expect(helper.styled_item_then_text('css-class',
                                              'leading item',
                                              'some text',
                                              spacer: '--'))
            .to match(/<span class=\"(.*)\">leading item<\/span>--some text/)
        end

        it "nil is converted to an empty String (nil.to_s = '')" do
          expect(helper.styled_item_then_text(nil,
                                              'leading item',
                                              'some text',
                                              spacer: '--')).to eq "<span class=\"\">leading item</span>--some text"
        end

        it 'empty string is just an empty string (which is invalid css and meaningless, but allowed)' do
          expect(helper.styled_item_then_text('',
                                              'leading item',
                                              'some text',
                                              spacer: '--')).to eq "<span class=\"\">leading item</span>--some text"
        end

        it '424242 / 7 / 6  becomes the String representation of the result of that expression' do
          expect(helper.styled_item_then_text(424242 / 7 / 6,
                                              'leading item',
                                              'some text',
                                              spacer: '--')).to eq "<span class=\"10101\">leading item</span>--some text"
        end

      end

      describe 'item' do

        it 'is surrounded by the <span></span> tag' do
          expect(helper.styled_item_then_text('css-class',
                                              'leading item',
                                              'some text',
                                              spacer: '--'))
            .to match(/<span class=\"css-class\">(.*)<\/span>--some text/)
        end

        it "nil is converted to an empty String (nil.to_s = '')" do
          expect(helper.styled_item_then_text('css-class',
                                              nil,
                                              'some text',
                                              spacer: '--')).to eq "<span class=\"css-class\"></span>--some text"
        end

        it "empty string is just an empty String" do
          expect(helper.styled_item_then_text('css-class',
                                              '',
                                              'some text',
                                              spacer: '--')).to eq "<span class=\"css-class\"></span>--some text"
        end

        it '424242 / 7 / 6  becomes the String representation of the result of that expression' do
          expect(helper.styled_item_then_text('css-class',
                                              424242 / 7 / 6,
                                              'some text',
                                              spacer: '--')).to eq "<span class=\"css-class\">10101</span>--some text"
        end

      end

      describe 'text' do

        it 'comes after the spacer' do
          expect(helper.styled_item_then_text('css-class',
                                              'leading item',
                                              'some text',
                                              spacer: '--'))
            .to match(/<span class=\"css-class\">leading item<\/span>--(.)+/)

        end


        it "nil is converted to an empty String (nil.to_s = '')" do
          expect(helper.styled_item_then_text('css-class',
                                              'leading item',
                                              nil,
                                              spacer: '--')).to eq "<span class=\"css-class\">leading item</span>--"
        end

        it 'empty string is just an empty String' do
          expect(helper.styled_item_then_text('css-class',
                                              'leading item',
                                              '', spacer: '--')).to eq "<span class=\"css-class\">leading item</span>--"
        end

        it '424242 / 7 / 6  becomes the String representation of the result of that expression' do
          expect(helper.styled_item_then_text('css-class',
                                              'leading item',
                                              424242 / 7 / 6,
                                              spacer: '--')).to eq "<span class=\"css-class\">leading item</span>--10101"
        end

      end

      describe 'spacer' do

        it 'comes after the <span></span> tag' do
          expect(helper.styled_item_then_text('css-class',
                                              'leading item',
                                              'some text',
                                              spacer: '--')).to match /<span class=\"css-class\">leading item<\/span>(.)+some text/

        end

        it 'default is a single space' do
          expect(helper.styled_item_then_text('css-class',
                                              'leading item',
                                              'some text')).to eq "<span class=\"css-class\">leading item</span> some text"

        end

        it "nil is converted to an empty String (nil.to_s = '')" do
          expect(helper.styled_item_then_text('css-class',
                                              'leading item',
                                              'some text',
                                              spacer: nil)).to eq "<span class=\"css-class\">leading item</span>some text"

        end

        it 'empty String is just an empty String' do
          expect(helper.styled_item_then_text('css-class',
                                              'leading item',
                                              'some text',
                                              spacer: '')).to eq "<span class=\"css-class\">leading item</span>some text"

        end

        it "'--'" do
          expect(helper.styled_item_then_text('css-class',
                                              'leading item',
                                              'some text',
                                              spacer: '--')).to eq "<span class=\"css-class\">leading item</span>--some text"
        end

        it '424242 / 7 / 6  becomes the String representation of the result of that expression' do
          expect(helper.styled_item_then_text('css-class',
                                              'leading item',
                                              'some text',
                                              spacer: 424242 / 7 / 6)).to eq "<span class=\"css-class\">leading item</span>10101some text"
        end

      end

    end

    context 'invalid arguments will raise exceptions' do

      describe 'css_class' do
        it 'does not respond to .to_s raises Exception ' do
          expect { helper.styled_item_then_text(blorfo,
                                                'leading item',
                                                'some text',
                                                spacer: '--') }.to raise_exception NameError
        end
      end

      describe 'item' do
        it 'does not respond to .to_s raises Exception ' do
          expect { helper.styled_item_then_text('css-class',
                                                blorfo,
                                                'some text',
                                                spacer: '--') }.to raise_exception NameError
        end
      end

      describe 'text' do
        it 'does not respond to .to_s raises Exception ' do
          expect { helper.styled_item_then_text('css-class',
                                                'leading item',
                                                blorfo,
                                                spacer: '--') }.to raise_exception NameError
        end
      end

      describe 'spacer' do
        it 'does not respond to .to_s raises Exception ' do
          expect { helper.styled_item_then_text('css-class',
                                                'leading item',
                                                'some text',
                                                spacer: blorfo) }.to raise_exception NameError
        end
      end
    end

  end

end
