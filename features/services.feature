
Feature: manage resources by REST
    As a user I should be able to manage my resources: create, retrieve, update and delete certain resources. a resource can be a folder or an image

    Scenario: List all folders when user is new

        When GET "api/content/"
        Then I expect HTTP code 200
        And I expect JSON result is empty list

    Scenario: Add my first folder
        When POST "api/add/content/" using json
        """
        { "type":"folder", "name":"animals" }
        """
        Then I expect HTTP code 200
        And I expect JSON equivalent to
        """
        { "status":"succeed", "message":"folder added succeedfuly"}
        """

    Scenario: Add my fist image
        When POST "api/add/content/" using json
        """
        { "type":"image", "name":"Clint-Eastwood.jpg", "data":"clint_eastwood_base64" }
        """
        Then I expect HTTP code 200
        And I expect JSON equivalent to
        """
        { "status":"succeed", "message":"image added succeedfuly"}
        """

    Scenario: Add my second folder with duplicated name
        When POST "api/add/content/" using json
        """
        { "type":"folder", "name":"animals" }
        """
        Then I expect HTTP code 200
        And I expect JSON equivalent to
        """
        { "status":"error", "message":"folder 'animals' already exist"}
        """

    Scenario: Add my second image duplicated name
        When POST "api/add/content/" using json
        """
        { "type":"image", "name":"Clint-Eastwood.jpg", "data":"white_wolf_base64_img" }
        """
        Then I expect HTTP code 200
        And I expect JSON equivalent to
        """
        { "status":"error", "message":"image 'Clint-Eastwood.jpg' already exist"}
        """

    Scenario: List root folder with content

        When GET "api/content/"
        Then I expect HTTP code 200
        And I expect JSON with preview equivalent to
        """
        [{"name":"animals", "type":"folder"}, {"name":"Clint-Eastwood.jpg", "type":"image", "preview":"clint_eastwood_preview"}]
        """

    Scenario: Add folder inside another folder

        When POST "api/add/content/animals/" using json
        """
        { "type":"folder", "name":"bears" }
        """
        Then I expect HTTP code 200
        And I expect JSON equivalent to
        """
        { "status":"succeed", "message":"folder added succeedfuly" }
        """

    Scenario: Add image inside a folder

        When POST "api/add/content/animals/" using json
        """
        { "type":"image", "name":"blue_eyes_wolf.jpg", "data":"blue_eyes_base64" }
        """
        Then I expect HTTP code 200
        And I expect JSON equivalent to
        """
        { "status":"succeed", "message":"image added succeedfuly" }
        """


    Scenario: List folder inside another folder with content

        When GET "api/content/animals/"
        Then I expect HTTP code 200
        And I expect JSON with preview equivalent to
        """
        [{"name":"bears","type":"folder"}, {"name":"blue_eyes_wolf.jpg", "type":"image", "preview":"blue_eyes_preview"}]
        """

    Scenario: List folder inside another folder and expect empty

        When GET "api/content/animals/bears/"
        Then I expect HTTP code 200
        And I expect JSON result is empty list
