
require_relative 'model'
#########################
# Rest Services Section #
#########################


root = ElemFolder.new '/'

#set :port, 8080

# Retrieve the content of the current folder
#
get '/api/content' do
  return_message = []
  list = root.list_elements '/'
  list.map{|elem| 
    item = {}
    item['name'] = elem.name
    item['type'] = elem.class.type_name
    if item['type'] == 'image'
      item['preview'] = elem.preview
    end
    return_message.push(item)
    item
  }
  return_message.to_json
end

# Add a content to the server, This content could be an image or a 
# folder
post '/api/add/content' do

  return_message = {} 
  if params[:data] == nil
    return_message[:status] = "error"
    return_message[:message] = "no 'data' value is given'"
    return return_message.to_json 
  end

  jdata = JSON.parse(params[:data], :symbolize_names => true) 

  if not jdata.has_key?(:name) 
    return_message[:status] = "error"
    return_message[:message] = "unable to add - missing data"
    return return_message.to_json 
  end

  if jdata[:type] != "image" and jdata[:type] != "folder" 
    return_message[:status] = "error"
    return_message[:message] = "media type not supported '#{jdata[:type]}'"
    return return_message.to_json 
  end

  begin
    if jdata[:type] == "image"
      root.add_image(jdata[:name], jdata[:data])
    end

    if jdata[:type] == "folder"
      root.add_folder(jdata[:name])
    end
  rescue DuplicateElementException => e 
    return_message[:status] = "error"
    return_message[:message] = e.message
    return return_message.to_json 
  end

  return_message[:status] = "succeed"
  return_message[:message] = "#{jdata[:type]} added succeedfuly"

  return_message.to_json 
end
