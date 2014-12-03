require 'rubygems'
require 'sinatra'

# Services import
require 'sinatra/reloader' if development?
require 'rubygems'
require 'net/http'
require 'json'
require 'base64'
require 'fileutils'
require 'RMagick'
require '../features/support/http_services_helper'
require 'rest-client'
include Magick



$host = "127.0.0.1"
$port = 4567

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
  pics_obj = PicsRestClient.new()
  @items = pics_obj.get_content("/api/content")
  erb  :gallery
end 

get '/secure/load_file' do
  erb :load_file
end

post '/secure/load_file' do 

    picture_to_upload = params["picturetoupload"]

    f_thumb = picture_to_upload[:tempfile]
    thumb_s = f_thumb.read
    content = Base64.encode64(thumb_s)
    f_thumb.close

    picture_obj = PicsRestClient.new()
    result = picture_obj.add_content("#{picture_to_upload[:filename]}", "image", content)
    # :TODO Add code to display warning message if image is not following some standards
    # :TODO Add code to save Display name and tags.

  redirect to '/secure/gallery'
end

get '/secure/add_folder' do
  erb :add_folder
end

post '/secure/add_folder' do

  folder_name = params["folderName"]
  folder_obj = PicsRestClient.new()
  result = folder_obj.add_content("/#{folder_name}", "folder", "")
  # :TODO add code to display warning message when folder is not created
  redirect to '/secure/gallery'
end

#############
# Rest client
#############

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
  def get_content(url)
    final_url = "http://localhost:4567#{url}"
    response = RestClient.get final_url, {:params => {}}
    items = JSON.parse(response.body)
    items
  end

  def add_content(path_name, type, content)
    boundary = "AaB03xxA"
    url = "/api/add/content"
    final_url = "http://localhost:4567#{url}"

    response = RestClient.post final_url,:data => {:type=>type, :name=>path_name, 
                                                   :data => content}.to_json, :accept => :json

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
  
  def normalize(url)
    return "http://#{$host}:#{$port}/#{url}"
  end

end

########
#
########

module Comparable
  # Compare Elem objects by name and type_name
  def <=>(elem)
    comparison = self.name <=> elem.name

    if comparison == 0
      return self.type_name <=> elem.type_name
    else
      return comparison
    end
  end
end

#################
# Model section #
#################

class DuplicateElementException < Exception
end


class FSElement
  attr_accessor :name, :type_name

  def initialize  name
    @name = name
  end

  def self.type_name
    raise NotImplementError.new
  end

end

class ElemFolder < FSElement
  include Comparable

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
    add_element(elem)
  end

  # Add an Image for this folder
  # Params:
  # +name+:: name of image to be added
  # +data+:: data file name encoded using base 64
  def add_image(name, data)
    elem = ElemImage.new(name, data)
    add_element(elem)
  end

  def add_element(element)
    if @element_list.include?(element)
      raise(DuplicateElementException, 
            "#{element.class.type_name} '#{element.name}' already exist")
    else
      @element_list.push(element)
    end
  end

  # Remove an element of current folder given the name
  # Params:
  # +name+:: item name to be removed
  def remove_element(name)
    @element_list.delete_if{|e|
      e.name == name
    }
  end

  # Return the list of elements: folders and images
  # Params:
  # +path+:: folders path
  def list_elements(path)
    return @element_list
  end

  # Return the name of the type value of this class
  def self.type_name
    @@type_name
  end

  private :add_element
end


class ElemImage < FSElement
  include Comparable

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
    set_preview()
  end

  # Set a thumbnail for the current image
  def set_preview()
    temporal = get_random_dir()
    FileUtils::mkdir_p "./temp/#{temporal}"

    File.open("./temp/#{temporal}/#{@name}", 'wb') do |f|
        f.write(Base64.decode64(@data))
        f.close
    end

    img = ImageList.new("./temp/#{temporal}/#{@name}")
    width, height = 150, 150
    thumb = img.scale(width, height)
    thumb.write("./temp/#{temporal}/thumb_#{@name}")
    img.destroy!
    thumb.destroy!
    GC.start

    f_thumb = File.open("./temp/#{temporal}/thumb_#{@name}", 'rb')
    thumb_s = f_thumb.read
    encoded_string = Base64.encode64(thumb_s)
    f_thumb.close

    @preview = encoded_string

    FileUtils.rm_rf(Dir.glob('./temp/#{temporal}/*'))
    FileUtils.rm_rf('./temp/#{temporal}/')
    true
  end

  # Generate a random dir name
  def get_random_dir()
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
    @root_folder = ElemFolder.new '/'
  end

  def get_root_folder()
    return @root_folder
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
