#############
# Rest client
#############

$host = "127.0.0.1"
$port = 4567

class PicsRestClient

  # :TODO add code to generate folder automatically when user is login
  # Static user folder  ./public/pictures

  IMAGES = "./public/pictures"

  def initialize()
    FileUtils::mkdir_p IMAGES
  end

  #
  # Params:
  # +url+:: /api/content
  def get_content(root_folder)

    final_url = "http://localhost:4567/api/content/#{root_folder}"
    response = RestClient.get final_url, {:params => {}}
    items = JSON.parse(response.body)
    items
  end

  def add_content(root_folder, path_name, type, content, tags)
    boundary = "AaB03xxA"
    url = "/api/add/content#{root_folder}"
    final_url = "http://localhost:4567#{url}"
    if tags
      tags = tags.split(",")
    else
      tags = []
    end

    response = RestClient.post final_url,:data => {:type=>type, :name=>path_name, 
                                                   :data => content, :tags => tags}.to_json, 
                                                   :accept => :json

    items = JSON.parse(response.body)
    $message_status = items["message"]
    if items["status"] != "succeed"
      return false
    end

    if type == "image"
      
      preview_data = items["preview"]
      if preview_data == nil
        return
      end
      path = add_content_image(path_name, preview_data)

    elsif type == "folder"
      path = add_content_folder(path_name)
    else
      raise "Type not supported"
    end
    return path
  end

  def add_content_folder(path_name)
    FileUtils::mkdir_p IMAGES + path_name
    return IMAGES + path_name
  end

  def add_content_image(path_name, preview_data)
    
    File.open(IMAGES + path_name, 'wb') do |f|
        f.write(Base64.decode64(preview_data))
        f.close
    end
    return IMAGES + path_name
  end

  def search_image(search_text, root_folder)
    search_url = "http://localhost:4567/api/search/content/#{root_folder}?text=#{search_text}"
    response = RestClient.get search_url
    items = JSON.parse(response.body)
    items
  end
  
  def normalize(url)
    return "http://#{$host}:#{$port}/#{url}"
  end

  def manage_tag_content(root_file, tag, operation)
    boundary = "AaB03xxA"
    url = "/api/tag/content#{root_file}"
    final_url = "http://localhost:4567#{url}"
    response = RestClient.post final_url,:data => {:tag=>tag, :operation=>operation}.to_json, 
                                                   :accept => :json
    items = JSON.parse(response.body)
    $message_status = items["message"]
    if items["status"] != "succeed"
      return false
    end
    return $message_status
  end

  def delete_content(root_file)

    url = "/api/delete/content#{root_file}"
    final_url = "http://localhost:4567#{url}"
    response = RestClient.get final_url, {:params => {}}
    items = JSON.parse(response.body)
    $message_status = items["message"]
    if items["status"] != "succeed"
      return false
    end 
    return $message_status
  end
end
