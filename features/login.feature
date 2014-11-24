Feature: Login Page
    As a user I should be able to sign-in or sign-up to the application

    Scenario: I open the page as an extrange user
        Given I have opened the page
        Then I should see the Picture manager message "Please login to see your pictures"
        And I should see the user as "Hello stranger"


    Scenario: I open the page and login as admin
    	Given I have opened the page
    	Then I should see the user as "Hello stranger"
    	When I click the user dropdown "Hello stranger"
    	Then I should see the "Login" admin option
    	When I select the "Login" admin option
    	And I fill the user name as "admin"
    	#Add I fill the password as "admin123"
    	Then I should see the user as "admin"
    	And I should see the user "admin" gallery

    Scenario: I open the page and login as admin and logout
        Given I have opened the page
        Then I should see the Picture manager message "Please login to see your pictures"
        When I click the user dropdown "Hello stranger"
		And I select the "Login" admin option
    	And I fill the user name as "admin"        
    	#Add I fill the password as "admin123"
    	Then I should see the user as "admin"
    	When I click the user dropdown "admin"
    	Then I should see the "Logout" admin option
    	When I select the "Logout" admin option
    	Then I should see the user as "Hello stranger"