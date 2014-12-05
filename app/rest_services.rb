
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
    if(image.nil?())
      is_folder = true
    else
      is_folder = false

    end
  end

  if is_folder
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
