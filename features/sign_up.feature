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
