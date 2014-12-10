require 'rubygems'
require 'sinatra'
require 'warden'
require 'sinatra/flash'

# Services import
require 'net/http'
require 'json'
require 'base64'
require 'fileutils'

require '../features/support/http_services_helper'
require 'rest-client'

require_relative 'rest_services'
require_relative 'rest_client'


#############
# Routers
#############

configure do
  enable :sessions
end

use Warden::Manager do |config|
  # Tell Warden how to save our User info into a session.
  # Sessions can only take strings, not Ruby code, we'll store
  # the User's `id`
  config.serialize_into_session{|user| user.id }
  # Now tell Warden how to take what we've stored in the session
  # and get a User from that information.
  config.serialize_from_session{|id| User.get(id) }

  config.scope_defaults :default,
    # "strategies" is an array of named methods with which to
    # attempt authentication. We have to define this later.
    strategies: [:password],
    # The action is a route to send the user to when
    # warden.authenticate! returns a false answer. We'll show
    # this route below.
    action: 'auth/unauthenticated'
  # When a user tries to log in and cannot, this specifies the
  # app to send the user to.
  config.failure_app = self
end

Warden::Manager.before_failure do |env,opts|
    env['REQUEST_METHOD'] = 'POST'
end

Warden::Strategies.add(:password) do
  def valid?
    params['user'] && params['user']['username'] && params['user']['password']
  end

  def authenticate!
    user = User.first(username: params['user']['username'])

    if user.nil?
      fail!("The username you entered does not exist.")
    elsif user.authenticate(params['user']['password'])
      success!(user)
    else
      fail!("Could not log in")
    end
  end
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

get '/' do
  @root_folder = "/" 
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
  @username = params['username']
  session[:identity] = @username
  where_user_came_from = session[:previous_url] || '/secure/gallery/'
  redirect to where_user_came_from 
end

get '/secure/place' do
  env['warden'].authenticate!
  erb "This is a secret place that only <%=session[:identity]%> has access to!"
end

post '/welcome' do
    erb :welcome, :locals => {'username' => @username}
end

get '/logout' do
  env['warden'].raw_session.inspect
  env['warden'].logout
  flash[:success] = 'Successfully logged out'
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end 

get '/secure/gallery/*' do |path|
  env['warden'].authenticate!
  @root_folder = "#{path}"  
  rest_client = PicsRestClient.new()
  
  @items = rest_client.get_content(@root_folder)

  if @items.is_a?(Hash)
    @error = @items['message'] 
    @items =[]
  end
  erb  :gallery
end 

get '/secure/search/*' do |path|
  @root_folder = "#{path}"
  rest_client = PicsRestClient.new()
  text_to_search = params['text']
  @items = rest_client.search_image(text_to_search, @root_folder)
  erb  :gallery
end

get '/secure/search_tag/*' do |path|
  @root_folder = "#{path}"
  rest_client = PicsRestClient.new()
  tag_to_search = params['text_tag']
  @items = rest_client.search_tag(tag_to_search, @root_folder)
  erb  :gallery
end

get '/secure/load_file*' do |path|
  env['warden'].authenticate!
  @root_folder = "/#{path}"
  erb :load_file
end

post '/secure/load_file*' do |path|
    @root_folder = "/#{path}" 

    picture_to_upload = params["picturetoupload"]
    tags = params['tags']

    f_thumb = picture_to_upload[:tempfile]
    thumb_s = f_thumb.read
    content = Base64.encode64(thumb_s)
    f_thumb.close

    rest_client = PicsRestClient.new()
    error_message = rest_client.add_content(@root_folder, 
                                            "#{picture_to_upload[:filename]}", 
                                            "image", content, tags)
    if error_message 
      @error = error_message
      erb :add_folder
    else
      url = "/secure/gallery/#{path}"
      redirect to url
    end
end

get '/secure/manage_tag_content*' do |path|
  @root_file = "#{path}"

  tag = params['tag']
  operation = params['operation']
  rest_client = PicsRestClient.new()
  rest_client.manage_tag_content(@root_file, tag, operation)
end

get '/secure/add_folder*' do |path|
  env['warden'].authenticate!
  @root_folder = "/#{path}"
  erb :add_folder
end

post '/secure/add_folder*' do |path|
  @root_folder = "/#{path}"

  folder_name = params["folderName"]
  rest_client = PicsRestClient.new()
  error_message = rest_client.add_content(@root_folder, "#{folder_name}", "folder", "", "")
  if error_message 
    @error = error_message
    erb :add_folder
  else
    url = "/secure/gallery#{path}"
    redirect to url
  end
end

get '/signin/form' do
  erb :signin_form
end

get '/signup/form' do
  erb :signup_form
end


post '/signin/attempt' do
  env['warden'].authenticate!
  @username = env['warden'].user.username
  session[:identity] = @username
  flash[:success] = env['warden'].message
  redirect '/secure/gallery/'
end

post '/signup/attempt' do
  username = params['username']
  password = params['password']
  new_user = User.new(:username => username)
  new_user.password = password
  new_user.save
  redirect '/'
end

get '/secure/delete_content*' do |path|
  @content_to_delete = "/#{path}"
  redirect_folder = params['redirect_folder']
  rest_client = PicsRestClient.new()
  rest_client.delete_content(@content_to_delete)
  where_user_came_from =  "/secure/gallery/#{redirect_folder}"
  redirect to where_user_came_from
end
