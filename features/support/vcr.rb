require 'vcr'

VCR.cucumber_tags do |t|
  t.tag '@dinkurs_fetch'
  t.tag '@dinkurs_invalid_key'
end
