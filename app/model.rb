require 'sinatra'
require 'mongoid'
require 'carrierwave'
require 'carrierwave/mongoid'

configure do
  Mongoid.load!("./mongoid.yml")
end

#################
# Model section #
#################

class DuplicateElementException < Exception
end


class FSElement
  include Mongoid::Document
  belongs_to :to_folder, :class_name => 'ElemFolder', :inverse_of => :fselements
  field :name, type: String
  field :type_name, type: String
  validates_presence_of :name
  validates_presence_of :type_name
end

class ElemFolder < FSElement
  include Mongoid::Document
  include Comparable
  belongs_to :to_user, :class_name => 'User', :inverse_of => :folder
  has_many :fselements, :class_name => 'FSElement', :inverse_of => :to_folder
  type_name = "folder"

  # Add a Folder for the current folder
  # Params:
  # +name+:: name of folder to be added
  def add_folder name
    elem = ElemFolder.create
    elem.name = name
    add_element(elem)
  end

  # Add an Image for this folder
  # Params:
  # +name+:: name of image to be added
  # +data+:: data file name encoded using base 64
  def add_image(name, data)
    elem = ElemImage.create
    elem.name = name
    elem.data = data
    add_element(elem)
  end

  def add_element(element)
  	element_found = fselements.where(name: element.name)
  	if element_found
    	if element_found.type_name == element.type_name
      	raise(DuplicateElementException,
        	    "#{element.class.type_name} '#{element.name}' already exist")
    	end
    end
    fselements.push(element)
  end

  # Remove an element of current folder given the name
  # Params:
  # +name+:: item name to be removed
  def remove_element(name)
    fselements.where(name: name).destroy_all
  end

  # Return the list of elements: folders and images
  # Params:
  # +path+:: folders path
  def list_elements(path)
    return fselements
  end

  private :add_element
end


class ElemImage < FSElement
  include Mongoid::Document
  include Comparable

  field :data, type: String
  field :preview, type: String
  type_name = "image"

  @random_generator = Random.new(12345)

  # Generate a random dir name
  def get_random_dir()
    random_folder = @random_generator.rand(1000000)
    return random_folder.to_s
  end

  private :get_random_dir

end

class User
  include Mongoid::Document
  has_one :folder, :class_name => 'ElemFolder', :inverse_of => :to_user
  field :user_name
  validates_presence_of :user_name
end