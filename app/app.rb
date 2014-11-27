require 'rubygems'
require 'sinatra'


class Item

  attr_accessor :id
  attr_accessor :url
  attr_accessor :name
  attr_accessor :type


  def initialize(id, url, name, type)
    @id  = id
    @url  = url
    @name  = name
    @type  = type
  end

end


configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

before '/secure/*' do
  if !session[:identity] then
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb(:index)
  end
end

get '/' do
	erb :index
end

get '/index' do
	erb :index
end

get '/welcome' do
    erb :welcome
end

get '/login/form' do 
  erb :login_form
end

post '/login/attempt' do
  @username	= params['username']
  session[:identity] = @username
  where_user_came_from = session[:previous_url] || '/secure/gallery'
  redirect to where_user_came_from 
end

get '/secure/place' do
  erb "This is a secret place that only <%=session[:identity]%> has access to!"
end

post '/welcome' do
    erb :welcome, :locals => {'username' => @username}
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end	

get '/secure/gallery' do
  @pictures = Dir.glob("public/pictures/*.*")
  @items =  []


  @pictures.each do |picture|
    @items.push(Item.new('1', picture.sub!(/public\//, '/'), File.basename(picture), 1))
  end
  erb  :gallery
end 

get '/secure/load_file' do
  erb :load_file
end

post '/secure/load_file' do 

  if params['fileName']  && params['upload']
    filename = params['fileName'][:filename]
    tempfile = params['fileName'][:tempfile]
    target = "public/pictures/#{filename}"

    File.open(target, 'wb') {|f| f.write tempfile.read }
    #TODO: Add code to save Display name and tags.
  end

  redirect to '/secure/gallery'
end

get '/secure/add_folder' do
  erb :add_folder
end

post '/secure/add_folder' do
  #TODO add functionality to add folder
  redirect to '/secure/gallery'
end



require 'sinatra/reloader' if development?
require 'json'
require 'base64'
require 'fileutils'
require 'rubygems'
require 'RMagick'
include Magick


#################
# Model section #
#################

class FSElement
  attr_accessor :name

  def initialize  name
    @name = name
  end

end

class ElemFolder < FSElement

  attr_accessor :element_list, :type_name
  @@type_name = "folder"

  def initialize name
    super(name)
    @element_list = Array.new
  end
  
  # Add a Folder for the current folder
  # Params:
  # +name+:: name of folder to be added
  def add_folder name
    elem = ElemFolder.new(name)
    @element_list.push(elem)
  end

  # Add an Image for this folder
  # Params:
  # +name+:: name of image to be added
  # +data+:: data file name encoded using base 64
  def add_image(name, data)
    elem = ElemImage.new(name, data)
    @element_list.push(elem)
  end

  # Remove an element of current folder given the name
  # Params:
  # +name+:: item name to be removed
  def remove_element name
    @element_list.delete_if{|e|
      e.name == name
    }
  end

  # Return the list of elements: folders and images
  # Params:
  # +path+:: folders path
  def list_elements path
    return @element_list
  end

  # Return the name of the type value of this class
  def self.type_name
    @@type_name
  end
end

class ElemImage < FSElement
  attr_accessor :data, :preview
  @@type_name = "image"

  # Create a new element image
  # Params:
  # +name+:: image name file
  # +data+:: raw data encoded in base64 format
  def initialize(name, data)
    super(name)
    @data = data
    @random_generator = Random.new(12345)
    set_preview
  end

  # Set a thumbnail for the current image
  def set_preview
    temporal = get_random_dir()
    FileUtils::mkdir_p temporal

    file = File.open("./#{temporal}/#{@name}", 'wb') do|f|
        f.write(Base64.decode64(@data))
    end

    img = ImageList.new("./#{temporal}/#{@name}")
    width, height = 50, 50
    thumb = img.scale(width, height)
    thumb.write("./#{temporal}/thumb_#{@name}")

    f_thumb = File.open("./#{temporal}/thumb_#{@name}", 'rb').read
    encoded_string = Base64.encode64(f_thumb)

    @preview = encoded_string
    FileUtils.rm_rf('./#{temporal}')
  end

  # Generate a random dir name
  def get_random_dir
    random_folder = @random_generator.rand(1000000)
    return random_folder.to_s
  end

  # Return the name of the type value of this class
  def self.type_name
    @@type_name
  end

  private :set_preview, :get_random_dir

end

class User
  attr_accessor :username

  def initialize usrname
    @username = name
    @root_folder = ElemFolder.new
  end
end


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
  print(params[:data])
  jdata = JSON.parse(params[:data],:symbolize_names => true) 
  if jdata.has_key?(:name) 
    if jdata[:type] == "image"
      root.add_image(jdata[:name], jdata[:data])
    elsif jdata[:type] == "folder"
      root.add_folder(jdata[:name])
    else
      status 500
    end
    return_message[:status] = 'succeed'
  else
    return_message[:status] = 'unable to add - missing data'
  end
  return_message.to_json 
end


