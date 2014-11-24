Given(/^I have an account in the application$/) do
    puts "I have my account: user/password"
end

When(/^I navigate to the login page$/) do
    visit   "http://localhost:4567/login"
    # puts page.methods
    expect(page).to have_content /login/i
end

When(/^I enter my account credentials$/) do 
    fill_in "username", :with => "user"
    fill_in "password", :with => "mypassword"
    click_button "Login"
end

Then(/^I should see the home page$/) do
    expect(page).to have_title "PhoneBook"
end
