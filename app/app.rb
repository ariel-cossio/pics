require 'rubygems'
require 'sinatra'

# Services import
require 'net/http'
require 'json'
require 'base64'
require 'fileutils'

require '../features/support/http_services_helper'
require 'rest-client'

require_relative 'rest_services'




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

get '/signin/form' do
  erb :signin_form
end

post '/signin/attempt' do
  @username = params['username']
  session[:identity] = @username
  where_user_came_from = session[:previous_url] || '/secure/gallery'
  redirect to where_user_came_from
end

get '/secure/search' do
  pics_obj = PicsRestClient.new()
  @items = pics_obj.get_content("/api/content")
  erb  :search
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
