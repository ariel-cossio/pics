Feature: Sign up a new user
    As a user I should be able to sign-up as a new user


    Scenario: I open the page and I can see the sign up form
        Given I have opened the page
        Then I should see the Picture manager message "Please login to see your pictures"
        And I should see the user as "Hello stranger"
        And I should see the sign up form
        And I should see the user name text field
        And I should see the email text field


    Scenario: I can sign up a new user
        Given I have opened the page
        Then I should see the Picture manager message "Please login to see your pictures"
        And I should see the user as "Hello stranger"
        And I should see the sign up form
        When I set the user name as "picture"
        And I set the email as "picture@hotmai.com"
        Then I should see the user as "picture"
    	And I should see the user "picture" gallery

    Scenario: I sign up a new user and login 
        Given I have opened the page
        Then I should see the Picture manager message "Please login to see your pictures"
        And I should see the user as "Hello stranger"
        And I should see the sign up form
        When I set the user name as "new1"
        And I set the email as "picture@hotmai.com"
        Then I should see the user as "new1"
        And I should see the user "new1" gallery
        When I click the user dropdown "new1"
        Then I should see the "Logout" admin option
        When I select the "Logout" admin option
        Then I should see the user as "Hello stranger"
        When I click the user dropdown "Hello stranger"
        And I select the "Login" admin option
        And I fill the user name as "new1"        
        #Add I fill the password as "admin123"
        Then I should see the user as "admin"
        And I should see the user "new1" gallery

    Scenario: I sign up a repeated user
        Given I have opened the page
        Then I should see the Picture manager message "Please login to see your pictures"
        And I should see the user as "Hello stranger"
        And I should see the sign up form
        When I set the user name as "repeated"
        And I set the email as "repeated@hotmai.com"
        Then I should see the user as "repeated"
        And I should see the user "repeated" gallery
        When I click the user dropdown "repeated"
        Then I should see the "Logout" admin option
        When I select the "Logout" admin option
        Then I should see the user as "Hello stranger"
        When I have opened the page
        Then I should see the Picture manager message "Please login to see your pictures"
        And I should see the user as "Hello stranger"
        And I should see the sign up form
        When I set the user name as "repeated"
        And I set the email as "repeated@hotmai.com"
        Then I should see the user as "Hello stranger"