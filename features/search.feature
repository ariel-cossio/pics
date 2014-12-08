Feature: Login Page
    As a user I should be able to sign-in or sign-up to the application

    Scenario: I open the page login as admin I see the search option in the gallery
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
            And I should see the menu "Search"

    Scenario: I open the search form
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
            And I should see the menu "Search"
        When I select the "Search" menu option
        Then I should see the "Search" form

    Scenario: I search a picture
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
            And I should see the menu "Search"
        When I select the "Search" menu option
        Then I should see the "Search" form
        When I fill out the form with the following attributes:
                | search    | picture       |
            And I click the button "Search"
        Then I should see the "picture"