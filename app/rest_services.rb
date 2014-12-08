
require_relative 'model_operations'


root = ElemFolder.new ""

#set :port, 8080

# Retrieve the content of given data,
# It could be an image or a folder
# folder e.g. http://localhost/api/content/my_folder/
# image  e.g. http://localhost/api/content/my_image.png
#
get '/api/content/*' do
  path = "/#{params[:splat][0]}"
  #remove last character '/'
  if path[-1] == "/"
    is_folder = true
    path = path.chomp('/')
  else
    # treat as an image
    visitant = GetImage.new(path)
    root.accept(visitant)
    result = visitant.get_result
    if(result.nil?())
      is_folder = true
    else
      is_folder = false

    end
  end

  if is_folder
    #treat as a folder
    visitant = GetContent.new(path)
    root.accept(visitant)
    result = visitant.get_result
  end

  return_message = normalize_return_data(result, 
                      "no element found for '/api/content/#{params[:splat][0]}'")
  return_message.to_json
end


# Add a content to the server, This content could be an image or a 
# folder
post '/api/add/content/*' do

  path = params[:splat][0]
  #remove last character '/'
  if path[-1] == "/"
    path = path.chomp('/')
  end

  if path != ""
    path = "/#{path}"
  end

  return_message = {} 
  if params[:data] == nil
    return_message[:status] = "error"
    return_message[:message] = "no 'data' value is given'"
    return return_message.to_json 
  end

  jdata = JSON.parse(params[:data], :symbolize_names => true) 

  if not jdata.has_key?(:name) 
    return_message[:status] = "error"
    return_message[:message] = "unable to add - missing 'name' field"
    return return_message.to_json 
  end

  if jdata[:type] != "image" and jdata[:type] != "folder" 
    return_message[:status] = "error"
    return_message[:message] = "media type not supported '#{jdata[:type]}'"
    return return_message.to_json 
  end

  if jdata[:type] == "image"
    elem = ElemImage.new(jdata[:name], jdata[:data])
    if jdata.has_key?(:tags)
      jdata[:tags].each{|tag|
        elem.add_tag(tag)
      }
    end
  end

  if jdata[:type] == "folder"
    elem = ElemFolder.new(jdata[:name])
  end


  visitant = SetContent.new(path, elem)
  begin
    root.accept(visitant)

  rescue DuplicateElementException => e 
    return_message[:status] = "error"
    return_message[:message] = e.message
    return return_message.to_json 
  end

  if visitant.get_result
    return_message[:status] = "succeed"
    return_message[:message] = "#{jdata[:type]} added succeedfuly"
  else
    return_message[:status] = "error"
    return_message[:message] = "No path folder found '#{path}'"
  end

  return_message.to_json 
end


# Add or Remove a tag service for the given image
# e.g. /api/tag/content/my_image.png
post '/api/tag/content/*' do

  path = params[:splat][0]

  if path != ""
    path = "/#{path}"
  end

  return_message = {}

  if params[:data] == nil
    return_message[:status] = "error"
    return_message[:message] = "no 'data' value is given'"
    return return_message.to_json 
  end

  jdata = JSON.parse(params[:data], :symbolize_names => true) 

  if not jdata.has_key?(:operation) 
    return_message[:status] = "error"
    return_message[:message] = "unable to do something - missing 'operation' field"
    return return_message.to_json 
  end

  if not jdata.has_key?(:tag) 
    return_message[:status] = "error"
    return_message[:message] = "unable to do something - missing 'tag' field"
    return return_message.to_json 
  end
  
  result = false
  begin
    visitant = ManageTag.new(path, jdata[:tag], jdata[:operation])
    root.accept(visitant)
    result = visitant.succeed
  rescue UnknownTagOperation => e
    return_message[:status] = "error"
    return_message[:message] = e.message
    return return_message.to_json
  end

  if result == false
    return_message[:status] = "error"
    return_message[:message] = "unable to #{jdata[:operation]} tag '#{jdata[:tag]}'"
    return return_message.to_json 
  end

  if jdata[:operation] == "add"
    message = "tag '#{jdata[:tag]}' added"
  else 
    message = "tag '#{jdata[:tag]}' deleted"
  end

  return_message[:status] = "succeed"
  return_message[:message] = message
  return_message.to_json

end

# Retrieve all images in a simplified way for the given folder.
# folder e.g. http://localhost/api/name_images/content/my_folder/
# returns a list [{"name":"images", "path":"my_folder/here/"}, ...]
#
get '/api/name_images/content/*' do
  path = "/#{params[:splat][0]}"
  path = path.chomp('/')

  visitant = GetShortImages.new(path)
  root.accept(visitant)
  result = visitant.get_result

  if result.nil?()
    return_message[:status] = "error"
    return_message[:message] = "no found '/api/name_images/content/#{params[:splat][0]}'"
    return_message.to_json
  end

  result.to_json
end
