When (/^I fill out the form with the following attributes:$/) do |table|
      puts table.rows_hash
      criteria = table.rows_hash.each do |field, value|
        fill_in field, :with => value
      end
end

When(/^I click the button "(.*?)"$/) do |button_name|
  click_button button_name
end