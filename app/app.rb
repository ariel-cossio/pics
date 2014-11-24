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


