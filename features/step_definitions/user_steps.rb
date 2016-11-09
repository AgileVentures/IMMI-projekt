When(/^I fill in the form with data :$/) do |table|
  data = table.hashes.first
  data.each do |label, value|
    if !value.empty?
      fill_in label, with: value
    end
  end
end

When(/^I fill in:$/) do |table|
  table.hashes.each do |hash|
      fill_in hash[:element], with: hash[:content]
  end
end
