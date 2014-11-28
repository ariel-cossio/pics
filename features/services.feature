
Feature: manage resources by REST
    As a user I should be able to manage my resources: create, retrieve, update and delete certain resources. a resource can be a folder or an image

    Scenario: List all folders when user is new

        When GET "api/content"
        Then I expect HTTP code 200
        And I expect JSON result is empty list

    Scenario: Add my first folder
        When POST "api/add/content" using json
        """
        { "type":"folder", "name":"vacations" }
        """
        Then I expect HTTP code 200
        And I expect JSON equivalent to
        """
        { "status":"succeed", "message":"folder added succeedfuly"}
        """

    Scenario: Add my fist image
        When POST "api/add/content" using json
        """
        { "type":"image", "name":"wolf.jpg", "data":"data_content" }
        """
        Then I expect HTTP code 200
        And I expect JSON equivalent to
        """
        { "status":"succeed", "message":"image added succeedfuly"}
        """
