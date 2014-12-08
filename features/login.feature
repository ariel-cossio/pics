Feature: Login Page
    As a user I should be able to sign-in or sign-up to the application

    Scenario: I open the page as an extrange user
        Given I go to "/"
        Then I should see the Picture manager message "Please login to see your pictures"
            And I should see the user as "Hello stranger"


    Scenario: I open the page and login as admin
        Given I go to "/"
        Then I should see the user as "Hello stranger"
        When I click the user dropdown "Hello stranger"
        Then I should see the "Login" user option
        When I select the "Login" user option
            And I fill out the form with the following attributes:
                | username    | admin       |
               #| password    | admin123    |
            And I click the button "log in"
        Then I should see the user as "admin"
            And I should see the user "admin" gallery

    Scenario: I open the page and login as admin and logout
        Given I go to "/"
        Then I should see the Picture manager message "Please login to see your pictures"
        When I click the user dropdown "Hello stranger"
		    And I select the "Login" user option
            And I fill out the form with the following attributes:
                | username    | admin       |
               #| password    | admin123    |
            And I click the button "log in"
    	Then I should see the user as "admin"
    	When I click the user dropdown "admin"
    	Then I should see the "Logout" user option
    	When I select the "Logout" user option
    	Then I should see the user as "Hello stranger"

    Scenario: I login as admin twice the data persists
        Given I go to "/"
        Then I should see the Picture manager message "Please login to see your pictures"
        When I click the user dropdown "Hello stranger"
            And I select the "Login" user option
            And I fill out the form with the following attributes:
                | username    | admin       |
               #| password    | admin123    |
            And I click the button "log in"
        Then I should see the user as "admin"
            And I should see the user "admin" gallery
        When I click the user dropdown "admin"
        Then I should see the "Logout" user option
        When I select the "Logout" user option
        Then I should see the user as "Hello stranger"            
        When I go to "/"
        Then I should see the Picture manager message "Please login to see your pictures"
        When I click the user dropdown "Hello stranger"
            And I select the "Login" user option
            And I fill out the form with the following attributes:
                | username    | admin       |
               #| password    | admin123    |
            And I click the button "log in"
        Then I should see the user as "admin"
        And I should see the user "admin" gallery

    Scenario: I login as a not registered user
        Given I go to "/"
        Then I should see the Picture manager message "Please login to see your pictures"
        When I click the user dropdown "Hello stranger"
            And I select the "Login" user option
            And I fill out the form with the following attributes:
                | username    | unregistered |
               #| password    | admin123     |
            And I click the button "log in"
        Then I should see the sign up form