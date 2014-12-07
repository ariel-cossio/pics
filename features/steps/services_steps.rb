require 'net/http'
require 'json'

$host = "localhost"
$port = 4567


When(/^GET "(.*?)"$/) do |url|
  http = get_http()
  request = get_request(normalize(url))
  execute_http_request(http, request)
end


When(/^POST "(.*?)" using json$/) do |url, string|

  boundary = "AaB03x"
  
  '''
  data = {type:"folder", 
          name:"vacations"}
  '''
  data = JSON.parse(string)
  if data.has_key?("data")
    data["data"] = send(data["data"])
  end

  http = get_http()
  request = post_request(normalize(url), boundary)
  request.body = generate_multipart_body("data", data, boundary)
  
  execute_http_request(http, request)
end


Then(/^I expect HTTP code (\d+)$/) do |code|
  @response.code.should == code
end


Then(/^I expect JSON result is empty list$/) do
  actual = JSON.parse(last_json())
  expect(true).to eq(actual.empty?())
end


Then(/^I expect JSON equivalent to$/) do |string|
  actual = JSON.parse(last_json())
  
  '''
  expected = {"status" => "succeed", 
              "message" => "folder added succeedfuly"}
  '''
  expected = JSON.parse(string)
  
  actual.should == expected
end

Then(/^I expect JSON with preview equivalent to$/) do |string|
  actual = JSON.parse(last_json())
  expected = JSON.parse(string)
  if expected.kind_of?(Array)
    expected.each{|element|
      if element.has_key?("preview")
        element["preview"] = send(element["preview"])
      end
    }
  end

  actual.should == expected
end

Then(/^I expect JSON with data equivalent to$/) do |string|
  actual = JSON.parse(last_json())
  expected = JSON.parse(string)
  if expected.has_key?("data")
    expected["data"] = send(expected["data"])
  end
  
  actual.should == expected
end
