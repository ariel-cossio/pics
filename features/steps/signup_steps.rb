Then(/^I should see the sign up link$/) do
  page.find('a', :text => "Sign in")
end

When(/^I set the user name as "(.*?)"$/) do |user_name|
  fill_in "username", :with => user_name
end

When(/^I set the email as "(.*?)"$/) do |user_mail|
  fill_in "email", :with => user_mail
  click_button "Sign in"
end

Then(/^I should see the sign up form$/) do
  page.find('.page-header', :text => "Sign in")
end

When(/^I click the sign up link$/) do
  page.find('a', :text => "Sign in").click
end