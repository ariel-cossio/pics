Given(/^I go to "(.*?)"$/) do |relative_url|
  visit "http://localhost:4567#{relative_url}"
end

When(/^I set the dropdown "(.*?)" as "(.*?)"$/) do |dropdown_locator, user_option|
  page.find(dropdown_locator, :text => user_option).click
end

When(/^I select the "(.*?)" user option$/) do |option|
  step 	'I set the dropdown ".dropdown-menu li" as "'+option+'"'
end

Then(/^I should see the menu "(.*?)"$/) do |menu_option|
  pending # express the regexp above with the code you wish you had
end

When(/^I select the "(.*?)" menu option$/) do |menu_option|
  pending # express the regexp above with the code you wish you had
end