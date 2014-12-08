Then(/^I should see the sign up link$/) do
  page.find('a', :text => "Sign in")
end

Then(/^I should see the sign up form$/) do
  page.find('.page-header', :text => "Sign in")
end

When(/^I click the sign up link$/) do
  page.find('a', :text => "Sign in").click
end