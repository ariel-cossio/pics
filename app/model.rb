require 'data_mapper'
require 'dm-sqlite-adapter'
require 'bcrypt'

DataMapper.setup(:default, "sqlite://#{Dir.pwd}/db.sqlite")

class User
  include DataMapper::Resource
  include BCrypt

  property :id, Serial, key: true
  property :username, String, length: 128

  property :password, BCryptHash

  def authenticate(attempted_password)
    if self.password == attempted_password
      true
    else
      false
    end
  end
end

# Tell DataMapper the models are done being defined
DataMapper.finalize

# Update the database to match the properties of User.
DataMapper.auto_upgrade!

# Create a test User
if User.count == 0
  @user = User.create(username: "admin")
  @user.password = "admin"
  @user.save
end

#require 'sinatra'
#require 'mongoid'
#require 'carrierwave'
#require 'carrierwave/mongoid'
#
#configure do
#  Mongoid.load!("./mongoid.yml")
#end
#
#class ImageUploader < CarrierWave::Uploader::Base
#  storage :file
#end
#
#class FSElement
# include Mongoid::Document
# belongs_to :to_folder, :class_name => 'Folder', :inverse_of => :fselements
# field :path
# field :name, type: String
# field :created
# validates_presence_of :path
# validates_presence_of :name
# validates_presence_of :created
#end
#
#class Image < FSElement
# include Mongoid::Document
# mount_uploader :image, ImageUploader, type: String
# field :alias, type: String
# field :size
# validates_presence_of :size
#end
#
#class Folder < FSElement
# include Mongoid::Document
# belongs_to :to_user, :class_name => 'User', :inverse_of => :folder
# has_many :fselements, :class_name => 'FSElement', :inverse_of => :to_folder
#end
#
#class User
# include Mongoid::Document
# has_one :folder, :class_name => 'Folder', :inverse_of => :to_user
# field :user_name, type: String
# field :password, type: String
# validates_presence_of :user_name
#end

require 'json'
require 'base64'
require 'fileutils'
require 'RMagick'
include Magick
require_relative 'model_utils'


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
  include Visitable, Comparable

  attr_reader :element_list, :type_name
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

  def image_number()
    get_number("image")
  end

  def folder_number()
    get_number("folder")
  end

  def get_number(elem_type)
    res = 0
    @element_list.each{|elem|
      if elem.class.type_name == elem_type
        res = res + 1
      end
    }
    return res
  end

  # Return the name of the type value of this class
  def self.type_name
    @@type_name
  end

end


class ElemImage < FSElement
  include Visitable, Comparable

  attr_reader :data, :preview, :tags
  @@type_name = "image"

  # Create a new element image
  # Params:
  # +name+:: image name file
  # +data+:: raw data encoded in base64 format
  def initialize(name, data = nil)
    super(name)

    # Create a fake ElemImage
    if not data.nil?
      @data = data
      set_preview()
    end

    @tags = Array.new
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
    thumb = img.resize_to_fit(width, height)
    thumb.write("./temp/#{temporal}/thumb_#{@name}")
    img.destroy!
    thumb.destroy!
    GC.start

    f_thumb = File.open("./temp/#{temporal}/thumb_#{@name}", 'rb')
    thumb_s = f_thumb.read
    encoded_string = Base64.strict_encode64(thumb_s)
    f_thumb.close

    @preview = encoded_string

    FileUtils.rm_rf(Dir.glob('./temp/#{temporal}/*'))
    FileUtils.rm_rf('./temp/#{temporal}/')
    true
  end

  # Add a tag element to tags list
  # Params:
  # +tag+:: String tag element to be added
  def add_tag(tag)
    if not tag.kind_of?(String)
      raise "tag '#{tag.inspect}' is not a String"
    end

    if not @tags.include?(tag)
      @tags.push(tag)
    end
    
  end

  # Remove an existing tag
  # Params:
  # +tag+:: String tag to be removed
  def delete_tag(tag)
    if not tag.kind_of?(String)
      raise "tag '#{tag.inspect}' is not a String"
    end

    if @tags.include?(tag)
      @tags.delete(tag)
    end
  end

  # Generate a random dir name
  def get_random_dir()
    return (0...50).map { ('a'..'z').to_a[rand(26)] }.join
  end

  # Return the name of the type value of this class
  def self.type_name
    @@type_name
  end

  private :set_preview, :get_random_dir

end
