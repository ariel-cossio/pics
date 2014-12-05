
Feature: manage resources by REST
    As a user I should be able to manage my resources: create, retrieve, update and delete certain resources. a resource can be a folder or an image

    Scenario: List all folders when user is new

        When GET "api/content/"
        Then I expect HTTP code 200
        And I expect JSON result is empty list

    Scenario: Add my first folder
        When POST "api/add/content/" using json
        """
        { "type":"folder", "name":"vacations" }
        """
        Then I expect HTTP code 200
        And I expect JSON equivalent to
        """
        { "status":"succeed", "message":"folder added succeedfuly"}
        """

    Scenario: Add my fist image
        When POST "api/add/content/" using json
        """
        { "type":"image", "name":"wolf.jpg", "data":"base64_wolf_img" }
        """
        Then I expect HTTP code 200
        And I expect JSON equivalent to
        """
        { "status":"succeed", "message":"image added succeedfuly"}
        """

    Scenario: Add my second folder duplicated name
        When POST "api/add/content/" using json
        """
        { "type":"folder", "name":"vacations" }
        """
        Then I expect HTTP code 200
        And I expect JSON equivalent to
        """
        { "status":"error", "message":"folder 'vacations' already exist"}
        """

    Scenario: Add my second image duplicated name
        When POST "api/add/content/" using json
        """
        { "type":"image", "name":"wolf.jpg", "data":"base64_wolf2_img" }
        """
        Then I expect HTTP code 200
        And I expect JSON equivalent to
        """
        { "status":"error", "message":"image 'wolf.jpg' already exist"}
        """

    Scenario: List root folder with content

        When GET "api/content/"
        Then I expect HTTP code 200
        And I expect JSON with preview equivalent to
        """
        [{"name":"vacations", "type":"folder"}, {"name":"wolf.jpg", "type":"image", "preview":"base64_wolf_img_preview"}]
        """
