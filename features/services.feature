
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
        [{"name":"animals", "type":"folder"}, {"name":"Clint-Eastwood.jpg", "type":"image", "tags":[], "preview":"clint_eastwood_preview"}]
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
        [{"name":"bears","type":"folder"}, {"name":"blue_eyes_wolf.jpg", "type":"image", "tags":[], "preview":"blue_eyes_preview"}]
        """

    Scenario: Retrieve an especific image content

        When GET "api/content/animals/blue_eyes_wolf.jpg"
        Then I expect HTTP code 200
        And I expect JSON with data equivalent to
        """
        {"name":"blue_eyes_wolf.jpg", "type":"image", "data":"blue_eyes_base64"}
        """

    Scenario: List folder inside another folder and expect empty

        When GET "api/content/animals/bears/"
        Then I expect HTTP code 200
        And I expect JSON result is empty list



#Feature: Manage tags by REST services
#    As a user I should be able to add Image with tags, also remove them

    Scenario: Add an image with tags

        When POST "api/add/content/animals/bears/" using json
        """
        { "type":"image", "name":"bear_swimming.jpg", "tags":["swim", "cute"], "data":"bear_swimming_base64" }
        """
        Then I expect HTTP code 200
        And I expect JSON equivalent to
        """
        { "status":"succeed", "message":"image added succeedfuly" }
        """

    Scenario: Add a tag for an image

        When POST "api/tag/content/animals/bears/bear_swimming.jpg" using json
        """
        { "operation":"add", "tag":"polar" }
        """
        Then I expect HTTP code 200
        And I expect JSON equivalent to
        """
        { "status":"succeed", "message":"tag 'polar' added" }
        """

    Scenario: Delete a tag for an image

        When POST "api/tag/content/animals/bears/bear_swimming.jpg" using json
        """
        { "operation":"delete", "tag":"cute" }
        """
        Then I expect HTTP code 200
        And I expect JSON equivalent to
        """
        { "status":"succeed", "message":"tag 'cute' deleted" }
        """

    Scenario: List folder to see tag content

        When GET "api/content/animals/bears/"
        Then I expect HTTP code 200
        And I expect JSON with preview equivalent to
        """
        [{"name":"bear_swimming.jpg", "type":"image", "tags":["swim", "polar"], "preview":"bear_swimming_preview"}]
        """



#Feature: Search services
#    As a user I should be able to seach an image by name or tag

    Scenario: List all images that are inside root folder in simple format

        When GET "api/name_images/content/"
        Then I expect HTTP code 200
        And I expect JSON with preview equivalent to
        """
        [{"name":"bear_swimming.jpg", "path":"animals/bears/"}, {"name":"blue_eyes_wolf.jpg", "path":"animals/"}, {"name":"Clint-Eastwood.jpg", "path":""}]
        """

    Scenario: List all images that are inside a given folder in simple format

        When GET "api/name_images/content/animals/"
        Then I expect HTTP code 200
        And I expect JSON with preview equivalent to
        """
        [{"name":"bear_swimming.jpg", "path":"animals/bears/"}, {"name":"blue_eyes_wolf.jpg", "path":"animals/"}]
        """

    Scenario: Obtain all images that meet a given string

        When GET "api/search/content/animals?text=wi"
        Then I expect HTTP code 200
        And I expect JSON with preview equivalent to
        """
        [{"name":"bear_swimming.jpg", "path":"animals/bears/", "preview":"bear_swimming_preview"}]
        """

    Scenario: Obtain all images that meet a given string for root folder

        When GET "api/search/content/?text=in"
        Then I expect HTTP code 200
        And I expect JSON with preview equivalent to
        """
        [{"name":"bear_swimming.jpg", "path":"animals/bears/", "preview":"bear_swimming_preview"}, {"name":"Clint-Eastwood.jpg", "path":"", "preview":"clint_eastwood_preview"}]
        """

    Scenario: Search images by tags in folder
        When GET "api/search_tag/content/?tags=swim"
        Then I expect HTTP code 200
        And I expect JSON with preview equivalent to
        """
        [{"name":"bear_swimming.jpg", "path":"animals/bears/", "preview":"bear_swimming_preview"}]
        """

    Scenario: Add a tag for an existing image

        When POST "api/tag/content/Clint-Eastwood.jpg" using json
        """
        { "operation":"add", "tag":"swim" }
        """
        Then I expect HTTP code 200
        And I expect JSON equivalent to
        """
        { "status":"succeed", "message":"tag 'swim' added" }
        """

    Scenario: Search images by several tags in folder
        When GET "api/search_tag/content/?tags=swim,polar"
        Then I expect HTTP code 200
        And I expect JSON with preview equivalent to
        """
        [{"name":"bear_swimming.jpg", "path":"animals/bears/", "preview":"bear_swimming_preview"}, {"name":"Clint-Eastwood.jpg", "path":"", "preview":"clint_eastwood_preview"}]
        """

    Scenario: Search images by tags in folder
        When GET "api/search_tag/content/animals/?tags=swim,polar"
        Then I expect HTTP code 200
        And I expect JSON with preview equivalent to
        """
        [{"name":"bear_swimming.jpg", "path":"animals/bears/", "preview":"bear_swimming_preview"}]
        """

#Feature: Remove elements
#    As a user I should be able to delete element: images or folders

    Scenario: Add an image to be deleted

        When POST "api/add/content/animals/" using json
        """
        { "type":"image", "name":"husky.jpg", "tags":["polar", "cute"], "data":"husky_base64" }
        """
        Then I expect HTTP code 200
        And I expect JSON equivalent to
        """
        { "status":"succeed", "message":"image added succeedfuly" }
        """

    Scenario: Get Elements from a folder to be deleted

        When GET "api/content/animals/"
        Then I expect HTTP code 200
        And I expect JSON with preview equivalent to
        """
        [{"name":"bears","type":"folder"}, {"name":"blue_eyes_wolf.jpg", "type":"image", "tags":[], "preview":"blue_eyes_preview"}, {"name":"husky.jpg", "type":"image", "tags":["polar", "cute"], "preview":"husky_preview"}]
        """

    Scenario: Delete Element image

        When GET "api/delete/content/animals/husky.jpg"
        Then I expect HTTP code 200
        And I expect JSON with preview equivalent to
        """
        { "status":"succeed", "message":"resource 'animals/husky.jpg' was deleted" }
        """

    Scenario: Get Elements again to verify element was really deleted

        When GET "api/content/animals/"
        Then I expect HTTP code 200
        And I expect JSON with preview equivalent to
        """
        [{"name":"bears","type":"folder"}, {"name":"blue_eyes_wolf.jpg", "type":"image", "tags":[], "preview":"blue_eyes_preview"}]
        """

#Feature: Restriccion for not confirmed user
#    As a user Not confirmed I shouldn't be able more than 2 folder and 2 images by folder

    
    Scenario: add a second folder is permitted

        When POST "api/add/content/animals/" using json
        """
        { "type":"folder", "name":"cats" }
        """
        Then I expect HTTP code 200
        And I expect JSON equivalent to
        """
        { "status":"succeed", "message":"folder added succeedfuly" }
        """

    Scenario: add a third folder is not permitted

        When POST "api/add/content/animals/" using json
        """
        { "type":"folder", "name":"pets" }
        """
        Then I expect HTTP code 200
        And I expect JSON equivalent to
        """
        { "status":"error", "message":"operation not permitted until you confirm your password" }
        """
