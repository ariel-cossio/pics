Feature: Sign up a new user
    As a user I should be able to sign-up as a new user


    Scenario: I open the page and I can see the sign up form
        Given I go to "/"
        Then I should see the Picture manager message "Please login to see your pictures"
        And I should see the user as "Hello stranger"
        And I should see the sign up link
        When I click the sign up link
        And I should see the sign up form


    Scenario: I can sign up a new user
        Given I go to "/"
        Then I should see the Picture manager message "Please login to see your pictures"
            And I should see the user as "Hello stranger"
            And I should see the sign up link
        When I click the sign up link
        Then I should see the sign up form
        When I fill out the form with the following attributes:
                | username    | picture             |
                | email       | picture@hotmai.com  |
            And I click the button "Sign in"
        Then I should see the user as "picture"
    	And I should see the user "picture" gallery

    Scenario: I sign up a new user and login
        Given I go to "/"
        Then I should see the Picture manager message "Please login to see your pictures"
        And I should see the user as "Hello stranger"
        And I should see the sign up form
        When I fill out the form with the following attributes:
                | username    | new1             |
                | email       | new1@hotmai.com  |
            And I click the button "Sign in"
        Then I should see the user as "new1"
        And I should see the user "new1" gallery
        When I click the user dropdown "new1"
        Then I should see the "Logout" user option
        When I select the "Logout" user option
        Then I should see the user as "Hello stranger"
        When I click the user dropdown "Hello stranger"
        And I select the "Login" user option
            And I fill out the form with the following attributes:
                | username    | new1        |
               #| password    | admin123    |
            And I click the button "log in"
        Then I should see the user as "admin"
        And I should see the user "new1" gallery

    Scenario: I sign up a repeated user
        Given I go to "/"
        Then I should see the Picture manager message "Please login to see your pictures"
        And I should see the user as "Hello stranger"
        And I should see the sign up form
        When I fill out the form with the following attributes:
                | username    | repeated             |
                | email       | repeated@hotmai.com  |
            And I click the button "Sign in"
        Then I should see the user as "repeated"
        And I should see the user "repeated" gallery
        When I click the user dropdown "repeated"
        Then I should see the "Logout" user option
        When I select the "Logout" user option
        Then I should see the user as "Hello stranger"
        Given I go to "/"
        Then I should see the Picture manager message "Please login to see your pictures"
        And I should see the user as "Hello stranger"
        And I should see the sign up form
        When I fill out the form with the following attributes:
                | username    | repeated             |
                | email       | repeated@hotmai.com  |
            And I click the button "Sign in"
        Then I should see the user as "Hello stranger"