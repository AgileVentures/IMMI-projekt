And(/^the following companies exist:$/) do |table|
  table.hashes.each do |company|
    FactoryGirl.create(:company, company)
  end
end