Feature: Login Page
    As a user I should be able to sign-in or sign-up to the application

    Scenario: Already registered user enters the application

        Given I have an account in the application
        When I navigate to the login page
        And I enter my account credentials
        Then I should see the home page
