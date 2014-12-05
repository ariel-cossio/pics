Then(/^I should see the Picture manager message "(.*?)"$/) do |login_message|
  page.has_content?(login_message)
end

Then(/^I should see the user as "(.*?)"$/) do |user|
  page.find('.dropdown-toggle', :text => user)
end

When(/^I click the user dropdown "(.*?)"$/) do |user|
  page.find('.dropdown-toggle', :text => user).click
end

Then(/^I should see the "(.*?)" user option$/) do |login_option|
  page.find('.dropdown-menu').find('li', :text => login_option)
end

When(/^I fill the user name as "(.*?)"$/) do |user_name|
  fill_in 'username', :with => user_name
  click_button "log in"
end

Then(/^I should see the user "(.*?)" gallery$/) do |user_name|
  page.find('.page-header', :text => "#{user_name}'s Gallery")
end