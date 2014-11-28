

# Create an http
def get_http()
  return Net::HTTP.new($host, $port)
end


# Create a GET request
# Params:
# +url+:: url string to for create the request
def get_request(url)

  request = Net::HTTP::Get.new(url)
  request['content-type'] = 'application/x-www-form-urlencoded'
  request['accept'] = '*/*'
  return request
end


# Create a POST request
# Params:
# +url+:: url string to for create the request
# +boundary+:: unique header insert for a POST multi-part body request
def post_request(url, boundary=nil)
  request = Net::HTTP::Post.new(url) # , header
  content_type_str = "multipart/form-data"
  request['accept'] = '*/*'

  if boundary != nil
    content_type_str << ", boundary=#{boundary}"
  end
  request['content-type'] = content_type_str

  return request
end


# Perform an http with the given reques
def execute_http_request(http, request)
  @response = http.request(request)
  @http_headers = {}
end

def normalize(url)
  return "http://#{$host}:#{$port}/#{url}"
end


# required by json_spec
def last_json
  @response.body
end


# Generate a simple multipart body to be added inside an http post
# Params:
# +name+:: multipart variable name
# +values+:: hash {(key, value)} with data to be generated
# +boundary+:: a unique code for this multipart
#
#
# ------multipart-boundary-808358
# Content-Disposition: form-data; name="myfile"; filename="test.txt"
# 
# hello
# ------multipart-boundary-808358
# Content-Disposition: form-data; name="test"
#  
# content
# ------multipart-boundary-808358--
def generate_multipart_body(name, value, boundary)
  nline = "\r\n"
  post_body = ""

  #Add Data
  post_body << "--#{boundary}#{nline}"
  post_body << "Content-Disposition: form-data; name=\"#{name}\"#{nline}#{nline}"
  post_body << value.to_json
  post_body << "#{nline}--#{boundary}--#{nline}"

  return post_body
end
