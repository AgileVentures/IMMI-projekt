# frozen_string_literal: true

require 'rails_helper'

describe InputSanitizer do
  context 'URL sanitizer' do
    it 'handles nil' do
      expect(InputSanitizer.sanitize_url(nil)).to eq ''
    end

    it 'removes javascript' do
      expect(InputSanitizer.sanitize_url('blorfo///"javascript//"')).to eq 'blorfo///"//"'
    end

    it 'uses Sanitizer to remove CSS tags' do
      expect(InputSanitizer.sanitize_url('<STYLE>@import"alert(\'XSS\')";</STYLE>')).to eq '@import"alert(\'XSS\')";'
    end

    it 'uses Santizer to remove anything inside a tag' do
      expect(InputSanitizer.sanitize_url('<IMG SRC="javascript:alert(\'XSS\');">')).to eq ''
    end

    it 'uses remove tags and javascript' do
      expect(InputSanitizer.sanitize_url('<STYLE>@import"javascript:alert(\'XSS\')";</STYLE>')).to eq '@import":alert(\'XSS\')";'
    end
  end

  context 'HTML Sanitizer' do
    it 'handles nil and empty string' do
      expect(InputSanitizer.sanitize_html(nil)).to eq ''
      expect(InputSanitizer.sanitize_html('')).to eq ''
    end

    it 'removes script tags' do
      expect(InputSanitizer.sanitize_html("<script>alert('Hello');</script>"))
        .to eq "alert('Hello');"

      expect(InputSanitizer.sanitize_html("<SCRIPT>alert('Hello');</SCRIPT>"))
        .to eq "alert('Hello');"

      expect(InputSanitizer.sanitize_html("<scscriptript>alert('Hello');</scscriptript>"))
        .to eq "alert('Hello');"
    end

    it 'removes javascript' do
      str = "<img src=javascript:alert('Hello')>"
      expect(InputSanitizer.sanitize_html(str)).to eq '<img>'

      str = %{<table background="javascript:alert('Hello')">}
      expect(InputSanitizer.sanitize_html(str)).to eq '<table></table>'
    end

    it 'removes other unwanted tags' do
      str = '<button>Please click me</button>'
      expect(InputSanitizer.sanitize_html(str)).to eq 'Please click me'

      str = '<canvas> ... </canvas>'
      expect(InputSanitizer.sanitize_html(str)).to eq ' ... '

      str = '<embed> ... </embed>'
      expect(InputSanitizer.sanitize_html(str)).to eq ' ... '

      str = '<html> ... </html>'
      expect(InputSanitizer.sanitize_html(str)).to eq ' ... '

      str = '<input> ... </input>'
      expect(InputSanitizer.sanitize_html(str)).to eq ' ... '
    end

    it 'removes iframe' do
      str = '<iframe src="www.othersite.com"></iframe>'
      expect(InputSanitizer.sanitize_html(str)).to be_empty
    end

    it 'removes event handlers' do
      str = '<img src="http://www.harmless.com/img" width="400" ' \
            'height="400" onmouseover="..." />'
      expect(InputSanitizer.sanitize_html(str))
        .to eq '<img src="http://www.harmless.com/img" width="400" height="400">'

      str = '<button onclick="...">Please click me</button>'
      expect(InputSanitizer.sanitize_html(str)).to eq 'Please click me'
    end
  end
end
